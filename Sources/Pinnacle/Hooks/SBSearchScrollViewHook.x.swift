import Orion
import PinnacleC

var scrollViewPanGesture: UIPanGestureRecognizer? = nil

class SBSearchScrollViewHook: ClassHook<SBSearchScrollView> {
  typealias Group = SpotlightHookGroup

  func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
    orig.addGestureRecognizer(gestureRecognizer)
    if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
      scrollViewPanGesture = panGesture
    }
  }
}
