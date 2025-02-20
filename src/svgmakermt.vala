/* Copyright 2025 Zhou Qiankang <wszqkzqk@qq.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
*/

public class PdfSvgConv.SvgMakerMT {
    int num_threads = 0;
    // Note: Poppler.Page is NOT thread-safe
    // But we can open multiple Poppler.Document instances in different threads
    ThreadPool<Task2Svg>? pool = null;
    Reporter.ProgressBar progress;
    uint _success_count = 0;
    uint _failure_count = 0;

    uint success_count {
        get {
            return AtomicUint.get (ref _success_count);
        }
        set {
            AtomicUint.set (ref _success_count, value);
        }
    }

    uint failure_count {
        get {
            return AtomicUint.get (ref _failure_count);
        }
        set {
            AtomicUint.set (ref _failure_count, value);
        }
    }

    public SvgMakerMT (int num_threads = 0) {
        if (num_threads > 0) {
            this.num_threads = num_threads;
        } else {
            this.num_threads = (int) get_num_processors ();
        }

        progress = new Reporter.ProgressBar (0, "Converting to SVG");
    }

    // Generate unique SVG file name for each page.
    static inline string get_svg_filename_for_page (string base_svg, int page_index) throws RegexError {
        GLib.Regex re_int_printf = /%[-+0 #]*(?:\d+)?(?:\.\d+)?d/;
        string replaced = re_int_printf.replace_eval (
            base_svg,
            -1,
            0,
            0,
            (match_info, builder) => {
                // MUST `append`, otherwise the previous content will be lost
                builder.append_printf (match_info.fetch (0), page_index + 1);
                return false;
            }
        );
        return replaced;
    }

    inline void automt_convert_page (Poppler.Document pdffile, int index,
                                     string svg_filename, string pdf_uri,
                                     string? password) throws Error {
        if (this.num_threads == 1 || pool == null) {
            // Open the PDF file
            var page = pdffile.get_page (index);

            // Poppler stuff
            double width, height;
            page.get_size (out width, out height);

            // Cairo stuff
            var surface = new Cairo.SvgSurface (svg_filename, width, height);
            var drawcontext = new Cairo.Context (surface);

            // Render the PDF file into the SVG file
            page.render_for_printing (drawcontext);
            drawcontext.show_page ();
            surface.finish ();
            // Update progress bar
            AtomicUint.inc (ref _success_count);
            progress.update (success_count, failure_count);
        } else {
            // Multi-threaded conversion.
            // DO NOT use pdffile provided by the main thread
            // MUST create a new instance of Poppler.Document in each thread
            // since Poppler.Page is NOT thread-safe
            var pdf_new = new Poppler.Document.from_file (pdf_uri, password);
            pool.add (new Task2Svg (pdf_new, index, svg_filename));
            // But DO NOT update the progress bar here since it's not the same thread
            // Update in the thread pool instead
        }
    }

    public int convert_pdf (string pdf_uri, string svg_filename, string? password, string? page_label) {
        Regex re_valid_label = /^(?:\d+(?:-\d+)?|all)$/;
        if ((page_label != null) && (! re_valid_label.match (page_label))) {
            Reporter.error_puts ("PageFormatError", "invalid page label");
            return 1; // Invalid page label error
        }

        Poppler.Document pdffile;
        try {
            pdffile = new Poppler.Document.from_file (pdf_uri, password);
        } catch (Error e) {
            Reporter.error ("PopplerError", "failed to open file %s: %s", pdf_uri, e.message);
            return 1; // Poppler error
        }

        if (this.num_threads > 1) {
            try {
                this.pool = new ThreadPool<Task2Svg>.with_owned_data ((task) => {
                    task.run ();
                    AtomicUint.inc (ref _success_count);
                    progress.update (success_count, failure_count);
                }, this.num_threads, false);
            } catch (ThreadError e) {
                Reporter.error ("ThreadError", e.message);
                return 1; // Thread error
            }
        }

        if (page_label == null || page_label == "all") {
            // Convert all pages
            int page_count = pdffile.get_n_pages ();
            // Update progress bar
            progress.total_steps = page_count;
            for (int i = 0; i < page_count; i += 1) {
                try {
                    string page_svg = get_svg_filename_for_page (svg_filename, i);
                    automt_convert_page (pdffile, i, page_svg, pdf_uri, password);
                } catch (RegexError e) {
                    Reporter.error ("RegexError", e.message);
                    AtomicUint.inc (ref _failure_count);
                    progress.update (success_count, failure_count);
                } catch (Error e) {
                    Reporter.error ("PopplerError", "failed to convert page %d: %s", i + 1, e.message);
                    AtomicUint.inc (ref _failure_count);
                    progress.update (success_count, failure_count);
                }
            }
        } else if (page_label.index_of_char ('-') >= 0) {
            // Page range specified in the format "start-end" (pages are 1-indexed)
            string[] range_tokens = page_label.split ("-");
            if (range_tokens.length != 2) {
                Reporter.error_puts ("PageFormatError", "invalid page range format");
                return 1; // Invalid page range format error
            }
            int page_count = pdffile.get_n_pages ();
            int start = int.parse (range_tokens[0]) - 1;
            int end = int.parse (range_tokens[1]) - 1;
            // Clamp start and end to valid boundaries
            if (start < 0) {
                start = 0;
                Reporter.warning_puts ("IndexWarning", "start page is less than 1, clamped to 1");
            }
            if (end >= page_count) {
                end = page_count - 1;
                Reporter.warning_puts ("IndexWarning", "end page is greater than total page count, clamped to last page");
            }
            // Ensure start is not greater than end
            if (start > end) {
                Reporter.error_puts ("RangeError", "start page is greater than end page");
                return 1; // Invalid page range error
            }
            // Update progress bar
            progress.total_steps = end - start + 1;
            for (int i = start; i <= end; i += 1) {
                try {
                    string page_svg = get_svg_filename_for_page (svg_filename, i);
                    automt_convert_page (pdffile, i, page_svg, pdf_uri, password);
                } catch (RegexError e) {
                    Reporter.error ("RegexError", e.message);
                    AtomicUint.inc (ref _failure_count);
                    progress.update (success_count, failure_count);
                } catch (Error e) {
                    Reporter.error ("PopplerError", "failed to convert page %d: %s", i + 1, e.message);
                    AtomicUint.inc (ref _failure_count);
                    progress.update (success_count, failure_count);
                }
            }
        } else {
            // Single page number specified, 1-indexed
            // Only one tast, so no need to use thread pool
            progress.total_steps = 1;
            var thread_old = this.num_threads;
            this.num_threads = 1;
            int page_index = int.parse (page_label) - 1;
            int page_count = pdffile.get_n_pages ();
            // Clamp page_index to valid boundaries
            if (page_index < 0) {
                page_index = 0;
                Reporter.warning_puts ("IndexWarning", "page index is less than 1, clamped to 1");
            }
            else if (page_index >= page_count) {
                page_index = page_count - 1;
                Reporter.warning_puts ("IndexWarning", "page index is greater than total page count, clamped to last page");
            }
            try {
                automt_convert_page (pdffile, page_index, svg_filename, pdf_uri, password);
            } catch (Error e) {
                Reporter.error ("PopplerError", "failed to convert page %d: %s", page_index + 1, e.message);
                AtomicUint.inc (ref _failure_count);
                progress.update (success_count, failure_count);
            }
            this.num_threads = thread_old;
        }

        if (pool != null) {
            ThreadPool.free ((owned) pool, false, true);
        }
        return 0; // Success
    }
}
