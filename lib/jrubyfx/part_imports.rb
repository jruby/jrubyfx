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
  # add OpenJFX support if follow instruction from https://openjfx.io
  if ENV['JFX_DIR'] or
    jre[:version].to_f < 1.8 or
    (jre[:version].to_f == 1.8 and jre[:release] == 'ea' and jre[:build].to_i < 75)
    require 'jfxrt.jar'
  elsif ENV['PATH_TO_FX'] # support the OpenJFX installation as in https://openjfx.io/openjfx-docs/#install-javafx as of 15th May 2020
    Dir.glob(File.join(ENV['PATH_TO_FX'],"*.jar")).each do |jar|
      require jar
    end
  end

  # Java 8 at some point requires explicit toolkit/platform initialization
  # before any controls can be loaded.
  JRubyFX.load_fx
  
  # Attempt to load a javafx class
  Java.javafx.application.Application
rescue  LoadError, NameError
  # Advice user too about the OpenJFX support
  puts "JavaFX runtime not found.  Please install Java 7u6 or newer, set environment variable JFX_DIR to the folder that contains jfxrt.jar or set the environment variable PATH_TO_FX that points to the OpenJFX libraries"
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
    JFX_CLASS_HIERARCHY = {
      :javafx => {
        :animation => %w[Animation AnimationTimer FadeTransition FillTransition Interpolatable Interpolator KeyFrame KeyValue ParallelTransition PathTransition PauseTransition RotateTransition ScaleTransition SequentialTransition StrokeTransition Timeline Transition TranslateTransition],
        :application => %w[Application ConditionalFeature HostServices Platform Preloader],
        :beans => {
          :binding => %w[Binding Bindings BooleanBinding BooleanExpression DoubleBinding DoubleExpression FloatBinding FloatExpression IntegerBinding IntegerExpression ListBinding ListExpression LongBinding LongExpression MapBinding MapExpression NumberBinding NumberExpression NumberExpressionBase ObjectBinding ObjectExpression SetBinding SetExpression StringBinding StringExpression When],
          '' => %w[DefaultProperty InvalidationListener NamedArg Observable WeakInvalidationListener WeakListener],
          :property => {
            :adapter => %w[JavaBeanBooleanProperty JavaBeanBooleanPropertyBuilder JavaBeanDoubleProperty JavaBeanDoublePropertyBuilder JavaBeanFloatProperty JavaBeanFloatPropertyBuilder JavaBeanIntegerProperty JavaBeanIntegerPropertyBuilder JavaBeanLongProperty JavaBeanLongPropertyBuilder JavaBeanObjectProperty JavaBeanObjectPropertyBuilder JavaBeanProperty JavaBeanStringProperty JavaBeanStringPropertyBuilder ReadOnlyJavaBeanBooleanProperty ReadOnlyJavaBeanBooleanPropertyBuilder ReadOnlyJavaBeanDoubleProperty ReadOnlyJavaBeanDoublePropertyBuilder ReadOnlyJavaBeanFloatProperty ReadOnlyJavaBeanFloatPropertyBuilder ReadOnlyJavaBeanIntegerProperty ReadOnlyJavaBeanIntegerPropertyBuilder ReadOnlyJavaBeanLongProperty ReadOnlyJavaBeanLongPropertyBuilder ReadOnlyJavaBeanObjectProperty ReadOnlyJavaBeanObjectPropertyBuilder ReadOnlyJavaBeanProperty ReadOnlyJavaBeanStringProperty ReadOnlyJavaBeanStringPropertyBuilder],
            '' => %w[BooleanProperty BooleanPropertyBase DoubleProperty DoublePropertyBase FloatProperty FloatPropertyBase IntegerProperty IntegerPropertyBase ListProperty ListPropertyBase LongProperty LongPropertyBase MapProperty MapPropertyBase ObjectProperty ObjectPropertyBase Property ReadOnlyBooleanProperty ReadOnlyBooleanPropertyBase ReadOnlyBooleanWrapper ReadOnlyDoubleProperty ReadOnlyDoublePropertyBase ReadOnlyDoubleWrapper ReadOnlyFloatProperty ReadOnlyFloatPropertyBase ReadOnlyFloatWrapper ReadOnlyIntegerProperty ReadOnlyIntegerPropertyBase ReadOnlyIntegerWrapper ReadOnlyListProperty ReadOnlyListPropertyBase ReadOnlyListWrapper ReadOnlyLongProperty ReadOnlyLongPropertyBase ReadOnlyLongWrapper ReadOnlyMapProperty ReadOnlyMapPropertyBase ReadOnlyMapWrapper ReadOnlyObjectProperty ReadOnlyObjectPropertyBase ReadOnlyObjectWrapper ReadOnlyProperty ReadOnlySetProperty ReadOnlySetPropertyBase ReadOnlySetWrapper ReadOnlyStringProperty ReadOnlyStringPropertyBase ReadOnlyStringWrapper SetProperty SetPropertyBase SimpleBooleanProperty SimpleDoubleProperty SimpleFloatProperty SimpleIntegerProperty SimpleListProperty SimpleLongProperty SimpleMapProperty SimpleObjectProperty SimpleSetProperty SimpleStringProperty StringProperty StringPropertyBase],
          },
          :value => %w[ChangeListener ObservableBooleanValue ObservableDoubleValue ObservableFloatValue ObservableIntegerValue ObservableListValue ObservableLongValue ObservableMapValue ObservableNumberValue ObservableObjectValue ObservableSetValue ObservableStringValue ObservableValue ObservableValueBase WeakChangeListener WritableBooleanValue WritableDoubleValue WritableFloatValue WritableIntegerValue WritableListValue WritableLongValue WritableMapValue WritableNumberValue WritableObjectValue WritableSetValue WritableStringValue WritableValue],
        },
        :collections => {
          '' => %w[ArrayChangeListener FXCollections ListChangeListener MapChangeListener ModifiableObservableListBase ObservableArray ObservableArrayBase ObservableFloatArray ObservableIntegerArray ObservableList ObservableListBase ObservableMap ObservableSet SetChangeListener WeakListChangeListener WeakMapChangeListener WeakSetChangeListener],
          :transformation => %w[FilteredList SortedList TransformationList],
        },
        :concurrent => %w[ScheduledService Service Task Worker WorkerStateEvent],
        :css => {
          '' => %w[CompoundSelector CssMetaData CssParser Declaration FontCssMetaData FontFace Match ParsedValue PseudoClass Rule Selector SimpleSelector SimpleStyleableBooleanProperty SimpleStyleableDoubleProperty SimpleStyleableFloatProperty SimpleStyleableIntegerProperty SimpleStyleableLongProperty SimpleStyleableObjectProperty SimpleStyleableStringProperty Size SizeUnits Style Styleable StyleableBooleanProperty StyleableDoubleProperty StyleableFloatProperty StyleableIntegerProperty StyleableLongProperty StyleableObjectProperty StyleableProperty StyleablePropertyFactory StyleableStringProperty StyleClass StyleConverter StyleOrigin Stylesheet],
          :converter => %w[BooleanConverter ColorConverter CursorConverter DeriveColorConverter DeriveSizeConverter DurationConverter EffectConverter EnumConverter FontConverter InsetsConverter LadderConverter PaintConverter ShapeConverter SizeConverter StopConverter URLConverter],
        },
        :embed => {
          :swing => %w[JFXPanel SwingFXUtils SwingNode],
        },
        :event => %w[ActionEvent Event EventDispatchChain EventDispatcher EventHandler EventTarget EventType WeakEventHandler],
        :fxml => %w[FXML FXMLLoader Initializable JavaFXBuilderFactory LoadException LoadListener],
        :geometry => %w[BoundingBox Bounds Dimension2D HorizontalDirection HPos Insets NodeOrientation Orientation Point2D Point3D Pos Rectangle2D Side VerticalDirection VPos],
        :print => %w[Collation JobSettings PageLayout PageOrientation PageRange Paper PaperSource PrintColor Printer PrinterAttributes PrinterJob PrintQuality PrintResolution PrintSides],
        :scene => {
          '' => %w[AccessibleAction AccessibleAttribute AccessibleRole AmbientLight CacheHint Camera Cursor DepthTest Group ImageCursor LightBase Node ParallelCamera Parent PerspectiveCamera PointLight Scene SceneAntialiasing SnapshotParameters SnapshotResult SubScene],
          :canvas => %w[Canvas GraphicsContext],
          :chart => %w[AreaChart Axis BarChart BubbleChart CategoryAxis Chart LineChart NumberAxis PieChart ScatterChart StackedAreaChart StackedBarChart ValueAxis XYChart],
          :control => {
            '' => %w[Accordion Alert Button ButtonBar ButtonBase ButtonType Cell CheckBox CheckBoxTreeItem CheckMenuItem ChoiceBox ChoiceDialog ColorPicker ComboBox ComboBoxBase ContentDisplay ContextMenu Control CustomMenuItem DateCell DatePicker Dialog DialogEvent DialogPane FocusModel Hyperlink IndexedCell IndexRange Label Labeled ListCell ListView Menu MenuBar MenuButton MenuItem MultipleSelectionModel OverrunStyle Pagination PasswordField PopupControl ProgressBar ProgressIndicator RadioButton RadioMenuItem ResizeFeaturesBase ScrollBar ScrollPane ScrollToEvent SelectionMode SelectionModel Separator SeparatorMenuItem SingleSelectionModel Skin SkinBase Skinnable Slider SortEvent Spinner SpinnerValueFactory SplitMenuButton SplitPane Tab TableCell TableColumn TableColumnBase TableFocusModel TablePosition TablePositionBase TableRow TableSelectionModel TableView TabPane TextArea TextField TextFormatter TextInputControl TextInputDialog TitledPane Toggle ToggleButton ToggleGroup ToolBar Tooltip TreeCell TreeItem TreeSortMode TreeTableCell TreeTableColumn TreeTablePosition TreeTableRow TreeTableView TreeView],
            :cell => %w[CheckBoxListCell CheckBoxTableCell CheckBoxTreeCell CheckBoxTreeTableCell ChoiceBoxListCell ChoiceBoxTableCell ChoiceBoxTreeCell ChoiceBoxTreeTableCell ComboBoxListCell ComboBoxTableCell ComboBoxTreeCell ComboBoxTreeTableCell MapValueFactory ProgressBarTableCell ProgressBarTreeTableCell PropertyValueFactory TextFieldListCell TextFieldTableCell TextFieldTreeCell TextFieldTreeTableCell TreeItemPropertyValueFactory],
            :skin => %w[AccordionSkin ButtonBarSkin ButtonSkin CellSkinBase CheckBoxSkin ChoiceBoxSkin ColorPickerSkin ComboBoxBaseSkin ComboBoxListViewSkin ComboBoxPopupControl ContextMenuSkin DateCellSkin DatePickerSkin HyperlinkSkin LabeledSkinBase LabelSkin ListCellSkin ListViewSkin MenuBarSkin MenuButtonSkin MenuButtonSkinBase NestedTableColumnHeader PaginationSkin ProgressBarSkin ProgressIndicatorSkin RadioButtonSkin ScrollBarSkin ScrollPaneSkin SeparatorSkin SliderSkin SpinnerSkin SplitMenuButtonSkin SplitPaneSkin TableCellSkin TableCellSkinBase TableColumnHeader TableHeaderRow TableRowSkin TableRowSkinBase TableViewSkin TableViewSkinBase TabPaneSkin TextAreaSkin TextFieldSkin TextInputControlSkin TitledPaneSkin ToggleButtonSkin ToolBarSkin TooltipSkin TreeCellSkin TreeTableCellSkin TreeTableRowSkin TreeTableViewSkin TreeViewSkin VirtualContainerBase VirtualFlow],
          },
          :effect => %w[Blend BlendMode Bloom BlurType BoxBlur ColorAdjust ColorInput DisplacementMap DropShadow Effect FloatMap GaussianBlur Glow ImageInput InnerShadow Light Lighting MotionBlur PerspectiveTransform Reflection SepiaTone Shadow],
          :image => %w[Image ImageView PixelFormat PixelReader PixelWriter WritableImage WritablePixelFormat],
          :input => %w[Clipboard ClipboardContent ContextMenuEvent DataFormat Dragboard DragEvent GestureEvent InputEvent InputMethodEvent InputMethodHighlight InputMethodRequests InputMethodTextRun KeyCharacterCombination KeyCode KeyCodeCombination KeyCombination KeyEvent Mnemonic MouseButton MouseDragEvent MouseEvent PickResult RotateEvent ScrollEvent SwipeEvent TouchEvent TouchPoint TransferMode ZoomEvent],
          :layout => %w[AnchorPane Background BackgroundFill BackgroundImage BackgroundPosition BackgroundRepeat BackgroundSize Border BorderImage BorderPane BorderRepeat BorderStroke BorderStrokeStyle BorderWidths ColumnConstraints ConstraintsBase CornerRadii FlowPane GridPane HBox Pane Priority Region RowConstraints StackPane TilePane VBox],
          :media => %w[AudioClip AudioEqualizer AudioSpectrumListener AudioTrack EqualizerBand Media MediaErrorEvent MediaException MediaMarkerEvent MediaPlayer MediaView SubtitleTrack Track VideoTrack],
          :paint => %w[Color CycleMethod ImagePattern LinearGradient Material Paint PhongMaterial RadialGradient Stop],
          :robot => %w[Robot],
          :shape => %w[Arc ArcTo ArcType Box Circle ClosePath CubicCurve CubicCurveTo CullFace Cylinder DrawMode Ellipse FillRule HLineTo Line LineTo Mesh MeshView MoveTo ObservableFaceArray Path PathElement Polygon Polyline QuadCurve QuadCurveTo Rectangle Shape Shape3D Sphere StrokeLineCap StrokeLineJoin StrokeType SVGPath TriangleMesh VertexFormat VLineTo],
          :text => %w[Font FontPosture FontSmoothingType FontWeight HitInfo Text TextAlignment TextBoundsType TextFlow],
          :transform => %w[Affine MatrixType NonInvertibleTransformException Rotate Scale Shear Transform TransformChangedEvent Translate],
          :web => %w[HTMLEditor HTMLEditorSkin PopupFeatures PromptData WebEngine WebErrorEvent WebEvent WebHistory WebView],
        },
        :stage => %w[DirectoryChooser FileChooser Modality Popup PopupWindow Screen Stage StageStyle Window WindowEvent],
        :util => {
          '' => %w[Builder BuilderFactory Callback Duration FXPermission Pair StringConverter],
          :converter => %w[BigDecimalStringConverter BigIntegerStringConverter BooleanStringConverter ByteStringConverter CharacterStringConverter CurrencyStringConverter DateStringConverter DateTimeStringConverter DefaultStringConverter DoubleStringConverter FloatStringConverter FormatStringConverter IntegerStringConverter LocalDateStringConverter LocalDateTimeStringConverter LocalTimeStringConverter LongStringConverter NumberStringConverter PercentageStringConverter ShortStringConverter TimeStringConverter],
        },
      },
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
