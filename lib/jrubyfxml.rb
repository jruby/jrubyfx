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

require 'java'
require 'jruby/core_ext'

#not sure if I like this hackyness, but is nice for just running scripts.
#This is also in the rakefile
require ((Java.java.lang.System.getProperties["java.runtime.version"].match(/^1.7.[0123456789]+.(0[456789]|[1])/) != nil) ?
    Java.java.lang.System.getProperties["sun.boot.library.path"].gsub(/[\/\\][amdix345678_]+$/, "") + "/" : "") + 'jfxrt.jar'

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

  def self.in_jar?()
    $LOAD_PATH.inject(false) { |res,i| res || i.include?(".jar!/META-INF/jruby.home/lib/ruby/")}
  end

  def self.launch(*args)
    #call our custom launcher to avoid a java shim
    JavaFXImpl::Launcher.launch_app(self, *args)
  end
  
  def load_fxml(filename, ctrlr)
    fx = Java.javafx.fxml.FXMLLoader.new()
    fx.location = if self.class.in_jar?
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

# inherit from this class for FXML controllers
class FXMLController
  java_import 'javafx.event.ActionEvent'
  java_import 'java.lang.Void'
  java_import 'java.net.URL'
  java_import 'java.util.ResourceBundle'
  
  include Java.javafx.fxml.Initializable #interfaces
  
  # block construct to define methods and automatically add action events
  def self.on_action(name, &block)
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
  
  def self.fx_id(name)
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

# Due to certain bugs in JRuby 1.7 (namely some newInstance mapping bugs), we
# are forced to re-create the Launcher if we want a pure ruby wrapper
module JavaFXImpl
  
  #JRuby, you make me have to create real classes!
  class FinisherInterface
    include Java.com.sun.javafx.application.PlatformImpl::FinishListener
    
    def initialize(&block)
      @exitBlock = block
    end
    
    def idle(someBoolean)
      @exitBlock.call
    end
    
    def exitCalled()
      @exitBlock.call
    end
  end
  
  class Launcher
    java_import 'java.util.concurrent.atomic.AtomicBoolean'
    java_import 'java.util.concurrent.CountDownLatch'
    java_import 'java.lang.IllegalStateException'
    
    @@launchCalled = AtomicBoolean.new(false) # Atomic boolean go boom on bikini
    
    def self.launch_app(classObj, args=nil)
      #prevent multiple!
      if @@launchCalled.getAndSet(true)
        throw IllegalStateException.new "Application launch must not be called more than once"
      end
      
      begin
        #create a java thread, and run the real worker, and wait till it exits
        count_down_latch = CountDownLatch.new(1)
        thread = Java.java.lang.Thread.new do
          begin
            launch_app_from_thread(classObj)
          rescue => ex
            puts "Exception starting app:"
            p ex
          end
          count_down_latch.countDown #always count down
        end
        thread.name = "JavaFX-Launcher"
        thread.start
        count_down_latch.await
      rescue => ex
        puts "Exception launching JavaFX-Launcher thread:"
        p ex
      end
    end
    
    def self.launch_app_from_thread(classO)
      #platformImpl startup?
      finished_latch = CountDownLatch.new(1)
      Java.com.sun.javafx.application.PlatformImpl.startup do
        finished_latch.countDown
      end
      finished_latch.await
      
      begin
        launch_app_after_platform(classO) #try to launch the app
      rescue => ex
        puts "Error running Application:"
        p ex
      end
      
      #kill the toolkit and exit
      Java.com.sun.javafx.application.PlatformImpl.tkExit
    end
    
    def self.launch_app_after_platform(classO)
      #listeners - for the end
      finished_latch = CountDownLatch.new(1)
      
      # register for shutdown
      Java.com.sun.javafx.application.PlatformImpl.addListener(FinisherInterface.new {
        # this is called when the stage exits
        finished_latch.countDown
      })
    
      app = classO.new
      # do we need to register the params if there are none?
      app.init()
      
      error = false
      #RUN! and hope it works!
      Java.com.sun.javafx.application.PlatformImpl.runAndWait do
        begin
          stage = Java.javafx.stage.Stage.new
          stage.impl_setPrimary(true)
          app.start(stage)
          # no countDown here because its up top... yes I know
        rescue => ex
          puts "Exception running Application:"
          p ex
          error = true
          finished_latch.countDown # but if we fail, we need to unlatch it
        end
      end
        
      #wait for stage exit
      finished_latch.await
      
      # call stop on the interface
      app.stop() unless error
    end
  end
end
