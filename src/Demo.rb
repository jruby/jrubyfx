#!/usr/bin/env jruby
=begin
JRubyFXML - Write JavaFX and FXML in Ruby
Copyright (C) 2012 Patrick Plenefisch

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as 
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

# Require JRubyFXML library so we can get FXMLApplication and FXMLController
require 'jrubyfxml'

# Inherit from FXMLApplication to create our Application
class SimpleFXMLApplication < FXMLApplication
  # we must override start to get a stage on application initialization
  def start(stage)
    # assign the title, width, and height
    stage.title = "Simple JavaFX FXML App in pure Ruby"
    stage.width = 620
    stage.height = 480
    
    # create a new instance of our controller. Note that you MUST use new_java
    # to ensure that it is really a java object. new_java is specific to 
    # the FXMLController class
    ctrlr = SimpleFXMLController.new_java
    
    # Load the FXML file with our controller. NEVER make this an absoloute path,
    # or Java will fail to load it if we are in a jar
    fxml = load_fxml("Demo.fxml", ctrlr)
    
    # Create a new Scene with our parsed FXML
    stage.scene = Scene.new(fxml)
    
    # Give our controller the scene also. THIS IS CRITICAL if you have fx:id
    # properties. Not setting this prevents the fx:id's from binding properly
    ctrlr.scene = stage.scene
    
    # finally, show our app
    stage.show
  end
end

# Inherit from FXMLController to create our controller for this FXML file.
# You will need one Controller per FXML file under normal conditions.
class SimpleFXMLController < FXMLController
  
  # Here we declare that AnchorPane is a fx:id in the file
  fx_id :AnchorPane
  
  # Initialize must have url and resources as it is actually an interface method
  def initialize(url = nil, resources = nil)
    if url == nil
      # ruby new
      puts "ruby new"
    else
      # Java interface call
      puts "initalized"
    end
  end
  
  # This is how events are defined in code.
  # This will be called from FXML by onAction="#click"
  fx_handler :click do 
    puts "Clicked Green"
  end
  
  # fx_action_handler and fx_handler all the same for standard ActionEvents
  fx_action_handler :clickbl do
    puts "Clicked Black"
    p @AnchorPane
  end
  
  # If you want to capture the ActionEvent object, just request it like this
  fx_handler :clickre do |arg|
    puts "Clicked Red"
    p arg
  end
  
  # For key events, you must use fx_key_handler
  fx_key_handler :keyPressed do |e|
    puts "You pressed a key!"
    puts "Alt: #{e.alt_down?} Ctrl: #{e.control_down?} Shift: #{e.shift_down?} Meta (Windows): #{e.meta_down?} Shortcut: #{e.shortcut_down?}"
    puts "Key Code: #{e.code} Character: #{e.character.to_i} Text: '#{e.text}'"
  end
  
  # For Context menu event, you must use fx_context_handler
  fx_context_handler :cmenu do
    puts "Context Menu Requested"
  end
  
  # Full list of mappings:
  # fx_key_handler is for KeyEvent
  # fx_mouse_handler is for MouseEvent
  # fx_touch_handler is for TouchEvent
  # fx_gesture_handler is for GestureEvent
  # fx_context_handler is for ContextMenuEvent
  # fx_context_menu_handler is for ContextMenuEvent
  # fx_drag_handler is for DragEvent
  # fx_ime_handler is for InputMethodEvent
  # fx_input_method_handler is for InputMethodEvent
  # fx_window_handler is for WindowEvent
  # fx_action_handler is for ActionEvent
  # fx_generic_handler is for Event
  # 
  # And if you need a custom Event, you can use:
  # fx_handler :name, YourCustomEvent do |e| ... end
end

# Launch our application!
SimpleFXMLApplication.launch
