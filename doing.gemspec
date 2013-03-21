Gem::Specification.new do |s|
  s.name = %q{doing}
  s.description = %q{doing is like todo.txt but for time tracking}
  s.version = "0.0.1"
  s.date = %q{2013-03-21}
  s.summary = %q{doing is todo.txt for time tracking}
  s.authors=["Greg Schueler"]
  s.email=%q{greg.schueler@gmail.com}
  s.homepage=%q{https://github.com/gschueler/nom}
  s.files = [
    "lib/doing.rb",
    "lib/doing/cli.rb"
  ]
  s.executables << 'doing'
  s.require_paths = ["lib"]
end