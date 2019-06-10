import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_luakit_plugin/flutter_luakit_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  void listenFun(dynamic data) {
    print("notifyyy" + data.toString());
  }

  @override
  void initState() {
    super.initState();
    testLua();
    FlutterLuakitPlugin.addLuaObserver(3, listenFun);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> testLua() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterLuakitPlugin.callLuaFun("test", "fun");
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Center(
              child: FlatButton(
                onPressed: () {
                  Map<String,String> m = new Map<String,String>();
                  m["a"] = "a1";
                  m["b"] = "b2";
                  FlutterLuakitPlugin.postNotification(3, m);
                },
                child: Text("tap it"),
              ),
            )));
  }
}
