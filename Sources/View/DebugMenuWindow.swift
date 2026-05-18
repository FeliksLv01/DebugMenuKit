import UIKit

private enum DebugAssistiveTouchLayout {
    static let shrinkSize = CGSize(width: 60, height: 60)
    static let margin: CGFloat = 4
    static let positionYKey = "DebugAssistiveTouch.positionY"
    static let isRightKey = "DebugAssistiveTouch.isRight"
}

final class DebugAssistiveTouchFloatingView: UIView {
    private let touch: DebugAssistiveTouch
    private let shrinkView = DebugAssistiveTouchShrinkView()
    private var startPoint = CGPoint.zero
    private var shrinkFrame = CGRect(origin: CGPoint(x: 8, y: 200), size: DebugAssistiveTouchLayout.shrinkSize)
    private var isShrinkAnchoredRight = false
    private var lastBoundsSize = CGSize.zero
    private var didInitializeProperty = false

    init(touch: DebugAssistiveTouch) {
        self.touch = touch
        super.init(frame: .zero)

        backgroundColor = .clear
        initializeViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        initializePropertyIfNeeded()
        updateShrinkFrameForCurrentBoundsIfNeeded()
        shrinkView.frame = shrinkFrame
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard shrinkView.frame.contains(point) else {
            return nil
        }

        let shrinkPoint = convert(point, to: shrinkView)
        return shrinkView.hitTest(shrinkPoint, with: event)
    }

    private func initializePropertyIfNeeded() {
        guard !didInitializeProperty, bounds.size != .zero else {
            return
        }

        didInitializeProperty = true
        let hasSavedY = UserDefaults.standard.object(forKey: DebugAssistiveTouchLayout.positionYKey) != nil
        let y = hasSavedY ? CGFloat(UserDefaults.standard.double(forKey: DebugAssistiveTouchLayout.positionYKey)) : shrinkFrame.minY
        isShrinkAnchoredRight = UserDefaults.standard.bool(forKey: DebugAssistiveTouchLayout.isRightKey)
        let x = isShrinkAnchoredRight
            ? bounds.width - DebugAssistiveTouchLayout.shrinkSize.width - DebugAssistiveTouchLayout.margin
            : DebugAssistiveTouchLayout.margin
        shrinkFrame = CGRect(x: x, y: y, width: DebugAssistiveTouchLayout.shrinkSize.width, height: DebugAssistiveTouchLayout.shrinkSize.height)
        if !hasSavedY {
            shrinkFrame.origin.y = 200
        }
        shrinkFrame = clampedShrinkFrame(shrinkFrame)
    }

    private func initializeViews() {
        shrinkView.frame = shrinkFrame
        addSubview(shrinkView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShrinkTap))
        shrinkView.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleShrinkPan(_:)))
        shrinkView.addGestureRecognizer(pan)
    }

    private func updateShrinkFrameForCurrentBoundsIfNeeded() {
        guard lastBoundsSize != bounds.size else {
            return
        }

        lastBoundsSize = bounds.size
        shrinkFrame = clampedShrinkFrame(shrinkFrame)
    }

    private func clampedShrinkFrame(_ frame: CGRect) -> CGRect {
        let maxY = max(0, bounds.height - DebugAssistiveTouchLayout.shrinkSize.height - safeAreaInsets.bottom)
        let y = min(max(safeAreaInsets.top, frame.minY), maxY)
        let left = isShrinkAnchoredRight
            ? max(DebugAssistiveTouchLayout.margin, bounds.width - DebugAssistiveTouchLayout.shrinkSize.width - DebugAssistiveTouchLayout.margin)
            : DebugAssistiveTouchLayout.margin
        return CGRect(x: left, y: y, width: DebugAssistiveTouchLayout.shrinkSize.width, height: DebugAssistiveTouchLayout.shrinkSize.height)
    }

    @objc private func handleShrinkTap() {
        touch.expand(from: shrinkFrame)
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
            UserDefaults.standard.set(Double(shrinkFrame.minY), forKey: DebugAssistiveTouchLayout.positionYKey)
            UserDefaults.standard.set(isShrinkAnchoredRight, forKey: DebugAssistiveTouchLayout.isRightKey)
            shrinkView.frame = shrinkFrame
        }
    }
}

