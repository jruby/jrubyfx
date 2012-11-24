require 'jrubyfx'

class BindingApp
  include JRubyFX

  def start(stage)
    with(stage, title: 'Binding App', width: 300, height: 250) do
      rate = double_property
      price = double_property
      total = price.add(rate.multiply(price))
      total.add_change_listener { |obs, oval, nval|
        stage['#total'].text = "Total: $#{nval}"
      }

      layout_scene do
        # Properties with a total binding specified in terms of them      
        vbox do
          hbox do
            label('Price: ')
            text_field do
              text_property.add_change_listener do |obs, oval, nval| 
                price.value = nval.to_f
              end
            end
          end
          hbox do
            label('Tax rate: ')
            text_field do
              text_property.add_change_listener do |obs , oval, nval| 
                rate.value = nval.to_f
              end
            end
          end
          label('', id: 'total')
        end
      end
    end
    stage.show
  end
  
end

BindingApp.start
