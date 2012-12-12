require 'java'
require 'jfxrt.jar'
require 'jrubyfx.jar'
require 'jruby/core_ext'

module JRubyFX
  java_import 'javafx.animation.FadeTransition'
  java_import 'javafx.animation.Interpolator'
  java_import 'javafx.animation.KeyFrame'
  java_import 'javafx.animation.KeyValue'
  java_import 'javafx.animation.ParallelTransition'
  java_import 'javafx.animation.RotateTransition'
  java_import 'javafx.animation.ScaleTransition'
  java_import 'javafx.animation.Timeline'
  java_import 'javafx.beans.property.SimpleDoubleProperty'
  java_import 'javafx.beans.value.ChangeListener'
  java_import 'javafx.collections.FXCollections'
  java_import 'javafx.event.ActionEvent'
  java_import 'javafx.event.EventHandler'
  java_import 'javafx.geometry.HPos'
  java_import 'javafx.geometry.VPos'
  java_import 'javafx.scene.Group'
  java_import 'javafx.scene.Scene'
  java_import 'javafx.scene.control.Button'
  java_import 'javafx.scene.control.Label'
  java_import 'javafx.scene.control.TableColumn'
  java_import 'javafx.scene.control.TableView'
  java_import 'javafx.scene.control.TextField'
  java_import 'javafx.scene.effect.Bloom'
  java_import 'javafx.scene.effect.GaussianBlur'
  java_import 'javafx.scene.effect.Reflection'
  java_import 'javafx.scene.effect.SepiaTone'
  java_import 'javafx.scene.image.Image'
  java_import 'javafx.scene.image.ImageView'
  java_import 'javafx.scene.layout.ColumnConstraints'
  java_import 'javafx.scene.layout.GridPane'
  java_import 'javafx.scene.layout.Priority'
  java_import 'javafx.scene.layout.HBox'
  java_import 'javafx.scene.layout.VBox'
  java_import 'javafx.scene.media.Media'
  java_import 'javafx.scene.media.MediaPlayer'
  java_import 'javafx.scene.media.MediaView'
  java_import 'javafx.scene.paint.Color'
  java_import 'javafx.scene.paint.CycleMethod'
  java_import 'javafx.scene.paint.RadialGradient'
  java_import 'javafx.scene.paint.Stop'
  java_import 'javafx.scene.shape.ArcTo'
  java_import 'javafx.scene.shape.Circle'
  java_import 'javafx.scene.shape.Line'
  java_import 'javafx.scene.shape.LineTo'
  java_import 'javafx.scene.shape.MoveTo'
  java_import 'javafx.scene.shape.Path'
  java_import 'javafx.scene.shape.Rectangle'
  java_import 'javafx.scene.text.Font'
  java_import 'javafx.scene.text.Text'
  java_import 'javafx.scene.transform.Rotate'
  java_import 'javafx.scene.web.WebView'
  java_import 'javafx.stage.Stage'
  java_import 'javafx.stage.StageStyle'
  java_import 'javafx.util.Duration'

  module ClassUtils
    def start(*args)
      JRubyFX.start(new(*args))
    end
  end

  def self.included(mod)
    mod.extend(ClassUtils)
  end

  def self.start(app)
    Java.org.jruby.ext.jrubyfx.JRubyFX.start(app)
  end
  
  def load_fxml(filename, ctrlr)
    fx = Java.javafx.fxml.FXMLLoader.new()
    fx.location = Java.java.net.URL.new(
      Java.java.net.URL.new("file:"), filename)
    fx.controller = ctrlr
    return fx.load
  end

  ##
  # Set properties (e.g. setters) on the passed in object plus also invoke
  # any block passed against this object.
  # === Examples
  #
  #   with(grid, vgap: 2, hgap: 2) do
  #     set_pref_size(500, 400)
  #     children << location << go << view
  #   end
  #
  def with(obj, properties = {}, &block)
    if block_given?
      obj.extend(JRubyFX)
      obj.instance_eval(&block)
    end
    properties.each_pair { |k, v| obj.send(k.to_s + '=', v) }
    obj
  end

  ##
  # Create "build" a new JavaFX instance with the provided class and
  # set properties (e.g. setters) on that new instance plus also invoke
  # any block passed against this new instance
  # === Examples
  #
  #   grid = build(GridPane, vgap: 2, hgap: 2) do
  #     set_pref_size(500, 400)
  #     children << location << go << view
  #   end
  #
  def build(klass, *args, &block)
    if !args.empty? and args.last.respond_to? :each_pair
      properties = args.pop 
    else 
      properties = {}
    end

    with(klass.new(*args), properties, &block)
  end

  def listener(mod, name, &block)
    obj = Class.new { include mod }.new
    obj.instance_eval do
      @name = name
      @block = block
      def method_missing(msg, *a, &b)
        @block.call(*a, &b) if msg == @name
      end
    end
    obj
  end
end

# inherit from this class for FXML controllers
class FXMLController
  java_import 'javafx.event.ActionEvent'
  java_import 'java.lang.Void'
  java_import 'java.net.URL'
  java_import 'java.util.ResourceBundle'
  
  include Java.javafx.fxml.Initializable #interfaces
  
  # block construct to define methods and automatically add action events
  def self.fxml_event(name, &block)
    class_eval do
      #must define this way so block executes in class scope, not static scope
      define_method(name, block)
      #the first arg is the return type, the rest are params
      add_method_signature name, [Void::TYPE, ActionEvent]
    end
  end
  
  # when initialize method is created, add java signature
  def self.method_added(name)
    if name == :initialize
      add_method_signature :initialize, [Void::TYPE, URL, ResourceBundle]
    end
  end
  
  # FXML linked variable names by class
  @@fxml_linked_args = {}
  
  def self.fxml_linked(name)
    # we must distinguish between subclasses, hence self.
    (@@fxml_linked_args[self] ||= []) << name
  end
  
  # set scene object (setter), and update fxml-injected values
  def scene=(s)
    @scene = s
    (@@fxml_linked_args[self.class] ||= []).each do |name|
      #set each instance variable from the lookup on the scene
      instance_variable_set("@#{name}".to_sym, s.lookup(name.to_s))
    end
  end
  
  # return the scene object (getter)
  def scene()
    @scene
  end
  
  #magic self-java-ifying new call
  def self.new_java
    self.become_java!
    self.new
  end
end