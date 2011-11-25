require 'jrubyfx'

class WebViewApp
  include JRubyFX

  DEFAULT_URL = "http://jruby.org"

  def start(stage)
    # nodes
    view = build(WebView) {
      engine.load(DEFAULT_URL)
    }
    location = build(TextField, DEFAULT_URL)
    go = build(Button, 'Go', default_button: true)
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
    grid = build(GridPane, vgap: 2, hgap: 2) {
      set_pref_size(500, 400)
      GridPane.set_constraints(location, 0, 0, 1, 1)
      GridPane.set_constraints(go,       1, 0)
      GridPane.set_constraints(view,     0, 1, 2, 1, HPos::LEFT, VPos::CENTER)
      column_constraints <<
        ColumnConstraints.new(100, 100, 999, Priority::ALWAYS, HPos::CENTER, true) <<
        ColumnConstraints.new( 40,  40,  40, Priority::NEVER,  HPos::CENTER, true)
      children << location << go << view
    }
    scene = Scene.new(build(Group) { children << grid })
    scene.width_property.add_listener(
      listener(ChangeListener, :changed) { |observable, old_value, new_value|
        grid.pref_width = new_value
      }
    )
    scene.height_property.add_listener(
      listener(ChangeListener, :changed) { |observable, old_value, new_value|
        grid.pref_height = new_value
      }
    )
    with(stage, title: 'WebView', scene: scene).show
  end
end

WebViewApp.start
