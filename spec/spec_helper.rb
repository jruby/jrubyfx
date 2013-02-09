require 'rubygems'
require 'jrubyfx'
require 'jrubyfx/version'
# puts "LoadPath: #{$:}\n"

puts "   Java: #{ENV_JAVA['java.runtime.version']  } / jRuby: #{JRUBY_VERSION}"
puts " JavaFX: #{ENV_JAVA['javafx.runtime.version']} / jRubyFX: #{JRubyFX::VERSION}"

## RSpec configuration block
RSpec.configure do |config|
  config.mock_with :rspec
  config.order = "random"
end
