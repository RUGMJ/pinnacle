import Foundation
import SwiftUI

final class TweakPreferences {
    private(set) var settings: Settings!
    static let shared = TweakPreferences()

    private let preferencesFilePath = "/var/mobile/Library/Preferences/dev.rugmj.pinnacleprefs.plist"

    func loadSettings() throws {
        if let data = FileManager.default.contents(atPath: preferencesFilePath) {
            self.settings = try PropertyListDecoder().decode(Settings.self, from: data)
        } else {
            self.settings = Settings()
        }
    }
}

struct Settings: Codable {
    var enabled = true
    var fadeDuration = 0.2
    var fadeAmount = 0.3
    var iconMoveDuration = 0.5
    var springDamping = 0.6
    var springInitialVelocity = 0.0
}