final class DebugAssistiveTouchWindow: UIWindow {
    private let touch: DebugAssistiveTouch
    private let coverView = UIView()
    private let panelView: DebugAssistiveTouchPanelView
    private let shrinkView = DebugAssistiveTouchShrinkView()
    private var isExpanded = false
    private var collapsedFrame = CGRect(origin: CGPoint(x: 8, y: 200), size: DebugAssistiveTouchLayout.shrinkSize)
    private weak var previousKeyWindow: UIWindow?
    private lazy var debugRootViewController = DebugAssistiveTouchRootViewController(window: self)

    var onDidShrink: (() -> Void)?

    var orientationSourceViewController: UIViewController? {
        previousKeyWindow?.rootViewController ?? touch.hostRootViewController
    }

    override var canBecomeKey: Bool {
        isExpanded
    }

    init(windowScene: UIWindowScene, touch: DebugAssistiveTouch) {
        self.touch = touch
        self.panelView = DebugAssistiveTouchPanelView(touch: touch)
        super.init(windowScene: windowScene)

        frame = windowScene.coordinateSpace.bounds
        backgroundColor = .clear
        isHidden = true
        initializeViews()

        panelView.alpha = 0
        panelView.frame = collapsedFrame
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrameForCurrentSceneIfNeeded()
        coverView.frame = bounds
        if isExpanded {
            panelView.frame = expandedFrame()
        } else {
            shrinkView.frame = collapsedFrame
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isExpanded else {
            return nil
        }

        if panelView.frame.contains(point) {
            let panelPoint = convert(point, to: panelView)
            return panelView.hitTest(panelPoint, with: event)
        }

        let coverPoint = convert(point, to: coverView)
        return coverView.hitTest(coverPoint, with: event)
    }

    func expand(from shrinkFrame: CGRect) {
        guard !isExpanded else {
            return
        }

        collapsedFrame = shrinkFrame
        previousKeyWindow = windowScene?.windows.first { $0.isKeyWindow && $0 !== self }
        isExpanded = true
        rootViewController = debugRootViewController
        isHidden = false
        makeKey()
        setNeedsLayout()
        layoutIfNeeded()
        panelView.frame = collapsedFrame
        shrinkView.frame = collapsedFrame
        shrinkView.alpha = 1
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.coverView.alpha = 1
            self.panelView.alpha = 1
            self.panelView.frame = self.expandedFrame()
            self.shrinkView.alpha = 0
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
        onDidShrink?()
        previousKeyWindow?.makeKey()
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.coverView.alpha = 0
            self.panelView.alpha = 0
        } completion: { _ in
            self.isHidden = true
            self.rootViewController = nil
            self.previousKeyWindow = nil
            self.panelView.frame = self.collapsedFrame
            self.panelView.alpha = 1
        }
    }

    private func initializeViews() {
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.08)
        coverView.alpha = 0
        addSubview(coverView)

        shrinkView.alpha = 0
        shrinkView.frame = collapsedFrame
        addSubview(shrinkView)

        panelView.alpha = 0
        panelView.layer.masksToBounds = true
        panelView.layer.cornerRadius = 20
        panelView.onActionSelected = { [weak self] in
            self?.shrink()
        }
        addSubview(panelView)

        let coverTap = UITapGestureRecognizer(target: self, action: #selector(handleCoverTap))
        coverView.addGestureRecognizer(coverTap)
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

    @objc private func handleCoverTap() {
        shrink()
    }

    @objc func lookin_shouldCaptureImage() -> Bool {
        return false
    }
}

private final class DebugAssistiveTouchRootViewController: UIViewController {
    private unowned let debugWindow: DebugAssistiveTouchWindow

    init(window: DebugAssistiveTouchWindow) {
        self.debugWindow = window
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var shouldAutorotate: Bool {
        debugWindow.orientationSourceViewController?.shouldAutorotate ?? false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let mask = debugWindow.orientationSourceViewController?.supportedInterfaceOrientations,
           !mask.isEmpty {
            return mask
        }

        return debugWindow.windowScene?.interfaceOrientation.debugMenuInterfaceOrientationMask ?? .portrait
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        debugWindow.orientationSourceViewController?.preferredInterfaceOrientationForPresentation
            ?? debugWindow.windowScene?.interfaceOrientation
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
