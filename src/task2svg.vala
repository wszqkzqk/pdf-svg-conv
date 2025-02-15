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
public class PdfSvgConv.Task2Svg {
    Poppler.Document pdffile;
    string svg_filename;
    int index;

    public Task2Svg (Poppler.Document pdffile, int index, string svg_filename) {
        this.pdffile = pdffile;
        this.svg_filename = svg_filename;
        this.index = index;
    }

    public void run () {
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
    }
}
