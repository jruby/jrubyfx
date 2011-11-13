require 'java'
require 'jfxrt'
require 'jrubyfx'

java_import 'javafx.beans.value.ChangeListener'
java_import 'javafx.scene.Group'
java_import 'javafx.scene.Scene'
java_import 'javafx.scene.control.TextField'
java_import 'javafx.scene.control.Button'
java_import 'javafx.scene.layout.Priority'
java_import 'javafx.scene.layout.ColumnConstraints'
java_import 'javafx.scene.layout.GridPane'
java_import 'javafx.scene.web.WebView'
java_import 'javafx.stage.Stage'
java_import 'javafx.geometry.HPos'
java_import 'javafx.geometry.VPos'

# TODO: temporary manual bootstrap
java_import 'org.jruby.ext.jrubyfx.JRubyFX'

class WebViewApp
  DEFAULT_URL = "http://jruby.org"

  def start(stage)
    # nodes
    view = create(WebView) {
      set_min_size(500, 400)
      set_pref_size(500, 400)
      engine.load(DEFAULT_URL)
    }
    location = create(TextField, DEFAULT_URL)
    go = create(Button, 'Go')
    go.default_button = true
    # actions
    location.on_action = go.on_action = proc { |event|
      view.engine.load(location.text)
    }
    view.engine.location_property.add_listener(
      listener(ChangeListener, :changed) { |observable, old_value, new_value|
        location.text = new_value
      }
    )
    # layout
    grid = create(GridPane) {
      vgap = 3
      hgap = 2
      GridPane.set_constraints(location, 0, 0, 1, 1)
      GridPane.set_constraints(go,       1, 0)
      GridPane.set_constraints(view,     0, 1, 1, 1, HPos::LEFT, VPos::CENTER)
      column_constraints <<
        ColumnConstraints.new(100, 460, 500, Priority::ALWAYS, HPos::CENTER, true) <<
        ColumnConstraints.new( 40,  40,  40, Priority::NEVER,  HPos::CENTER, true)
      children << location << go << view
    }
    #
    stage.scene = Scene.new(create(Group) { children << grid })
    stage.show
  end

private

  def create(klass, *args, &block)
    obj = klass.new(*args)
    obj.instance_eval(&block) if block_given?
    obj
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

JRubyFX.start(WebViewApp.new)
