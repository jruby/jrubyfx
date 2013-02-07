#!/usr/bin/env jruby
=begin
JRubyFX - Write JavaFX and FXML in Ruby
Copyright (C) 2013 The JRubyFX Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

# Require JRubyFX library so we can get JRubyFX::Application and JRubyFX::Controller
require 'jrubyfx'

# Inherit from JRubyFX::Application to create our Application
class SimpleFXApplication < JRubyFX::Application
  # we must override start to get a stage on application initialization
  def start(stage)
    # assign the title
    stage.title = "Simple JavaFX FXML App in pure Ruby"
    
    # Load our FXML using our controller. width and height are optional, as is
    # either :fill => Color:: OR (not both) :depth_buffer => boolean. If you
    # have a custom initialize function, pass in arguments as :intialize => [args]
    @ctrlr = SimpleFXController.load_fxml("Demo.fxml", stage, :width => 620,
      :height => 480, :initialize => ["Arguments", "are supported"])
    
    # finally, show our app
    stage.show
  end
end

# Inherit from JRubyFX::Controller to create our controller for this FXML file.
# You will need one Controller per FXML file under normal conditions.
class SimpleFXController < JRubyFX::Controller
  
  # Here we declare that AnchorPane is a fx:id in the file so that we have 
  # access to it as @AnchorPane later.
  # If you have multiple you can comma separate them, or add another
  # fx_id statement. NOTE! If fx:id and id are different, then this will look
  # at the id value, NOT the fx:id value. Get rid of id or keep it the same
  fx_id :AnchorPane
  
  # if one controller will be used for multiple forms, use fx_id_optional 
  # instead of fx_id to avoid warnings that the id can't be found
  
  # Ready is optional
  def ready(first, second)
    puts "Ruby new"
    puts "#{first} #{second}"
    p @AnchorPane
  end
  
  # This is how events are defined in code.
  # This will be called from FXML by onAction="#click"
  fx_handler :click do 
    puts "Clicked Green"
  end
  
  # fx_action_handler and fx_handler all the same for standard ActionEvents
  # you can even register one handler for multiple events by using an array
  # of names like so:
  # fx_handler [:event1, :event2] do ... end
  fx_action_handler :clickbl do
    puts "Clicked Black"
    # This is the fx:id linked variable
    p @AnchorPane
  end
  
  # If you want to capture the ActionEvent object, just request it like this
  fx_handler :clickre do |arg|
    puts "Clicked Red"
    p arg
  end
  
  # Actually do something: export jar! Found under file menu
  fx_handler :export_jar do
    
    # the build function lets you set properties and call functions on an object
    # however, you can't reference stage, scene, or any local methods
    # note the title: "bla" is ruby 1.9 syntax, and equivalent to :title => "bla"
    # A handy shortcut to build(CamelCaseClass, bla) is snake_case_class(bla)
    dialog = file_chooser(:title => "Export Demo.rb as jar...") do
      # if we did not use the magic build method, this is the same as 
      # FileChooserInstance.add_extension_filter(...)
      # *.jar is autodetected from the description. If you don't want 
      # autodetection, there is an optional 2nd argument.
      # For multiple filters, use add_extension_filters with a list or
      # a hash of description => [extensions]
      add_extension_filter("Java Archive (*.jar)")
    end
    # Show the dialog!
    file = dialog.showSaveDialog(stage)
    
    unless file == nil
      output_jar = file.path
      # Note that JavaFX does not add extensions automatically, so lets add it
      output_jar += ".jar" unless output_jar.end_with? ".jar"
      # import the jarification tasks
      require 'jrubyfx_tasks'
      # Download jruby (current version running)
      JRubyFXTasks::download_jruby(JRUBY_VERSION)
      # Create a jar of all file in this same folder, this file is the root script,
      #  no fixed staging dir, and save it to our file we specified
      JRubyFXTasks::jarify_jrubyfx("#{File.dirname(__FILE__)}/*", __FILE__, nil, output_jar)
      puts "Success!"
    end
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
SimpleFXApplication.launch
