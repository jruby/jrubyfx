require 'jrubyfx/dsl'

# JRubyFX DSL extensions for JavaFX TableViews
class Java::javafx::scene::control::TableView
  java_import Java::javafx.scene.control.TableColumn

  include JRubyFX::DSL

  ##
  # Add to child list without need to ask for children
  def add(value)
    self.get_columns << value
  end

  include_method_missing TableColumn
end
