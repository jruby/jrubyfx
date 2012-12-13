Gem::Specification.new do |s|
  s.name        = "jrubyfxml"
  s.version     = "0.2"
  s.platform    = 'java'
  s.authors     = ["Patrick Plenefisch"]
  s.email       = ["simonpatp@gmail.com"]
  s.homepage    = "https://github.com/byteit101/JRubyFXML"
  s.summary     = "JavaFX for JRuby with FXML"
  s.description = "Enables FXML controller use in pure ruby"
 
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "bundler"

  s.files        = Dir.glob("lib/*") + %w(LICENSE README.md)
  s.executables  = []
  s.require_path = 'lib'
end