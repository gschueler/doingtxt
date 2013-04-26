Gem::Specification.new do |s|
  s.name = 'doing'
  s.description = 'doing is like todo.txt but for time tracking'
  s.version = "0.0.1"
  s.date = '2013-03-21'
  s.summary = 'doing is todo.txt for time tracking'
  s.authors = ["Greg Schueler"]
  s.email = 'greg.schueler@gmail.com'
  s.homepage = 'https://github.com/gschueler/nom'
  s.add_dependency('chronic', '>= 0.9.1')

  s.files = [
    "lib/doing.rb",
    "lib/doing/cli.rb",
    "lib/doing/formatters.rb",
    "lib/doing/formatters/markdown.rb",
    "lib/doing/formatters/table.rb",
    "lib/doing/formatters/status.rb"
  ]

  s.requirements << 'chronic'
  s.executables << 'doing'
  s.require_paths = ["lib"]
end