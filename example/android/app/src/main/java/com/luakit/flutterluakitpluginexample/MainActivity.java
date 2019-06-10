package com.luakit.flutterluakitpluginexample;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import com.common.luakit.LuaHelper;


public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    LuaHelper.startLuaKit(this);
    GeneratedPluginRegistrant.registerWith(this);
  }
}
