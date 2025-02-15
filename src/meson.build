version_file = vcs_tag(
   command: meson.project_version(),
     input: 'version.vala.in',
    output: 'version.vala',
)

basic_deps = [
  glib,
  gobject,
  gio,
  cairo,
]
pdf2svg_deps = basic_deps + [
  poppler,
]
svg2pdf_deps = basic_deps + [
  rsvg,
]

basic_sources = [
  'platformbindings.c',
  'reporter.vala',
  version_file,
]
pdf2svg_source = basic_sources + [
  'svgmakermt.vala',
  'task2svg.vala',
  'pdf2svg.vala',
]
svg2pdf_source = basic_sources + [
  'svg2pdf.vala',
]

pdf2svg_name = 'neopdf2svg'
svg2pdf_name = 'neosvg2pdf'

pdf2svg_bin = executable(
  pdf2svg_name,
  pdf2svg_source,
  dependencies: pdf2svg_deps,
  install: true,
)
svg2pdf_bin = executable(
  svg2pdf_name,
  svg2pdf_source,
  dependencies: svg2pdf_deps,
  install: true,
)

help2man_prog = find_program('help2man', required: get_option('manpages'))

if help2man_prog.found()
  custom_target('manpage-' + pdf2svg_name,
    output : pdf2svg_name + '.1',
    command : [
      help2man_prog,
      '-N',
      '-o',
      '@OUTPUT@',
      pdf2svg_bin,
      '--no-discard-stderr',
    ],
    install : true,
    install_dir : get_option('mandir') / 'man1',
  )

  custom_target('manpage-' + svg2pdf_name,
    output : svg2pdf_name + '.1',
    command : [
      help2man_prog,
      '-N',
      '-o',
      '@OUTPUT@',
      svg2pdf_bin,
      '--no-discard-stderr',
    ],
    install : true,
    install_dir : get_option('mandir') / 'man1',
  )
endif
