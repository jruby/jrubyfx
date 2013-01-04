require 'jrubyfx/dsl'

# JRubyFX DSL extensions for JavaFX XYCharts
class Java::javafx::scene::chart::XYChart
  include JRubyFX::DSL

  ##
  # This will defer to node to construct proper object, but will
  # optionally add paths primary child automatically if it is a
  # PathElement.
  def method_missing(name, *args, &block)
    super.tap do |obj|
      data.add(obj) if obj.kind_of? XYChart::Series
    end
  end
end

# JRubyFX DSL extensions for JavaFX XYChart Series
class Java::javafx::scene::chart::XYChart::Series
  include JRubyFX::DSL

  ##
  # This will defer to node to construct proper object, but will
  # optionally add paths primary child automatically if it is a
  # PathElement.
  def method_missing(name, *args, &block)
    super.tap do |obj|
      data.add(obj) if obj.kind_of? XYChart::Data
    end
  end

end

# JRubyFX DSL extensions for JavaFX XYChart Data
class Java::javafx::scene::chart::XYChart::Data
  include JRubyFX::DSL
end
