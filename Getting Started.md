Using JRubyFXML
===============
This guide assumes you have basic knowledge of Ruby, and have JRuby 1.7+ installed.

Installing JRubyFXML
--------------------
The first thing you need to do is to install the JRubyFXML gem. Currently it is not on any gem sites, so you must do this manually, but don't worry, its easy.

The first thing we need to install is rake and bundler:

	$ gem install rake bundler

Now we can clone the JRubyFXML sources and install them:

	$ git clone https://github.com/byteit101/JRubyFXML
	$ cd JRubyFXML
	$ rake install

Success! JRubyFXML should be installed now!

Creating your first JRubyFXML application
-----------------------------------------
Lets creating a JavaFX app that has the text "Hello World".
Create a new ruby file (this tutorial will call it `hello.rb`). To use JRubyFXML, we must require it in ruby, so add `require 'jrubyfxml'` at the top of the file. Now since JavaFX was originally for Java, we must create a class that inherits from `javafx.application.Application`, however using it raw is no fun, so inherit from the ruby class `FXApplication` to gain ruby's super power.

	class HelloWorldApp < FXApplication
	end

When we launch this application, JavaFX will call the `start` method, and will pass in a stage that we can put our content on, so lets add that:

	class HelloWorldApp < FXApplication
		def start(stage)
		end
	end

With that stage, we can set the title and size:

	def start(stage)
		stage.title = "Hello World!"
		stage.width = 800
		stage.height = 600
		stage.show()
	end

The `stage.show()` call shows the window. At this point, we can actually see something: the title and window size. Lets launch our app:

	$ ruby hello.rb

Wait, what? Nothing happened! We never actually launched the app, we only defined the class. So add `HelloWorldApp.launch()` to the end of hello.rb, and save. Now if you run it, it will work.

Code listing so far:

	require 'jrubyfxml'
	
	class HelloWorldApp < FXApplication
		def start(stage)
			stage.title = "Hello World!"
			stage.width = 800
			stage.height = 600
			stage.show()
		end
	end
	
	HelloWorldApp.launch

### Adding a bit of text
Cool, we made an empty window, but usually you want something in it. Lets add a label that says "Hello World!". There are three ways to do everything in JRubyFXML: the straight-up Java way, the generic JRubyFXML way, and using a specific DSL (Domain Specific Language). As it sounds like, the Java way is basically copy-paste Java style, and the RubyFXML way is much more elegant, though its good to know both.

#### Creating a Label the Java way

	label = Label.new()
	label.text = "Hello World!"

#### Creating a Label the JRubyFXML way

	label = build(Label, text: "Hello World!")

Whoa! So what does `build` do? Build takes a name of a class (`Label`), creates a new instance, and sets the properties specified on it. Note that I used Ruby 1.9 hash style, `text: "Hello World!"` is identical to the Ruby 1.8 hash of `:text => "Hello World!"`. build can also accept a ruby block to be executed against the object, so we could write the build like:

	label = build(Label) do
		text = "Hello World!"
	end

For this single contrived example, it makes no sense, but for certain things (like animations and file save dialogs), it can save some serious typing.

#### Creating a Label the JRubyFXML DSL way
The DSL is very similar to the `build` way:

	my_label_instance = label(text: "Hello World!")

### Putting the Label on the Stage
Now we can't just put the Label on the Stage, we must put it in a Scene so JavaFX knows how to layout the window.

#### Creating a Scene the Java way
Java always creates a scene of itself. Oh sorry, right:

	scene = Scene.new(label)
	stage.scene = scene

Yes, they could be on the same line like so:

	stage.scene = Scene.new(label)

#### Creating a Scene the DSL way
`build()` has a cousin `with()` that works the exact same way, except it does not create an object, only sets properties on it. Using `with`, we can rewrite the first bit of our function that sets the title and width to:

	def start(stage)
		with(stage, title: "Hello World!", width: 800, height: 600) do
		end
		stage.show()
	end

