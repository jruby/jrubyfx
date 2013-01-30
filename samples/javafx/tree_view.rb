require 'jrubyfx'

class SimpleTreeView < JRubyFX::Application
  def start(stage)
    with(stage, width: 300, height: 300, title: 'Simple Tree View') do
      layout_scene(:dark_blue) do
        stack_pane do
          tree_view do |t|
            tree_item("root", expanded: true) do |r|
              3.times { |i| tree_item("Item #{i}") }
            end
          end
        end
      end
      show
    end
  end
end

SimpleTreeView.launch
