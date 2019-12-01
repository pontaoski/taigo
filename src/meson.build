taigo_sources = [
  'main.vala',
  'window.vala',
  'taigochi.vala',
  'global.vala',
  'gdb.c',
  'statemachine.vala',
]

taigo_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('gee-0.8'),
  dependency('json-glib-1.0'),
  dependency('clutter-gtk-1.0'),
  dependency('clutter-1.0'),
]

gnome = import('gnome')

taigo_sources += gnome.compile_resources('taigo-resources',
  'taigo.gresource.xml',
  c_name: 'taigo'
)

executable('taigo', taigo_sources,
  vala_args: '--target-glib=2.50',  dependencies: taigo_deps,
  install: true,
)
