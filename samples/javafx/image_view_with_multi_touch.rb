#!/usr/bin/env jruby
require 'jrubyfx'

class MultiTouchImageView < Java::javafx::scene::layout::StackPane
  register_type self

  def initialize(image_url)
    super()
    effect drop_shadow(:gaussian, Color.rgb(0, 0, 0, 0.5), 8, 0, 0, 2)
    image_view(image(image_url), smooth: true)

    add_event_handler(ZoomEvent::ZOOM) do |event|
      set_scale_x event.total_zoom_factor
      set_scale_y event.total_zoom_factor
    end

    add_event_handler(RotateEvent::ROTATE) do |event|
      set_rotate event.total_angle
    end
  end
end

class ImageViewWithMultiTouchSample < JRubyFX::Application
  def start(stage)
    pane = nil
    with(stage, title: "Image Viewer") do
      layout_scene(400, 400, :oldlace) do
        pane = border_pane do
					# This exclamation mark means "yes, normally you would add this to the parent,
					# however don't add it, just create a javaFX MenuBar object"
          menu_bar = menu_bar! do
            menu("File") do
              menu_item("Open") do
                set_on_action do
                  file_chooser do
                    file = show_open_dialog(stage)
                    pane.center multi_touch_image_view(file.to_uri.to_s)
                  end
                end
              end
              menu_item("Quit") do
                set_on_action { |event| Platform.exit }
              end
            end
          end
          top menu_bar
        end
      end
      show
    end
  end
end

ImageViewWithMultiTouchSample.launch
