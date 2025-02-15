# PdfSvgConv：强大的 PDF/SVG 格式转化工具

PdfSvgConv 是一个强大的 PDF/SVG 格式转化工具，支持多线程的 PDF 转 SVG，支持 PDF 解密，计划支持 SVG 转 PDF。

## 特性

### NeoPdf2Svg (`neopdf2svg`)

* 支持多线程的 PDF 转 SVG
  * 每页转化并行处理，提高转化速度
* 支持 PDF 密码解密
* 支持选择性转化
  * 支持指定页码转化
  * 支持指定页码范围转化
  * 支持 `printf` 的整数格式化输出 SVG 文件名
    * 例如 `output-%03d.svg` 会输出 `output-001.svg`, `output-002.svg`, ...

### 计划

* 支持 SVG 转 PDF （`neosvg2pdf`）
* 支持进度显示

## 构建

### 依赖

**运行时依赖**：

* GLib
  * GObject
  * GIO
* Cairo
* Poppler
  * Poppler-Glib
* Pango
* RSVG （待`neosvg2pdf`支持）
* help2man （可选，用于生成 manpage）

**构建时依赖** - 除了运行时依赖外，还需要：

* Meson
* Vala

在 Arch Linux 上安装依赖：

```bash
sudo pacman -S --needed meson vala glib2 cairo poppler-glib pango librsvg help2man
```

在 MSYS2 上安装依赖：

```bash
pacman -S --needed mingw-w64-ucrt-x86_64-meson mingw-w64-ucrt-x86_64-vala mingw-w64-ucrt-x86_64-glib2 mingw-w64-ucrt-x86_64-cairo mingw-w64-ucrt-x86_64-poppler-glib mingw-w64-ucrt-x86_64-pango mingw-w64-ucrt-x86_64-librsvg help2man
```

### 编译

Meson 构建选项：

* `manpage`：是否生成 manpage，默认情况下自动检测是否安装了 `help2man`，如果安装了则生成 manpage

可以通过以下命令配置构建：

```bash
meson setup builddir --buildtype=release
```

然后编译项目：

```bash
meson compile -C builddir
```

安装项目：

```bash
meson install -C builddir
```

## 使用

### NeoPdf2Svg

运行 `neopdf2svg --help` 查看帮助信息：

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

例如，将 `example.pdf` 转化为 `output-%04d.svg`：

```bash
neopdf2svg example.pdf output-%04d.svg
```

将 `example.pdf` 的第 1 页转化为 `output.svg`：

```bash
neopdf2svg -l 1 example.pdf output.svg
```

将 `example.pdf` 的第 5-9 页转化为 `output-%04d.svg`：

```bash
neopdf2svg -l 5-9 example.pdf output-%04d.svg
```

指定 PDF 密码：

```bash
neopdf2svg -p xxxxxx example.pdf output-%04d.svg
```
