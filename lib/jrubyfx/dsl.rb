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

      ##
      # Register your own type for use in the DSL.
      #
      #   class MyFooWidget < Region
      #     #...
      #   end
      #   #...
      #   register_type(MyFooWidget)
      #   register_type(MyFooWidget, "aliased_name")
      #
      # Note, this also makes it possible to override existing definitions
      # of built-in components.
      #
      def register_type(type, name=nil)
        name = type.name.snake_case unless name
        JRubyFX::DSL::NAME_TO_CLASSES[name.to_s] = type
      end
      module_function :register_type

      ##
      # Define a dual-mode method which acts as both a getter and
      # setter depending on whether it has been supplied an argument
      # or not.
      #
      def getter_setter(name)
        self.class_eval do
          # FIXME: Is arity of splat the best way to do this?
          define_method(name) do |*r|
            if r.length > 0
              set_effect *r
            else
              get_effect
            end
          end
        end
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
              add(obj) if obj.kind_of?(type) && !name.to_s.end_with?('!')
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
      end)

    # List of known overrides for enums.
    ENUM_OVERRIDES = {PathTransition::OrientationType => {:orthogonal_to_tangent => :orthogonal},
      BlendMode => {:src_over => :over, :src_atop => :atop, :color_dodge => :dodge, :color_burn => :burn},
      ContentDisplay => {:graphic_only => :graphic, :text_only => :text},
      BlurType => {:one_pass_box => [:one, :one_pass], :two_pass_box => [:two, :two_pass], :three_pass_box => [:three, :three_pass]},
      Modality => {:window_modal => :window, :application_modal => [:application, :app]}}

    # This is the heart of the DSL. When a method is missing and the name of the
    # method is in the NAME_TO_CLASSES mapping, it calls JRubyFX.build with the
    # Java class. This means that instead of saying
    #   build(JavaClass, hash) { ... }
    # you can say
    #   java_class(hash) { ... }
    #
    # Another major portion of the DSL is the ability to implicitly add new
    # created components to their parent on construction.  There are a few
    # places where this is undesirable.  In order to prevent implicit
    # construction you can add a '!' on the end:
    #   circle!(30)
    # This will construct a Circle but it will not add it into its parent
    # container.  This is useful for specifying clipping regions in particular.
    #
    def method_missing(name, *args, &block)
      clazz = NAME_TO_CLASSES[name.to_s.gsub(/!$/, '')]
      super unless clazz

      build(clazz, *args, &block)
    end

    alias :node_method_missing :method_missing

    # Loads the special symbol to enum converter functions into all methods
    # and enums
    def self.load_enum_converter
      # load overrides
      ENUM_OVERRIDES.each do |cls, overrides|
        JRubyFX::Utils::CommonConverters.set_overrides_for cls, overrides
      end

      # use reflection to load all enums into all_enums and methods that use them
      # into enum_methods
      mod_list = {
        :methods => [],
        :all => []
      }
      JRubyFX::DSL::NAME_TO_CLASSES.each do |n,cls|
        cls.java_class.java_instance_methods.each do |method|
          args = method.argument_types.find_all(&:enum?).tap {|i| mod_list[:all] <<  i }

          # one and only, must be a setter style
          if method.argument_types.length == 1 and (args.length == method.argument_types.length)
            mod_list[:methods] << [method.name, cls]
          end
        end if cls.respond_to? :ancestors and cls.ancestors.include? JavaProxy # some are not java classes. ignore those
      end

      # Get the proper class (only need them once)
      mod_list[:all] = mod_list[:all].flatten.uniq.map {|i| JavaUtilities.get_proxy_class(i) }

      # Inject our converter into each enum/class
      mod_list[:all].each do |enum|
        inject_symbol_converter enum
      end

      # finally, "override" each method
      mod_list[:methods].each do |method|
        inject_enum_method_converter *method
      end
    end

    # Adds `parse_ruby_symbols` method to given enum/class to enable symbol conversion
    def self.inject_symbol_converter(jclass)
      # inject!
      class << jclass
        define_method :parse_ruby_symbols do |const|
          # cache it. It could be expensive
          @map = JRubyFX::Utils::CommonConverters.map_enums(self) if @map == nil
          @map[const.to_s] || const
        end
      end
    end

    # "overrides" given function name in given class to parse ruby symbols into
    # proper enums. Rewrites method name as `my_method=` from `setMyMethod`
    def self.inject_enum_method_converter(jfunc, in_class)
      jclass = in_class.java_class.java_instance_methods.find_all {|i| i.name == jfunc.to_s}[0].argument_types[0]
      jclass = JavaUtilities.get_proxy_class(jclass)

      # Define the conversion function as the snake cased assignment, calling parse_ruby
      in_class.class_eval do
        define_method "#{jfunc.to_s.gsub(/^set/i,'').snake_case}=" do |rbenum|
          java_send jfunc, [jclass], jclass.parse_ruby_symbols(rbenum)
        end
      end
    end

    # This loads the entire DSL. Call this immediately after requiring
    # this file, but not inside this file, or it requires itself twice.
    def self.load_dsl
      rt = "#{File.dirname(__FILE__)}/core_ext".sub /\Ajar:/, ""
      Dir.glob("#{rt}/*.rb") do |file|
        require file
      end

      JRubyFX::DSL.load_enum_converter()
    end
  end
end
