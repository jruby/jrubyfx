# Original version is here: https://gist.github.com/1358093

require 'jrubyfx'
require 'jruby/core_ext'

class AnalogClock
  include JRubyFX

  def start(stage)
    stage.tap do |s|
      s.title, s.width, s.height = 'This is RUBY!!!!', 600,600
      ctrlr = TestController.new_java
      ctrlr.scene = s.scene = Scene.new(load_fxml "#{File.dirname(__FILE__)}/Sample.fxml", ctrlr)
      s.show
    end
  end

end

class TestController < FXMLController
  fxml_linked :AnchorPane
  def initialize(url = nil, resources = nil)
    if url == nil and resources == nil
      # ruby new
      puts "ruby new"
    else
      # Java interface call
      puts "initalized"
    end
  end
  
  fxml_event
  def click(stuff)
    puts "Clicked Green"
  end
  
  fxml_event
  def clickbl(stuff)
    puts "Clicked Black"
    p @AnchorPane
  end
  
  fxml_event
  def clickre(stuff)
    puts "Clicked Red"
  end
end

AnalogClock.start
