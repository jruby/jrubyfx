=begin
JRubyFXML - Write JavaFX and FXML in Ruby
Copyright (C) 2012 Patrick Plenefisch

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as 
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end


# Update load path to include the JavaFX runtime and fail nicely if we can't find it
begin
  if ENV['JFX_DIR']
    $LOAD_PATH << ENV['JFX_DIR']
  else #should we check for 1.7 vs 1.8? oh well, adding extra paths won't hurt anybody (maybe performance loading)
    $LOAD_PATH << ENV_JAVA["sun.boot.library.path"].gsub(/[\/\\][amdix345678_]+$/, "") # strip i386 or amd64 (including variants). TODO: ARM
  end
  require 'jfxrt.jar'
rescue
  fail "JavaFX runtime not found.  Please install Java 7u4 or newer or set environment variable JAVAFX_DIR to the folder that contains jfxrt.jar"
end

# If you need JavaFX, just include this module. Its sole purpose in life is to
# import all JavaFX stuff, plus a few useful Java classes (like Void)
module JFXImports
  # If something is missing, just java_import it in your code.
  # And then ask us to put it in this list
  java_import *%w{
      Animation
      AnimationTimer
      FadeTransition
      FillTransition
      Interpolator
      KeyFrame
      KeyValue
      ParallelTransition
      PathTransition
      PauseTransition
      RotateTransition
      ScaleTransition
      SequentialTransition
      StrokeTransition
      Timeline
      Transition
      TranslateTransition
    }.map{|i| "javafx.animation.#{i}"}
  java_import \
    'javafx.application.Platform'
  java_import \
    'javafx.beans.property.SimpleDoubleProperty'
    #TODO: import more
  java_import \
    'javafx.beans.value.ChangeListener'
  java_import \
    'javafx.collections.FXCollections'
  java_import \
    'javafx.event.Event',
    'javafx.event.ActionEvent',
    'javafx.event.EventHandler'
  java_import \
    'javafx.fxml.Initializable',
    'javafx.fxml.LoadException'
  java_import \
    'javafx.geometry.HorizontalDirection',
    'javafx.geometry.HPos',
    'javafx.geometry.Insets',
    'javafx.geometry.Orientation',
    'javafx.geometry.Pos',
    'javafx.geometry.Side',
    'javafx.geometry.VerticalDirection',
    'javafx.geometry.VPos'
  java_import *%w{
      Group
      Node
      Parent
      Scene
    }.map{|i| "javafx.scene.#{i}"}
  java_import \
    'javafx.scene.canvas.Canvas'
  java_import \
    'javafx.scene.chart.CategoryAxis',
    'javafx.scene.chart.LineChart',
    'javafx.scene.chart.NumberAxis',
    'javafx.scene.chart.XYChart'
  # TODO: import more of these
  java_import *%w{
      Accordion
      Button
      CheckBox
      CheckBoxTreeItem
      CheckMenuItem
      ChoiceBox
      ColorPicker
      ComboBox
      ContextMenu
      Hyperlink
      Label
      ListCell
      ListView
      Menu
      MenuBar
      MenuButton
      MenuItem
      Pagination
      PasswordField
      PopupControl
      ProgressBar
      ProgressIndicator
      RadioButton
      RadioMenuItem
      ScrollBar
      ScrollPane
      Separator
      SeparatorMenuItem
      Slider
      SplitMenuButton
      SplitPane
      Tab
      TableView
      TabPane
      TextArea
      TextField
      ToggleButton
      ToggleGroup
      ToolBar
      Tooltip
      TreeItem
      TreeView
      ContentDisplay
      OverrunStyle
      SelectionMode
    }.map{|i| "javafx.scene.control.#{i}"}
  java_import *%w{
      Blend
      BlendMode
      Bloom
      BlurType
      DropShadow
      GaussianBlur
      Reflection
      SepiaTone
    }.map{|i| "javafx.scene.effect.#{i}"}
  java_import *%w{
      Image
      ImageView PixelReader
      PixelWriter
    }.map{|i| "javafx.scene.image.#{i}"}
  java_import *%w{
      Clipboard
      ContextMenuEvent
      DragEvent
      GestureEvent
      InputEvent
      InputMethodEvent
      KeyEvent
      Mnemonic
      MouseDragEvent
      MouseEvent
      RotateEvent
      ScrollEvent
      SwipeEvent
      TouchEvent
      ZoomEvent
    }.map{|i| "javafx.scene.input.#{i}"}
  java_import *%w{
      AnchorPane
      BorderPane
      ColumnConstraints
      FlowPane
      GridPane
      HBox
      Priority
      RowConstraints
      StackPane
      TilePane
      VBox
    }.map{|i| "javafx.scene.layout.#{i}"}
  java_import \
    'javafx.scene.media.Media',
    'javafx.scene.media.MediaPlayer',
    'javafx.scene.media.MediaView'
    # TODO: fill this out
  java_import *%w{
      Color
      CycleMethod
      ImagePattern
      LinearGradient
      Paint
      RadialGradient
      Stop
    }.map{|i| "javafx.scene.paint.#{i}"}
  java_import *%w{
      Arc
      ArcTo
      ArcType
      Circle
      ClosePath
      CubicCurve
      CubicCurveTo
      Ellipse
      FillRule
      HLineTo
      Line
      LineTo
      MoveTo
      Path
      PathElement
      Polygon
      Polyline
      QuadCurve
      QuadCurveTo
      Rectangle
      Shape
      StrokeLineCap
      StrokeLineJoin
      StrokeType
      SVGPath
      VLineTo
    }.map{|i| "javafx.scene.shape.#{i}"}
  java_import *%w{
      Font
      FontPosture
      FontSmoothingType
      FontWeight
      Text
      TextAlignment
      TextBoundsType
    }.map{|i| "javafx.scene.text.#{i}"}
  java_import *%w{
      Affine
      Rotate
      Scale
      Shear
      Translate
    }.map{|i| "javafx.scene.transform.#{i}"}
  java_import \
    'javafx.scene.web.WebView'
  java_import *%w{
      DirectoryChooser
      FileChooser
      Modality
      Popup
      PopupWindow
      Screen
      Stage
      StageStyle
      Window
      WindowEvent
    }.map{|i| "javafx.stage.#{i}"}
  java_import \
    'javafx.util.Duration'
  java_import \
    'java.lang.Void'
end
