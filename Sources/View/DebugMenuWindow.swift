import UIKit

final class DebugAssistiveTouchWindow: UIWindow {
    private enum Constants {
        static let shrinkSize = CGSize(width: 60, height: 60)
        static let margin: CGFloat = 4
        static let positionYKey = "DebugAssistiveTouch.positionY"
        static let isRightKey = "DebugAssistiveTouch.isRight"
    }

    private let touch: DebugAssistiveTouch
    private let coverView = UIView()
    private let panelView: DebugAssistiveTouchPanelView
    private let shrinkView = DebugAssistiveTouchShrinkView()
    private var isExpanded = false
    private var startPoint = CGPoint.zero
    private var shrinkFrame = CGRect(origin: CGPoint(x: 8, y: 200), size: Constants.shrinkSize)
    private var isShrinkAnchoredRight = false
    private var lastBoundsSize = CGSize.zero
    private weak var previousKeyWindow: UIWindow?

    override var canBecomeKey: Bool {
        isExpanded
    }

    init(windowScene: UIWindowScene, touch: DebugAssistiveTouch) {
        self.touch = touch
        self.panelView = DebugAssistiveTouchPanelView(touch: touch)
        super.init(windowScene: windowScene)

        rootViewController = DebugAssistiveTouchRootViewController(touch: touch)
        frame = windowScene.coordinateSpace.bounds
        backgroundColor = .clear
        initializeProperty()
        initializeViews()

        panelView.alpha = 0
        panelView.frame = shrinkFrame
        shrinkView.alpha = 1
        shrinkView.frame = panelView.frame
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrameForCurrentSceneIfNeeded()
        updateShrinkFrameForCurrentBoundsIfNeeded()
        coverView.frame = bounds
        if isExpanded {
            panelView.frame = expandedFrame()
        } else {
            shrinkView.frame = shrinkFrame
            panelView.frame = shrinkFrame
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isExpanded {
            if panelView.frame.contains(point) {
                let panelPoint = convert(point, to: panelView)
                return panelView.hitTest(panelPoint, with: event)
            }
            let coverPoint = convert(point, to: coverView)
            return coverView.hitTest(coverPoint, with: event)
        }

        if shrinkView.frame.contains(point) {
            let shrinkPoint = convert(point, to: shrinkView)
            return shrinkView.hitTest(shrinkPoint, with: event)
        }

        return nil
    }

    func expand() {
        guard !isExpanded else {
            return
        }

        previousKeyWindow = windowScene?.windows.first { $0.isKeyWindow && $0 !== self }
        isExpanded = true
        makeKey()
        panelView.frame = expandedFrame()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.coverView.alpha = 1
            self.panelView.alpha = 1
            self.shrinkView.alpha = 0
            self.shrinkView.frame = self.shrinkFrame
        } completion: { _ in
            self.panelView.refresh()
        }
    }

