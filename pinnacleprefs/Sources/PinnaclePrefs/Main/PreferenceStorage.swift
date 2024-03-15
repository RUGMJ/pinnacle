import Comet
import Combine

final class PreferenceStorage: ObservableObject {
    private static let registry: String = "/var/mobile/Library/Preferences/dev.rugmj.pinnacleprefs.plist"

    @Published(key: "enabled",    registry: registry) var isEnabled: Bool = true
    @Published(key: "fadeAmount", registry: registry) var fadeAmount: Double = 0.3
    @Published(key: "fadeDuration", registry: registry) var fadeDuration: Double = 0.2
    @Published(key: "iconMoveDuration", registry: registry) var iconMoveDuration: Double = 0.5
    @Published(key: "springDamping", registry: registry) var springDamping: Double = 0.6
    @Published(key: "springInitialVelocity", registry: registry) var springInitialVelocity: Double = 0.0

    private var cancellables: Set<AnyCancellable> = []

    init() {
        self.objectWillChange.sink { _ in
            let center = CFNotificationCenterGetDarwinNotifyCenter()
            let name = "dev.rugmj.pinnacleprefs/Update" as CFString
            let object = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            CFNotificationCenterPostNotification(center, .init(name), object, nil, true)
        }.store(in: &cancellables)
    }
}
