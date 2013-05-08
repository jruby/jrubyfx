require 'spec_helper'

class FooControl
  include JRubyFX::DSL

  def initialize(age=18)
    @age = age
  end

  attr_reader :age
  attr_accessor :name
  attr_accessor :size

  register_type self
end

class BarControl
  include JRubyFX::DSL

  attr_reader :list

  def add(value)
    @list ||= []
    @list << value
  end

  register_type self
end

include JRubyFX::DSL

describe JRubyFX::DSL do
  it "should register new types" do
    foo_control.class.should == FooControl
  end

  it "should observe setters and getters as parameters" do
    foo_control(size: 4).size.should == 4
    foo_control(size: 4, name: "Mongo").name.should == "Mongo"
  end

  it "should accept a block" do
    f = foo_control(name: "Congo Jack") do
      self.size = 10
    end

    f.name.should == "Congo Jack"
    f.size.should == 10
  end

  it "should accept initialize arguments before properties" do
    f = foo_control(24, name: "Pip") do
      self.size = 12
    end

    f.age.should == 24
    f.name.should == "Pip"
    f.size.should == 12
  end

  it "should allow explicit block form" do
    f = foo_control do |control|
      control.size = 20
    end

    f.size.should == 20
  end

  it "should add foos to bars" do
    f = nil
    b = bar_control do
      f = foo_control
      add f
    end

    b.list.should == [f]
  end
end
