# Original version is here: http://drdobbs.com/blogs/java/231903245 (BindingEx2)

require 'jrubyfx'

class BindingApp
  include JRubyFX

  java_import 'java.lang.Double'

  def initialize
    @tax_rate = SimpleDoubleProperty.new
    @price = SimpleDoubleProperty.new
    @total = @price.add(@tax_rate.multiply(@price))
  end

  def start(stage)
    price_input = TextField.new
    tax_input = TextField.new
    total_lbl = Label.new

    root = build(Group) {
      children << build(VBox) {
        children <<
          build(HBox) { children << build(Label, 'Price: ', text_fill: :red) << price_input } <<
          build(HBox) { children << Label.new('Tax rate: ') << tax_input } <<
          total_lbl
      }
    }

    price_input.text_property.add_listener(
      listener(ChangeListener, :changed) { |ob, old_value, new_value|
        @price.value = Double.new(new_value.to_f)
      }
    )
    tax_input.text_property.add_listener(
      listener(ChangeListener, :changed) { |ob, old_value, new_value|
        @tax_rate.value = Double.new(new_value.to_f)
      }
    )
    @total.add_listener(
      listener(ChangeListener, :changed) { |ob, old_value, new_value|
        total_lbl.text = "Total: $#{new_value}"
      }
    )

    with(stage, title: 'Binding App', width: 300, height: 250, scene: Scene.new(root)).show
  end
end

BindingApp.start
