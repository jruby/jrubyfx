=begin
JRubyFX - Write JavaFX and FXML in Ruby
Copyright (C) 2013 The JRubyFX Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end
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
