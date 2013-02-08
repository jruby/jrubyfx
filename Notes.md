# What is this?
This document explains the extra syntactic sugar JRubyFX applies to JavaFX. All Java-style versions always work, this is just special ruby versions of the syntax.

# Enums and constants (including Color)
All JavaFX enums and some constants can be specified as a ruby symbol in setters and constructors. This includes most usages of `Color`.
If you have a constant or enum that is not being converted to a Java enum properly (easy to spot because of `Exception running Application: #<TypeError: cannot convert instance of class org.jruby.RubySymbol to _CLASS_TYPE_>`), it is proabbly a bug and please report it. Note that you must use either the `build` family of functions (`build`, `with`, and DSL _class_type_()), or the snake_cased= version of the setter. setProperty is not overridden in case you want to avoid conversions.

### Example
The following two lines are equivilent

	stage.init_style = :transparent

	stage.init_style = StageStyle::TRANSPARENT

Some Non-enum constants also work:

	timeline.cycle_count = :indefinite

# Duration
Any duration can be specified the java way (`Duration.millis(500)`) or with the monkey-patched Number class:

	500.ms # => Duration.millis(500)
	2.sec # => Duration.seconds(2)
	20.min # => Duration.minutes(20)
	24.hrs # => Duration.hours(24)
	1.hr # => Duration.hours(1)

# Animation
There are three types of animation syntaxes: Java style, multiple style, and single style. Java style is just java, use google for examples.

### Single Style
Animate is a method on the timeline:

	rectangle(x: 10, y: 40, width: 50, height: 50, fill: :red) do
		# note we must save this here as the property is
		# on the rectangle, not the timeline
		translate_x = translateXProperty
		timeline(cycle_count: :indefinite, auto_reverse: true) do
			# animates given property for given timeline
			# marks, over given values
			animate translate_x, 0.sec => 1.sec, 0 => 200
		end.play # play immediatly
	end

### Multiple Style
This is for creating actual transition objects:

	transition = parallel_transition(:node => self) do
		rotate_transition(duration: 5.sec, angle: {0 => 360})
		fade_transition(duration: 5.sec, value: {0.0 => 1.0})
		scale_transition(duration: 5.sec, x: {0.0 => 1.0}, y: {0.0 => 1.0})
	end

Some classes are probbably missing this, please report this.

# Builder methods
Many classes have automatic adding of children, like Panels and Timelines. To utilize, create the object inside one of the builders (build, with, or the DSL _class_name_). See the analog_clock example for details.

# Automatic adding
When you create an object inside another dsl-based method, it will automatically add the object as a child of the first. Ex:

	sp = stack_pane do
		label("hello!")
	end

which is the same as:

	sp = stack_pane()
	sp.children.add(label("hello!"))

However, if you DON'T want this behavior, append a ! to the end of the type. ex:

	border_pane do
		left label!("Hello Left!")
		right label!("Hello Right!")
	end

# FXML Controllers
Due to limitations in JRuby, you cannot place fx:controller attributes in fxml files. Similarly, you can't place ruby-only controls in FXML files, though you can add them later once FXML has loaded.

When creating controllers, `Controller.new` does NOT call `initialize`, as `initialize` is magically called by `FXMLLoader`. Instead, `initialize` has been split up into `initialize_ruby`, which is called by `new`, and `initialize_fxml`, which is called when the fxml has been loaded, and all fx_id's have been bound
