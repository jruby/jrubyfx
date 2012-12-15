task :default => [:build, :run]

jar = ENV['jar'] || "jar"
target = ENV['target'] || "target"
jfx_path = ENV['jfx_path'] || "../javafx/rt/lib"
output_jar = ENV['output_jar'] || "rubyfx-app.jar"
main_script = ENV['main_script'] || 'samples/SimpleFXMLDemo.rb'

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
end

task :run do
  ruby "-I lib '#{main_script}'"
end

task :build => :clean do
  sh "gem build jrubyfxml.gemspec"
end

task :install => :build do
  sh "gem install jrubyfxml-*-java.gem"
end

desc "Create a full jar with embedded JRuby and given script (via main_script ENV var)"
task :jar do
  mkdir_p target
  #copy jruby jar file in, along with script and our rb files
  cp get_jruby_jar, "#{target}/#{output_jar}"
  cp main_script, "#{target}/jar-bootstrap.rb"
  ruby "lib/jrubyfxml.rb jar-ify #{target}/jrubyfxml.rb"
  # edit the jar
  cd target
  sh "#{jar} ufe '#{output_jar}' org.jruby.JarBootstrapMain *"
  chmod 0775, output_jar
  cd "../"
end
desc "Create a full jar and run it"
task :run_jar => :jar do
  sh "java -jar #{target}/#{output_jar}"
end

def get_jfx_path
  #remove platform-specific bits. TODO: arm
  #NOTE: this is also in jrubyfxml.rb
  Java.java.lang.System.getProperties["sun.boot.library.path"].gsub(/[\/\\][amdix345678_]+$/, "")
end

def get_jruby_jar
  Java.java.lang.System.getProperties["sun.boot.class.path"].split(':').find_all{|i| i.match(/jruby\.jar$/)}[0]
end
