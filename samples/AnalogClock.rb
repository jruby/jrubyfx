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

class TestController_ruby
  java_import 'javafx.event.ActionEvent'
  java_import 'java.lang.Void'
  java_import 'java.net.URL'
  java_import 'java.util.ResourceBundle'
  
  include Java.javafx.fxml.Initializable #interfaces
  
  #the first arg is the return type, the rest are params
  add_method_signature :initialize, [Void::TYPE, URL, ResourceBundle]
  def initialize(fxmlFileLocation, resources)
    puts "initalized"
  end
  
  add_method_signature :click, [Void::TYPE, ActionEvent]
  def click(stuff)
    puts "Clicked"
  end
end

TestController = TestController_ruby.become_java!
AnalogClock.start
