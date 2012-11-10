require 'java'
require 'jrubyfx'

module JRubyFX
  module DSL
    include JRubyFX
    include JRubyFX::Utils::CommonUtils

    # FIXME: This should be broken up with nice override for each type of 
    # fx object so we can manually create static overrides.
    NAME_TO_CLASSES = {
      'scene' => Java::javafx.scene.Scene,
      'group' => Java::javafx.scene.Group,
      # property
      'double_property' => Java::javafx.beans.property.SimpleDoubleProperty,
      # shapes
      'arc' => Java::javafx.scene.shape.Arc,
      'circle' => Java::javafx.scene.shape.Circle,
      'cubic_curve' => Java::javafx.scene.shape.CubicCurve,
      'ellipse' => Java::javafx.scene.shape.Ellipse,
      'line' =>Java::javafx.scene.shape.Line,
      'path' =>Java::javafx.scene.shape.Path,
      'polygon' =>Java::javafx.scene.shape.Polygon,
      'polyline' =>Java::javafx.scene.shape.Polyline,
      'quad_curve' =>Java::javafx.scene.shape.QuadCurve,
      'rectangle' => Java::javafx.scene.shape.Rectangle,
      'svg_path' => Java::javafx.scene.shape.SVGPath,
      'text' => Java::javafx.scene.text.Text,
      # controls
      'accordion' => Java::javafx.scene.control.Accordion,
      'button' => Java::javafx.scene.control.Button,
      'cell' => Java::javafx.scene.control.Cell,
      'check_box' => Java::javafx.scene.control.CheckBox,
      'choice_box' => Java::javafx.scene.control.ChoiceBox,
      'color_picker' => Java::javafx.scene.control.ColorPicker,
      'combo_box' => Java::javafx.scene.control.ComboBox,
      'html_editor' => Java::javafx.scene.web.HTMLEditor,
      'hyperlink' => Java::javafx.scene.control.Hyperlink,
      'label' => Java::javafx.scene.control.Label,
      'list_view' => Java::javafx.scene.control.ListView,
      'menu_bar' => Java::javafx.scene.control.MenuBar,
      'menu_button' => Java::javafx.scene.control.MenuButton,
      'pagination' => Java::javafx.scene.control.Pagination,
      'progress_indicator' => Java::javafx.scene.control.ProgressIndicator,
      'scroll_bar' => Java::javafx.scene.control.ScrollBar,
      'scroll_pane' => Java::javafx.scene.control.ScrollPane,
      'separator' => Java::javafx.scene.control.Separator,
      'slider' => Java::javafx.scene.control.Slider,
      'split_pane' => Java::javafx.scene.control.SplitPane,
      'table_view' => Java::javafx.scene.control.TableView,
      'tab_pane' => Java::javafx.scene.control.TabPane,
      'text_area' => Java::javafx.scene.control.TextArea,
      'text_field' => Java::javafx.scene.control.TextField,
      'titled_pane' => Java::javafx.scene.control.TitledPane,
      'tool_bar' => Java::javafx.scene.control.ToolBar,
      'toggle_button' => Java::javafx.scene.control.ToggleButton,
      'tree_view' => Java::javafx.scene.control.TreeView,
      # paints
      'color' => Java::javafx.scene.paint.Paint,
#      'image_pattern' => Java::javafx.scene.paint.ImagePattern,
      'linear_gradient' => Java::javafx.scene.paint.LinearGradient,
      'radial_gradient' => Java::javafx.scene.paint.RadialGradient,
      'stop' => Java::javafx.scene.paint.Stop,
      # path_elements
      'arc_to' => Java::javafx.scene.shape.ArcTo,
      'close_path' => Java::javafx.scene.shape.ClosePath,
      'cubic_curve_to' => Java::javafx.scene.shape.CubicCurveTo,
      'hline_to' => Java::javafx.scene.shape.HLineTo,
      'line_to' => Java::javafx.scene.shape.LineTo,
      'move_to' => Java::javafx.scene.shape.MoveTo,
      'quad_curve_to' => Java::javafx.scene.shape.QuadCurveTo,
      'vline_to' => Java::javafx.scene.shape.VLineTo,
      # transforms
      'affine' => Java::javafx.scene.transform.Affine,
      'rotate' => Java::javafx.scene.transform.Rotate,
      'scale' => Java::javafx.scene.transform.Scale,
      'shear' => Java::javafx.scene.transform.Shear,
      'translate' => Java::javafx.scene.transform.Translate,
      # region
      'axis' => Java::javafx.scene.chart.Axis,
      'category_axis' => Java::javafx.scene.chart.CategoryAxis,
      'chart' => Java::javafx.scene.chart.Chart,
      'number_axis' => Java::javafx.scene.chart.NumberAxis,
      # layout
      'pane' => Java::javafx.scene.layout.Pane,
      'anchor_pane' => Java::javafx.scene.layout.AnchorPane,
      'border_pane' => Java::javafx.scene.layout.BorderPane,
      'flow_pane' => Java::javafx.scene.layout.FlowPane,
      'grid_pane' => Java::javafx.scene.layout.GridPane,
      'hbox' => Java::javafx.scene.layout.HBox,
      'stack_pane' => Java::javafx.scene.layout.StackPane,
      'tile_pane' => Java::javafx.scene.layout.TilePane,
      'vbox' => Java::javafx.scene.layout.VBox,
      # charts
      'line_chart' => Java::javafx.scene.chart.LineChart,
      'xy_chart' => Java::javafx.scene.chart.XYChart::Series,
      'xy_chart_series' => Java::javafx.scene.chart.XYChart::Series,
      'xy_chart_data' => Java::javafx.scene.chart.XYChart::Data,
      # animation
      'key_frame' => Java::javafx.animation.KeyFrame,
      'key_value' => Java::javafx.animation.KeyValue,
      'timeline' => Java::javafx.animation.Timeline,
    }

    def method_missing(name, *args, &block)
      clazz = NAME_TO_CLASSES[name.to_s]
      super unless clazz

      build(clazz, *args, &block)
    end
  end
end
