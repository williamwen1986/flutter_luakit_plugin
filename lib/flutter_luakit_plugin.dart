import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef LuaNotificationFun = void Function(dynamic data);

class FlutterLuakitPlugin {
  static const MethodChannel _channel =
      const MethodChannel('flutter_luakit_plugin');

  static void listener(dynamic data) {
    final Map<dynamic, dynamic> args = data;
    int type = args["type"];
    dynamic d;
    if (args.containsKey("data")){
      d = args["data"];
    }
    if(listeners.containsKey(type)) {
      LuaValueNotifier n = listeners[type];
      n.data = d;
      n.value = !n.value;
    }
  }

  static Map<int, LuaValueNotifier> listeners =
      new Map<int, LuaValueNotifier>();

  static Map<LuaNotificationFun, VoidCallback> funMap =
      new Map<LuaNotificationFun, VoidCallback>();

  static Future<dynamic> callLuaFun(String moduleName, String methodName,
      [dynamic params]) async {
    final Map<String, dynamic> args = {
      'moduleName': moduleName,
      'methodName': methodName,
    };
    if (params != null) {
      args['params'] = params;
    }
    final dynamic response =
        await _channel.invokeMethod('callLuaFunction', args);
    return response;
  }
  static bool hasRegisterEventChannel = false;
  static EventChannel eventChannel = new EventChannel("com.luakit.eventchannel");
  static StreamSubscription<dynamic> observer;
  static void addLuaObserver(int type, LuaNotificationFun f) {
    if(!hasRegisterEventChannel) {
      observer = eventChannel
          .receiveBroadcastStream()
          .listen(listener);
    }
    hasRegisterEventChannel = true;
    if (!listeners.containsKey(type)) {
      LuaValueNotifier notifier = new LuaValueNotifier(true);
      listeners[type] = notifier;
    }
    LuaValueNotifier notifier = listeners[type];
    void fun() {
      LuaValueNotifier n = listeners[type];
      f(n.data);
    }

    ;
    funMap[f] = fun;
    notifier.addListener(fun);
  }

  static void removeLuaObserver(int type, LuaNotificationFun f) {
    LuaValueNotifier notifier = listeners[type];
    if (notifier != null) {
      VoidCallback fun = funMap[f];
      notifier.removeListener(fun);
      funMap.remove(f);
      if (!notifier.hasListeners) {
        listeners.remove(type);
      }
    }
  }

  static Future<dynamic> postNotification(int type, dynamic params) async {
    final Map<String, dynamic> args = {
      'type': type,
    };
    if (params != null) {
      args['params'] = params;
    }
    final dynamic response =
        await _channel.invokeMethod('postNotification', args);
    return response;
  }
}

class LuaValueNotifier extends ValueNotifier<bool> {
  LuaValueNotifier(bool b) : super(b);
  dynamic data;

  @override
  void notifyListeners() {
    super.notifyListeners();
    this.data = null;
  }
}
