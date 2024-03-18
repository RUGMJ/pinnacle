import PinnacleC

class PinnacleIconPicker: UIWindow {
    var callback: ((String?) -> Void)? = nil
    var buttonText: String {
        didSet {
            closeButton.setTitle(buttonText, for: .normal)
        }
    }

    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var collectionView: IconCollectionView = {
        let collectionView = IconCollectionView()
        return collectionView
    }()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Search"
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.tintColor = .clear
        searchBar.isTranslucent = true

        return searchBar
    }()
    
    override init(frame: CGRect) {
        self.buttonText = "Close"
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        self.buttonText = "Close"
        super.init(coder: coder)
        setupUI()
    }

    private func rotateWindowForInitialOrientation() {
        let orientation = UIDevice.current.orientation
        var rotationAngle: CGFloat = 0.0
        
        switch orientation {
        case .landscapeLeft:
            rotationAngle = CGFloat.pi / 2
        case .landscapeRight:
            rotationAngle = -CGFloat.pi / 2
        case .portraitUpsideDown:
            rotationAngle = CGFloat.pi
        default:
            rotationAngle = 0.0
        }
        
        self.transform = CGAffineTransform(rotationAngle: rotationAngle)
    }
    
    private func setupUI() {
        rotateWindowForInitialOrientation()
        searchBar.delegate = collectionView
        closeButton.setTitle(buttonText, for: .normal)

        addSubview(blurEffectView)
        addSubview(closeButton)
        addSubview(collectionView)
        addSubview(searchBar)


        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 50),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -100),

            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            closeButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            closeButton.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            collectionView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 50),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        closeButton.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
    }
    
    @objc private func closeButtonPressed() {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.0
        }) {_ in 
            self.isHidden = true
            self.callback?(nil)
            Dock.showDock()
        }
    }

    class IconCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
        private var apps: [LSApplicationProxy] = []

        init() {
            let layout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 20
            layout.minimumLineSpacing = 30
            layout.itemSize = CGSize(width: 60, height: 60)
            super.init(frame: .zero, collectionViewLayout: layout)

            translatesAutoresizingMaskIntoConstraints = false
            backgroundColor = .clear
            contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

            dataSource = self
            delegate = self

            apps = loadData()

            register(IconViewCell.self, forCellWithReuseIdentifier: "IconViewCell")
        }

        func loadData() -> [LSApplicationProxy] {
            let weirdApps = [
                "com.apple.dt.XcodePreviews",
                "com.apple.sidecar",
                "com.apple.PosterBoard",
                "com.apple.siri",
            ]

            var apps = LSApplicationWorkspace.default()!.atl_allInstalledApplications()! as! [LSApplicationProxy]
            apps = apps.filter { !$0.atl_isHidden() }
            apps = apps.filter { !weirdApps.contains($0.atl_bundleIdentifier!) }
            apps.sort {
                $0.atl_fastDisplayName().localizedStandardCompare($1.atl_fastDisplayName()) == .orderedAscending
            }

            return apps
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            guard searchText != "" else {
                apps = loadData()
                return
            }

            apps = loadData().filter {
                $0.atl_fastDisplayName()!.lowercased().contains(searchText.lowercased()) || $0.atl_bundleIdentifier.lowercased().contains(searchText.lowercased())
            }

            reloadData()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return apps.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconViewCell", for: indexPath) as! IconViewCell
            cell.bundle = apps[indexPath[1]].bundleIdentifier
            return cell
        }
    }

    class IconViewCell: UICollectionViewCell {
        var bundle: String? {
            didSet {
                guard let bundle = bundle else { return }
                guard let iconView = sharedIconList!._pinnacleCreateIconView(forDisplayIdentifier: bundle) else {
                    return
                }
                
                contentView.subviews.forEach { $0.removeFromSuperview() }

                iconView.translatesAutoresizingMaskIntoConstraints = false
                iconView.gestureRecognizers = []
                contentView.addSubview(iconView)
                iconView.setEditing(false)
                iconView.setAllowsLabelArea(true)

                let gesture = UITapGestureRecognizer()
                gesture.addTarget(self, action: #selector(handleTap))
                iconView.addGestureRecognizer(gesture)

                NSLayoutConstraint.activate([
                    iconView.topAnchor.constraint(equalTo: contentView.topAnchor),
                    iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    iconView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                ])
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        @objc public func handleTap() {
            let window = superview?.superview as! PinnacleIconPicker
            window.closeButtonPressed()
            window.callback?(bundle)
        }
    }
}
