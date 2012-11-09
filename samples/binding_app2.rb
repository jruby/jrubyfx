require 'jrubyfx'

class BindingApp
  include JRubyFX::DSL

  def start(stage)
    total_label = nil  # forward decl for price listener (defined in scene)

    stage.layout do
      title 'Binding App'
      width 300
      height 250

      # Properties with a total binding specified in terms of them
      tax_rate = simple_double_property
      price = simple_double_property
      price.add(tax_rate.multiply(price)) do
        add_listener do |*_, new_value|
          total_lbl.text = "Total: $#{new_value}"
        end
      end
      
      # Layout the scene
      scene do
        vbox do
          hbox do
            label('Price: ')
            text_field do
              text_property.add_listener do |*_, new_value| 
                price.value = new_value.to_f
              end
            end
          end
          hbox do
            label('Tax rate: ')
            text_field do
              text_property.add_listener do |*_, new_value|
                tax_rate.value = new_value.to_f
              end
            end
          end
          total_label = label('')
        end
      end
    end.show
  end
end

BindingApp.start
