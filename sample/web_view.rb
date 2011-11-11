require 'java'
require 'jfxrt'
require 'jrubyfx'

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
  MAX = java.lang.Double::MAX_VALUE

  def start(stage)
    url = "http://jruby.org"
    root = Group.new
    view = WebView.new
    view.set_min_size(500, 400)
    view.set_pref_size(500, 400)
    view.engine.load(url)
    location = TextField.new(url)
    go = Button.new("Go")
    go.default_button = true
    action = proc { |event|
      view.engine.load(location.text)
    }
    go.on_action = location.on_action = action
    view.engine.location_property.add_listener(proc { |observable, old_value, new_value|
      location.text = new_value
    })
    grid = GridPane.new
    grid.vgap = 5
    grid.hgap = 5
    GridPane.set_constraints(location, 0, 0, 1, 1, HPos::CENTER, VPos::CENTER, Priority::ALWAYS, Priority::SOMETIMES)
    GridPane.set_constraints(go,       1, 0)
    GridPane.set_constraints(view,     0, 1, 2, 1, HPos::CENTER, VPos::CENTER, Priority::ALWAYS, Priority::ALWAYS)
    grid.column_constraints <<
      ColumnConstraints.new(100, 100, MAX, Priority::ALWAYS, HPos::CENTER, true) <<
      ColumnConstraints.new( 40,  40,  40, Priority::NEVER,  HPos::CENTER, true)
    grid.children << location << go << view
    root.children << grid
    stage.scene = Scene.new(root)
    stage.show
  end
end

JRubyFX.start(WebViewApp.new)
