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

  # Controllers usually need access to the stage.
  attr_accessor :stage


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


  # Get the singleton class, and add special overloads as fx_EVENT_handler
  # This funky syntax allows us to define methods on self (like define_method("self.method"),
  # except that does not work)
  class << self
    include JRubyFX::FXImports
    {:key => KeyEvent,
      :mouse => MouseEvent,
      :touch => TouchEvent,
      :gesture => GestureEvent,
      :context => ContextMenuEvent,
      :context_menu => ContextMenuEvent,
      :drag => DragEvent,
      :ime => InputMethodEvent,
      :input_method => InputMethodEvent,
      :window => WindowEvent,
      :action => ActionEvent,
      :generic => Event}.each do |method, klass|
      #instance_eval on the self instance so that these are defined as class methods
      self.instance_eval do
        # define the handy overloads that just pass our arguments in
        define_method("on_#{method}") do |name, &block|
          on(name, klass, &block)
        end
      end
    end
  end

  # When FXMLLoader detects a method called initialze taking 0 args, then it calls it
  # We don't want this, as ruby new calls initialize
  # Override new to avoid calling initialize
  def self.new(*args, &block)
    obj = self.allocate
    obj.send(:initialize_ruby, *args, &block) if defined? obj.initialize_ruby
    obj
  end

  # this is the default initialize that the FXML loader will call
  def initialize()
  end
  # this is the default initialized method so we can always call it
  def initialize_fxml(*args)
    self.send(:initialize_fxml_warn, *args) if defined? initialize_fxml_warn
  end
  alias_method :initialize_orig, :initialize

  # When initialize is defined, rename it to initialized, and restore
  # initialize to default so java does not double call us
  def self.method_added(name)
    if name == :initialize && !@in_alias
      puts <<WARNIT
*****************************************************************************
*****************************************************************************
**                   WARNING! WARNING! WARNING! WARNING!                   **
** WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! **
**                   WARNING! WARNING! WARNING! WARNING!                   **
*****************************************************************************
**                                                                         **
** You probably meant to define `initialize_fxml` instead of `initialize`  **
** `initialize` is ambiguous in JavaFX controllers as FXMLLoader will call **
**  it if it has 0 arguments in addition to it being ruby's constructor.   **
**  If you need access to FXML elements (defined with `fx_id :myEltId`),   **
**   then use `initialize_fxml`. If you need the ruby constructor, which   **
**     does not have access to FXML yet, use `initialize_ruby` instead     **
**                                                                         **
**            Assuming you wanted `initialize_fxml` for this run           **
**                                                                         **
*****************************************************************************
**                   WARNING! WARNING! WARNING! WARNING!                   **
** WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! **
**                   WARNING! WARNING! WARNING! WARNING!                   **
*****************************************************************************
*****************************************************************************
WARNIT
      @in_alias = true
      alias_method :initialize_fxml_warn, :initialize
      alias_method :initialize, :initialize_orig
      @in_alias = false
    end
  end

  # FXML linked variable names by subclass
  @@fxml_linked_args = {}

  ##
  # call-seq:
  #   fx_id :name, ...
  #
  # Register one or more variable names to bind to a fx:id in the FXML file.
  # === Example
  #   fx_id :myVar
  #
  # === Equivalent Java
  #   @FXML
  #   private ClassName myVar;
  #
  def self.fx_id(*name)
    # we must distinguish between subclasses, hence self.
    (@@fxml_linked_args[self] ||= []).concat(name)
  end

  ##
  # call-seq:
  #   fx_id_optional :name, ...
  #
  # Register one or more variable name to bind to a fx:id in the FXML file if it exists.
  # If the name cannot be found, don't complain.
  # === Example
  #   fx_id_optional :myVar
  #
  # === Equivalent Java
  #   @FXML
  #   private ClassName myVar;
  #
  def self.fx_id_optional(*names)
    fx_id *names.map {|i| {i => :quiet} }
  end

  ##
  # Set scene object (setter), and update fxml-injected values. If you are manually
  # loading FXML, you MUST call this to link `fx_id` specified names.
  def scene=(s)
    @scene = s
    (@@fxml_linked_args[self.class] ||= []).each do |name|
      quiet = false
      # you can specify name => [quiet/verbose], so we need to check for that
      if name.is_a? Hash
        quiet = name.values[0] == :quiet
        name = name.keys[0]
      end
      # set each instance variable from the lookup on the scene
      val = s.lookup("##{name}")
      if val == nil && !quiet
        puts "[WARNING] fx_id not found: #{name}. Is id set to a different value than fx:id? (if this is expected, use fx_id_optional)"
      end
      instance_variable_set("@#{name}".to_sym, val)
    end
  end

  ##
  # Return the scene object (getter)
  def scene()
    @scene
  end

  ##
  # Magic self-java-ifying new call. (Creates a Java instance)
  def self.new_java(*args)
    self.become_java!
    self.new(*args)
  end

  ##
  # Load given fxml file onto the given stage. `settings` is an optional hash of:
  # * :initialize => [array of arguments to pass to the initialize function]
  # * :width => Default width of the Scene
  # * :height => Default height of the Scene
  # * :fill => Fill color of the Scene's background
  # * :depth_buffer => JavaFX Scene DepthBuffer argument (look it up)
  # * :relative_to => number of calls back, or filename. `filename` is evaluated
  #   as being relative to this. Default is relative to caller (1)
  # Returns a scene, either a new one, or the FXML root if its a Scene.
  # === Examples
  #
  #   controller = MyFXController.load_fxml("Demo.fxml", stage)
  #
  # === Equivalent Java
  #   Parent root = FXMLLoader.load(getClass().getResource("Demo.fxml"));
  #   Scene scene = new Scene(root);
  #   stage.setScene(scene);
  #   controller = root.getController();
  #
  def self.load_fxml(filename, stage, settings={})
    # Create our class as a java class with any arguments it wants
    ctrl = self.new_java *settings[:initialize_ruby].to_a
    # save the stage so we can reference it if needed later
    ctrl.stage = stage
    # load the FXML file
    parent = load_fxml_resource(filename, ctrl, settings[:relative_to] || 1)
    # set the controller and stage scene, so that all the fx_id variables are hooked up
    ctrl.scene = stage.scene = if parent.is_a? Scene
      parent
    elsif settings.has_key? :fill
      Scene.new(parent, settings[:width] || -1, settings[:height] || -1, settings[:fill] || Color::WHITE)
    else
      Scene.new(parent, settings[:width] || -1, settings[:height] || -1, settings[:depth_buffer] || settings[:depthBuffer] || false)
    end
    # instead of using the initializable interface, roll our own so we don't have to deal with java.
    ctrl.initialize_fxml(*settings[:initialize_fxml].to_a)
    # return the controller. If they want the new scene, they can call the scene() method on it
    return ctrl
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
