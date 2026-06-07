import UIKit
import Capacitor
import AVFoundation
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Use .ambient so the game does not register with Now Playing / lock screen
        // controls. .playback would suppress the mute switch but unavoidably shows
        // the Now Playing widget - there is no way to prevent WKWebView from
        // populating MPNowPlayingInfoCenter under .playback. .ambient respects the
        // mute switch (standard behavior for games) and never triggers Now Playing.
        // .mixWithOthers lets background music keep playing underneath game audio.
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[audio] AVAudioSession setup failed: \(error)")
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Stop all audio the instant the phone locks (or app loses focus).
        // Deactivating the AVAudioSession tears down the audio session entirely,
        // which (a) silences WKWebView audio and (b) removes the Now Playing
        // registration BEFORE the lock screen renders -- so no widget appears.
        // The web layer also pauses BGM on visibilitychange; this is the native
        // guarantee that fires earlier and covers the lock screen race.
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            print("[audio] session deactivate failed: \(error)")
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Belt-and-suspenders: clear Now Playing again once fully backgrounded.
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Re-activate the audio session on return so BGM/SFX work again. The web
        // layer resumes BGM on visibilitychange once this session is live.
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[audio] session reactivate failed: \(error)")
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Called when the app was launched with a url. Feel free to add additional processing here,
        // but if you want the App API to support tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // Called when the app was launched with an activity, including Universal Links.
        // Feel free to add additional processing here, but if you want the App API to support
        // tracking app url opens, make sure to keep this call
        return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

}
