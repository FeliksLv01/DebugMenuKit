import UIKit

class DebugAssistiveTouchActionCell: UITableViewCell {
    static let reuseIdentifier = "DebugAssistiveTouchActionCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        textLabel?.textColor = .white
        textLabel?.font = .systemFont(ofSize: 16)
        detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.68)
        detailTextLabel?.font = .systemFont(ofSize: 12)
        tintColor = .white
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(node: DebugMenuNode, detailText: String?) {
        textLabel?.text = node.title
        textLabel?.textColor = node.isHighlighted ? .systemRed : .white
        detailTextLabel?.text = detailText

        if case .group = node.kind {
            configureDisclosureAccessory()
        } else if case .selectionGroup = node.kind {
            configureDisclosureAccessory()
        } else if case .checkboxGroup = node.kind {
            configureDisclosureAccessory()
        } else if case .action = node.kind {
            configureDisclosureAccessory()
        } else {
            accessoryView = nil
            accessoryType = .none
        }
    }

    private func configureDisclosureAccessory() {
        accessoryType = .none
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .white
        imageView.contentMode = .center
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        accessoryView = imageView
    }
}

final class DebugAssistiveTouchSwitchCell: DebugAssistiveTouchActionCell {
    static let switchReuseIdentifier = "DebugAssistiveTouchSwitchCell"
    private let switchControl = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryView = switchControl
        switchControl.isUserInteractionEnabled = false
    }

    override func configure(node: DebugMenuNode, detailText: String?) {
        super.configure(node: node, detailText: detailText)
        accessoryView = switchControl
        switchControl.setOn(node.isOn, animated: false)
    }
}
