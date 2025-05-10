import PinnacleC

class PinnacleIconView: SBIconView {
    var isPlaceholder = false
    
    var xDir = 0
    var yDir = 0

    var bundle = ""
    var parentBundle = ""
    var index = 0

    var imageView: UIImageView? = nil

    convenience init(fromIconView: SBIconView, xDir: Int, yDir: Int, bundle: String, parentBundle: String, index: Int, isEditing: Bool) {
        self.init()
        setupCommonProperties(xDir: xDir, yDir: yDir, bundle: bundle, parentBundle: parentBundle, index: index)

        self.icon = fromIconView.icon
        self.setAllowsLabelArea(TweakPreferences.shared.settings.showAppLabels)

        if isEditing {
            self.gestureRecognizers = []
            let gesture = UITapGestureRecognizer()
            gesture.addTarget(self, action: #selector(handleTap))
            addGestureRecognizer(gesture)
        }
    }

    convenience init?(isPlaceholder: Bool, xDir: Int, yDir: Int, bundle: String, parentBundle: String, index: Int) {
        guard isPlaceholder else {
            return nil
        }

        self.init()
        setupCommonProperties(xDir: xDir, yDir: yDir, bundle: bundle, parentBundle: parentBundle, index: index)

        if placeholderImage == nil {
            placeholderImage = UIImage(contentsOfFile: plusCirclePath())
        }

        let imageView = UIImageView(image: placeholderImage)
        imageView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)

        imageView.isUserInteractionEnabled = true

        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(handleTap))

        imageView.addGestureRecognizer(gesture)

        self.imageView = imageView

        self.addSubview(imageView)
        self.isPlaceholder = true

    }

    private func setupCommonProperties(xDir: Int, yDir: Int, bundle: String, parentBundle: String, index: Int) {
        self.bundle = bundle
        self.parentBundle = parentBundle
        self.xDir = xDir
        self.yDir = yDir
        self.frame.origin = .zero
        self.index = index
    }

    override func _pinnacleReset() {

        UIView.animate(withDuration: settings!.fadeDuration, animations: {
            self.alpha = 0
        })

        UIView.animate(
            withDuration: settings!.iconMoveDuration,
            delay: 0,
            usingSpringWithDamping: settings!.springDamping,
            initialSpringVelocity: settings!.springInitialVelocity,

            animations: {
                self.layer.zPosition = -1
                self.frame.origin.x = 0.0
                self.frame.origin.y = 0.0
            },

            completion: {_ in self.removeFromSuperview() })

    }

    override func _pinnacleGetImageSize() -> CGRect {
        if let imageView = self.imageView {
            return imageView.frame
        } else {
            return iconImageFrame()
        }
    }

    @objc func handleTap() { 
        let window = PinnacleIconPicker(frame: UIScreen.main.bounds)
        if !isPlaceholder {
            window.buttonText = "Remove"
        }

        window.callback = {
            let newBundle = $0 ?? "dev.rugmj.PinnaclePlaceholder\(self.index + 1)"
            var stack = getStackData(for: self.parentBundle)
            guard let index = stack.firstIndex(of: self.bundle) else { return }
            stack[index] = newBundle
            setStackData(for: self.parentBundle, stack: stack)
            active = false

            // On ipad if the screen is rotated while the picker is open the stack closes and so we dont need to reset anything
            // and trying to get the icon view will fail as this class has no superview anymore
            guard let iconView = self.superview as? SBIconView else { return } 
            iconView._pinnacleGetIconList()._pinnacleResetAllIconViews()
        }

        let keyWindow = SpringBoard.shared.keyWindow
        window.rootViewController = keyWindow?.rootViewController
        window.windowScene = keyWindow?.windowScene
        Dock.hideDock()
        window.makeKeyAndVisible()
    }

    func expand() {
         _pinnacleMoveWith(x: xDir, y: yDir)
    }
}
