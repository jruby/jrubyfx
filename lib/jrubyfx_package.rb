require "ant"
require "pathname"
require "rake"

module JRubyFX
  module Package
    extend Rake::DSL

      # Currently only JDK8 will package up JRuby apps. In the near
      # future the necessary tools will be in maven central and
      # we can download them as needed, so this can be changed then.

      def check_jdk
        jdk_version = java.lang.System.getProperties["java.runtime.version"]
        nmbs = jdk_version.split('.')
        nmb = nmbs[1].to_i
        if nmb < 8
          raise "You must install JDK 8 to use the native-bundle packaging tools. You can still create an executable jar, though."
        else
          nmb
        end
      end

      # These webstart files don't work, and the packager doesn't have an option to
      # disable them, so remove them so the user isn't confused.

      def cleanup_webstart(full_build_dir)
        files_to_rm = FileList["#{full_build_dir}*.html","#{full_build_dir}*.jnlp"]
        rm files_to_rm
      end

      def native_bundles(base_dir=Dir.pwd, output_jar, verbosity, app_name)
        check_jdk
        output_jar = Pathname.new(output_jar)
        dist_dir = output_jar.parent
        jar_name = File.basename(output_jar)
        out_name = File.basename(output_jar, '.*')

        # Can't access the "fx" xml namespace directly, so we get it via __send__.
        # Thank you enebo!

        ant do
          taskdef(resource: "com/sun/javafx/tools/ant/antlib.xml",
                  uri: "javafx:com.sun.javafx.tools.ant",
                  classpath: ".:${java.home}/../lib/ant-javafx.jar")
          __send__("javafx:com.sun.javafx.tools.ant:deploy", nativeBundles: "all",
                   width: "100", height: "100", outdir: "#{base_dir}/build/",
                   outfile: out_name, verbose: verbosity) do
            application(mainClass: "org.jruby.JarBootstrapMain", name: app_name)
            resources do
              fileset(dir: dist_dir) do
                include name: jar_name
              end
            end
          end
        end

        cleanup_webstart("#{base_dir}/build/")
      end

      module_function :native_bundles
      module_function :check_jdk
      module_function :cleanup_webstart
  end
end
