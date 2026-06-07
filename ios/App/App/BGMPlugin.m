#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Register the BGM plugin so JS can call Capacitor.Plugins.BGM.*
// AVAudioPlayer plays natively (not through WKWebView), so the AVAudioSession
// stays .ambient and the Now Playing lock screen widget never appears.
CAP_PLUGIN(BGMPlugin, "BGM",
    CAP_PLUGIN_METHOD(play, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(pause, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(stop, CAPPluginReturnPromise);
    CAP_PLUGIN_METHOD(setVolume, CAPPluginReturnPromise);
)
