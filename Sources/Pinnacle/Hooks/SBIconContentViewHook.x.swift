import PinnacleC
import Orion

class SBIconContentViewHook: ClassHook<SBIconContentView> {
   @Property var hasInit = false

   func addGestureRecognizer(_ recognizer: UIGestureRecognizer) {
      guard !hasInit else {
         return orig.addGestureRecognizer(recognizer)
      }

      let newRecognizer = UITapGestureRecognizer()
      newRecognizer.addTarget(target, action: #selector(_pinnacleHandleTap))
      hasInit = true

      orig.addGestureRecognizer(recognizer)
      orig.addGestureRecognizer(newRecognizer)
   }

   // orion:new
   @objc func _pinnacleHandleTap() {
      guard active else { return }
      guard let iconList = activeIconList else { return }

      iconList._pinnacleResetAllIconViews()

      active = false
      activeIconList = nil
   }
}
