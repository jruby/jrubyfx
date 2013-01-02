require 'jrubyfx/dsl'

# JRubyFX DSL extensions for the JavaFX Stage
class Java::javafx::stage::Stage
  include JRubyFX::DSL

  def [](name)
    get_scene.lookup(name)
  end

  def layout_scene(*args, &code)
    root = code.arity == 1 ? code[node] : instance_eval(&code)
    build(Scene, root, *args).tap { |scene| set_scene scene }
  end

  def init_style=(style)
    java_style = case style
                 when :decorated then
                   StageStyle::DECORATED
                 when :undecorated then
                   StageStyle::UNDECORATED
                 when :transparent then
                   StageStyle::TRANSPARENT
                 when :utility then
                   StageStyle::UTILITY
                 else
                   style # Assume real Java value
                 end
    initStyle(java_style)
  end
end
