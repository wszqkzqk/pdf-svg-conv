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

basic_sources = [
  'platformbindings.c',
  'reporter.vala',
  version_file,
]

pdf2svg_name = 'neopdf2svg'

pdf2svg_deps = basic_deps + [
  poppler,
]

pdf2svg_source = basic_sources + [
  'mt2svg.vala',
  'pdf2svg.vala',
  'task2svg.vala',
]

svg2pdf_deps = basic_deps + [
  rsvg,
]

pdf2svg_bin = executable(
  pdf2svg_name,
  pdf2svg_source,
  dependencies: pdf2svg_deps,
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
endif
