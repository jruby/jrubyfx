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

# Inherit from this class for FXML controllers
class JRubyFX::Controller
  include JRubyFX
  include JRubyFX::DSL
  java_import 'java.net.URL'
  java_import 'javafx.fxml.FXMLLoader'

  @@default_settings = {
    width: -1,
    height: -1,
    fill: Color::WHITE,
    depth_buffer: false,
    relative_to: nil,
    initialized: nil,
  }

  # Controllers usually need access to the stage.
  attr_accessor :stage, :scene

  ##
  # Construction as a Java Class
  ##

  # Load given fxml file onto the given stage. `settings` is an optional hash of:
  # * :initialize => [array of arguments to pass to the initialize function]
  # * :width => Default width of the Scene
  # * :height => Default height of the Scene
  # * :fill => Fill color of the Scene's background
  # * :depth_buffer => JavaFX Scene DepthBuffer argument (look it up)
  # * :relative_to =>  filename search for fxml realtive to this file
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

  def self.new filename, stage, settings={}
    # Inherit from default settings
    settings = @@default_settings.merge settings

    # Magic self-java-ifying new call. (Creates a Java instance from our ruby)
    self.become_java!

    # like new, without initialize
    ctrl = self.allocate

    # Set the stage so we can reference it if needed later
    ctrl.stage = stage

    # load the FXML file
    root = load_fxml_resource filename, ctrl, settings[:relative_to]

    # Unless the FXML root node is a scene, wrap that node in a scene
    if root.is_a? Scene
      scene = root
    else
      scene = Scene.new root, settings[:width], settings[:height], settings[:depth_buffer]
      scene.set_fill settings[:fill]
    end

    # set the controller and stage scene
    ctrl.scene = stage.scene = scene
    ctrl.instance_variable_set :@nodes_by_id, {}

    # Everything is ready, call initialize_callback
    if ctrl.private_methods.include? :initialize_callback
      ctrl.send :initialize_callback, *settings[:initialize].to_a
    end

    # return the controller
    ctrl
  end

  # FXMLLoader#load also calls initalize
  # if defined, move initialize so we can call it when we're ready
  def self.method_added meth
    if meth == :initialize and not @ignore_method_added
      @ignore_method_added = true
      alias_method :initialize_callback, :initialize
      self.send(:define_method, :initialize) {|do_not_call_me|}
    end
  end


  ##
  # Event Handlers
  ##

  ##
  # call-seq:
  #   on(callback) { |event_info| block } => Method
  #   on(callback, EventType) { |event_info| block } => Method
  #   on_type(callback) { |event_info| block } => Method
  #
  # Registers a function of name `name` for a FXML defined event with the body in the block
  # Note: there are overrides for most of the default types, so you should never
  # need to manually specify the `type` argument unless you have custom events.
  # The overrides are in the format on_* where * is the event type (ex: on_key for KeyEvent).
  #
  # === Convienence Methods
  # * on_key           is for KeyEvent
  # * on_mouse         is for MouseEvent
  # * on_touch         is for TouchEvent
  # * on_gesture       is for GestureEvent
  # * on_context       is for ContextMenuEvent
  # * on_context_menu  is for ContextMenuEvent
  # * on_drag          is for DragEvent
  # * on_ime           is for InputMethodEvent
  # * on_input_method  is for InputMethodEvent
  # * on_window        is for WindowEvent
  # * on_action        is for ActionEvent
  # * on_generic       is for Event
  #
  # === Examples
  #   on :click do
  #     puts "button clicked"
  #   end
  #
  #   on_mouse :moved do |event|
  #     puts "Mouse Moved"
  #     p event
  #   end
  #
  #   on_key :keypress do
  #     puts "Key Pressed"
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
  #     System.out.println("Mouse Moved");
  #   }
  #
  #   @FXML
  #   private void keypress(KeyEvent event) {
  #     System.out.println("Key Pressed");
  #   }
  #
  def self.on(names, type=ActionEvent, &block)
    [names].flatten.each do |name|
      class_eval do
        # must define this way so block executes in class scope, not static scope
        define_method name, block
        # the first arg is the return type, the rest are params
        add_method_signature name, [Void::TYPE, type]
      end
    end
  end

  # Get the eigenclass, the singleton class of self, and add event handlers as on_EVENT
  # This syntax allows us to define methods in class scope (eg: def self.on_touch )
  class << self
    {
      :key          => KeyEvent,
      :mouse        => MouseEvent,
      :touch        => TouchEvent,
      :gesture      => GestureEvent,
      :context      => ContextMenuEvent,
      :context_menu => ContextMenuEvent,
      :drag         => DragEvent,
      :ime          => InputMethodEvent,
      :input_method => InputMethodEvent,
      :window       => WindowEvent,
      :action       => ActionEvent,
      :generic      => Event
    }.each do |method, klass|
      # define the handy overloads that just pass our arguments in
      define_method("on_#{method}") { |name, &block| on name, klass, &block }
    end
  end


  ##
  #  Node Lookup Methods
  ##

  # searches for an element by id (or fx:id, prefering id)
  def method_missing meth, *args, &block
    # if scene is attached, and the method is an id of a node in scene
    if @scene
      @nodes_by_id[meth] ||= find "##{meth}"
      return @nodes_by_id[meth] if @nodes_by_id[meth]
    end

    super
  end

  # return first matched node or nil
  def find css_selector
    @scene.lookup css_selector
  end

  # Return first matched node or throw exception
  def find! css_selector
    res = find(css_selector)
    raise "Selector(#{css_selector}) returned no results!" unless res
    res
  end

  # return an array of matched nodes
  def css css_selector
    @scene.get_root.lookup_all(css_selector).map {|e| e}
  end


  ##
  # call-seq:
  #   load_fxml_resource(filename) => Parent
  #   load_fxml_resource(filename, controller_instance) => Parent
  #   load_fxml_resource(filename, controller_instance, relative_to) => Parent
  #
  # Load a FXML file given a filename and a controller and return the root element
  # relative_to can be a file that this should be relative to, or an index
  # of the caller number. If you are calling this from a function, pass 0
  # as you are the immediate caller of this function.
  # === Examples
  #   root = JRubyFX::Controller.load_fxml_resource("Demo.fxml")
  #
  #   root = JRubyFX::Controller.load_fxml_resource("Demo.fxml", my_controller)
  #
  # === Equivalent Java
  #   Parent root = FXMLLoader.load(getClass().getResource("Demo.fxml"));
  #
  def self.load_fxml_resource(filename, ctrlr=nil, relative_to=0)
    fx = FXMLLoader.new()
    fx.location = if JRubyFX::Application.in_jar?
      # If we are in a jar file, use the class loader to get the file from the jar (like java)
      JRuby.runtime.jruby_class_loader.get_resource(filename)
    else
      if relative_to.is_a? Fixnum or relative_to == nil
        # caller[0] returns a string like so:
        # "/home/user/.rvm/rubies/jruby-1.7.1/lib/ruby/1.9/irb/workspace.rb:80:in `eval'"
        # and then we use a regex to filter out the filename
        relative_to = caller[relative_to||0][/(.*):[0-9]+:in /, 1] # the 1 is the first match, aka everything up to the :
      end
      # If we are in the normal filesystem, create a normal file url path relative to the main file
      URL.new(URL.new("file:"), "#{File.dirname(relative_to)}/#{filename}")
    end
    # we must set this here for JFX to call our events
    fx.controller = ctrlr
    return fx.load()
  end
end
