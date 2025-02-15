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
public class PdfSvgConv.Pdf2Svg {
    static bool show_help = false;
    static bool show_version = false;
    static int color_level = 1;
    static int num_threads = 0;
    static string? password = null;
    static string? page_label = null;

    const OptionEntry[] options = {
        { "help", 'h', OptionFlags.NONE, OptionArg.NONE, ref show_help, "Show help message", null },
        { "version", 'v', OptionFlags.NONE, OptionArg.NONE, ref show_version, "Display version", null },
        { "color", '\0', OptionFlags.NONE, OptionArg.INT, ref color_level, "Color level of log, 0 for no color, 1 for auto, 2 for always, defaults to 1", "LEVEL" },
        { "threads", 'T', OptionFlags.NONE, OptionArg.INT, ref num_threads, "Number of threads to use for extracting, 0 for auto", "NUM" },
        { "password", 'p', OptionFlags.NONE, OptionArg.STRING, ref password, "Password for the PDF file", "PASSWORD" },
        { "label", 'l', OptionFlags.NONE, OptionArg.STRING, ref page_label, "Page label, may be number (eg. 1), range (eg. 5-9), or 'all', 1-indexed", "LABEL" },
        null
    };

    // Main program function
    static int main (string[] original_args) {
        // Compatibility for Windows and Unix
        if (Intl.setlocale (LocaleCategory.ALL, ".UTF-8") == null) {
            Intl.setlocale ();
        }

#if WINDOWS
        var args = Win32.get_command_line ();
#else
        var args = strdupv (original_args);
#endif
        var opt_context = new OptionContext ("<input PDF file> <output SVG file>");
        // DO NOT use the default help option provided by g_print
        // g_print will force to convert character set to windows's code page
        // which is imcompatible windows's bash, zsh, etc.
        opt_context.set_help_enabled (false);
        opt_context.add_main_entries (options, null);
        try {
            opt_context.parse_strv (ref args);
        } catch (OptionError e) {
            Reporter.error_puts ("OptionError", e.message);
            stderr.printf ("\n%s", opt_context.get_help (true, null));
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

        if (show_help) {
            stderr.puts (opt_context.get_help (true, null));
            return 0;
        }

        if (show_version) {
            Reporter.info_puts ("Live Photo Converter", VERSION);
            return 0;
        }

        if (args.length != 3) {
            stderr.puts (opt_context.get_help (true, null));
            return 1; // Argument count error
        }

        // Get the input and output file paths
        string pdf_uri = File.new_for_commandline_arg (args[1]).get_uri ();
        string svg_filename = args[2];

        // Convert the PDF file
        MT2Svg mt_converter = new MT2Svg (num_threads);
        return mt_converter.convert_pdf (pdf_uri, svg_filename, password, page_label);
    }
}
