# Original version is here: https://gist.github.com/1358093

require 'jrubyfx'
require 'jruby/core_ext'

class AnalogClock
  include JRubyFX

  def start(stage)
    
    #puts caller
    #stage.initStyle StageStyle::TRANSPARENT
    #scene = load_fxml_scene("Sample.fxml")
    stage.tap do |s|
      s.title, s.width, s.height = 'This is RUBY!!!!', 600,600
      #s.resizable = false
      #group = Group.new.tap {|g| g.children << create_content }
      s.scene = Scene.new(load_fxml "#{File.dirname(__FILE__)}/Sample.fxml", TestController.new(nil, nil))
      #.tap do |sc|
      #  sc.fill = nil # Completes transparency
        #sc.set_on_key_pressed { |e| java.lang.System.exit(0) }
      #end
      s.show
    end
  end

end

class TestController
  include Java.javafx.fxml.Initializable
  #TODO: SOOPER HACK!!!! BAD BAD BAD
  #@java_aliases = {} if @java_aliases == nil
  #java_alias :initialize, :initialize
  def initialize(fxmlFileLocation, resources)
    puts "initalized"
    p fxmlFileLocation
    p resources
  end
  
#  def click(stuff)
#    p "Clicked"
#    p stuff
#  end
end
 #TestController.add_method_signature("click", [Java.javafx.event.ActionEvent])
 #TestController.add_method_signature("initialize", [Java.java.net.URL, Java.java.util.ResourceBundle])
    
#TestController.become_java!
 #   puts "AnalogClock.rb:raw start()@" + Time.now.usec.to_s
AnalogClock.start
 #   puts "AnalogClock.rb:raw start()-ed@" + Time.now.usec.to_s
