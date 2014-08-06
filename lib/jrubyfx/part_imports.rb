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

require_relative 'utils'

# Update load path to include the JavaFX runtime and fail nicely if we can't find it
begin
  if ENV['JFX_DIR']
    $LOAD_PATH << ENV['JFX_DIR']
  else #should we check for 1.7 vs 1.8? oh well, adding extra paths won't hurt anybody (maybe performance loading)
    jfx_path = ENV_JAVA["sun.boot.library.path"]
    $LOAD_PATH << if jfx_path.include? ":\\" and !jfx_path.include? "/" # can be tricked, but should work fine
      #windows
      jfx_path.gsub(/\\bin[\\]*$/i, "\\lib")
    else
      # *nix
      jfx_path.gsub(/[\/\\][amdix345678_]+$/, "") # strip i386 or amd64 (including variants). TODO: ARM
    end
  end

  # Java 8 (after ea-b75) and above has JavaFX as part of the normal distib, only require it if we are 7 or below
  jre = ENV_JAVA["java.runtime.version"].match %r{^(?<version>(?<major>\d+)\.(?<minor>\d+))\.(?<patch>\d+)(_\d+)?-?(?<release>ea|u\d)?(-?b(?<build>\d+))?}
  require 'jfxrt.jar' if ENV['JFX_DIR'] or
    jre[:version].to_f < 1.8 or
    (jre[:version].to_f == 1.8 and jre[:release] == 'ea' and jre[:build].to_i < 75)

  # Java 8 at some point requires explicit toolkit/platform initialization
  # before any controls can be loaded.
  JRubyFX.load_fx
  
  # Attempt to load a javafx class
  Java.javafx.application.Application
rescue  LoadError, NameError
  puts "JavaFX runtime not found.  Please install Java 7u6 or newer or set environment variable JFX_DIR to the folder that contains jfxrt.jar "
  puts "If you have Java 7u6 or later, this is a bug. Please report to the issue tracker on github. Include your OS version, 32/64bit, and architecture (x86, ARM, PPC, etc)"
  exit -1
end

module JRubyFX
  # If you need JavaFX, just include this module. Its sole purpose in life is to
  # import all JavaFX stuff, plus a few useful Java classes (like Void)
  module FXImports

    # If something is missing, just java_import it in your code.
    # And then ask us to put it in this list
    ###### IMPORTANT LINE ##### (see rakefile, this is a magic line, don't delete)

    ##
    # This is the list of all classes in JavaFX that most apps should care about.
    # It is a hashmaps with the leafs as arrays. Where a leaf also contains more
    # packages, the hashmap key is "" (empty string). You can utilize this constant
    # to save yourself some typing when adding code for most/all of the JavaFX
    # classes by using either `Hash.flat_tree_inject` from jrubyfx/utils.rb or
    # writing your own traversal function
    #
    JFX_CLASS_HIERARCHY = { :javafx => {
        :animation => %w[Animation AnimationTimer FadeTransition FillTransition Interpolator KeyFrame KeyValue ParallelTransition PathTransition
        PauseTransition RotateTransition ScaleTransition SequentialTransition StrokeTransition Timeline Transition TranslateTransition],
        :application => ['Platform'],
        :beans => {
          :property => %w[SimpleBooleanProperty SimpleDoubleProperty SimpleFloatProperty SimpleIntegerProperty SimpleListProperty SimpleLongProperty SimpleMapProperty SimpleObjectProperty SimpleSetProperty SimpleStringProperty],
          #TODO: import more
          :value => ['ChangeListener']
        },
        :collections => ['FXCollections'],
        :concurrent => %w[Worker Task Service],
        :event => %w[Event ActionEvent EventHandler],
        :fxml => ['Initializable', 'LoadException'],
        :geometry => %w[HorizontalDirection HPos Insets Orientation Pos Rectangle2D Side VerticalDirection VPos],
        :scene => {
          '' => %w[Group Node Parent Scene],
          :canvas => ['Canvas'],
          :chart => %w[AreaChart Axis BarChart BubbleChart CategoryAxis Chart LineChart NumberAxis
          PieChart ScatterChart StackedAreaChart StackedBarChart ValueAxis XYChart],
          :control => %w[Accordion Button Cell CheckBox CheckBoxTreeItem CheckMenuItem ChoiceBox ColorPicker ComboBox ContextMenu Hyperlink
          Label ListCell ListView Menu MenuBar MenuButton MenuItem Pagination PasswordField PopupControl ProgressBar ProgressIndicator RadioButton
          RadioMenuItem ScrollBar ScrollPane Separator SeparatorMenuItem Slider SplitMenuButton SplitPane Tab TableView TableCell TableColumn TabPane TextArea
          TextField TitledPane ToggleButton ToggleGroup ToolBar Tooltip TreeCell TreeItem TreeView ContentDisplay OverrunStyle SelectionMode],
          :effect => %w[Blend BlendMode Bloom BlurType BoxBlur ColorAdjust ColorInput DisplacementMap DropShadow GaussianBlur Glow ImageInput
          InnerShadow Lighting MotionBlur PerspectiveTransform Reflection SepiaTone Shadow],
          :image => %w[Image ImageView PixelReader PixelWriter],
          :input => %w[Clipboard ClipboardContent ContextMenuEvent DragEvent GestureEvent InputEvent InputMethodEvent KeyCode KeyEvent
          Mnemonic MouseButton MouseDragEvent MouseEvent RotateEvent ScrollEvent SwipeEvent TouchEvent TransferMode ZoomEvent],
          :layout => %w[AnchorPane BorderPane ColumnConstraints FlowPane GridPane HBox Pane Priority RowConstraints StackPane TilePane VBox],
          :media => %w[AudioClip AudioEqualizer AudioTrack EqualizerBand Media MediaException
          MediaErrorEvent MediaMarkerEvent MediaPlayer MediaView VideoTrack],
          :paint => %w[Color CycleMethod ImagePattern LinearGradient Paint RadialGradient Stop],
          :shape => %w[Arc ArcTo ArcType Circle ClosePath CubicCurve CubicCurveTo Ellipse FillRule HLineTo Line LineTo MoveTo Path PathElement
          Polygon Polyline QuadCurve QuadCurveTo Rectangle Shape StrokeLineCap StrokeLineJoin StrokeType SVGPath VLineTo],
          :text => %w[Font FontPosture FontSmoothingType FontWeight Text TextAlignment TextBoundsType],
          :transform => %w[Affine Rotate Scale Shear Translate],
          :web => ['WebView', 'HTMLEditor']
        },
        :stage => %w[DirectoryChooser FileChooser Modality Popup PopupWindow Screen Stage StageStyle Window WindowEvent],
        :util => ['Duration']
      }
    }

    $WRITE_OUT << <<HERE
    def const_missing(c)
      if LOCAL_NAME_MAP.has_key? c
        java_import(LOCAL_NAME_MAP[c])[0]
      else
        super
      end
    end

HERE

    # Imports all the listed JavaFX classes
    $WRITE_OUT << "LOCAL_NAME_MAP = { \n  "
    $WRITE_OUT << (JFX_CLASS_HIERARCHY.flat_tree_inject do |res, name, values|
        name = "#{name.to_s}."
        name = "" if name == "."
        res.concat(values.map{|i| "#{name}#{i}"})
      end).map{|x| "#{x.split(".").last.to_sym.inspect} => #{x.inspect}"}.join(",\n  ")
    $WRITE_OUT << "\n}\njava_import 'java.lang.Void'"
  end
end
