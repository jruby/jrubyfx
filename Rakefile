task :default => [:jar, :run]

javac = "javac"
jar = "jar"
src_java = "src"
target = "target"
target_classes = "#{target}/classes"
jfx_path = "../javafx/rt/lib"
output_jar = "jrubyfx.jar"

task :loadJFX do
  jversion = Java.java.lang.System.getProperties["java.runtime.version"]
  if jversion.match(/^1.7.[0123456789]+.(0[456789]|[1])/) != nil
    puts "Running Java 7 with JavaFx bundled...adding jar"
    jfx_path = get_jfx_path
  elsif jversion.match(/^1\.[89]\./) != nil || jversion.match(/^[2-9]+\.[09]\./) != nil
    puts "Running Java 8 or later...integrated into Java"
  else #external
    puts "Pre-FX Java assuming javafx rt in #{jfx_path}"
  end
end

task :clean do
  rm_rf target
  rm_rf "lib/#{output_jar}"
end
task :build => :loadJFX do
  mkdir_p target_classes
  # i'm not sure if this should be an each?
  #FileList['src/org/jruby/ext/jrubyfx/JRubyFX.java'].each do |filen|
  sh "#{javac} -d '#{target_classes}' -classpath '#{target_classes}:#{get_jruby_jar}:#{jfx_path}/jfxrt.jar' -sourcepath '#{src_java}' -g 'src/org/jruby/ext/jrubyfx/JRubyFX.java'"
  #end
end

task :jar => :build do
  cd target_classes
  sh "#{jar} cf '../../lib/#{output_jar}' 'org/jruby/ext/jrubyfx/JRubyFX.class'"
  cd "../../"
end

task :run do
  puts Java.java.lang.System.getProperties["java.runtime.version"]
  ruby "-I lib:#{get_jfx_path} samples/SimpleFXMLDemo.rb"
end

def get_jfx_path
  #remove platform-specific bits. TODO: arm
  Java.java.lang.System.getProperties["sun.boot.library.path"].gsub(/[\/\\][ix345678_]+$/, "")
end

def get_jruby_jar
  Java.java.lang.System.getProperties["sun.boot.class.path"].split(':').find_all{|i| i.match(/jruby\.jar$/)}[0]
end