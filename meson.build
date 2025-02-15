project('pdf-svg-conv', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 1.1',
)

glib = dependency('glib-2.0')
gobject = dependency('gobject-2.0')
gio = dependency('gio-2.0')
cairo = dependency('cairo')
poppler = dependency('poppler-glib')
rsvg = dependency('librsvg-2.0')

if target_machine.system() == 'windows'
  add_project_arguments('-D', 'WINDOWS', language: 'vala')
endif

subdir('src')
