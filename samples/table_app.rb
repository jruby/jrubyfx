# Original version is here: http://drdobbs.com/blogs/java/231903245 (BindingEx1)

require 'jrubyfx'

class TableApp
  include JRubyFX

  def start(stage)
    # build
    tbl = create_table()
    scene = build(Scene, build(Group) { children << tbl })
    # adjust width/height
    tbl.pref_width = 640
    tbl.pref_height = 480
    scene.width_property.add_listener(
      listener(ChangeListener, :changed) { |observable, old_value, new_value|
        tbl.pref_width = new_value
      }
    )
    scene.height_property.add_listener(
      listener(ChangeListener, :changed) { |observable, old_value, new_value|
        tbl.pref_height = new_value
      }
    )
    # show
    stage.title = 'My Table'
    stage.scene = scene
    stage.show
  rescue
    p $!
  end
    
  def create_table
    data = FXCollections.observableArrayList
    100.times do |idx|
      data << idx.to_s
    end
    tbl = build(TableView, column_resize_policy: TableView::CONSTRAINED_RESIZE_POLICY)
    26.times do |idx|
      tbl.columns << build(TableColumn, min_width: 50, text: (?A.ord + idx).chr)
    end
    tbl.items = data
    tbl
  end
end

TableApp.start
