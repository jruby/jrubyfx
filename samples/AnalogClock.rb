# Original version is here: https://gist.github.com/1358093

require 'jrubyfx'
require 'jruby/core_ext'

class AnalogClock
  include JRubyFX

  def start(stage)
    stage.tap do |s|
      s.title, s.width, s.height = 'This is RUBY!!!!', 600,600
      s.scene = Scene.new(load_fxml "#{File.dirname(__FILE__)}/Sample.fxml", TestController.newInstance)
      s.show
    end
  end

end

class TestController_ruby < FXMLController
  def initialize(fxmlFileLocation, resources)
    puts "initalized"
  end
  
  fxml_event
  def click(stuff)
    puts "Clicked Green"
  end
  
  fxml_event
  def clickbl(stuff)
    puts "Clicked Black"
  end
  
  fxml_event
  def clickre(stuff)
    puts "Clicked Red"
  end
end

TestController = TestController_ruby.become_java!
AnalogClock.start
