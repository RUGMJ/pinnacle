import Orion
import PinnacleC

var sharedIconList: SBIconListView? = nil

class SBIconListViewHook: ClassHook<SBIconListView> {
    func didMoveToSuperview() {
        orig.didMoveToSuperview()

        if sharedIconList == nil { sharedIconList = target }
    }
    
    // orion:new
    /// - Returns: A ``SBIconView`` not attached to any superview
    func _pinnacleCreateIconView(forDisplayIdentifier: String) -> SBIconView? {
        guard let icon = SBIconController.sharedInstance()!.model.expectedIcon(forDisplayIdentifier: forDisplayIdentifier) else { return nil }
        target._addIconViews(forIcons: [icon])
        
        guard let iconView = target.iconView(for: icon) else { return nil }
        iconView.removeFromSuperview()
        
        return iconView;
    }

    // orion:new
    func _pinnacleIsEditing() -> Bool {
        let editing: Bool? = Ivars(target)[safelyAccessing: "_editing"]
        return editing!
    }
    
    // orion:new
    func _pinnacleResetAllIconViews() {
        _pinnacleForIconViews({
            $0._pinnacleReset()
        })
    }

    // orion:new
    func _pinnacleForIconViews(_ action:(SBIconView) -> Void) {
        var iconViews: [UIView]
        if target.subviews[0].isKind(of: SBFTouchPassThroughView.classForCoder()) {
            iconViews = target.subviews[0].subviews
        } else {
            iconViews = target.subviews
        }

        iconViews.forEach({
            guard let iconView = $0 as? SBIconView else { return }
            action(iconView)
        })
    }
}
