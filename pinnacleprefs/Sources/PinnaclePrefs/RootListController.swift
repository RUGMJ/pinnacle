import SwiftUI
import Comet
import PinnaclePrefsC

class RootListController: CMViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup(content: RootView())
        self.title = "Pinnacle"
    }
}
