module JRubyFX
  module Utils
    module CommonConverters
      java_import 'javafx.scene.paint.Color'

      ARG_CONVERTER_SUFFIX = '_arg_converter'
      NAME_TO_COLORS = {
        'black' => Color::BLACK,
        'blue' => Color::BLUE,
        'cyan' => Color::CYAN,
        'cadet_blue' => Color::CADETBLUE,
        'dark_blue' => Color::DARKBLUE,
        'dark_cyan' => Color::DARKCYAN,
        'dark_green' => Color::DARKGREEN,
        'dark_magenta' => Color::DARKMAGENTA,
        'dark_red' => Color::DARKRED,
        'dark_yellow' => Color.web('0xc0c000'),
        'green' => Color::GREEN,
        'light_blue' => Color::LIGHTBLUE,
        'light_cyan' => Color::LIGHTCYAN,
        'light_green' => Color::LIGHTGREEN,
        'light_magenta' => Color.web('0xffc0ff'),
        'light_red' => Color.web('0xffc0c0'),
        'light_yellow' => Color::LIGHTYELLOW,
        'magenta' => Color::MAGENTA,
        'red' => Color::RED,
        'silver' => Color::SILVER,
        'yellow' => Color::YELLOW,
        'white' => Color::WHITE,
      }

      ##
      # Generate a converter for a map of supplied values.
      def map_converter(map)
        lambda do |value|
          map.key?(value) ? map[value] : value
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
        self.__send__(:define_method, method_name.to_s + 
                      ARG_CONVERTER_SUFFIX) do |*values|
          converter = converters.find { |e| e.length == values.length }

          # FIXME: Better error reporting on many things which can fail
          i = 0
          values.inject([]) do |s, value|
            conv = converter[i]
            if conv.kind_of? Proc
              s << conv.call(value)
            else
              s << CONVERTERS[converter[i]].call(value)
            end
            i += 1
            s
          end
        end        
      end

      CONVERTERS = {
        :none => lambda { |value|
          value
        },
        :color => lambda { |value|
          new_value = NAME_TO_COLORS[value.to_s]
          new_value ? new_value : value
        },
      }
    end
  end
end
