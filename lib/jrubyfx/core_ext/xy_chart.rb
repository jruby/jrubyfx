require 'jrubyfx/dsl'

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

class Java::javafx::scene::chart::XYChart::Data
  include JRubyFX::DSL
end
