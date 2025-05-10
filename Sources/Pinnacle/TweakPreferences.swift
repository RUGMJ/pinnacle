import Foundation
import libroot

final class TweakPreferences {
    private(set) var settings: Settings!
    static let shared = TweakPreferences()

    private let preferencesFilePath = jbRootPath("/var/mobile/Library/Preferences/dev.rugmj.pinnacleprefs.plist")

    func loadSettings() {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: preferencesFilePath)),
           let decodedSettings = try? PropertyListDecoder().decode(Settings.self, from: data) {
            self.settings = decodedSettings
        } else {
            self.settings = Settings()
        }
    }
}

struct Settings: Codable {
    var enabled = true
    var showAppLabels = true
    var fadeDuration = 0.2
    var fadeAmount = 0.3
    var iconMoveDuration = 0.5
    var springDamping = 0.6
    var springInitialVelocity = 0.0
    var hapticFeedback = true
    var activationGestureDirection = "up"
    var indicator = "none"
}
