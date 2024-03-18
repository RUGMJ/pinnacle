import Orion
import PinnacleC

struct Dock {
  static func hideDock() {
    guard UIDevice.current.userInterfaceIdiom == .pad else { return }

    let iconController = SBIconController.sharedInstance().as(interface: SBIconController.self)
    iconController.parentViewController.homeScreenFloatingDockAssertion?.floatingDockController?._dismissFloatingDockIfPresented(animated: true, completionHandler: nil)
  }

  static func showDock() {
    guard UIDevice.current.userInterfaceIdiom == .pad else { return }

    let iconController = SBIconController.sharedInstance().as(interface: SBIconController.self)
    iconController.parentViewController.homeScreenFloatingDockAssertion?.floatingDockController?._presentFloatingDockIfDismissed(animated: true, completionHandler: nil)
  }
}