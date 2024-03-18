import Orion
import PinnacleC

@objc protocol SBHomeScreenViewController {
  var homeScreenFloatingDockAssertion: SBFloatingDockBehaviorAssertion? { get }
}

@objc  protocol SBFloatingDockBehaviorAssertion {
  var floatingDockController: SBFloatingDockController? { get }
}

@objc protocol SBFloatingDockController {
  func _dismissFloatingDockIfPresentedAnimated(_ animated: Bool, completionHandler: (() -> Void)?)
  func _presentFloatingDockIfDismissedAnimated(_ animated: Bool, completionHandler: (() -> Void)?)
}

@objc protocol IconController {
  var parentViewController: SBHomeScreenViewController { get }
}

struct Dock {
  static func hideDock() {
    guard UIDevice.current.userInterfaceIdiom == .pad else { return }

    let iconController = SBIconController.sharedInstance().as(interface: IconController.self)
    iconController.parentViewController.homeScreenFloatingDockAssertion?.floatingDockController?._dismissFloatingDockIfPresentedAnimated(true, completionHandler: nil)
  }

  static func showDock() {
    guard UIDevice.current.userInterfaceIdiom == .pad else { return }
    
    let iconController = SBIconController.sharedInstance().as(interface: IconController.self)
    iconController.parentViewController.homeScreenFloatingDockAssertion?.floatingDockController?._presentFloatingDockIfDismissedAnimated(true, completionHandler: nil)
  }
}