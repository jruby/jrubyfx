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
require_relative 'complex_control'

# Inherit from JRubyFX::Application to create our Application
class SimpleFXApplication < JRubyFX::Application
  # we must override start to get a stage on application initialization
  def start(stage)
    # assign the title
    stage.title = "Simple JavaFX FXML App in pure Ruby"

    # Load our FXML using our controller.
    # Only fxml and stage are required
    # Optional Settings Hash:
    #   :width        => int
    #   :height       => int
    #   :fill         => Color::
    #   :depth_buffer => boolean
    #   :initialize   => [args]
    #   :relative_to  => path_to_fxml_views
    #   :filename     => FXML file to use

    SimpleFXController.load_into stage,
      initialize: ["Send Stuff", "To initialized"],
      fill: :wheat # you can use symbols instead of Color objects

    # finally, show our app
    stage.show
  end
end

# Include JRubyFX::Controller to create our controller for this FXML file.
# You will need one Controller per FXML file
class SimpleFXController
  include JRubyFX::Controller

  fxml_root "Demo.fxml"

  ##
  # Setup the View
  ##

  def initialize(first, second)
    puts "FXML loaded"
    puts "#{first} #{second}"

    # find elements by fx:id or id (prefers non-namespaced id when both present)
    # If your element is the same ID as a control type, you must call send or find
    puts "Find by Ruby magic", @rootAnchorPane, @root, nil

    puts "Find single node CSS lookup", find('#rootAnchorPane'), find!("#root"), nil

    # Save a Node for quick access later
    # note that rootAnchorPane is a magic method
    @anchor_pane = @rootAnchorPane

    puts "find returns #{find('#not_found').inspect} when no match."
    begin
      find!("#not_found")
    rescue
      puts "find! raises exceptions\n"
    end

    # find elements by simple css selector (case-sensitive)
    puts "\nFind by basic CSS selector:"
    ['rootAnchorPane','Pane','#root','MenuBar','Button'].each do |query|
      puts "\t#{query} => #{css(query).inspect}"
    end

    puts "\nComplex CSS doesn't work:"
    ['MenuBar Menu','MenuBar MenuItem','MenuItem','Menu','[textFill="WHITE"]','[fx|id]'].each do |query|
      puts "\t#{query} => #{css(query).inspect}"
    end

    # you can use custom controls as if they were built in via the dsl
    @ui_border_pane.bottom = complex_control("Enter text and hit enter:")
  end


  ##
  # Handle Events
  ##

  # This will be called from FXML by onAction="#click"
  def click_green
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
    file = dialog.showSaveDialog(@stage)

    unless file == nil
      output_jar = file.path
      # Note that JavaFX does not add extensions automatically, so lets add it
      output_jar += ".jar" unless output_jar.end_with? ".jar"
      # import the jarification tasks
      require 'jrubyfx_tasks'
      # Download jruby (current version running)
      JRubyFX::Tasks::download_jruby(JRUBY_VERSION)
      # Create a jar of all file in this same folder, this file is the root script,
      #  no fixed staging dir, and save it to our file we specified
      JRubyFX::Tasks::jarify_jrubyfx("#{File.dirname(__FILE__)}/*", __FILE__, nil, output_jar)
      puts "Success!"
    end
  end
end

# Launch our application!
SimpleFXApplication.launch
