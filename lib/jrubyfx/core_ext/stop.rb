class Java::javafx::scene::paint::Stop
  extend JRubyFX::Utils::CommonConverters

  converter_for :color, [:color]

  class << self
    extend JRubyFX::Utils::CommonConverters

    converter_for :new, [:none, :color]
  end

end