Fancy, huh? but now that we've used `with`, we can create our scene inside using the DSL:

	def start(stage)
		with(stage, title: "Hello World!", width: 800, height: 600) do
			layout_scene() do
				label(text: "Hello World!")
			end
		end
		stage.show()
	end

If you run it now, you should find a large, white window with the tiny words Hello World! somewhere inside.

Using FXML instead of code
--------------------------
So now lets say your hello world program goes viral, and everyone wants it. You decide to hire a real designer for version 2.0 so it looks nice and professional. Unfortunatly, however, all the layout is in the code, mixed in with the business logic (hmm, just pretend it does awesome computations to show  Hello World). The solution to this is to not put the layout and UI in the code. How? FXML. If you have ever played with .NET, you might have come across WPF, or Windows Presentation Foundation. WPF and JavaFX and very similar in that you can describe the layout of the UI completely declaratively in an xml file (XAML for WPF, FXML for JavaFX). The good thing about this is that both WPF and JavaFX have visual designers for the XML files, which means designers don't have to worry about code!

JavaFX's designer is called JavaFX Scene Builder, and is a free download from the main JavaFX site. Go install it now, and play with it for a bit. 

Done? Good, copy and paste this code into a new file called `Hello.fxml`:

	<?xml version="1.0" encoding="UTF-8"?>

	<?import java.lang.*?>
	<?import java.util.*?>
	<?import javafx.scene.control.*?>
	<?import javafx.scene.layout.*?>
	<?import javafx.scene.paint.*?>
	<?import javafx.scene.text.*?>

	<HBox alignment="CENTER" xmlns:fx="http://javafx.com/fxml">
	  <children>
		<Label text="Hello World!!" underline="true">
		  <font>
		    <Font size="66.0" />
		  </font>
		</Label>
	  </children>
	</HBox>

You can open this file with the Scene Builder and easily edit it. This is similar to the code we had before, with two exceptions: I set the font to a larger size and the label is in a `HBox` that is centered. Most real UI's have some sort of root container to layout the controls such as an `HBox` or a `GridPanel`.

### Using FXML in code
Once you've saved the `Hello.fxml` file in the same directory as `Hello.rb`, lets use the FXML file instead of ruby code to draw the UI. FXML files have controllers to handle events and such. Since this is a simple example, we don't need any events to be handled, so we will use the default `FXController` class. Modify the start method to look like this:

	def start(stage)
		with(stage, title: "Hello World!", width: 800, height: 600)
		FXController.load_fxml("Hello.fxml", stage)
		stage.show()
	end

If you run it now, you should see the large Hello World! text centered in the middle of the window. So whats this about controllers? Read on...

FXML Controllers
----------------
Without interaction, most programs are useless. FXML lets you specify what method should be called when something happens, like a button click or key press. However, in order to call code, it needs to know where its located, which is where the controller comes in. FXML allows multiple types of actions: script actions in embedded javascript, and controller actions in Java/JRuby. If you want to use embedded script actions in javascript, this is not the guide for you; look it up on the internet. 

In the Scene Builder, drag a `Button` onto the surface of the designer, and click the Code section at the bottom of the properties on the right side. This is all the events that it supports. Yes, quite a few! Find the On Action one (it should be the first one), and set its value to `#click`. Lets have it so when we click this button, the "Hello World!" text changes to "You clicked me!".

**NOTE:** If you are using the sample, you won't be able to move the button around, only in front of or after the label. This is how HBox'es work. Don't panic. If you _really_ want absoloute positiong (not really a good idea for proper apps), then use an `AnchorPane`.

**CAUTION:** When setting event handlers in FXML, the name _MUST_ be prefixed with #. If you don't, JavaFX will think it is a script handler instead of a controller handler and complain (and crash your app). This always gets me. Double check your names!

Now, to change the text of the label, we must somehow get access to the label in code. To do this, we must set the `fx:id` property on it (first at the top of the properties pane). Set the `fx:id` value to "helloLabel" and save the FXML file.

**WARNING:** JavaFX has an fx:id property and a normal id property. For JRubyFXML to work, id must not be set (defaults to fx:id), or it must be the same as fx:id.

