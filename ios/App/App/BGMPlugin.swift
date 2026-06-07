import Foundation
import Capacitor
import AVFoundation

// Native BGM player. Plays bgm.m4a via AVAudioPlayer with .ambient session.
// Bypasses WKWebView entirely -- WKWebView is what registers audio with
// MPNowPlayingInfoCenter. Audio played here is invisible to Now Playing.
@objc(BGMPlugin)
public class BGMPlugin: CAPPlugin {
    private var player: AVAudioPlayer?

    @objc func play(_ call: CAPPluginCall) {
        let vol = Float(call.getFloat("volume") ?? 0.25)
        DispatchQueue.main.async {
            // If already playing just update volume
            if let p = self.player, p.isPlaying {
                p.volume = vol
                call.resolve()
                return
            }
            // Locate bgm.m4a inside the app bundle (cap sync copies it here)
            let path = Bundle.main.bundlePath + "/public/assets/Sound fx/Music/bgm.m4a"
            let url  = URL(fileURLWithPath: path)
            do {
                // Force .ambient so this audio session never registers Now Playing
                try AVAudioSession.sharedInstance().setCategory(
                    .ambient, mode: .default, options: [.mixWithOthers])
                try AVAudioSession.sharedInstance().setActive(true)
                self.player = try AVAudioPlayer(contentsOf: url)
                self.player!.numberOfLoops = -1
                self.player!.volume       = vol
                self.player!.prepareToPlay()
                self.player!.play()
                call.resolve()
            } catch {
                call.reject("BGM play failed: \(error.localizedDescription)")
            }
        }
    }

    @objc func pause(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.player?.pause()
            call.resolve()
        }
    }

    @objc func stop(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.player?.stop()
            self.player?.currentTime = 0
            call.resolve()
        }
    }

    @objc func setVolume(_ call: CAPPluginCall) {
        let vol = Float(call.getFloat("volume") ?? 0.25)
        DispatchQueue.main.async {
            self.player?.volume = vol
            call.resolve()
        }
    }
}
