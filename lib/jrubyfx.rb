require 'java'

# Load built-in JavaFX support or potentially override or define for Java 6
# if you specify JAVAFX_JRE_DIR environment variable.
begin
  $: << ENV['JAVAFX_JRE_DIR'] if ENV['JAVAFX_JRE_DIR']
  $: << ENV_JAVA['sun.boot.library.path']
  require 'jfxrt.jar'
rescue LoadError
  fail <<EOS
Unable to load JavaFX runtime.  Please either use Java 7u4 or higher
or set environment variable JAVAFX_JRE_DIR to specify the directory
where jxfrt.jar can be found.
EOS
end

# FIXME: core_ext could be loaded on demand through dsl API if we only had
# dsl API.
require 'jrubyfx.jar'
require 'jrubyfx/utils/common_utils'
require 'jrubyfx/core_ext/node'
require 'jrubyfx/core_ext/circle'
require 'jrubyfx/core_ext/labeled'
require 'jrubyfx/core_ext/observable_value'
require 'jrubyfx/core_ext/parent'
require 'jrubyfx/core_ext/path'
require 'jrubyfx/core_ext/radial_gradient'
require 'jrubyfx/core_ext/scene'
require 'jrubyfx/core_ext/shape'
require 'jrubyfx/core_ext/stage'
require 'jrubyfx/core_ext/stop'
require 'jrubyfx/core_ext/table_view'
require 'jrubyfx/core_ext/timeline'
require 'jrubyfx/core_ext/xy_chart'
require 'jrubyfx/core_ext/border_pane'

module JRubyFX
  java_import 'javafx.animation.FadeTransition'
  java_import 'javafx.animation.Interpolator'
  java_import 'javafx.animation.KeyFrame'
  java_import 'javafx.animation.KeyValue'
  java_import 'javafx.animation.ParallelTransition'
  java_import 'javafx.animation.RotateTransition'
  java_import 'javafx.animation.ScaleTransition'
  java_import 'javafx.animation.Timeline'
  java_import 'javafx.application.Platform'
  java_import 'javafx.beans.property.SimpleDoubleProperty'
  java_import 'javafx.beans.value.ChangeListener'
  java_import 'javafx.collections.FXCollections'
  java_import 'javafx.event.EventHandler'
  java_import 'javafx.geometry.HPos'
  java_import 'javafx.geometry.VPos'
  java_import 'javafx.scene.Group'
  java_import 'javafx.scene.Scene'
  java_import 'javafx.scene.chart.CategoryAxis'
  java_import 'javafx.scene.chart.LineChart'
  java_import 'javafx.scene.chart.NumberAxis'
  java_import 'javafx.scene.chart.XYChart'
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
  java_import 'javafx.scene.shape.StrokeType'
  java_import 'javafx.scene.shape.StrokeLineJoin'
  java_import 'javafx.scene.text.Font'
  java_import 'javafx.scene.text.Text'
  java_import 'javafx.scene.transform.Rotate'
  java_import 'javafx.scene.web.WebView'
  java_import 'javafx.stage.Stage'
  java_import 'javafx.stage.StageStyle'
  java_import 'javafx.util.Duration'

  include JRubyFX::Utils::CommonUtils

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
    populate_properties(obj, properties)

    if block_given?
      obj.extend(JRubyFX)
      obj.instance_eval(&block)
    end
    
    obj
  end

  ##
  # Convenience method so anything can safely schedule to run on JavaFX
  # main thread.
  def run_later(&block)
    Platform.run_later &block
  end

  ##
  # Create "build" a new JavaFX instance with the provided class and
  # set properties (e.g. setters) on that new instance plus also invoke
  # any block passed against this new instance.  This also can build a proc
  # or lambda form in which case the return value of the block will be what 
  # is used to set the additional properties on.
  # === Examples
  #
  #   grid = build(GridPane, vgap: 2, hgap: 2) do
  #     set_pref_size(500, 400)
  #     children << location << go << view
  #   end
  #
  #  build(proc { Foo.new }, vgap: 2, hgap: 2)
  #
  def build(klass, *args, &block)
    args, properties = split_args_from_properties(*args)

    obj = if klass.kind_of? Proc
            klass.call(*args)
          else
            klass.new(*attempt_conversion(klass, :new, *args))
          end

    with(obj, properties, &block)
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
  module_function :listener
end
