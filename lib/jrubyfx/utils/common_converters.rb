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
false # Do NOT delete this or it will make RDOC associate the copyright header with JRubyFX module

module JRubyFX
  module Utils
    # Contains conversion utilities to ease Ruby => JavaFX coding
    module CommonConverters
      java_import 'javafx.scene.paint.Color'

      # argument converter method name suffix
      ARG_CONVERTER_SUFFIX = '_arg_converter'
      
      # map of snake_cased colors to JavaFX Colors
      NAME_TO_COLORS = {
        'darkyellow' => Color.web('0xc0c000'),
        'lightmagenta' => Color.web('0xffc0ff'),
        'lightred' => Color.web('0xffc0c0'),
      }.merge(Color.java_class.fields.inject({}) {|final, field|
          final[field.name.downcase] = field.value(nil) # TODO: what is nil supposed to be?
          final
        })

      ##
      # Generate a converter for a map of supplied values.
      def map_converter(map)
        lambda do |value|
          map.key?(value) ? map[value] : value
        end
      end
      
      ##
      # Generate a converter for an enum of the given class
      def enum_converter(enum_class)
        lambda do |value|
          (JRubyFX::Utils::CommonConverters.map_enums(enum_class)[value.to_s] || value)
        end
      end
      
      ##
      # call-seq:
      #   animation_converter_for :property_name, ...
      #   
      # Generates an animation adapter for the given properties so you can specify
      # transformations, etc with a hashmap of from, to values
      # === Examples
      #   animation_converter_for :value
      #   
      #   ...
      #   
      #   _my_type_(value: {0 => 360})
      #
      def animation_converter_for(*prop_names)
        prop_names.each do |prop_name|
          self.__send__(:define_method, prop_name.to_s + "=") do |hash|
            method("from_#{prop_name}=").call hash.keys[0]
            method("to_#{prop_name}=").call hash.values[0]
          end
        end
      end

      ##
      # Allows you to specify you want a converter method created for the
      # specified method where each listed converter corresponds to each
      # argument for that method.  You can have n-arity lists for all
      # matching Java overloads.  This mechanism means you may not always
      # be able to specify all coercions you want.
      # === Examples
      #
      #    coverter_for :new, [:none, :color]
      #
      # This method will define a method on the current class called
      # *new_arg_converter* which will perform no argument coercion on
      # the first argument and a color coercion on the second argument.
      #
      def converter_for(method_name, *converters)
        sheep = lambda do |direct, this, *values|
          converter = converters.find { |e| e.length == values.length }

          # FIXME: Better error reporting on many things which can fail
          i = 0
          values = values.inject([]) do |s, value|
            conv = converter[i]
            if conv.kind_of? Proc
              s << conv.call(value)
            else
              s << CONVERTERS[converter[i]].call(value)
            end
            i += 1
            s
          end
          if direct
            return this.method("set_" + method_name.to_s).call(*values)
          else
            return values
          end
        end
        # define a setter for normal usage
        unless method_name == :new
          self.__send__(:define_method, method_name.to_s + "=") do |*values|
            sheep.call(true, self, *values)
          end
        end
        # define a build/with usage
        self.__send__(:define_method, method_name.to_s + ARG_CONVERTER_SUFFIX) do |*values|
          sheep.call(false, self, *values)
        end
      end

      # Map of different kinds of known converters
      CONVERTERS = {
        :none => lambda { |value|
          value
        },
        :color => lambda { |value|
          new_value = NAME_TO_COLORS[value.to_s.gsub(/_/, "")]
          new_value ? new_value : value
        },
      }
      
      # Store enum mapping overrides
      @overrides = {}
      
      # sets the given overrides for the given class/enum
      def self.set_overrides_for(enum_class,ovr)
        @overrides[enum_class] = ovr
      end
      
      # Given a class, returns a hash of lowercase strings mapped to Java Enums
      def self.map_enums(enum_class)
        res = enum_class.java_class.enum_constants.inject({}) {|res, i| res[i.to_s.downcase] = i; res }
        (@overrides[enum_class]||[]).each do |oldk, newks|
          [newks].flatten.each do |newk|
            res[newk.to_s] = res[oldk.to_s]
          end
        end
        res
      end
    end
  end
end
