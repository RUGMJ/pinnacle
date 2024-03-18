import Orion
import PinnacleC

class SBIconViewHook: ClassHook<SBIconView> {
    @Property var hasInit = false
    @Property var icon: SBApplicationIcon?

    @Property var row: UInt? = nil
    @Property var column: UInt? = nil

    @Property var originalX: CGFloat? = nil
    @Property var originalY: CGFloat? = nil

    func didMoveToSuperview() {
        orig.didMoveToSuperview()

        guard !target.isFolderIcon() else { return }
        guard target.icon != nil else { return }
        guard target.icon.isKind(of: SBApplicationIcon.classForCoder()) else { return }
        icon = target.icon as? SBApplicationIcon

        guard target.superview != nil else { return }
        guard !target.superview!.isKind(of: SBDockIconListView.classForCoder()) else { return }

        guard !target.isKind(of: PinnacleIconView.classForCoder()) else { return }

        guard !hasInit else { return }
        hasInit = true

        let swipeGesture = UISwipeGestureRecognizer()
        swipeGesture.direction = .up
        swipeGesture.addTarget(target, action: #selector(_pinnacleHandleActivation))

        target.addGestureRecognizer(swipeGesture)
    }

    // orion:new
    @objc func _pinnacleHandleActivation() { 
        guard !target.isFolderIcon() else { return }
        guard !active else { return }
        active = true

        let iconList = _pinnacleGetIconList()
        activeIconList = iconList
        iconList._pinnacleEnsureTapToEndIsRegistered()

        target.didMoveToSuperview()

        _pinnacleCalculateRowAndColumn()
        let parentBundle = icon!.applicationBundleID()!

        let data = getStackData(for: parentBundle)
        let origAvailableDirections = _pinnacleCalcAvailableDirections()
        var availableDirections = origAvailableDirections
        var lastDirection = 0
        var directionsToMove = [0, 0, 0, 0]

        let offsets = [
            (0, -1),   // Up
            (1, 0),   // Right
            (0, 1),  // Down
            (-1, 0)   // Left
        ]


        if iconList._pinnacleIsEditing() {
            target._removeJitter()
        }

        for (index, bundle) in data.enumerated() {
            var direction = (lastDirection + 1) % 4
            while availableDirections[direction] == 0 {
                direction = (direction + 1) % 4
            }

            let amount = Int(origAvailableDirections[direction] - availableDirections[direction] + 1)
            let (xDir, yDir) = offsets[direction]

            if bundle.contains("dev.rugmj.PinnaclePlaceholder") {
                if iconList._pinnacleIsEditing() {
                    let pinnacleIconView = PinnacleIconView(
                        isPlaceholder: true,
                        xDir: xDir * amount,
                        yDir: yDir * amount,
                        bundle: bundle,
                        parentBundle: parentBundle,
                        index: index
                    )!
                    target.addSubview(pinnacleIconView)
                    directionsToMove[direction] += 1
                }
            } else {
                guard let iconView = iconList._pinnacleCreateIconView(forDisplayIdentifier: bundle) else { continue }

                let pinnacleIconView = PinnacleIconView(
                    fromIconView: iconView,
                    xDir: xDir * amount,
                    yDir: yDir * amount,
                    bundle: bundle,
                    parentBundle: parentBundle,
                    index: index,
                    isEditing: iconList._pinnacleIsEditing()
                )

                target.addSubview(pinnacleIconView)
                directionsToMove[direction] += 1
            }

            availableDirections[direction] -= 1
            lastDirection = direction
        }

        var expanded = 0
        _pinnacleForSubviews({
            $0.expand()
            expanded += 1
        })

        guard expanded != 0 else {
            active = false
            return
        }

        iconList._pinnacle(forIconViews: {
            guard let iconView = $0 else { return }
            guard !iconView.isKind(of: PinnacleIconView.classForCoder()) else { return }
            iconView._pinnacleCalculateRowAndColumn()
            guard let row = self.row, let column = self.column else { return }
            iconView._pinnacleMoveAway(row, column: column, directions: directionsToMove as [NSNumber])
        })

        if settings!.hapticFeedback {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    // orion:new
    func _pinnacleReset() {
        UIView.animate(withDuration: settings!.fadeDuration, animations: {
            self.target.alpha = 1
        })

        guard !target.icon.isKind(of: SBWidgetIcon.classForCoder()) else { return }

        if let x = originalX, let y = originalY {
            UIView.animate(
                withDuration: settings!.iconMoveDuration,
                delay: 0,
                usingSpringWithDamping: settings!.springDamping,
                initialSpringVelocity: settings!.springInitialVelocity
            )
                {
                    self.target.frame.origin.y = y
                    self.target.frame.origin.x = x
                }
        }

        for subview in target.subviews {
            if let iconView = subview as? PinnacleIconView {
                iconView._pinnacleReset()
            }
        }
    }



    // orion:new
    func _pinnacleForSubviews(_ action:(PinnacleIconView) -> Void) {
        target.subviews.forEach({
            if let iconView = $0 as? PinnacleIconView {
                action(iconView)
            }
        })
    }

    // orion:new
    /// - Parameters:
    ///     - row: the row to move away from
    ///     - column: the column to move away from
    ///     - directions: the directions that should move and by how much (from the row and column provided) `[up, right, down, left]`
    func _pinnacleMoveAway(_ row: UInt, column: UInt, directions: [NSNumber]) {
        guard !target.icon.isKind(of: SBWidgetIcon.classForCoder()) else {
            UIView.animate(withDuration: settings!.fadeDuration, animations: {
                self.target.alpha = 0
            })

            return
        }

        originalX = target.frame.origin.x
        originalY = target.frame.origin.y

        if !(row == self.row && column == self.column) {
            UIView.animate(withDuration: settings!.fadeDuration, animations: {
                self.target.alpha = settings!.fadeAmount
            })
        }

        guard row == self.row || column == self.column else {
            return
        }
        
        let sRow = Int(self.row!) + 1
        let sColumn = Int(self.column!) + 1

        let mRow = Int(row) + 1
        let mColumn = Int(column) + 1

        var xDiff = normalise(sColumn - mColumn)
        var yDiff = normalise(sRow - mRow)

        if xDiff < 0 {
            xDiff *= directions[3] as! Int
        } else {
            xDiff *= directions[1] as! Int
        }

        if yDiff < 0 {
            yDiff *= directions[0] as! Int
        } else {
            yDiff *= directions[2] as! Int
        }


        _pinnacleMoveWith(x: xDiff, y: yDiff)
    }        

    func tapGestureDidChange(_ arg0: Any) {
        orig.tapGestureDidChange(arg0)

        activeIconList!._pinnacleResetAllIconViews()
        active = false
        activeIconList = nil
    }

    // orion:new
    /// Moves by the values provided
    func _pinnacleMoveWith(x: Int, y: Int) {
        let amount = _pinnacleGetEffectiveIconSpacing()

        let height = target.frame.height + amount.height - 15 // TODO find a way to find this offset at runtime
        let width = target.frame.width + amount.width

        UIView.animate(
            withDuration: settings!.iconMoveDuration,
            delay: 0,
            usingSpringWithDamping: settings!.springDamping,
            initialSpringVelocity: settings!.springInitialVelocity
        )
        {
            self.target.frame.origin.y += CGFloat(y) * height
            self.target.frame.origin.x += CGFloat(x) * width
        }
    }

    // orion:new
    /// - Returns: `SBIconListView.effectiveIconSpacing`
    func _pinnacleGetEffectiveIconSpacing() -> CGSize {
        return _pinnacleGetIconList().effectiveIconSpacing
    }

    // orion:new
    /// - Returns: The number of icon spaces in each direction, clockwise. `[up, right, down, left]`
    func _pinnacleCalcAvailableDirections() -> [UInt] {
         let iconList = _pinnacleGetIconList()

         let maxRows = iconList.iconRowsForCurrentOrientation
         let maxColumns = iconList.iconColumnsForCurrentOrientation

         let up = row!
         let down = maxRows - row! - 1
         let left = column!
         let right = maxColumns - column! - 1

         return [up, right, down, left]
     }

    // orion:new
    /// - Returns: The closest ``SBIconListView``
    func _pinnacleGetIconList() -> SBIconListView {
        if let listView = target.superview as? SBIconListView { return listView }
        if let listView = target.superview?.superview as? SBIconListView { return listView }
        if let listView = target.superview?.superview?.superview as? SBIconListView { return listView }

        remLog("_pinnacleGetIconList() - icon list isnt where we expect, searching up the tree")

        var view = target.superview!
        while !view.isKind(of: SBIconListView.classForCoder()) {
            if let superview = view.superview { view = superview }
        }

        return view as! SBIconListView
    }

    // orion:new
    /// Calculates the row and column of this instance and sets the `row` and `col` properties
    func _pinnacleCalculateRowAndColumn() {
        let iconList = _pinnacleGetIconList()
        
        let origin = target.frame.origin

        row = iconList.row(at: origin)
        column = iconList.column(at: origin)
    }

    func hitTest(_ point: CGPoint, withEvent event: UIEvent) -> UIView? {
        if target.point(inside: point, with: event) {
            return orig.hitTest(point, withEvent: event)
        }

        for subview in target.subviews {
            if let hitTestView = subview.hitTest(target.convert(point, to: subview), with: event) {
                return hitTestView
            }
        }

        return nil
    }

}
