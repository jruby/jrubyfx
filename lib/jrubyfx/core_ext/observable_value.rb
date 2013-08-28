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
  java_import Java::javafx.beans.InvalidationListener

  ##
  # call-seq:
  #   add_change_listener { |observable, old_value, new_value| block }
  #   add_change_listener { |new_value| block }
  #
  # Add a ruby block to call when the property changes changes
  def add_change_listener(type=nil, &block)
    unless type
      type = :list if self.is_a? Java::javafx::collections::ObservableList
      type = :map if self.is_a? Java::javafx::collections::ObservableMap
    end
    if type == :list || type == :map
      super(&block)
    else
      old_verbose = $VERBOSE
      begin
        $VERBOSE = nil
        addListener(ChangeListener.impl {|name, x, y, z|
            if block.arity == 1
              block.call(z) # just call with new
            else
              block.call(x, y, z)
            end
          })
      ensure
        # always re-set to old value, even if block raises an exception
        $VERBOSE = old_verbose
      end
    end
  end


  ##
  # call-seq:
  #   add_invalidation_listener { |observable| block }
  #
  # Add a ruby block to call when the property invalidates itself (bad property!)
  def add_invalidation_listener(&block)
      old_verbose = $VERBOSE
      begin
        $VERBOSE = nil
        addListener(InvalidationListener.impl {|name, change| block.call(change) })
      ensure
        # always re-set to old value, even if block raises an exception
        $VERBOSE = old_verbose
      end
  end

  # FIXME: Not sure how to remove with this API.  We are passing in a proc
  # and we would need to examine each proc to determine which listener to
  # remove.  Probably a way to do it in each derived real class which actually
  # stores the listeners.
end

# JRubyFX DSL extensions for JavaFX ObservableLists
module Java::javafx::collections::ObservableList
  java_import Java::javafx.collections.ListChangeListener

  ##
  # call-seq:
  #   add_change_listener { |change| block }
  #
  # Add a ruby block to call when the property changes changes
  def add_change_listener(&block)
    old_verbose = $VERBOSE
    begin
      $VERBOSE = nil
      addListener(ListChangeListener.impl {|name, x|block.call(x)})
    ensure
      # always re-set to old value, even if block raises an exception
      $VERBOSE = old_verbose
    end
  end

  def index(x)
    indexOf(x)
  end

  # FIXME: Not sure how to remove with this API.  We are passing in a proc
  # and we would need to examine each proc to determine which listener to
  # remove.  Probably a way to do it in each derived real class which actually
  # stores the listeners.
end

# JRubyFX DSL extensions for JavaFX ObservableMaps
module Java::javafx::collections::ObservableMap
  java_import Java::javafx.collections.MapChangeListener

  ##
  # call-seq:
  #   add_change_listener { |change| block }
  #
  # Add a ruby block to call when the property changes changes
  def add_change_listener(&block)
    old_verbose = $VERBOSE
    begin
      $VERBOSE = nil
      addListener(MapChangeListener.impl {|name, x|block.call(x)})
    ensure
      # always re-set to old value, even if block raises an exception
      $VERBOSE = old_verbose
    end
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
    symbol_names.each do |symbol_name|
      send(:define_method, symbol_name.id2name + "_property") do
        instance_variable_get("@#{symbol_name}")
      end
    end
  end
end
