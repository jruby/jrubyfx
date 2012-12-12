/*=begin
JRubyFXML - Write JavaFX and FXML in Ruby
Copyright (C) 2012 Patrick Plenefisch

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as 
published by the Free Software Foundation, either version 3 of
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end*/
package org.jruby.ext.jrubyfx;

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
        Application.launch((String[]) null);
    }

    @Override
    public void init() throws Exception {
        callMethodIfPossible("init");
    }

    @Override
    public void start(Stage primaryStage) throws Exception {
        IRubyObject[] args = new IRubyObject[]{
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
}
