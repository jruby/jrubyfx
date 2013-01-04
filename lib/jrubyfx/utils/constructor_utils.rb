module JRubyFX
  module ConstructorUtils #:nodoc: all
    def split_args_from_properties(*args)
      if !args.empty? and args.last.respond_to? :each_pair
        properties = args.pop 
      else 
        properties = {}
      end

      return args, properties
    end
  end
end
