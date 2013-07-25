# See: http://docs.oracle.com/javafx/2/binding/jfxpub-binding.htm
require 'jrubyfx'

class MyDoubleBinding < Java::javafx.beans.binding.DoubleBinding
  def initialize(a, b, c, d)
    @a, @b, @c, @d = a, b, c, d
    super()
    bind(@a, @b, @c, @d)
  end

  java_signature 'protected double computeValue()'
  def computeValue
    (@a.get * @b.get) + (@c.get * @d.get)
  end
end

module LowLevelBindingDemo
  import Java::javafx.beans.property.SimpleDoubleProperty
  
  def self.main
    a = SimpleDoubleProperty.new(1)
    b = SimpleDoubleProperty.new(2)
    c = SimpleDoubleProperty.new(3)
    d = SimpleDoubleProperty.new(4)

    db = MyDoubleBinding.new(a, b, c, d)
    puts db.get
    b.value = 3
    puts db.get
  end
end

LowLevelBindingDemo.main

