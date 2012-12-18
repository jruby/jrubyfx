JRubyFXML
=======
JRubyFXML is a pure ruby wrapper for JavaFX 2.x with FXML support (based on JRubyFX)

Status
------
JRubyFXML should be usable in its current form and able to run FXML apps if used properly (see Issues).
The syntax of the FXML side of JRubyFXML should be fairly stable, but the JavaFX DSL may change.
At this point in time, no custom ruby controls are supported from FXML, though you
can certainly create them in code.

Build
-----
Build is done using rake/gem/bundler. You obviously need JRuby, Java 1.7 (with JavaFX) also.

```text
rake install
```
Once the gem is installed, just run a ruby file that uses it normally.

Creating a Jar
--------------
If you want to distribute your application, you can create a jar with embedded JRuby.
Place all your sources in the src folder (you can use any folder, but you must pass in src=pattern where
pattern will match the files in the folder), and run (replacing Demo.rb with your main file):

```text
rake jar main_script=samples/fxml/Demo.rb
```
This jar can then run anywhere there is a JVM with JavaFX. Note than the main file is
renamed to jar-bootstrap.rb inside the jar. If you need to detect if you are in a jar,
use the FXApplication.in_jar? method.

Sample
-------

To run sample:

```text
jruby samples/fxml/Demo.rb
```

Or, if you have not installed the gem, or are testing edits to jrubyfxml.rb:

```text
rake run main_script=samples/fxml/Demo.rb
```

Creating Application and Controller
-----------------------------------

Import jrubyfxml file, and subclass FXApplication and FXController.
At the bottom of the file, call _yourFXApplicationClass_.launch().
Override start(stage) in the application, and initialize(url, resources) in 
the controller. See samples/fxml/Demo.rb for commented example.

Issues
------
* You must NOT set fx:controller in the FXML files. At the moment, due to JRuby bugs, Java is unable
  to initialize Ruby objects in this way. See Demo.rb for proper way to set the controller (passing it
  in to load_fxml())
* You must use the provided JavaFXImpl::Launcher to launch the app. This is due to the same JRuby bugs
  as above.
* Errors loading jfxrt.jar are bugs. Please report if you encounter this issue, tell us your platform,
  OS, and version of JRuby
* Any other difficulties are bugs. Please report them

License
-------
Main code is LGPLv3+. See LICENSE.
Some samples may have other licenses.

Authors
-------
- Patrick Plenefisch
- Hiroshi Nakamura (JRubyFX)
- Hiro Asari (JRubyFX)
- Thomas E Enebo (JRubyFX)

