require 'jrubyfx/utils/common_converters'

module JRubyFX
  # Several utilities that have no better place to go
  module Utils
    # Utilities to manage argument properties for build/with
    module CommonUtils
      ##
      # If last argument of the arg list is a hash-like entity (:each_pair)
      # then this strip off last argument and return it as second return
      # value.
      # === Examples:
      #   split_args_from_properties(1, 2, a: 1) #=> [[1,2], {a: 1}]
      #   split_args_from_properties(1, 2) #=> [[1,2], {}]
      #
      def split_args_from_properties(*args)
        if !args.empty? and args.last.respond_to? :each_pair
          properties = args.pop 
        else 
          properties = {}
        end

        return args, properties
      end

      ##
      # Sets the hashmap given on the passed in object as a set of properties, 
      # using converter if necessary.
      #
      def populate_properties(obj, properties)
        properties.each_pair do |name, value|
          obj.send(name.to_s + '=', *attempt_conversion(obj, name, value))
        end
        obj
      end

      ##
      # Attempts to convert given value to JavaFX equvalent, if any, by calling
      # obj.name_CommonConverters::ARG_CONVERTER_SUFFING.
      # See CommonConverters for current conversions
      #
      def attempt_conversion(obj, name, *values)
        converter_method = name.to_s + 
          JRubyFX::Utils::CommonConverters::ARG_CONVERTER_SUFFIX

        # Each type can create their own converter method to coerce things
        # like symbols into real values JavaFX likes.
        if obj.respond_to? converter_method
          values = obj.__send__ converter_method, *values
        end
        values
      end
    end
  end
end
