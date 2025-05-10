import PinnacleC
import Orion
import libroot

struct SpotlightHookGroup: HookGroup {}

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

        if settings!.activationGestureDirection != "up" {
            SpotlightHookGroup().activate()
        }
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

private let stackDataPath = URL(fileURLWithPath: jbRootPath("/var/mobile/Library/Pinnacle/stackData.plist"))

private func getStackData() -> [String: [String]] {
    guard let data = try? Data(contentsOf: stackDataPath),
          let stackData = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: [String]]
    else {
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
    guard let data = try? PropertyListSerialization.data(fromPropertyList: stackData, format: .xml, options: .init())
    else {
        return
    }
    do {
        try createStackDataPlistIfNeeded()
        try data.write(to: stackDataPath)
    } catch {
        remLog("failed to write: \(error)")
    }
}

private func createStackDataPlistIfNeeded() throws {
    let fileManager = FileManager.default
    let directory = (stackDataPath.path as NSString).deletingLastPathComponent
    
    do {
        try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        
        if !fileManager.fileExists(atPath: stackDataPath.path) {
            let data: [String: Any] = [:]
            let plistData = try PropertyListSerialization.data(fromPropertyList: data, format: .xml, options: 0)
            fileManager.createFile(atPath: stackDataPath.path, contents: plistData, attributes: nil)
        }
    } catch {
        remLog("Error creating empty stack data: \(error.localizedDescription)")
    }
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

var grabberImage: UIImage? = nil
var placeholderImage: UIImage? = nil
