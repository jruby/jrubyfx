# Original version is here: http://drdobbs.com/blogs/java/231903245 (BindingEx1)
require 'jrubyfxml'

class TableApp < FXApplication

  def start(stage)
    with(stage, title: 'MyTable') do
      layout_scene do
        group do
          table_view(id: 'table', pref_width: 640, pref_height: 480,
                     column_resize_policy: TableView::CONSTRAINED_RESIZE_POLICY) do
            26.times do |i|
              table_column(min_width: 50, text: (?A.ord + i).chr)
            end
            set_items observable_array_list((1..100).to_a.map(&:to_s))
          end
        end
      end
    end.show
    stage.scene.width_property.add_change_listener do |obs, ovalue, new_value|
      stage['#table'].pref_width = new_value
    end 
    stage.scene.height_property.add_change_listener do |obs, ovalue, new_value|
      stage['#table'].pref_height = new_value
    end 
  end
end

TableApp.launch
