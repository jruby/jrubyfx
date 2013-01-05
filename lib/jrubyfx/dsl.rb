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

      def enum_map(jfunc)
        # TODO: make this less evil
        jclass = self.java_class.java_instance_methods.find_all {|i| i.name == jfunc.to_s}[0].argument_types[0]
        jclass = eval("Java." + jclass.name)
        
        # Define the conversion function as the snake cased assignment, calling parse_ruby
        self.class_eval do
          define_method "#{jfunc.to_s.snake_case}=" do |rbenum|
            java_send jfunc, [jclass], jclass.parse_ruby(rbenum)
          end
        end
        
        # define parse_ruby as a static method on the enum
        class << jclass
          define_method :parse_ruby do |const|
            # cache it. It could be expensive
            @map = JRubyFX::Utils::CommonConverters.map(self) if @map == nil
            @map[const.to_s] || const
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
