import PinnacleC
import Orion

class Pinnacle: Tweak {
    required init() {
        remLog("Starting")
        loadSettings()
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let name = "dev.rugmj.pinnacleprefs/Update" as CFString
        let observer = UnsafeMutableRawPointer(Unmanaged.passRetained(self).toOpaque())

        CFNotificationCenterAddObserver(center, observer, { center, observer, name, object, userInfo in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                loadSettings()
            })
        }, name, nil, .deliverImmediately)
    }

    static func handleError(_ error: OrionHookError) {
        remLog(error)
        DefaultTweak.handleError(error)
    }
}


func loadSettings() {
        TweakPreferences.shared.loadSettings()
        settings = TweakPreferences.shared.settings
}

var active: Bool = false
var activeIconList: SBIconListView?

private func getStackData() -> [String: [String]] {
    guard let stackData = UserDefaults.standard.object(forKey: "dev.rugmj.pinnacle.stackdata") as? [String: [String]] else {
        return [:]
    }

    return stackData
}

func getStackData(for bundle: String) -> [String] {
    return getStackData()[bundle] ?? [
        "dev.rugmj.PinnaclePlaceholder1",
        "dev.rugmj.PinnaclePlaceholder2",
        "dev.rugmj.PinnaclePlaceholder3",
        "dev.rugmj.PinnaclePlaceholder4"
    ]
}

func setStackData(for bundle: String, stack: [String]) {
    var stackData = getStackData()
    stackData[bundle] = stack
    UserDefaults.standard.set(stackData, forKey: "dev.rugmj.pinnacle.stackdata")
}

func normalise(_ number: Int) -> Int {
    switch number {
    case let x where x > 0:
        return 1
    case let x where x < 0:
        return -1
    default:
        return 0
    }
}

var settings: Settings?
