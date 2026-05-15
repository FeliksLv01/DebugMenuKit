import UIKit

final class DebugAssistiveTouchShrinkView: UIView {
    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private let iconView = DebugAssistiveTouchIconView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        clipsToBounds = true
        layer.cornerRadius = 14
        layer.masksToBounds = true
        addSubview(backgroundView)
        addSubview(iconView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        backgroundView.layer.cornerRadius = layer.cornerRadius
        backgroundView.layer.masksToBounds = true
        iconView.frame = bounds
    }
}

final class DebugAssistiveTouchIconView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        contentMode = .redraw
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        var white: CGFloat = 0.25
        var padding: CGFloat = 7
        for _ in 0..<3 {
            white += 0.25
            let circleRect = rect.insetBy(dx: padding, dy: padding)
            context.setFillColor(UIColor(white: white, alpha: 1).cgColor)
            context.fillEllipse(in: circleRect)
            padding += 5
        }
    }
}
