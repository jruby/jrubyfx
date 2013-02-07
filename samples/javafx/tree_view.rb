#!/usr/bin/env jruby

require 'jrubyfx'

##
# Example showing a tree_view and also how complicated you can tailor
# behavior of a tree_view.  In this example we allow you to drag and drop
# tree_items around.  There are three things you can see in d&d here:
# 1. drag onto other tree item will put it as a child in that tree item
# 2. drag and drop to rearrange items
# 3. drag and drop into another window...it should paste the contents there
#
# This example also allows you to edit your tree and change the text of
# existing contents.  Just double click the item to edit it and hit escape
# to cancel or return to save the new name.
#
class DraggableTreeCell < Java::javafx::scene::control::TreeCell
  include JRubyFX::DSL
  
  SELECTION_PERCENT = 0.25

  class << self
    attr_accessor :drag_item, :drop_type
  end

  def initialize()
    super

    set_on_drag_over do |event|
      if !child_of_target? && !over_self?
        if drop_into_range? y_percentage(event)
          set_effect inner_shadow(offset_x: 1.0)
          self.class.drop_type = :drop_into
        else
          set_effect nil
          self.class.drop_type = :rearrange
        end

        event.accept_transfer_modes :move
      end
    end

    set_on_drag_detected do |event|
      drag_item = tree_item
      if drag_item
        content = clipboard_content { put_string drag_item.value }
        tree_view.start_drag_and_drop(TransferMode::MOVE).set_content content
        self.class.drag_item = drag_item
      end
      event.consume
    end

    set_on_drag_dropped do |event|
      if drag_item && tree_item
        drop_into if drop_type == :drop_into
        rearrange(event) if drop_type == :rearrange

        self.class.drag_item = nil
        event.drop_completed = true
      end

      event.consume
    end

    set_on_drag_exited do |event|
      set_effect nil
    end
  end

  def y_percentage(event)
    y = event.scene_y - local_to_scene(0, 0).y
    y == 0 ? 0 : y / height
  end

  def child_of_target?(parent = tree_item)
    return true if drag_item == parent
    return false if !parent || !parent.parent
    child_of_target?(parent.parent)
  end

  def drop_into
    if !child_of_target? && !over_self?
      drag_item.parent.children.remove(drag_item)
      tree_item.children.add(drag_item)
      tree_item.expanded = true
    end
  end

  def drop_into_range?(percent)
    percent >= SELECTION_PERCENT && percent <= (1-SELECTION_PERCENT)
  end

  def over_self?
    drag_item.parent == tree_item
  end

  def updateItem(item, empty)
    super(item, empty);

    if empty
      set_text nil
      set_graphic nil
    else
      if editing?
        @text_field.text = get_string if @text_field
        set_text nil
        set_graphic @text_field
      else
        set_text get_string
        set_graphic tree_item.graphic
      end
    end
  end

  def drag_item
    self.class.drag_item
  end

  def drop_type
    self.class.drop_type
  end

  def rearrange(event)
    parent = tree_item.parent

    unless parent # root of tree view
      parent = tree_item 
      where = 0
    end

    drag_item.parent.children.remove(drag_item)
    saved_items = parent.children.to_a

    unless where # where already deduced from root being view_item 
      where = saved_items.find_index { |e| e == tree_item } 
      where += 1 if y_percentage(event) > SELECTION_PERCENT
    end

    if (where >= saved_items.size)
      parent.children.add(drag_item)
    else
      parent.children.set(where, drag_item)
      where.upto(saved_items.size - 2) do |i|
        parent.children.set(i+1, saved_items[i])
      end
      parent.children.add(saved_items[saved_items.size - 1])
    end
  end

  #### These methods are part of the code to make the tree editable

  def startEdit
    super
    create_text_field unless @text_field

    set_text nil
    set_graphic @text_field
    @text_field.select_all
  end

  def cancelEdit
    super
    set_text get_item
    set_graphic tree_item.graphic
  end

  def get_string
    get_item ? get_item.to_s : ''
  end

  def create_text_field
    @text_field = TextField.new(get_string)
    @text_field.set_on_key_released do |event|
      if event.code == KeyCode::ENTER
        commitEdit(@text_field.text)
      elsif event.code == KeyCode::ESCAPE
        cancelEdit
      end
    end
  end
end

class SimpleTreeView < JRubyFX::Application
  def start(stage)
    with(stage, width: 300, height: 300, title: 'Simple Tree View') do
      layout_scene(:blue) do
        stack_pane(padding: insets(30)) do
          tree_view(editable: true, cell_factory: proc { DraggableTreeCell.new}) do
            tree_item("Root") do
              5.times {|i| tree_item "File #{i}" }
            end
          end
        end
      end
      show
    end
  end
end

SimpleTreeView.launch
