import Orion
import PinnacleC

class SBIconScrollViewHook: ClassHook<SBIconScrollView> {
    func handlePan(_ arg0: Any) {
        orig.handlePan(arg0)
        guard active else { return }

        guard let iconList = activeIconList else { return }
        iconList._pinnacleResetAllIconViews()
        active = false
        activeIconList = nil
    }
}
