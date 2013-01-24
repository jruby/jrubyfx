JRubyFX
=======
JRubyFX is a pure ruby wrapper for JavaFX 2.x with FXML support

Status
------
JRubyFX should be usable in its current form and able to run FXML apps if used properly (see Issues).
The syntax of the FXML side of JRubyFX should be fairly stable, but the JavaFX DSL may change.
At this point in time, no custom ruby controls are supported from FXML, though you
can certainly create them in code.

Build
-----
Build is done using rake/gem/bundler/rdoc. You obviously need JRuby, Java 1.7 (with JavaFX) also.

```text
rake install
```
Once the gem is installed, just run a ruby file that uses it normally.

**NOTE:** If you don't have JRuby installed as the `ruby` command, use `jruby -S rake` instead of `rake`. If
you are using RVM, this does not apply to you (though make sure you `rvm use jruby`).

Creating a Jar
--------------
If you want to distribute your application, you can create a jar with embedded JRuby.
Place all your sources in a folder, and run (replacing paths as appropriate):

```text
jrubyfx-jarify samples/fxml/ --main samples/fxml/Demo.rb Demo.jar
```
This jar can then run anywhere there is a JVM with JavaFX. Note than the main file is
renamed to jar-bootstrap.rb inside the jar. If you need to detect if you are in a jar,
use the JRubyFX::Application.in_jar? method.

Sample
-------

To run sample:

```text
jruby samples/fxml/Demo.rb
```

Or, if you have not installed the gem, or are testing edits to jrubyfx.rb:

```text
rake run main_script=samples/fxml/Demo.rb
```

To run all samples (a nice quick way to make sure you didn't break anything), run:

```text
jruby samples/test_all_the_samples.rb
```

Creating Application and Controller
-----------------------------------

Require the 'jrubyfx' file/gem, and subclass JRubyFX::Application (and JRubyFX::Controller if you are using FXML).
At the bottom of the file, call _yourFXApplicationClass_.launch().
Override start(stage) in the application. See samples/fxml/Demo.rb for commented FXML example, 
or the fils in samples/javafx for non-FXML (programatic JavaFX, but you should really 
look into FXML, its better) or see the Getting Started Guide and the Notes.

If you want rdoc, run `rake rdoc`.

Issues
------
* You must NOT set fx:controller in the FXML files. At the moment, due to JRuby bugs, Java is unable
  to initialize Ruby objects in this way. See Demo.rb for proper way to set the controller (passing it
  in to load_fxml())
* You must use the provided JavaFXImpl::Launcher to launch the app (aka: call _yourFXApplicationClass_.launch()). This is due to the same JRuby bugs
  as above.
* Errors loading jfxrt.jar are bugs. Please report if you encounter this issue, tell us your platform,
  OS, and version of JRuby
* Jarify command needs the `jar` executable in your path.
* Any other difficulties are bugs. Please report them

License
-------
Main code is Apache 2.0. See LICENSE.
Some samples in contrib may have other licenses.

Authors
-------
- Patrick Plenefisch
- Thomas E Enebo
- Hiroshi Nakamura
- Hiro Asari

