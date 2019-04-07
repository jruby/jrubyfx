require 'spec_helper'

require 'jrubyfx/inspect'

describe "JRubyFX Inspect" do

  context "javafx.scene.shape.Shape" do

    it "javafx.scene.shape.Arc" do
      subject = Java::JavafxSceneShape::Arc.new
      subject.inspect.should match /#<Java::JavafxSceneShape::Arc:0x[0-9a-f]+/
      subject.inspect.should match 'centerX:0.0'
      subject.inspect.should match 'centerY:0.0'
      subject.inspect.should match 'length:0.0'
      subject.inspect.should match 'radiusX:0.0'
      subject.inspect.should match 'radiusY:0.0'
      subject.inspect.should match 'startAngle:0.0'
      subject.inspect.should match 'type:OPEN'
    end

    it "javafx.scene.shape.Circle" do
      subject = Java::JavafxSceneShape::Circle.new
      subject.inspect.should match /#<Java::JavafxSceneShape::Circle:0x[0-9a-f]+/
      subject.inspect.should match 'centerX:0.0'
      subject.inspect.should match 'centerY:0.0'
      subject.inspect.should match 'radius:0.0'
    end

    it "javafx.scene.shape.CubicCurve" do
      subject = Java::JavafxSceneShape::CubicCurve.new
      subject.inspect.should match /#<Java::JavafxSceneShape::CubicCurve:0x[0-9a-f]+/
      subject.inspect.should match 'controlX1:0.0'
      subject.inspect.should match 'controlX2:0.0'
      subject.inspect.should match 'controlY1:0.0'
      subject.inspect.should match 'controlY2:0.0'
      subject.inspect.should match 'startX:0.0'
      subject.inspect.should match 'startY:0.0'
      subject.inspect.should match 'endX:0.0'
      subject.inspect.should match 'endY:0.0'
    end

    it "javafx.scene.shape.Ellipse" do
      subject = Java::JavafxSceneShape::Ellipse.new
      subject.inspect.should match /#<Java::JavafxSceneShape::Ellipse:0x[0-9a-f]+/
      subject.inspect.should match 'centerX:0.0'
      subject.inspect.should match 'centerY:0.0'
      subject.inspect.should match 'radiusX:0.0'
      subject.inspect.should match 'radiusY:0.0'
    end

    it "javafx.scene.shape.Line" do
      subject = Java::JavafxSceneShape::Line.new
      subject.inspect.should match /#<Java::JavafxSceneShape::Line:0x[0-9a-f]+/
      subject.inspect.should match 'endX:0.0'
      subject.inspect.should match 'endY:0.0'
      subject.inspect.should match 'startX:0.0'
      subject.inspect.should match 'startY:0.0'
    end

    it "javafx.scene.shape.Path" do
      subject = Java::JavafxSceneShape::Path.new
      subject.inspect.should match /#<Java::JavafxSceneShape::Path:0x[0-9a-f]+/
      subject.inspect.should match 'fillRule:NON_ZERO'
    end

    it "javafx.scene.shape.Polygon" do
      subject = Java::JavafxSceneShape::Polygon.new
      subject.inspect.should match /#<Java::JavafxSceneShape::Polygon:0x[0-9a-f]+>/
    end

    it "javafx.scene.shape.Polyline" do
      subject = Java::JavafxSceneShape::Polyline.new
      subject.inspect.should match /#<Java::JavafxSceneShape::Polyline:0x[0-9a-f]+>/
    end

    it "javafx.scene.shape.QuadCurve" do
      subject = Java::JavafxSceneShape::QuadCurve.new
      subject.inspect.should match /#<Java::JavafxSceneShape::QuadCurve:0x[0-9a-f]+/
      subject.inspect.should match 'controlX:0.0'
      subject.inspect.should match 'controlY:0.0'
      subject.inspect.should match 'startX:0.0'
      subject.inspect.should match 'startY:0.0'
      subject.inspect.should match 'endX:0.0'
      subject.inspect.should match 'endY:0.0'
    end

    it "javafx.scene.shape.Rectangle" do
      subject = Java::JavafxSceneShape::Rectangle.new
      subject.inspect.should match /#<Java::JavafxSceneShape::Rectangle:0x[0-9a-f]+/
      subject.inspect.should match 'arcWidth:0.0'
      subject.inspect.should match 'arcHeight:0.0'
      subject.inspect.should match 'x:0.0'
      subject.inspect.should match 'y:0.0'
      subject.inspect.should match 'width:0.0'
      subject.inspect.should match 'height:0.0'
    end

    it "javafx.scene.shape.SVGPath" do
      subject = Java::JavafxSceneShape::SVGPath.new
      subject.inspect.should match /#<Java::JavafxSceneShape::SVGPath:0x[0-9a-f]+/
      subject.inspect.should match 'fillRule:NON_ZERO'
      subject.inspect.should match 'content:'
    end

    it "javafx.scene.text.Text" do
      subject = Java::JavafxSceneText::Text.new 'test'
      subject.inspect.should match /#<Java::JavafxSceneText::Text:0x[0-9a-f]+/
      subject.inspect.should match 'text:'
      subject.inspect.should match 'textAlignment:LEFT'
      subject.inspect.should match 'font:'
      subject.inspect.should match 'underline:false'
      subject.inspect.should match 'lineSpacing:0.0'
      subject.inspect.should match 'x:0.0'
      subject.inspect.should match 'y:0.0'
      subject.inspect.should match 'textOrigin:BASELINE'
      subject.inspect.should match 'boundsType:LOGICAL'
      subject.inspect.should match 'wrappingWidth:0.0'
      subject.inspect.should match 'strikethrough:false'
      subject.inspect.should match 'fontSmoothingType:GRAY'
    end

  end

  it "javafx.scene.canvas.Canvas" do
    subject = Java::JavafxSceneCanvas::Canvas.new
    subject.inspect.should match /#<Java::JavafxSceneCanvas::Canvas:0x[0-9a-f]+ width:0\.0 height:0\.0>/
  end

  it "javafx.scene.media.MediaView" do
    subject = Java::JavafxSceneMedia::MediaView.new
    subject.inspect.should match /#<Java::JavafxSceneMedia::MediaView:0x[0-9a-f]+/
    subject.inspect.should match 'x:0.0'
    subject.inspect.should match 'y:0.0'
    subject.inspect.should match 'smooth:true'
    subject.inspect.should match 'fitWidth:0.0'
    subject.inspect.should match 'fitHeight:0.0'
    subject.inspect.should match 'preserveRatio:true'
    subject.inspect.should match 'viewport:'
    subject.inspect.should match 'onError:'
    subject.inspect.should match 'mediaPlayer:'
  end

end
