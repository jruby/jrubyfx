require 'spec_helper'

require 'jrubyfx/utils/inspector'

# Inject the inspector into the base JavaFX class
Java::JavafxScene::Node.send :include, JRubyFX::Utils::Inspector

## Alternate Syntax
# class Java::JavafxSceneShape::Ellipse
#   include JRubyFX::Utils::Inspector
#   inspect_properties radiusX: :radiusX, radiusY: :radiusY
# end

describe JRubyFX::Utils::Inspector do

  subject { Java::JavafxSceneShape::Ellipse.new 1.3, 2, 3.2, 42.0 }

  # Clear the property cache
  before do
    subject.class.instance_variable_set '@inspect_properties', nil
  end

  it "without inspect_properties" do
    subject.inspect.should match /#<Java::JavafxSceneShape::Ellipse:0x[0-9a-f]+ centerX:1\.3 centerY:2\.0 radiusX:3\.2 radiusY:42\.0>/
  end

  it "with blank inspect_properties" do
    Java::JavafxSceneShape::Ellipse.inspect_properties
    subject.inspect.should match /#<Java::JavafxSceneShape::Ellipse:0x[0-9a-f]+>/
  end

  it "with {} inspect_properties" do
    Java::JavafxSceneShape::Ellipse.inspect_properties {}
    subject.inspect.should match /#<Java::JavafxSceneShape::Ellipse:0x[0-9a-f]+>/
  end

  it "with nil inspect_properties" do
    Java::JavafxSceneShape::Ellipse.inspect_properties nil
    subject.inspect.should match /#<Java::JavafxSceneShape::Ellipse:0x[0-9a-f]+ centerX:1\.3 centerY:2\.0 radiusX:3\.2 radiusY:42\.0>/
  end

  it "with basic inspect_properties" do
    Java::JavafxSceneShape::Ellipse.inspect_properties radiusX: :radiusX, radiusY: :radiusY
    subject.inspect.should match /#<Java::JavafxSceneShape::Ellipse:0x[0-9a-f]+ radiusX:3\.2 radiusY:42\.0>/
  end

  it "with basic inspect_properties v2" do
    Java::JavafxSceneShape::Ellipse.inspect_properties foo: :radiusX, bar: :radius_y
    subject.inspect.should match /#<Java::JavafxSceneShape::Ellipse:0x[0-9a-f]+ foo:3\.2 bar:42\.0>/
  end

  it "with formatted inspect_properties" do
    Java::JavafxSceneShape::Ellipse.inspect_properties radius: ["(%g,%g)",:radiusX,:radiusY]
    subject.inspect.should match /#<Java::JavafxSceneShape::Ellipse:0x[0-9a-f]+ radius:\(3\.2,42\)>/
  end

end
