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
require 'jrubyfx'

# Inherit from JRubyFX::Application to create our Application
class SimpleFXApplication < JRubyFX::Application
  # we must override start to get a stage on application initialization
  def start stage
    # assign the title
    stage.title = "Simple JavaFX FXML App in pure Ruby"

    # Load our FXML using our controller. width and height are optional, as is
    # either :fill => Color:: OR (not both) :depth_buffer => boolean. If you
    # have a custom initialize_fxml function, pass in arguments as :intialize_fxml => [args]
    # note the difference between the constructor (initialize_ruby) and fxml loaded (initialize_fxml)
    @ctrlr = SimpleFXController.load_fxml("Demo.fxml", stage, :width => 620,
      :height => 480, :initialize_ruby => ["Arguments", "are supported"],
      :initialize_fxml => ["Send Stuff", "To initialized"])

    # finally, show our app
    stage.show
  end
end

# Inherit from JRubyFX::Controller to create our controller for this FXML file.
# You will need one Controller per FXML file
class SimpleFXController < JRubyFX::Controller

  # Here we declare that AnchorPane is a fx:id in the file so that we have
  # access to it as @AnchorPane later.
  # If you have multiple you can comma separate them, or add another
  # fx_id statement. NOTE! If fx:id and id are different, then this will look
  # at the id value, NOT the fx:id value. Get rid of id or keep it the same
  fx_id :AnchorPane

  ##
  # Setup the View
  ##

  def initialize first, second
    puts "FXML loaded"
    puts "#{first} #{second}"
    # fx_id's are initialized
    puts "AnchorPane is '#{@AnchorPane.inspect}' (expected non-nil)"
  end


  ##
  # Handle Events
  ##

  # This will be called from FXML by onAction="#click"
  on :click_green do
    puts "Clicked Green"
  end

  # `on_action` and `on` are the same for standard ActionEvents
  on_action :click_purple do
    puts "Clicked Purple"
  end

  # If you want to capture the ActionEvent object, just request it like this
  on :click_red do |arg|
    puts "Clicked Red", arg
  end

  # you can even register one handler for multiple events by using an array
  on [:click_blue, :click_orange, :click_black] do
    puts "Clicked Blue, Orange, or Black"
  end

  # this is a different style
  on(:quit) { Platform.exit }

  # For key events, you must use on_key
  on_key :keyPressed do |e|
    puts "You pressed a key!"
    puts "Alt: #{e.alt_down?} Ctrl: #{e.control_down?} Shift: #{e.shift_down?} Meta (Windows): #{e.meta_down?} Shortcut: #{e.shortcut_down?}"
    puts "Key Code: #{e.code} Character: #{e.character.to_i} Text: '#{e.text}'"
  end

  # For Context menu event, you must use on_context or on_context_menu
  on_context :cmenu do
    puts "Context Menu Requested"
  end

  # Full list of mappings:
  # on              is for ActionEvent
  # on_action       is for ActionEvent
  # on_key          is for KeyEvent
  # on_mouse        is for MouseEvent
  # on_touch        is for TouchEvent
  # on_gesture      is for GestureEvent
  # on_context      is for ContextMenuEvent
  # on_context_menu is for ContextMenuEvent
  # on_drag         is for DragEvent
  # on_ime          is for InputMethodEvent
  # on_input_method is for InputMethodEvent
  # on_window       is for WindowEvent
  # on_generic      is for Event
  #
  # And if you need a custom Event, you can use:
  # on :name, YourCustomEvent do |e| ... end

  # Actually do something: export jar! Found under file menu
  on :export_jar do

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
end

# Launch our application!
SimpleFXApplication.launch
