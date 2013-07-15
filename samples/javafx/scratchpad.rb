#!/usr/bin/env jruby
require 'irb'
require 'jrubyfx'

# FIXME: Add inspect window
# FIXME: Add multi-line text input w/ execute button?
# FIXME: Add command-line history
# FIXME: Add undo removes last executed component addition

class ScratchPad < JRubyFX::Application
  attr_accessor :canvas_binding

  WIDTH = ENV['WIDTH'] || 400
  HEIGHT = ENV['HEIGHT'] || 400

  def evaluate_code(code)
    saved_code_lines << code

    if code == "clear"
      clear_saved_objects
    else
      code = preprocess_code(code)
      ret_value = eval code, canvas_binding
      if ret_value.respond_to?(:parent) && !saved_objects.include?(ret_value)
        saved_objects << ret_value
      end
      ret_value
    end
  end

  def start(stage)
    me = self
    with(stage, title: 'Scratch Path', width: WIDTH, height: HEIGHT) do
      layout_scene(WIDTH, HEIGHT, :white) do
        vbox do
          code_prompt = text_field(prompt_text: "code> ") do
            set_on_key_pressed do |event|
              # FIXME: Experiment...make history a cursor and save current line
              if event.code == KeyCode::UP
                code_prompt.text = me.saved_code_lines[-1]
              end
            end
            set_on_action do |event|
              me.evaluate_code(event.source.text)
            end
          end
          group { me.canvas_binding = binding }
        end
      end
    end.show
  end

  def clear_saved_objects
    saved_objects.each do |object|
      object.parent.children.remove object
    end
  end

  def preprocess_code(code)
    # _ is the last saved object
    code = code.gsub(/\b_\b/, "me.saved_objects[-1]")
    code
  end

  def saved_objects
    @saved_objects ||= []
  end

  def saved_code_lines
    @saved_code_lines ||= []
  end
end

ScratchPad.launch
