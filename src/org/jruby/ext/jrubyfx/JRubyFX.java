package org.jruby.ext.jrubyfx;

import java.io.Console;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Date;
import javafx.application.Application;
import javafx.stage.Stage;
import org.jruby.javasupport.Java;
import org.jruby.javasupport.JavaObject;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

public class JRubyFX extends Application {
    public static IRubyObject handler;

    public static void start(IRubyObject obj) {
        if (obj == null) {
            throw new NullPointerException("Application required");
        }
        handler = obj;
        Application.launch((String[])null);
    }

    @Override
    public void init() throws Exception {
        callMethodIfPossible("init");
    }

    @Override
    public void start(Stage primaryStage) throws Exception {
        IRubyObject[] args = new IRubyObject[] {
            Java.wrap(ctx().runtime, JavaObject.wrap(ctx().runtime, primaryStage))
        };
        handler.callMethod(ctx(), "start", args);
    }

    @Override
    public void stop() throws Exception {
        callMethodIfPossible("stop");
    }

    private ThreadContext ctx() {
        return handler.getRuntime().getCurrentContext();
    }

    private void callMethodIfPossible(String methodName) {
        if (handler.respondsTo(methodName)) {
            handler.callMethod(ctx(), methodName);
        }
    }
    
    public static void p(Object o)
    {
        System.out.println(o);
    }
    
    public static void reflexDump(Object o)
    {
        Class c = o.getClass();
        p("Fields:");
        for (Field f : c.getDeclaredFields())
        {
            p(f.getName());
        }
        p("------------\n");
        p("Methods:");
        for (Method f : c.getDeclaredMethods())
        {
            p(f.getName());
            for (Class p : f.getParameterTypes())
            {
                p("\t" + p.getSimpleName());
            }
        }
        p("------------\n");
    }
}
