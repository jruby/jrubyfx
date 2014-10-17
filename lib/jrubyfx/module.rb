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

require_relative 'utils/common_utils'

# This module contains useful methods for defining JavaFX code. Include it in your
# class to use it, and the JRubyFX::FXImports. JRubyFX::Application and JRubyFX::Controller already include it.
module JRubyFX
  include JRubyFX::FXImports
  include JRubyFX::Utils::CommonUtils

  ##
  # call-seq:
  #   with(obj, hash) => obj
  #   with(obj) { block } => obj
  #   with(obj, hash) { block }=> obj
  #
  # Set properties (e.g. setters) on the passed in object plus also invoke
  # any block passed against this object.
  # === Examples
  #
  #   with(grid, vgap: 2, hgap: 2) do
  #     set_pref_size(500, 400)
  #     children << location << go << view
  #   end
  #
  def with(obj, properties = {}, &block)
    puts "Warning: calling 'with' on a nil object from #{caller[0]}" if obj.nil?
    populate_properties(obj, properties)

    if block_given?
      # cache the proxy - http://wiki.jruby.org/Persistence
      obj.class.__persistent__ = true if obj.class.ancestors.include? JavaProxy
      obj.extend(JRubyFX)
      obj.instance_eval(&block)
    end

    obj
  end

  ##
  # call-seq:
  #   run_later { block }
  #
  # Convenience method so anything can safely schedule to run on JavaFX
  # main thread.
  def run_later(&block)
    Java::javafx.application.Platform.run_later &block
  end

  ##
  # call-seq:
  #   build(class) => obj
  #   build(class, hash) => obj
  #   build(class) { block } => obj
  #   build(class, hash) { block } => obj
  #
  # Create "build" a new JavaFX instance with the provided class and
  # set properties (e.g. setters) on that new instance plus also invoke
  # any block passed against this new instance.  This also can build a proc
  # or lambda form in which case the return value of the block will be what
  # is used to set the additional properties on.
  # === Examples
  #
  #   grid = build(GridPane, vgap: 2, hgap: 2) do
  #     set_pref_size(500, 400)
  #     children << location << go << view
  #   end
  #
  #  build(proc { Foo.new }, vgap: 2, hgap: 2)
  #
  def build(klass, *args, &block)
    args, properties = split_args_from_properties(*args)

    obj = if klass.kind_of? Proc
      klass.call(*args)
    else
      klass.new(*attempt_conversion(klass, :new, *args))
    end

    with(obj, properties, &block)
  end

  def self.included(mod)
    mod.extend(JRubyFX::FXMLClassUtils)
    mod.extend(JRubyFX::FXImports)
  end

  module FXMLClassUtils
    def fxml_raw_accessor(symbol_name, type=java::lang::String)
      # TODO: RDoc
      # TODO: somebody clean this up
      # TODO: _reader and _writer
      send(:define_method, symbol_name.id2name.snake_case + "=") do |val|
        instance_variable_set("@#{symbol_name}", val)
      end
      send(:define_method, symbol_name.id2name.snake_case) do
        instance_variable_get("@#{symbol_name}")
      end
      send(:define_method, symbol_name.id2name.snake_case + "GetType") do
        return type.java_class
      end
      camel = symbol_name.id2name
      camel = camel[0].upcase + camel[1..-1]
      send(:define_method, "set" + camel) do |val|
        instance_variable_set("@#{symbol_name}", val)
      end
      send(:define_method, "get" + camel) do
        instance_variable_get("@#{symbol_name}")
      end
      send(:define_method, symbol_name.id2name + "GetType") do
        return type.java_class
      end
    end
    def fxml_accessor(symbol_name,ptype=Java::javafx.beans.property.SimpleStringProperty, type=nil)
      # TODO: RDoc
      # TODO: somebody clean this up
      # TODO: _reader and _writer ? maybe? not?
      pname = symbol_name.id2name + "Property"
      raise "#{ptype} does not inherit from Property." unless ptype.ancestors.include? Java::javafx.beans.property.Property
      unless type
        type = ptype.java_class.java_instance_methods.find_all{|x|x.name == "getValue"}.map{|x|x.return_type}.find_all{|x|x != java.lang.Object.java_class}
        if type.length != 1
          raise "Unknown property type. Please manually supply a type or report this as a bug"
        end
        type = type[0]
      else
        type = type.java_class
      end
      send(:define_method, symbol_name.id2name.snake_case + "=") do |val|
        send(pname).setValue val
      end
      send(:define_method, symbol_name.id2name.snake_case) do
        send(pname).getValue
      end
      send(:define_method, symbol_name.id2name.snake_case + "GetType") do
        return type
      end
      camel = symbol_name.id2name
      camel = camel[0].upcase + camel[1..-1]
      send(:define_method, "set" + camel) do |val|
        send(pname).setValue val
      end
      send(:define_method, "get" + camel) do
        send(pname).getValue
      end
      send(:define_method, symbol_name.id2name + "GetType") do
        return type
      end
      send(:define_method, pname) do
        unless instance_variable_get("@#{symbol_name}")
          instance_variable_set("@#{symbol_name}", ptype.new(self, symbol_name.to_s))
        end
        return instance_variable_get("@#{symbol_name}")
      end
      send(:define_method, pname.snake_case) do
        send(pname)
      end
      add_method_signature pname, [ptype]
      add_method_signature "set" + camel, [java.lang.Void, type]
      add_method_signature "get" + camel, [type]
    end
  end
end
