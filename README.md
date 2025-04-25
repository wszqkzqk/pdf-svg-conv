# PDF/SVG Converter: A Powerful PDF/SVG Format Conversion Tool
English | [简体中文](README-zh.md)

PDF/SVG Converter is a powerful PDF/SVG format conversion tool that supports multi-threaded PDF to SVG conversion (including encrypted PDFs), as well as SVG to PDF conversion.

## Features
### PDF to SVG (`pdf2svg`)
* Supports multi-threaded PDF to SVG conversion
  * Each page is processed in parallel, improving conversion speed
* Supports color progress bar display
* Supports PDF password decryption
* Supports selective conversion
  * Supports conversion of specified page numbers
  * Supports conversion of specified page ranges
  * Supports `printf`-style integer formatting for multi SVG filenames
    * For example, `output-%03d.svg` will output `output-001.svg`, `output-002.svg`, ...

### SVG to PDF (`svg2pdf`)
* Supports SVG to PDF conversion
* Supports color progress bar display
* Supports merging multiple SVG files into a single PDF in order

## Build Scripts
This project provides build scripts for Arch Linux and Windows (MSYS2) environments.

#### Arch Linux
Arch Linux users can install directly from the AUR, for example using the AUR helper `paru`:
```bash
paru -S pdf-svg-conv
```

Alternatively, you can manually clone the AUR repository and build/install:
```bash
git clone https://aur.archlinux.org/pdf-svg-conv.git
cd pdf-svg-conv
makepkg -si
```

#### Windows (MSYS2)
Windows (MSYS2) users can build using the provided [`PKGBUILD`](https://gist.github.com/wszqkzqk/5ece53f3cda6213c62c5f77a9da26af4). For example, run the following commands in the MSYS2 UCRT64 environment's `bash` shell:
```bash
mkdir live-photo-conv
cd live-photo-conv
wget https://gist.githubusercontent.com/wszqkzqk/5ece53f3cda6213c62c5f77a9da26af4/raw/PKGBUILD
makepkg-mingw -si
```

## Manual Build
### Dependencies
**Runtime dependencies**:
* GLib
  * GObject
  * GIO
* Cairo
* Poppler
  * Poppler-GLib
* Rsvg
* help2man (optional, for generating manpages)

**Build-time dependencies** - In addition to runtime dependencies, you also need:
* Meson
* Vala

Install dependencies on Arch Linux:
```bash
sudo pacman -S --needed meson vala glib2 cairo poppler-glib librsvg help2man
```

Install dependencies on MSYS2:
```bash
pacman -S --needed mingw-w64-ucrt-x86_64-meson mingw-w64-ucrt-x86_64-vala mingw-w64-ucrt-x86_64-glib2 mingw-w64-ucrt-x86_64-cairo mingw-w64-ucrt-x86_64-poppler mingw-w64-ucrt-x86_64-librsvg help2man
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
### PDF to SVG (`pdf2svg`)
Run `pdf2svg --help` to view help information:
```log
Usage:
  pdf2svg [OPTION…] <input-PDF-file> <output-SVG-file>
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
pdf2svg example.pdf output-%04d.svg
```

Convert the first page of `example.pdf` to `output.svg`:
```bash
pdf2svg -l 1 example.pdf output.svg
```

Convert pages 5-9 of `example.pdf` to `output-%04d.svg`:
```bash
pdf2svg -l 5-9 example.pdf output-%04d.svg
```

Specify a PDF password:
```bash
pdf2svg -p xxxxxx example.pdf output-%04d.svg
```

### SVG to PDF (`svg2pdf`)
Run `svg2pdf --help` to view help information:
```log
Usage:
  svg2pdf [OPTION…] <input-SVG-file> [more-SVG-files ...] <output-PDF-file>
Convert SVG files to a PDF file.
Options:
  -h, --help        Show help message
  -v, --version     Display version
  --color=LEVEL     Color level of log, 0 for no color, 1 for auto, 2 for always, defaults to 1
```

For example, convert `example1.svg`, `example2.svg` to `output.pdf`:
```bash
svg2pdf example1.svg example2.svg output.pdf
```

## License
PDF/SVG Converter is licensed under LGPL-2.1-or-later. For more details, see the [COPYING](COPYING) file.
