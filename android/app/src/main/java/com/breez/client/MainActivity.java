package com.breez.client;

import com.breez.client.plugins.breez.breezlib.Breez;
import com.breez.client.plugins.breez.*;
import com.ryanheise.audioservice.AudioService;

import android.os.Bundle;
import android.content.Intent;
import android.nfc.NfcAdapter;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.android.SplashScreen;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.PluginRegistry;
import io.flutter.plugins.GeneratedPluginRegistrant;
import android.view.WindowManager.LayoutParams;
import android.util.Log;

import androidx.annotation.NonNull;

public class MainActivity extends FlutterFragmentActivity {
    private static final String TAG = "Breez";
    private LifecycleEvents _lifecycleEventsPlugin;
    public boolean isPos = false;
    NfcHandler m_nfc;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        Log.d(TAG, "Breez activity created...");    
        BreezApplication.isRunning = true;

        registerBreezPlugins(flutterEngine);
        GeneratedPluginRegistrant.registerWith(flutterEngine);

    }

    @Override
    public void onPause() {
        super.onPause();
        getWindow().addFlags(LayoutParams.FLAG_SECURE);
    }

    @Override
    public void onResume() {
        super.onResume();
        getWindow().clearFlags(LayoutParams.FLAG_SECURE);
    }

    @Override
    protected void onDestroy() {
        Log.d(TAG, "Breez activity destroyed...");
        super.onDestroy();
        stopService(new Intent(this, AudioService.class));
        System.exit(0);
    }

    void registerBreezPlugins(@NonNull FlutterEngine flutterEngine) {
        flutterEngine.getPlugins().add(new NfcHandler());
        BreezApplication.breezShare = new BreezShare();
        final PluginRegistry pluginRegistry = flutterEngine.getPlugins();
        pluginRegistry.add(BreezApplication.breezShare);
        pluginRegistry.add(new Breez());
        pluginRegistry.add(new LifecycleEvents());
        pluginRegistry.add(new Permissions());
        pluginRegistry.add(new Tor());
    }

    @Override
    public SplashScreen provideSplashScreen() {
        return null;
    }
}
