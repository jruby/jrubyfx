package org.jruby.ext.jrubyfx;

import javafx.application.Application;
import javafx.stage.Stage;
import org.jruby.Ruby;
import org.jruby.runtime.ThreadContext;
import org.jruby.javasupport.Java;
import org.jruby.javasupport.JavaObject;
import org.jruby.runtime.builtin.IRubyObject;

public class JRubyFX extends Application {
    public static IRubyObject handler;

    public static void start(IRubyObject obj) {
        handler = obj;
        Application.launch((String[])null);
    }

    @Override
    public void init() throws Exception {
        if (handler.respondsTo("init")) {
            handler.callMethod(ctx(), "init");
        }
    }

    @Override
    public void start(Stage primaryStage) throws Exception {
        Ruby runtime = Ruby.getGlobalRuntime();
        IRubyObject[] args = new IRubyObject[] {
            Java.wrap(runtime, JavaObject.wrap(runtime, primaryStage))
        };
        handler.callMethod(ctx(), "start", args);
    }

    @Override
    public void stop() throws Exception {
        if (handler.respondsTo("stop")) {
            handler.callMethod(ctx(), "stop");
        }
    }

    private ThreadContext ctx() {
        return Ruby.getGlobalRuntime().getCurrentContext();
    }
}
