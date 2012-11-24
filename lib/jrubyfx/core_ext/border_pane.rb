class Java::javafx::scene::layout::BorderPane
  include JRubyFX::DSL

  # We don't want to add automatically for this type of pane
  alias :method_missing :node_method_missing

  alias :left :setLeft
  alias :right :setRight
  alias :top :setTop
  alias :bottom :setBottom
  alias :center :setCenter
end
