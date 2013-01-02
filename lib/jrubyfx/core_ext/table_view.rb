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

  ##
  # This will defer to node to construct proper object, but will
  # optionally add paths primary child automatically if it is a
  # PathElement.
  def method_missing(name, *args, &block)
    super.tap do |obj|
      add(obj) if obj.kind_of? TableColumn
    end
  end
end
