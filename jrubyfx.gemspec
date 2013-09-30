# -*- encoding: utf-8 -*-
require_relative 'lib/jrubyfx/version'

# This must be assigned to the global spec variable as its relied upon in the Rakefile.
$spec = Gem::Specification.new do |s|
  s.name        = "jrubyfx"
  s.version     = JRubyFX::VERSION
  s.platform    = 'java'
  s.authors     = ["Patrick Plenefisch", "Thomas E Enebo", "Hiroshi Nakamura", "Hiro Asari"]
  s.email       = ["simonpatp@gmail.com", "tom.enebo@gmail.com", "nahi@ruby-lang.org", "asari.ruby@gmail.com"]
  s.homepage    = "https://github.com/jruby/jrubyfx"
  s.summary     = "JavaFX for JRuby with FXML"
  s.description = "Enables JavaFX with FXML controllers and application in pure ruby"
  s.rubyforge_project         = "jrubyfx"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"

  s.add_dependency "jrubyfx-fxmlloader", ">= 0.3"

  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md)
  s.executables  = ['jrubyfx-generator', 'jrubyfx-jarify', 'jrubyfx-compile']
  s.require_path = 'lib'
  s.license      = 'Apache License 2.0'
end
