JRubyFXML
=======
JRuby wrapper for JavaFX 2.x with FXML support (based on JRubyFX)

BUILD
-----
Build is done using rake/gem. You obviously need JRuby, Java 1.7 (with JavaFX) also.

```text
    rake install
```
Once the gem is installed, just run a ruby file that uses it normally.

SAMPLES
-------

To run sample:

```text
   jruby samples/SimpleFXMLDemo.rb
```

Or, if you are testing edits to jrubyfxml.rb:

```text
   rake run
```

CREATING Application AND Controller
-------

Import jrubyfxml file, and subclass FXMLApplication and FXMLController.
At the bottom of the file, call _yourFxmlApplicationClass_.launch().
Override start(stage) in the application, and initialize(url, resources) in 
the controller. See SimpleFXMLDemo.rb for commented example.

To run sample:

LICENSE
-------
LGPLv3+. See LICENSE.

AUTHORS
-------
- Patrick Plenefisch
- Hiroshi Nakamura (JRubyFX)
- Hiro Asari (JRubyFX)
- Thomas E Enebo (JRubyFX)

