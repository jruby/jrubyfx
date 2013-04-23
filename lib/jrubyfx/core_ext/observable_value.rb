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
require 'jrubyfx'

# JRubyFX DSL extensions for JavaFX ObservableValues
module Java::javafx::beans::value::ObservableValue
  java_import Java::javafx.beans.value.ChangeListener

  ##
  # call-seq:
  #   add_change_listener { |observable, old_value, new_value| block }
  #
  # Add a ruby block to call when the property changes changes
  def add_change_listener(&block)
    java_send :addListener, [ChangeListener.java_class], block
  end

  # FIXME: Not sure how to remove with this API.  We are passing in a proc
  # and we would need to examine each proc to determine which listener to
  # remove.  Probably a way to do it in each derived real class which actually
  # stores the listeners.
end

class Class
  def property_writer(*symbol_names)
    symbol_names.each do |symbol_name|
      send(:define_method, symbol_name.id2name + "=") do |val|
        instance_variable_get("@#{symbol_name}").setValue val
      end
    end
  end
  def property_reader(*symbol_names)
    symbol_names.each do |symbol_name|
      send(:define_method, symbol_name.id2name) do
        instance_variable_get("@#{symbol_name}").getValue
      end
    end
  end
  def property_accessor(*symbol_names)
    property_reader *symbol_names
    property_writer *symbol_names
  end
end
