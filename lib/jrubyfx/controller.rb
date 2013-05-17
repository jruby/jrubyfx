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

require 'jrubyfx-fxmlloader'

# Special methods for fxml loading
module Kernel
  def fxml_root(value=nil)
    if value
      @@jrubyfx_fxml_dir = File.expand_path(value)
    else
      @@jrubyfx_fxml_dir
    end
  end
end

# Inherit from this class for FXML controllers
module JRubyFX::Controller
  include JRubyFX::DSL
  java_import 'java.net.URL'

  DEFAULT_SETTINGS = {
    width: -1,
    height: -1,
    fill: :white,
    depth_buffer: false,
    root_dir: nil,
    initialized: nil
  }

  # Controllers usually need access to the stage.
  attr_writer :stage, :scene

  def self.included(base)
    base.extend(ClassMethods)
    # register ourselves as a control. overridable with custom_fxml_control
    register_type base if base.is_a? Class
  end
  
  # class methods for FXML controllers
  module ClassMethods
    include JRubyFX::DSL

    #nested including, TODO: don't duplicate this
    def included(base)
      base.extend(JRubyFX::Controller::ClassMethods)
      # register ourselves as a control. overridable with custom_fxml_control
      JRubyFX::DSL::ClassUtils.register_type base if base.is_a? Class
    end

    # Load given fxml file onto the given stage. `settings` is an optional hash of:
    # * :initialize => [array of arguments to pass to the initialize function]
    # * :width => Default width of the Scene
    # * :height => Default height of the Scene
    # * :fill => Fill color of the Scene's background
    # * :depth_buffer => JavaFX Scene DepthBuffer argument (look it up)
    # * :root_dir =>  filename search for fxml realtive to this file
    #
    # === Examples
    #
    #   controller = MyFXController.new "Demo.fxml", stage
    #
    # === Equivalent Java
    #   Parent root = FXMLLoader.load(getClass().getResource("Demo.fxml"));
    #   Scene scene = new Scene(root);
    #   stage.setScene(scene);
    #   controller = root.getController();

    def load_into(stage, settings={})
      # Inherit from default settings
      settings = DEFAULT_SETTINGS.merge({root_dir: (self.instance_variable_get("@fxml_root_dir") || fxml_root),
          filename: self.instance_variable_get("@filename") || guess_filename(ctr)}).merge settings

      # Custom controls don't always need to be pure java, but oh well...
      become_java!

      # like new, without initialize
      ctrl = allocate

      # Set the stage so we can reference it if needed later
      ctrl.stage = stage

      # load the FXML file
      root = Controller.get_fxml_loader(settings[:filename], ctrl, settings[:root_dir]).load

      # Unless the FXML root node is a scene, wrap that node in a scene
      if root.is_a? Scene
        scene = root
      else
        scene = Scene.new root, settings[:width], settings[:height], settings[:depth_buffer]
        scene.fill = settings[:fill]
      end

      # set the controller and stage scene
      ctrl.scene = stage.scene = scene

      ctrl.finish_initialization *settings[:initialize].to_a
    end

    # This is the default override for custom controls
    # Normal FXML controllers will use Control#new
    def new(*args, &block)
      # Custom controls don't always need to be pure java, but oh well...
      become_java!

      # like new, without initialize
      ctrl = allocate

      # return the controller
      ctrl.initialize_controller({root_dir: @fxml_root_dir || fxml_root,
          filename: @filename || guess_filename(ctrl)},
        *args, &block)
    end

    #decorator to force becoming java class
    def become_java
      @force_java = true
    end

    # Set the filename of the fxml this control is part of
    def fxml(fxml=nil, name = nil, root_dir = nil)
      @filename = fxml
      # snag the filename from the caller
      @fxml_root_dir = root_dir
      register_type(self, name) if name
    end

    # guess the fxml filename if nobody set it
    def guess_filename(obj)
      firstTry = obj.class.name[/([\w]*)$/, 1] + ".fxml"
      #TODO: check to see if snake_case version is on disk
      firstTry
    end

    ##
    # Event Handlers
    ##

    ##
    # call-seq:
    #   on(callback, ...) { |event_info| block } => Method
    #
    # Registers a function of name `name` for a FXML defined event with the body in the block.
    # Note you can also just use normal methods
    #
    # === Examples
    #   on :click do
    #     puts "button clicked"
    #   end
    #
    #   on :moved, :pressed do |event|
    #     puts "Mouse Moved or Key Pressed"
    #     p event
    #   end
    #
    # === Equivalent Java
    #   @FXML
    #   private void click(ActionEvent event) {
    #     System.out.println("button clicked");
    #   }
    #
    #   @FXML
    #   private void moved(MouseEvent event) {
    #     System.out.println("Mouse Moved or Key Pressed");
    #   }
    #
    #   @FXML
    #   private void keypress(KeyEvent event) {
    #     System.out.println("Key Pressed or Key Pressed");
    #   }
    #
    def on(names, &block)
      [names].flatten.each do |name|
        class_eval do
          # must define this way so block executes in class scope, not static scope
          define_method name, block
        end
      end
    end
  end

  #default java ctor, override for arguments
  def java_ctor(ctor, initialize_arguments)
    ctor.call
  end

  # Initialize all controllers
  def initialize_controller(options={}, *args, &block)

    # JRuby complains loudly (probably broken behavior) if we don't call the ctor
    java_ctor self.class.superclass.instance_method(:initialize).bind(self), args

    # load the FXML file with the current control as the root
    load_fxml options[:filename], options[:root_dir]

    finish_initialization *args, &block
  end

  def load_fxml(filename, root_dir=nil)
    fx = Controller.get_fxml_loader(filename, self, root_dir)
    fx.root = self
    fx.load
  end

  def finish_initialization(*args, &block)
    @nodes_by_id = {}

    # custom controls are their own scene
    self.scene = self unless @scene

    # Everything is ready, call initialize
    if private_methods.include? :initialize
      self.send :initialize, *args, &block
    end

    #return ourself
    self
  end

  ##
  #  Node Lookup Methods
  ##

  # return first matched node or nil
  def find(css_selector)
    @scene.lookup(css_selector)
  end

  # Return first matched node or throw exception
  def find!(css_selector)
    res = find(css_selector)
    raise "Selector(#{css_selector}) returned no results!" unless res
    res
  end

  # return an array of matched nodes
  def css(css_selector)
    @scene.get_root.lookup_all(css_selector).to_a
  end
  
  # Loads a controller-less file
  def self.load_fxml_only(filename, stage, settings={})
    # Inherit from default settings
    settings = DEFAULT_SETTINGS.merge({root_dir: fxml_root,
        filename: filename}).merge settings

    # load the FXML file
    root = Controller.get_fxml_loader(settings[:filename], nil, settings[:root_dir]).load
      
    # TODO: de-duplicate this code

    # Unless the FXML root node is a scene, wrap that node in a scene
    if root.is_a? Scene
      scene = root
    else
      scene = Scene.new root, settings[:width], settings[:height], settings[:depth_buffer]
      scene.fill = settings[:fill]
    end

    # set the controller and stage scene
    stage.scene = scene
  end


  ##
  # call-seq:
  #   get_fxml_loader(filename) => FXMLLoader
  #   get_fxml_loader(filename, controller_instance) => FXMLLoader
  #   get_fxml_loader(filename, controller_instance, root_dir) => FXMLLoader
  #
  # Load a FXML file given a filename and a controller and return the loader
  # root_dir is a directory that the file is relative to.
  # === Examples
  #   root = JRubyFX::Controller.get_fxml_loader("Demo.fxml").load
  #
  #   root = JRubyFX::Controller.get_fxml_loader("Demo.fxml", my_controller).load
  #
  # === Equivalent Java
  #   Parent root = FXMLLoader.load(getClass().getResource("Demo.fxml"));
  #
  def self.get_fxml_loader(filename, controller = nil, root_dir = nil)
    fx = FxmlLoader.new
    fx.location =
      if JRubyFX::Application.in_jar?
      # If we are in a jar file, use the class loader to get the file from the jar (like java)
      # TODO: should just be able to use URLs
      JRuby.runtime.jruby_class_loader.get_resource filename
    else
      root_dir ||= fxml_root
      # If we are in the normal filesystem, create a file url path relative to relative_to or this file
      URL.new "file:#{File.join root_dir, filename}"
    end
    # we must set this here for JFX to call our events
    fx.controller = controller
    fx
  end
end
