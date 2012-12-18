# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jrubyfx/version'

Gem::Specification.new do |s|
  s.name        = "jrubyfxml"
  s.version     = JRubyFX::VERSION
  s.platform    = 'java'
  s.authors     = ["Patrick Plenefisch", "Thomas E Enebo", "Hiroshi Nakamura", "Hiro Asari"]
  s.email       = ["simonpatp@gmail.com", "tom.enebo@gmail.com", "nahi@ruby-lang.org", "asari.ruby@gmail.com"]
  s.homepage    = "https://github.com/byteit101/JRubyFXML"
  s.summary     = "JavaFX for JRuby with FXML"
  s.description = "Enables JavaFX with FXML controllers and application in pure ruby"
 
  s.add_dependency "rake" # should I even bother?
  s.rubyforge_project         = "jrubyfxml"

  s.files        = Dir.glob("lib/**/*") + %w(LICENSE README.md)
  s.executables  = []
  s.require_path = 'lib'
end
