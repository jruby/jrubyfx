

# OpenJFX

OpenJFX used was pre-built library downloaded from [https://gluonhq.com/products/javafx/](https://gluonhq.com/products/javafx/) as that is referred by [https://openjfx.io](https://openjfx.io) download link.

## Limitation

It is limited by the pre-built OpenJFX class file is compiled using Java version 10 (class file version 54.0) proved by the following error message while trying to run it using OpenJDK 1.8:
```ruby
NameError: cannot link Java class com.sun.javafx.application.PlatformImpl com/sun/javafx/application/PlatformImpl has been compiled by a more recent version of the Java Runtime (class file version 54.0), this version of the Java Runtime only recognizes class file versions up to 52.0
```
Therefore it is only compatible from JDK/JRE 10 and above.

## Changes

The changes only limited to lib/jrubyfx/utils/part\_imports.rb that shall load the OpenJFX library via the environment variable PATH\_TO\_FX as instructed on the [https://openjfx.io](https://openjfx.io/openjfx-docs/#install-javafx) hence if developer followed the instruction, JRubyFX shall be able to work out-of-the-box.

## Testing Result

The patch is tested on two OSes:
* Linux Mint 19.3 Tricia x86\_64, kernel 5.3.0-51-generic
* MacOS Catalina 10.15.4

Java used to run the test is
* (Linux Mint) openjdk version "11.0.7" 2020-04-14 
* (Mac OS) java version "11.0.2" 2019-01-15 LTS 

Ruby used to run the test is
* (Linux Mint) jruby 9.2.9.0 (2.5.7) 2019-10-30 458ad3e OpenJDK 64-Bit Server VM 11.0.7+10-post-Ubuntu-2ubuntu218.04 on 11.0.7+10-post-Ubuntu-2ubuntu218.04 +jit [linux-x86_64]
* (Mac OS) jruby 9.2.0.0 (2.5.0) 2018-05-24 81156a8 Java HotSpot(TM) 64-Bit Server VM 11.0.2+9-LTS on 11.0.2+9-LTS +jit [darwin-x86_64]

The OpenJFX version used in this integration and tested are:
* version 11.0.2 (LTS Public Version)
* version 14.0.1 (Latest Release - as of time of writing)
* version 15 (Early Access Build)

After integrated, the samples/test\_all\_the\_samples.rb was run:

| Demo App                       | version 11.0.2 | version 14.0.1 | version 15 |
| ------------------------------- | ------------- | -------------- | ---------- |
| samples/fxml/Demo.rb           |   Success (Linux & MacOS)   |   Success  (Linux & MacOS)   |  Success  (Linux), halted on Mac (MacOS Note 2)  |
| samples/javafx/binding\_app.rb |   Success (Linux & MacOS)   |   Success  (Linux & MacOS)   |  Success  (Linux), halted on Mac (MacOS Note 2)  | 
| samples/javafx/movie\_app.rb   |  Success  (Linux & MacOS)             |   Success  (Linux & MacOS)            |  Success  (Linux), halted on Mac (MacOS Note 2)  | 
| samples/javafx/movie\_app.rb   |   No movie is shown but using Oracle Java yield the same result. Media key detected.   (Linux & MacOS)            |   No movie is shown but using Oracle Java yield the same result. Media key detected.   (Linux & MacOS)            |  No movie is shown but using Oracle Java yield the same result. Media key detected.   (Linux), halted on Mac (MacOS Note 2) | 
| samples/javafx/tree\_view.rb   |  Success   (Linux & MacOS)            |   Success     (Linux & MacOS)         |  Success   (Linux), halted on Mac (MacOS Note 2)  | 
| samples/javafx/image\_view\_with\_multi\_touch.rb  |   Success            |   Success             |  Success   (Linux), halted on Mac (MacOS Note 2)   | 
| samples/javafx/hello\_jrubyfx.rb  |  Success (Linux & MacOS)            |   Success    (Linux & MacOS)          |  Success  (Linux), halted on Mac (MacOS Note 2)  | 
| samples/javafx/analog\_clock.rb  |  Success (Linux & MacOS)           |  Success  (Linux & MacOS)              |  Success (Linux), halted on Mac (MacOS Note 2)  | 
| samples/javafx/line\_chart.rb  |  Success (Linux & MacOS)             |  Success (Linux & MacOS)              |  Success (Linux), halted on Mac (MacOS Note 2)   | 
| samples/javafx/scratchpad.rb   |  Success (Linux & MacOS)            | Success (Linux & MacOS)               |  Success (Linux), halted on Mac (MacOS Note 2)   | 
| samples/javafx/table\_app.rb   |  Success (Linux & MacOS)            |  Success (Linux & MacOS)              |  Succes (Linux), halted on Mac (MacOS Note 2) | 
| samples/javafx/hello\_devoxx.rb  | Success (Linux & MacOS)             |  Success (Linux & MacOS)              |  Success (Linux), halted on Mac (MacOS Note 2)  | 
| samples/contrib/concurrency\_demos/progress\_bar\_task\_demo.rb  |  Success (Linux & MacOS)             |    Success (Linux & MacOS)            |   Success (Linux), halted on Mac (MacOS Note 2)  | 
| samples/contrib/fxmlexample/FXMLExample.rb  | Success (Linux & MacOS)    |    Success (Linux & MacOS)   |   Success (Linux), halted on Mac (MacOS Note 2) | 
| samples/contrib/fxmltableview/FXMLTableView.rb  |    Success (Linux & MacOS)    |    Success  (Linux & MacOS)          |  Success (Linux), halted on Mac (MacOS Note 2)  | 
| samples/contrib/binding\_examples/binding\_demo.rb  |  Success (Linux & MacOS)  |    Success (Linux & MacOS)           |  Success (Linux), halted on Mac (MacOS Note 2)  | 


Running the ruby files inside tests/

|                   | version 11.0.2 | version 14.0.1 | version 15 |
| ----------------- | -------------- | -------------- | ---------- |
| bindings.rb       |   Success             |    Success            |  Success   |
| bug.rb            |   Success             |   Success             |  Success   |
| ctrl.rb           |   \*note 1             |   \*note 1              |  \*note 1   |
| Hello.rb          |   Success             |   Success             |  Success   |
| js.rb             |   Failed as error in note 2  |  Failed as error in note 2   |  Failed as error in note 2   |
| jsCtrl.rb         |   Failed as error in note 2  |   Failed as error in note 2  |  Failed as error in note 2   |
| jsNoCtrl.rb       |   Failed as error in note 2  |  Failed as error in note 2   |  Failed as error in note 2   |
| noCtrl.rb         |   \*similar to note 1        |    \*similar to note 1       |  \*similar to note 1   |
| rb.rb             |   Failed as error in note 2  |   Failed as error similar to note 2   |  Failed as error similar to note 2   |


\* note 1: Window shown, error shown on console:
  JIT compiled method for file:/jrubyfx-openjfx-patch/jrubyfx/tests/ctrl.fxml FAILED with error:
  can't modify frozen NilClass
  org/jruby/RubyKernel.java:2263:in `instance_variable_set'

\* note 2: Exception in thread "JavaFX Application Thread" java.lang.NoClassDefFoundError: javax/script/ScriptEngineFactory


MacOS Notes:

\* Note 1: Sometimes when exiting the window, the following error shall be prompted:
  Java has been detached already, but someone is still trying to use it at -[GlassViewDelegate dealloc]:/Users/jenkins/workspace/OpenJFX11.0.2-mac/modules/javafx.graphics/src/main/native-glass/mac/GlassViewDelegate.m:198

\* Note 2: On version 15, shall hit exception "xxx.dylib cannot be opened because the developer cannot be verified. macOS cannot verify that this app is free from malware.". Therefore testing halted.
