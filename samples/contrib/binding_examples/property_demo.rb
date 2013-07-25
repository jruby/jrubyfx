# See: http://docs.oracle.com/javafx/2/binding/jfxpub-binding.htm
require 'jrubyfx'

class Bill
  import javafx.beans.property.SimpleDoubleProperty

  attr_accessor :amount_due
  
  def initialize
    @amount_due = SimpleDoubleProperty.new
  end

  def amount_due
    @amount_due.get
  end

  def amount_due=(value)
    @amount_due.set(value)
  end

  def amount_due_prop
    @amount_due
  end
end

def main
  electric_bill = Bill.new
  electric_bill.amount_due_prop.add_change_listener do |obj, old_val, new_val|
    puts "Electric bill has changed!"
  end
  electric_bill.amount_due = 100.0

  bill1, bill2, bill3 = Bill.new, Bill.new, Bill.new
  total = Java::javafx.beans.binding.Bindings.add(bill1.amount_due_prop.add(
    bill2.amount_due_prop), bill3.amount_due_prop)

  total.add_change_listener do |observable|
    puts "The binding is now invalid"
  end

  # First call makes the binding invalid
  bill1.amount_due = 200.0

  # The binding is now invalid
  bill2.amount_due = 100.0
  bill3.amount_due = 75.0

  # Make the binding valid
  puts total.value

  # Make invalid...
  bill3.amount_due = 150.0

  # Make valid
  puts total.value
end

main
