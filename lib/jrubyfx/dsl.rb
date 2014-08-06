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

module JRubyFX
  # Defines a nice DSL for building JavaFX applications. Include it in a class for
  # access to the DSL. JRubyFX::Application and JRubyFX::Controller include it already.
  module DSL
    include JRubyFX
    include JRubyFX::FXImports

    # Contains methods to be defined inside all classes that include JRubyFX
    module ClassUtils
      include JRubyFX::FXImports

      ##
      # DEPRECATED: Please include JRubyFX::DSLControl instead of this method.
      #
      # Register your own type for use in the DSL.
      #
      #   class MyFooWidget < Region
      #     #...
      #   end
      #   #...
      #   register_type(MyFooWidget)
      #   register_type(MyFooWidget, "aliased_name")
      #
      #   class MyOtherWidget < Region
      #     register_type
      #   end
      #
      #
      # Note, this also makes it possible to override existing definitions
      # of built-in components.
      #
      def register_type(type=self, name=nil)
        name = type.name.snake_case unless name
        JRubyFX::DSL::NAME_TO_CLASSES[name.to_s] = type
      end
      module_function :register_type
    end

    # When a class includes JRubyFX, extend (add to the metaclass) ClassUtils
    def self.included(mod)
      mod.extend(JRubyFX::DSL::ClassUtils)
      mod.extend(JRubyFX::FXImports)
    end

    #--
    # FIXME: This should be broken up with nice override for each type of
    # fx object so we can manually create static overrides.
    #++
    # The list of snake_case names mapped to full java classes to use for DSL mapping.
    # This list is dynamically generated using the `rake reflect` task.
    require_relative 'dsl_map'

    # List of known overrides for enums.

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
      fixed_name = name.to_s.gsub(/!$/, '')
      clazz = NAME_TO_CLASSES[fixed_name]
      unless clazz
        clazz = NAME_TO_CLASS_NAME[fixed_name]
        clazz = (NAME_TO_CLASSES[fixed_name] = clazz.constantize_by("::")) if clazz
      end

      unless clazz
        @supers = {} unless @supers
        @supers[name] = 0 unless @supers.has_key?(name)
        @supers[name] += 1
        if @supers[name] > 3
          raise "Whoa! method_missing caught infinite loop. Trying to run #{name}(#{args.inspect}) failed. Method not found."
        end
        res = super
        @supers[name] -= 1
        return res
      end

      build(clazz, *args, &block)
    end

    alias :node_method_missing :method_missing

    # Loads the special symbol to enum converter functions into all methods
    # and enums
    def self.write_enum_converter(outf)

      # use reflection to load all enums into all_enums and methods that use them
      # into enum_methods
      mod_list = {
        :methods =>{},
        :all => []
      }
      JRubyFX::DSL::NAME_TO_CLASS_NAME.each do |n,clsz|
        cls = eval(clsz) # TODO: use constantize
        cls.java_class.java_instance_methods.each do |method|
          args = method.argument_types.find_all(&:enum?).tap {|i| mod_list[:all] <<  i }

          # one and only, must be a setter style
          if method.argument_types.length == 1 and (args.length == method.argument_types.length) and !(cls.ancestors[1].public_instance_methods.include? method.name.to_sym)
            mod_list[:methods][cls] = [] unless mod_list[:methods][cls]
            # stuff both method name and the type of the argument in
            mod_list[:methods][cls] << [method.name, JavaUtilities.get_proxy_class(args[0])]
          end
        end if cls.respond_to? :ancestors and cls.ancestors.include? JavaProxy # some are not java classes. ignore those
      end

      require 'yaml'

      child_catcher = {}



      # finally, "override" each method
      mod_list[:methods].each do |clz, method|
        child_catcher[clz.to_s] = "" unless child_catcher[clz.to_s]
        write_enum_method_converter child_catcher, clz, method
      end
      # cleanout and search for colors. TODO: combind with previous
      mod_list = {:methods =>{}, :all => []}
      JRubyFX::DSL::NAME_TO_CLASS_NAME.each do |n,clsz|
        cls = eval(clsz) # TODO: use constantize
        cls.java_class.java_instance_methods.each do |method|
          args = method.argument_types.find_all{|i| JavaUtilities.get_proxy_class(i).ancestors.include? Java::javafx.scene.paint.Paint}

          # one and only, must be a setter style
          if args.length == 1  and !(cls.ancestors[1].public_instance_methods.include? method.name.to_sym) #TODO: multiple args
            mod_list[:methods][cls] = [] unless mod_list[:methods][cls]
            # stuff both method name and the type of the argument in
            mod_list[:methods][cls] << method.name
          end
        end if cls.respond_to? :ancestors and cls.ancestors.include? JavaProxy # some are not java classes. ignore those
      end

      mod_list[:methods].each do |clz, method|
        child_catcher[clz.to_s] = "" unless child_catcher[clz.to_s]
        write_color_method_converter child_catcher, clz, method
      end

      # cleanout and search for events. TODO: combind with previous
      mod_list = {:methods =>{}}
      JRubyFX::DSL::NAME_TO_CLASS_NAME.each do |n,clsz|
        cls = eval(clsz) # TODO: use constantize
        cls.java_class.java_instance_methods.each do |method|
          # one and only, must be a setter style
          if method.name.start_with? "setOn"  and !(cls.ancestors[1].public_instance_methods.include? method.name.to_sym) #TODO: multiple args
            mod_list[:methods][cls] = [] unless mod_list[:methods][cls]
            # stuff both method name and the type of the argument in
            mod_list[:methods][cls] << method.name
          end
        end if cls.respond_to? :ancestors and cls.ancestors.include? JavaProxy # some are not java classes. ignore those
      end

      mod_list[:methods].each do |clz, method|
        child_catcher[clz.to_s] = "" unless child_catcher[clz.to_s]
        write_event_method child_catcher, clz, method
      end

      # load the yaml descriptors

      ydescs = YAML.load_file("#{File.dirname(__FILE__)}/core_ext/exts.yml")

      builders = {add: ->(on, adder){
          "  def add(value)
    #{adder}() << value
  end\n"
        },
        rotate: ->(on){
          "  def rotate(*args)
    transforms << build(Rotate, *args)
  end\n"
        },
        method_missing: ->(on, type) {
          # we must manually call super otherwise it will call super(type)
          "  def method_missing(name, *args, &block)
    super(name, *args, &block).tap do |obj|
      add(obj) if obj.kind_of?(#{type}) && !name.to_s.end_with?('!')
    end
  end\n"
        },
        logical_child: ->(on, prop_name){"  #TODO: logical_child(#{prop_name})\n"},
        logical_children: ->(on, prop_name){"  #TODO: logical_children(#{prop_name})\n"},
        getter_setter: ->(on, name) {
          # FIXME: Is arity of splat the best way to do this?
          "  def #{name}(*r)
    if r.length > 0
      self.#{name} = r[0]
    else
      get_#{name}
    end
  end\n"
        },
        new_converter: ->(on, *args){
          els = 0
          "  def self.new(*args)
    super *JRubyFX::Utils::CommonConverters.convert_args(args, #{args.map{|i|i.map(&:to_sym)}.inspect})
  end\n"
        },
        dsl: ->(on, *args){" "},
      }

      #parse the ydescs
      ydescs.each do |clz, acts|
        acts.each do |mname, arg|
          child_catcher[clz] = "" unless child_catcher[clz]
          lamb = builders[mname.to_sym]
          arg = [arg] unless arg.is_a? Array
          child_catcher[clz] << lamb.call(*([clz] + arg))
        end
      end

      child_catcher.each do |clz, defs|
        next if defs == "" || defs == nil
        # TODO: do we need to include the dsl? is this the fastest way to do it?
        outf<< <<HERDOC
class #{clz}
  include JRubyFX::DSL
#{defs}end
HERDOC
      end
    end

    def self.write_event_method(outf, in_class, jfuncnclasses)
      jfuncnclasses.each do |jfunc, jclass|
        next if jfunc.include? "impl_"
        outf[in_class.to_s] << <<ENDNAIVE
  def #{jfunc.to_s.gsub(/^set/i,'').snake_case}(&block)
    if block_given?
      #{jfunc.to_s} block
    else
      #{jfunc.to_s.gsub(/^set/i,'get')}
    end
  end
ENDNAIVE
      end
    end

    def self.write_enum_method_converter(outf, in_class, jfuncnclasses)
      jfuncnclasses.each do |jfunc, jclass|
        next if jfunc.include? "impl_"
        outf[in_class.to_s] << <<ENDNAIVE
  def #{jfunc.to_s.gsub(/^set/i,'').snake_case}=(rbenum)
    java_send #{jfunc.inspect}, [#{jclass}], JRubyFX::Utils::CommonConverters.parse_ruby_symbols(rbenum, #{jclass})
  end
ENDNAIVE
      end
    end

    def self.write_color_method_converter(outf, in_class, jfuncnclasses)
      jfuncnclasses.each do |jfunc|
        next if jfunc.include? "impl_"
        outf[in_class.to_s] << <<ENDNAIVE
  def #{jfunc.to_s.gsub(/^set/i,'').snake_case}=(value)
    #{jfunc}(JRubyFX::Utils::CommonConverters::CONVERTERS[:color].call(value))
  end
ENDNAIVE
      end
    end

    def self_test_lookup(selector)
      if selector.start_with? "#"
        return (if "##{self.id}" == selector
            self
          else
            nil
          end)
      end
    end

    def logical_lookup(*args)
      unless self.is_a?(Node)
        p self
        p self.to_s
        return self_test_lookup(*args)
      end
      self.lookup(*args) || self.tap do |x|
        return nil unless x.respond_to? :children
        return x.children.map_find{|i| i.logical_lookup(*args)}
      end
    end

    # This loads the entire DSL. Call this immediately after requiring
    # this file, but not inside this file, or it requires itself twice.
    def self.load_dsl
      unless File.size? "#{File.dirname(__FILE__)}/core_ext/precompiled.rb"
        puts "Please run `rake reflect` to generate the converters"
        exit -1
      end
      rt = "#{File.dirname(__FILE__)}/core_ext".sub /\Ajar:/, ""
      Dir.glob("#{rt}/*.rb") do |file|
        require file
      end
    end

    # This loads the entire DSL. Call this immediately after requiring
    # this file, but not inside this file, or it requires itself twice.
    def self.compile_dsl(out)
      JRubyFX::DSL.write_enum_converter out
    end
  end
end
