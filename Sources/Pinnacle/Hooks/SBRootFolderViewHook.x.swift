import Orion
import PinnacleC

class SBRootFolderViewHook: ClassHook<SBRootFolderView> {
    func setEditing(_ editing: Bool, animated: Bool) {
        orig.setEditing(editing, animated: animated)

        guard active else { return }
        guard !editing else { return }

        guard let iconList = activeIconList else { return }
        iconList._pinnacleResetAllIconViews()
        active = false
        activeIconList = nil
    }
}