### Creating our controller
In the code, we need to create a new class that inherits from FXController

	class HelloWorldController < FXController
	end

We need to mark what id's to get, which we can do with `fx_id :name`:

	class HelloWorldController < FXController
		fx_id :helloLabel
	end

And we need to add our event handlers:

	class HelloWorldController < FXController
		fx_id :helloLabel
	
		fx_handler :click do
			@helloLabel.text = "You clicked me!"
		end
	end

Whoa, what is the fx_handler stuff? just think of it like a normal function, but annotated as an event handler:

	(not valid code)
	fx_handler
	def click
		@helloLabel.text = "You clicked me!"
	end

#### Event types
onAction uses the default event type, so you can get away with `fx_handler`. If you have a mouse event, keyboard event, etc, then you need to use `fx_mouse_handler` or `fx_key_handler`, respectively. A full list of handlers is in samples/fxml/Demo.rb, or line 46 to 57 of lib/fxml_controller.rb in the sources for JavaFXML (`:mouse => MouseEvent` means fx_mouse_handler handles the native Java `MouseEvent` events). If there is not a custom override, you can use the full version of `fx_handler`:

	fx_handler :click, ActionEvent do
		@helloLabel.text = "You clicked me!"
	end

#### Using our controller
The only thing needed to use our custom controller is to modify the call to `load_fxml` and use `HelloWorldController` instead of `FXController`

	HelloWorldController.load_fxml("Hello.fxml", stage)

Run it, and click the button.

Code listing for Hello.fxml:

	<?xml version="1.0" encoding="UTF-8"?>

	<?import java.lang.*?>
	<?import java.util.*?>
	<?import javafx.scene.control.*?>
	<?import javafx.scene.layout.*?>
	<?import javafx.scene.paint.*?>
	<?import javafx.scene.text.*?>

	<VBox alignment="CENTER" xmlns:fx="http://javafx.com/fxml">
	  <children>
		<Label fx:id="helloLabel" text="Hello World!" underline="true">
		  <font>
		    <Font size="66.0" />
		  </font>
		</Label>
		<Button mnemonicParsing="false" onAction="#click" prefHeight="49.0" prefWidth="166.0" text="Click Me!">
		  <font>
		    <Font size="23.0" />
		  </font>
		</Button>
	  </children>
	</VBox>

Code listing for Hello.rb:

	require 'jrubyfxml'
	
	class HelloWorldApp < FXApplication
		def start(stage)
			with(stage, title: "Hello World!", width: 800, height: 600)
			HelloWorldController.load_fxml("Hello.fxml", stage)
			stage.show()
		end
	end
	
	class HelloWorldController < FXController
		fx_id :helloLabel
	
		fx_handler :click do
			@helloLabel.text = "You clicked me!"
		end
	end
	
	HelloWorldApp.launch

Now what?
---------
Now you know the basics of FXML and JRubyFXML! If you haven't already, I suggest looking over samples/fxml/Demo.rb for a bit more detail. JavaFX help is all around, and most of it is applicable to JRubyFXML.

### Using the generator
Got a large FXML file with dozens of fx:id's and events? Assuming you only have a FXML file:

    $ rubyfx-generator YourComplex.fxml NewAppFile.rb MyComplexAppName

And just like that, `NewAppFile.rb` contains all the fx_id and fx_*_handler declarations you need! Note that the generator is not well tested on complex documents with obscure handler types, so if it fails, please send the FXML so we can try to fix it.

### JavaFX Scene Builder vs Writing FXML by hand
Note that all instances of using Scene Builder are replacable by writing FXML by hand, and in some cases it is less appropriate or even impossible to use Scene Builder to create FXML files (like changing root element). I HIGHLY suggest you start by using the Scene Builder, and looking at the FXML files it generates. Once you know enough FXML, you get rid of the Scene Builder from your workflow. On the other hand, it is very useful for tweaking values and getting immediate feedback. Unless you are allergic to it, I suggest keeping it around.
