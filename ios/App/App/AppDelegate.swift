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
        // Clear Now Playing before the lock screen appears. WKWebView registers
        // audio with MPNowPlayingInfoCenter even under .ambient session. Wiping
        // the info here (before the lock screen renders) ensures the widget never
        // shows. This fires on lock, incoming call, and app-switch - all the right
        // moments.
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Belt-and-suspenders: clear again once fully backgrounded.
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
