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

require 'jrubyfxml'

class FXMLApplication < Java.javafx.application.Application
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
  java_import 'javafx.scene.paint.Color'

  def self.in_jar?()
    $LOAD_PATH.inject(false) { |res,i| res || i.include?(".jar!/META-INF/jruby.home/lib/ruby/")}
  end

  def self.launch(*args)
    #call our custom launcher to avoid a java shim
    JavaFXImpl::Launcher.launch_app(self, *args)
  end
  
  def self.load_fxml(filename, ctrlr)
    fx = Java.javafx.fxml.FXMLLoader.new()
    fx.location = if in_jar?
      JRuby.runtime.jruby_class_loader.get_resource(filename)
    else
      Java.java.net.URL.new(
        Java.java.net.URL.new("file:"), "#{File.dirname($0)}/#{filename}") #hope the start file is relative!
    end
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