    func shrink() {
        panelView.endEditing(true)
        guard isExpanded else {
            return
        }

        isExpanded = false
        previousKeyWindow?.makeKey()
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
            self.coverView.alpha = 0
            self.panelView.alpha = 0
            self.shrinkView.alpha = 1
            self.shrinkView.frame = self.shrinkFrame
        } completion: { _ in
            self.panelView.frame = self.shrinkFrame
            self.previousKeyWindow = nil
        }
    }

    private func initializeProperty() {
        let hasSavedY = UserDefaults.standard.object(forKey: Constants.positionYKey) != nil
        let y = hasSavedY ? CGFloat(UserDefaults.standard.double(forKey: Constants.positionYKey)) : shrinkFrame.minY
        isShrinkAnchoredRight = UserDefaults.standard.bool(forKey: Constants.isRightKey)
        let x = isShrinkAnchoredRight ? bounds.width - Constants.shrinkSize.width - Constants.margin : Constants.margin
        shrinkFrame = CGRect(x: x, y: y, width: Constants.shrinkSize.width, height: Constants.shrinkSize.height)
        if !hasSavedY {
            shrinkFrame.origin.y = 200
        }
        shrinkFrame = clampedShrinkFrame(shrinkFrame)
    }

    private func initializeViews() {
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        coverView.alpha = 0
        addSubview(coverView)

        panelView.alpha = 0
        panelView.layer.masksToBounds = true
        panelView.layer.cornerRadius = 20
        panelView.onActionSelected = { [weak self] in
            self?.shrink()
        }
        addSubview(panelView)

        let coverTap = UITapGestureRecognizer(target: self, action: #selector(handleCoverTap))
        coverView.addGestureRecognizer(coverTap)

        shrinkView.frame = shrinkFrame
        addSubview(shrinkView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShrinkTap))
        shrinkView.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleShrinkPan(_:)))
        shrinkView.addGestureRecognizer(pan)
    }

    private func expandedFrame() -> CGRect {
        let safeAreaInsets = safeAreaInsets
        let top = safeAreaInsets.top + 44
        var frame = bounds
        frame.origin.y += top
        frame.size.height -= top
        return frame
    }

    private func updateFrameForCurrentSceneIfNeeded() {
        guard let sceneBounds = windowScene?.coordinateSpace.bounds,
              frame.size != sceneBounds.size
        else {
            return
        }

        frame = sceneBounds
    }

    private func updateShrinkFrameForCurrentBoundsIfNeeded() {
        guard lastBoundsSize != bounds.size else {
            return
        }

        lastBoundsSize = bounds.size
        shrinkFrame = clampedShrinkFrame(shrinkFrame)
    }

    private func clampedShrinkFrame(_ frame: CGRect) -> CGRect {
        let maxY = max(0, bounds.height - Constants.shrinkSize.height - safeAreaInsets.bottom)
        let y = min(max(safeAreaInsets.top, frame.minY), maxY)
        let left = isShrinkAnchoredRight
            ? max(Constants.margin, bounds.width - Constants.shrinkSize.width - Constants.margin)
            : Constants.margin
        return CGRect(x: left, y: y, width: Constants.shrinkSize.width, height: Constants.shrinkSize.height)
    }

    @objc private func handleShrinkTap() {
        expand()
    }

    @objc private func handleCoverTap() {
        shrink()
    }

    @objc private func handleShrinkPan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            startPoint = pan.location(in: self)
        case .changed:
            let location = pan.location(in: self)
            shrinkView.frame.origin.x += location.x - startPoint.x
            shrinkView.frame.origin.y += location.y - startPoint.y
            startPoint = location
        default:
            isShrinkAnchoredRight = shrinkView.frame.midX > bounds.midX
            shrinkFrame = clampedShrinkFrame(shrinkView.frame)
            UserDefaults.standard.set(Double(shrinkFrame.minY), forKey: Constants.positionYKey)
            UserDefaults.standard.set(isShrinkAnchoredRight, forKey: Constants.isRightKey)
            isExpanded = true
            shrink()
        }
    }
}

private final class DebugAssistiveTouchRootViewController: UIViewController {
    private unowned let touch: DebugAssistiveTouch

    init(touch: DebugAssistiveTouch) {
        self.touch = touch
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var shouldAutorotate: Bool {
        true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let hostRootViewController = touch.hostRootViewController else {
            return view.window?.windowScene?.interfaceOrientation.debugMenuInterfaceOrientationMask ?? .portrait
        }

        if hostRootViewController.shouldAutorotate {
            return UIDevice.current.userInterfaceIdiom == .pad ? .all : .allButUpsideDown
        }

        let mask = hostRootViewController.supportedInterfaceOrientations
        return mask.isEmpty
            ? view.window?.windowScene?.interfaceOrientation.debugMenuInterfaceOrientationMask ?? .portrait
            : mask
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        touch.hostRootViewController?.preferredInterfaceOrientationForPresentation
            ?? view.window?.windowScene?.interfaceOrientation
            ?? .portrait
    }
}

private extension UIInterfaceOrientation {
    var debugMenuInterfaceOrientationMask: UIInterfaceOrientationMask {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .unknown:
            return .portrait
        @unknown default:
            return .portrait
        }
    }
}
