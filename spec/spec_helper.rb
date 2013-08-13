require 'jrubyfx'
require 'jrubyfx/version'

puts "   Java: #{ENV_JAVA['java.runtime.version']  } / JRuby: #{JRUBY_VERSION}"
puts " JavaFX: #{ENV_JAVA['javafx.runtime.version']} / JRubyFX: #{JRubyFX::VERSION}"

## RSpec configuration block
RSpec.configure do |config|
  config.mock_with :rspec
  config.order = "random"
end
