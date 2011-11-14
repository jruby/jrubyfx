require 'java'
require 'jfxrt'
require 'jrubyfx'

# TODO: temporary manual bootstrap
java_import 'org.jruby.ext.jrubyfx.JRubyFX'

module Utils
  def with(obj, keyword_injection = nil, &block)
    if block_given?
      obj.extend(Utils)
      obj.instance_eval(&block)
    end
    if keyword_injection
      keyword_injection.each do |k, v|
        obj.send(k.to_s + '=', v)
      end
    end
    obj
  end

  def build(klass, *args, &block)
    if !args.empty? and Hash === args.last
      keyword_injection = args.pop
    end
    obj = klass.new(*args)
    with(obj, keyword_injection, &block)
  end

  def listener(mod, name, &block)
    obj = Class.new { include mod }.new
    obj.instance_eval do
      @name = name
      @block = block
      def method_missing(msg, *a, &b)
        @block.call(*a, &b) if msg == @name
      end
    end
    obj
  end
end
