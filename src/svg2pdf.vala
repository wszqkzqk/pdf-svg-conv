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

[Compact (opaque = true)]
public class PdfSvgConv.Svg2Pdf {
    static bool show_version = false;
    static int color_level = 1;
    //static int num_threads = 0;

    const OptionEntry[] options = {
        { "version", 'v', OptionFlags.NONE, OptionArg.NONE, ref show_version, "Display version", null },
        { "color", '\0', OptionFlags.NONE, OptionArg.INT, ref color_level, "Color level of log, 0 for no color, 1 for auto, 2 for always; defaults to 1", "LEVEL" },
        //{ "threads", 'T', OptionFlags.NONE, OptionArg.INT, ref num_threads, "Number of threads to use, 0 for auto; defaults to 0", "NUM" },
        null
    };

    static int convert_svgs (string[] svg_files, string pdf_file) {
        Cairo.PdfSurface? surface = null;
        Cairo.Context? cr = null;

        uint success_count = 0;
        uint failure_count = 0;

        var progress = new Reporter.ProgressBar (svg_files.length, "Converting to one PDF");
        foreach (unowned var svg_file in svg_files) {
            Rsvg.Handle svg_handle;
            try {
                svg_handle = new Rsvg.Handle.from_file (svg_file);
            } catch (Error e) {
                Reporter.error ("RsvgError", "failed to load file %s: %s", svg_file, e.message);
                failure_count += 1;
                progress.update (success_count, failure_count);
                continue;
            }

            bool has_width, has_height, has_viewbox;
            Rsvg.Length svg_width, svg_height;
            Rsvg.Rectangle viewbox;
            svg_handle.get_intrinsic_dimensions (out has_width, out svg_width, out has_height, out svg_height, out has_viewbox, out viewbox);
            double width = (svg_width.length > 0) ? svg_width.length : 595; // A4 width
            double height = (svg_height.length > 0) ? svg_height.length : 842; // A4 height
            // If no viewbox or invalid viewbox, use the whole page
            if ((! has_viewbox) || viewbox.width <= 0 || viewbox.height <= 0) {
                viewbox.x = 0;
                viewbox.y = 0;
                viewbox.width = width;
                viewbox.height = height;
            }

            if (surface == null) {
                surface = new Cairo.PdfSurface (pdf_file, width, height);
                cr = new Cairo.Context (surface);
            } else {
                surface.set_size (width, height);
            }

            try {
                svg_handle.render_document (cr, viewbox);
            } catch (Error e) {
                Reporter.error ("RsvgError", "failed to render file %s: %s", svg_file, e.message);
                failure_count += 1;
                continue;
            }
            cr.show_page ();
            
            success_count += 1;
            progress.update (success_count, failure_count);
        }

        if (surface != null) {
            surface.finish ();
        }

        return 0;
    }

    // Main program function
    static int main (string[] original_args) {
        Intl.setlocale ();

#if WINDOWS
        var args = Win32.get_command_line ();
#else
        var args = strdupv (original_args);
#endif
        var opt_context = new OptionContext ("<input-SVG-file> [moret-SVG-files ...] <output-PDF-file>");
        // DO NOT use the default help option provided by g_print
        // g_print will force to convert character set to windows's code page
        // which is imcompatible windows's bash, zsh, etc.
        opt_context.set_help_enabled (false);
        opt_context.add_main_entries (options, null);
        // Set a summary hint for multi-page output:
        opt_context.set_summary ("Convert SVG files to a PDF file.");
        try {
            opt_context.parse_strv (ref args);
        } catch (OptionError e) {
            Reporter.error_puts ("OptionError", e.message);
            printerr ("\n%s", opt_context.get_help (true, null));
            return 1; // Argument parsing error
        }

        switch (color_level) {
        case 0:
            Reporter.color_setting = Reporter.ColorSettings.NEVER;
            break;
        case 1:
            Reporter.color_setting = Reporter.ColorSettings.AUTO;
            break;
        case 2:
            Reporter.color_setting = Reporter.ColorSettings.ALWAYS;
            break;
        default:
            Reporter.warning_puts ("OptionWarning", "invalid color level, fallback to level 1 (auto)");
            Reporter.color_setting = Reporter.ColorSettings.AUTO;
            break;
        }

        if (show_version) {
            Reporter.info_puts ("SVG to PDF Converter", VERSION);
            return 0;
        }

        // Get the input and output file paths
        if (args.length < 2) {
            Reporter.error_puts ("ArgumentError", "missing input or output file path");
            printerr ("\n%s", opt_context.get_help (true, null));
            return 1; // Missing input or output file path error
        }

        // The last argument is the output PDF file
        // The first argument (arg[0]) is the executable name
        // The rest are input SVG files
        string pdf_file = args[args.length - 1];
        string[] svg_files = args[1:args.length - 1];

        return convert_svgs (svg_files, pdf_file);
    }
}
