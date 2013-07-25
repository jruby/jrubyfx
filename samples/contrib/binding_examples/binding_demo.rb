# See: http://docs.oracle.com/javafx/2/binding/jfxpub-binding.htm
require 'jrubyfx'

module HighLevelBindingExample
  import javafx.beans.property.IntegerProperty
  import javafx.beans.property.SimpleIntegerProperty
  import javafx.beans.binding.NumberBinding
  
  def self.main
    num1 = SimpleIntegerProperty.new(1)
    num2 = SimpleIntegerProperty.new(2)
    sum = num1.add(num2)
    puts sum.value
    num1.value = 2
    puts sum.value
  end
end

HighLevelBindingExample.main
