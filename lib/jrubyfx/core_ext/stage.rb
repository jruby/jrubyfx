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
  
  def fxml(source, options={})
    if source.is_a? String
      JRubyFX::Controller.load_fxml_only(source, self, options)
    else
      source.load_into self, options
    end
  end
  
  def fxml=(source)
    fxml(source)
  end
end
