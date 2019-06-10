package com.luakit.flutterluakitplugin;

import com.common.luakit.ILuaCallback;
import com.common.luakit.INotificationObserver;
import com.common.luakit.LuaHelper;
import com.common.luakit.LuaNotificationListener;
import com.common.luakit.NotificationHelper;

import java.util.HashMap;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FlutterLuakitPlugin */
public class FlutterLuakitPlugin implements MethodCallHandler {
  static final String STREAM = "com.luakit.eventchannel";
  static LuaNotificationListener  listener = null;
  static EventChannel.EventSink sink = null;
  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_luakit_plugin");
    channel.setMethodCallHandler(new FlutterLuakitPlugin());
    new EventChannel(registrar.messenger(),STREAM).setStreamHandler(
            new EventChannel.StreamHandler() {
              @Override
              public void onListen(Object o, EventChannel.EventSink eventSink) {
                sink = eventSink;
                INotificationObserver observer = new INotificationObserver() {
                  @Override
                  public void onObserve(int type, Object info) {
                    HashMap<String, Object> map = new HashMap<String, Object>();
                    map.put("type",new Integer(type));
                    if (info != null) {
                      map.put("data",info);
                    }
                    if (sink != null) {
                      sink.success(map);
                    }
                  }
                };
                listener = new LuaNotificationListener();
                listener.addObserver(0, observer);
              }

              @Override
              public void onCancel(Object o) {
                sink = null;
              }
            }
    );
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("callLuaFunction")) {
      HashMap<String,Object> arguments =  (HashMap<String,Object>)call.arguments;
      final Result resultInside = result;
      if (arguments.containsKey("params")) {
        LuaHelper.callLuaFunction((String) arguments.get("moduleName"), (String) arguments.get("methodName"), arguments.get("params"), new ILuaCallback() {
          @Override
          public void onResult(Object o) {
            resultInside.success(o);
          }
        });
      } else {
        LuaHelper.callLuaFunction((String) arguments.get("moduleName"), (String) arguments.get("methodName"), new ILuaCallback() {
          @Override
          public void onResult(Object o) {
            resultInside.success(o);
          }
        });
      }
    } else if(call.method.equals("postNotification")){
       HashMap<String,Object> arguments =  (HashMap<String,Object>)call.arguments;
       Integer type = (Integer) arguments.get("type");
       Object data = arguments.get("params");
       NotificationHelper.postNotification(type, data);
       result.success(null);
    } else {
      result.notImplemented();
    }
  }
}
