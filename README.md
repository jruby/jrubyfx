JRubyFX
=======
JRubyFX is a pure ruby wrapper for JavaFX 2.2+ with FXML support

Status
------
JRubyFX master should be usable in its current form and able to run simple FXML apps if used properly (see Issues).
FXML syntax in master/1.0 is very different from 0.9 series. Please see the [JRubyFX github wiki](https://github.com/jruby/jrubyfx/wiki/) for more details.

Install
-----
```text
gem install jrubyfx
```

Manual Build and Install
-----
Build is done using rake/gem/bundler/rdoc. You need JRuby >1.7.4 (in 1.9 mode), Java >1.6 with JavaFX 2.2, but Java 7 is recommended. Building native application packages requires JDK 8.

```text
gem install jrubyfx-fxmlloader
rake install
```
Once the gem is installed, just run a ruby file that uses it normally.

**NOTE:** If you don't have JRuby installed as the `ruby` command, use `jruby -S rake` instead of `rake`. If
you are using RVM, this does not apply to you (though make sure you `rvm use jruby`).

**If you are reporting bugs or encountering fxml issues:** please install [master jrubyfx-fxmlloader](https://github.com/byteit101/JRubyFX-FXMLLoader/) instead of from rubygems

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

You can create native application packages and installers. For now, this requires that you have [JDK8 installed](http://jdk8.java.net/download.html), although this may change in the near future. Just pass the `--native` option. The packaging toolkit can only create packages for the OS it is being used on, so for Windows installers you will need to run it on a Windows machine, for OSX installers you will need to run it on a Mac, etc.

In order for the installer to be created, you will need some additional tools installed on your system. For Windows you need either Inno Setup 5 or later for an EXE or [Windows Installer XML (WiX) toolset](http://wix.sourceforge.net/) to generate an MSI. Make sure the WiX toolset's `bin` folder is on the `PATH`.  No special tools are need to generate a DMG, just a recent version of OSX. For linux, the packager uses dpkg-deb to create DEB installers and rpmbuild for RPM.

If you don't want your application to be called "JarBootstrapMain", I highly suggest passing the `--name` option with an appropriate string.

To customize the package, for example to change the icons or license pass the `-v` or `--verbose` option. This will cause the JavaFX packaging tools to enter verbose mode, and provide more details about the process, including (the important part for customization) the location of a temporary folder where the config resources for the build are held and a list of the resources and the role of each. Copy the contents of this tmp folder into a folder in your project directory (the dir you run jrubyfx-jarify from) where the packaging tools will know to look for them. For example, on linux this would be `main_project_dir/package/linux`. On OSX, it is `main_project_dir/package/macosx`. So, if I wanted to use a custom icon, I'd replace the default icon with my own, ensuring it has the same name, and place it inside that linux or macosx folder.  Then run the build again. You can find more information on customizing at the [official Oracle documentation](http://docs.oracle.com/javafx/2/deployment/self-contained-packaging.htm#BCGICFDB).  [This blog post](http://ed4becky.net/homepage/javafx-from-the-trenches-part-1-native-packaging/4/) may also be helpful, as he goes through the process of customizing an app for both Windows and OSX.

The JavaFX tools provide far more options than are available from this tool. You can create your own rake tasks and access them directly, however. See [this article](https://github.com/jruby/jruby/wiki/Packaging-Native-Installers-with-the-JavaFX-Ant-Tasks) in the JRuby wiki.

Example: If my project directory is `Hello`, all my files are in `src`, I have a `dist` folder created for my jar file, my main file is called `HelloWorldApp.rb`, my app's name is "Hello World App", and I want the customization info, the command line would look like this:

```
jrubyfx-jarify src --main src/HelloWorldApp.rb dist/HelloWorldApp.jar --native --name "Hello World App" -v
```

Also note that you can do this in code, see samples/fxml/Demo.rb for the rake task usage.

Samples
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
jruby -I lib samples/test_all_the_samples.rb
```

Several other files that can be used as examples are in the tests/ folder

Creating Application and Controller
-----------------------------------

Require the 'jrubyfx' file/gem, and subclass JRubyFX::Application (and JRubyFX::Controller if you are using FXML).
At the bottom of the file, call _yourFXApplicationClass_.launch().
Override start(stage) in the application. See samples/fxml/Demo.rb for commented FXML example,
or the fils in samples/javafx for non-FXML (programatic JavaFX, but you should really
look into FXML, its better) or see the [Getting Started Guide](https://github.com/jruby/jrubyfx/wiki/Getting-Started) and the Syntax Notes on the [JRubyFX github wiki](https://github.com/jruby/jrubyfx/wiki/)

If you want rdoc, run `rake rdoc`. Please note that there are lots of generated methods and conventions that are not in the RDoc. Please read the Getting Started Guide or the tutorials.

Issues
------
* Use JRubyFX-FxmlLoader's FxmlLoader instead of javafx.fxml.FXMLLoader for maximum Ruby support.
* FXML support in master for very complex documents is untested. Report bugs against JRubyFX-FxmlLoader with the FXML file if it fails.
* You must use the provided JavaFXImpl::Launcher to launch the app (aka: call _yourFXApplicationClass_.launch())
* Errors loading JavaFX are bugs. Please report if you encounter this issue, tell us your platform, OS, and version of JRuby
* Jarify command needs the `jar` executable in your path.
* Any other difficulties are bugs. Please report them

Contact
-------
Find us in #jruby on freenode.

License
-------
Main code is Apache 2.0. See LICENSE.
Some samples in contrib may have other licenses.

Authors
-------
- Patrick Plenefisch (byteit101)
- Thomas E Enebo (enebo)
- Hiro Asari (BanzaiMan or asarih)
- Jeremy Ebler (whitehat101)
- Hiroshi Nakamura (nahi)
- Eric West (e_dub or edubkendo)

