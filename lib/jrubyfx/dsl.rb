=begin
JRubyFX - Write JavaFX and FXML in Ruby
Copyright (C) 2013 Patrick Plenefisch

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as 
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end
require 'java'
require 'jrubyfx'

module JRubyFX
  # Defines a nice DSL for building JavaFX applications. Include it in a class for
  # access to the DSL. JRubyFX::Application and JRubyFX::Controller include it already.
  module DSL
    include JRubyFX

    # Contains methods to be defined inside all classes that include JRubyFX
    module ClassUtils
      include JRubyFX::FXImports
      
      # Make sure we are added to the mapping. FIXME: is this ever used?
      def register_type(name, type)
        JRubyFX::DSL::NAME_TO_CLASSES[name.to_s] = type
      end
      
      # Lots of DSL extensions use these methods, so define them here so multiple classes can use them
      
      ##
      # call-seq:
      #   include_add
      #   include_add :child_getter
      # 
      # Include a function to add to child list (optional argument) without need
      # to ask for children
      #   include_add
      #   include_add :elements
      #
      def include_add(adder = :get_children)
        self.class_eval do
          define_method :add do |value|
            self.send(adder) << value
          end
        end
      end
      
      ##
      # Adds a function to the class that Adds rotate to transform (manually 
      # added ebcause there is a getRotate on Node already.  Use get_rotate
      # to get property
      def include_rotate
        self.class_eval do
          def rotate(*args) #:nodoc:
            transforms << build(Rotate, *args)
          end
        end
      end
    
      ##
      # Adds a method_missing that automatically calls add if the DSL builds it
      # as the given type.
      # This will defer to node to construct proper object, but will
      # optionally add paths primary child automatically if it is a
      # PathElement.
      def include_method_missing(type)
        self.class_eval do
          define_method :method_missing do |name, *args, &block|
            # we must manually call super otherwise it will call super(type)
            super(name, *args, &block).tap do |obj|
              add(obj) if obj.kind_of? type
            end
          end
        end
      end
    end

    # When a class includes JRubyFX, extend (add to the metaclass) ClassUtils
    def self.included(mod)
      mod.extend(JRubyFX::DSL::ClassUtils)
    end

    #--
    # FIXME: This should be broken up with nice override for each type of 
    # fx object so we can manually create static overrides.
    #++
    # The list of snake_case names mapped to full java classes to use for DSL mapping.
    # This list is dynamically generated using JRubyFX::FXImports::JFX_CLASS_HIERARCHY and
    # Hash.flat_tree_inject.
    NAME_TO_CLASSES = {
      # observable structs
      'observable_array_list' => proc { |*args| FXCollections.observable_array_list(*args) },
      'double_property' => SimpleDoubleProperty,
      'xy_chart_series' => Java::javafx.scene.chart.XYChart::Series,
      'xy_chart_data' => Java::javafx.scene.chart.XYChart::Data,
    }.merge(JFX_CLASS_HIERARCHY.flat_tree_inject(Hash) do |res, name, values|
        # Merge in auto-generated list of classes from all the imported classes
        unless values.is_a? Hash
          values.map do |i|
            # this regexp does snake_casing
            # TODO: Anybody got a better way to get the java class instead of evaling its name?
            res.merge!({i.snake_case.gsub(/(h|v)_(line|box)/, '\1\2') => eval(i)})
          end
          res
        else
          # we are not at a leaf node anymore, merge in previous work
          res.merge!(values)
        end
      end) unless const_defined?(:NAME_TO_CLASSES)

    # This is the heart of the DSL. When a method is missing and the name of the
    # method is in the NAME_TO_CLASSES mapping, it calls JRubyFX.build with the
    # Java class. This means that instead of saying
    #   build(JavaClass, hash) { ... }
    # you can say
    #   java_class(hash) { ... }
    #
    def method_missing(name, *args, &block)
      clazz = NAME_TO_CLASSES[name.to_s]
      super unless clazz
      
      build(clazz, *args, &block)
    end

    alias :node_method_missing :method_missing
  end
end

# we must load it AFTER we finish declaring the DSL class
# This loads all custom DSL overrides that exist
JRubyFX::DSL::NAME_TO_CLASSES.each do |name, cls|
  require_relative "core_ext/#{name}" if File.exists? "#{File.dirname(__FILE__)}/core_ext/#{name}.rb"
end
# observable_value is not in the list, so include it manually
require_relative 'core_ext/observable_value'
