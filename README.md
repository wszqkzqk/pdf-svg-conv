# PDF/SVG Converter: A Powerful PDF/SVG Format Conversion Tool
English | [简体中文](README-zh.md)

PDF/SVG Converter is a powerful PDF/SVG format conversion tool that supports multi-threaded PDF to SVG conversion, PDF decryption, and plans to support SVG to PDF conversion.

## Features
### Neo PDF to SVG (`neopdf2svg`)
* Supports multi-threaded PDF to SVG conversion
  * Each page is processed in parallel, improving conversion speed
* Supports PDF password decryption
* Supports selective conversion
  * Supports conversion of specified page numbers
  * Supports conversion of specified page ranges
  * Supports `printf`-style integer formatting for SVG filenames
    * For example, `output-%03d.svg` will output `output-001.svg`, `output-002.svg`, ...

### Planned Features
* Support for SVG to PDF (`neosvg2pdf`)
* Support for progress display

## Building
### Dependencies
**Runtime dependencies**:
* GLib
  * GObject
  * GIO
* Cairo
* Poppler
  * Poppler-Glib
* Pango
* RSVG (pending `neosvg2pdf` support)
* help2man (optional, for generating manpages)

**Build-time dependencies** - In addition to runtime dependencies, you also need:
* Meson
* Vala

Install dependencies on Arch Linux:
```bash
sudo pacman -S --needed meson vala glib2 cairo poppler-glib pango librsvg help2man
```

Install dependencies on MSYS2:
```bash
pacman -S --needed mingw-w64-ucrt-x86_64-meson mingw-w64-ucrt-x86_64-vala mingw-w64-ucrt-x86_64-glib2 mingw-w64-ucrt-x86_64-cairo mingw-w64-ucrt-x86_64-poppler-glib mingw-w64-ucrt-x86_64-pango mingw-w64-ucrt-x86_64-librsvg help2man
```

### Compilation
Meson build options:
* `manpage`: Whether to generate manpages. By default, it automatically detects whether `help2man` is installed, and if so, generates manpages.

Configure the build with the following command:
```bash
meson setup builddir --buildtype=release
```

Then compile the project:
```bash
meson compile -C builddir
```

Install the project:
```bash
meson install -C builddir
```

## Usage
### Neo PDF to SVG (`neopdf2svg`)
Run `neopdf2svg --help` to view help information:
```log
Usage:
  neopdf2svg [OPTION…] <input-PDF-file> <output-SVG-file>
Convert a PDF file to SVG file(s).
Hint: For multi-page conversion, use a format string like 'output-%04d.svg'.
Options:
  -h, --help                  Show help message
  -v, --version               Display version
  --color=LEVEL               Color level of log, 0 for no color, 1 for auto, 2 for always, defaults to 1
  -T, --threads=NUM           Number of threads to use for extracting, 0 for auto
  -p, --password=PASSWORD     Password for the PDF file
  -l, --label=LABEL           Page label, may be number (eg. 1), range (eg. 5-9), or 'all', 1-indexed
```

For example, convert `example.pdf` to `output-%04d.svg`:
```bash
neopdf2svg example.pdf output-%04d.svg
```

Convert the first page of `example.pdf` to `output.svg`:
```bash
neopdf2svg -l 1 example.pdf output.svg
```

Convert pages 5-9 of `example.pdf` to `output-%04d.svg`:
```bash
neopdf2svg -l 5-9 example.pdf output-%04d.svg
```

Specify a PDF password:
```bash
neopdf2svg -p xxxxxx example.pdf output-%04d.svg
```
