require 'jrubyfx/dsl'

# JRubyFX DSL extensions for JavaFX TableViews
class Java::javafx::scene::control::TableView
  java_import Java::javafx.scene.control.TableColumn

  include JRubyFX::DSL

  include_add :get_columns
  include_method_missing TableColumn
end
