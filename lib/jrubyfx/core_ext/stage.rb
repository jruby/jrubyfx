require 'jrubyfx/dsl'

# JRubyFX DSL extensions for the JavaFX Stage
class Java::javafx::stage::Stage
  include JRubyFX::DSL

  ##
  # call-seq:
  #   [name] => node or nil
  #   
  # Returns the item in the scene with the given CSS selector, or nil if not found.
  # === Example
  #   stage['#my_button'] #=> Button
  #   stage['#doesNotExist'] #=> nil
  #
  def [](name)
    get_scene.lookup(name)
  end

  ##
  # call-seq:
  #   layout_scene() { block } => scene
  #   layout_scene(fill) { block } => scene
  #   layout_scene(width, height) { block } => scene
  #   layout_scene(width, height, fill) { block } => scene
  #   layout_scene(width, height, depth_buffer) { block } => scene
  #   layout_scene(hash) { block } => scene
  #   layout_scene(fill, hash) { block } => scene
  #   layout_scene(width, height, hash) { block } => scene
  #   layout_scene(width, height, fill, hash) { block } => scene
  #   layout_scene(width, height, depth_buffer, hash) { block } => scene
  #   layout_scene(fill, hash) => scene
  #   layout_scene(width, height, hash) => scene
  #   layout_scene(width, height, fill, hash) => scene
  #   layout_scene(width, height, depth_buffer, hash) => scene
  #   layout_scene(fill) => scene
  #   layout_scene(width, height) => scene
  #   layout_scene(width, height, fill) => scene
  #   layout_scene(width, height, depth_buffer) => scene
  # 
  # Creates a new scene with given constructor arguments (fill, width, height), 
  # sets all the properties in the hash, and calls the block on the scene.
  # === Examples
  #   layout_scene(fill: "white") do
  #     label("Hello World!")
  #   end
  # 
  #   layout_scene(:white) do
  #     label("Hello World!")
  #   end
  # 
  #   layout_scene do
  #     fill = Color::WHITE
  #     label("Hello World!")
  #   end
  #
  def layout_scene(*args, &code)
    root = code.arity == 1 ? code[node] : instance_eval(&code)
    build(Scene, root, *args).tap { |scene| set_scene scene }
  end

  # Easily change the StageStyle. Valid values are:
  # * :decorated - For a standard window (default)
  # * :undecorated - For a standard window, minus the titlebar
  # * :transparent - For a completely transparent window
  # * :utility - For a toolbar style window (no title, only close)
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
