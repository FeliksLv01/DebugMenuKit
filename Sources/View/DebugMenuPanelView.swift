import UIKit

final class DebugAssistiveTouchPanelView: UIView, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    private let touch: DebugAssistiveTouch
    private let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchField = UITextField(frame: .zero)

    private var currentNode: DebugMenuNode
    private var searchResults: [DebugAssistiveTouchSearchResult] = []

    var onActionSelected: (() -> Void)?

    init(touch: DebugAssistiveTouch) {
        self.touch = touch
        self.currentNode = touch.rootNode
        super.init(frame: .zero)

        initializeViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        tableView.frame = bounds
    }

    func refresh() {
        tableView.reloadData()
        if !visibleNodes.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleNodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = visibleNodes[indexPath.row]
        item.node.refreshStateIfNeeded()
        switch item.node.kind {
        case .toggle:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DebugAssistiveTouchSwitchCell.switchReuseIdentifier,
                for: indexPath
            ) as! DebugAssistiveTouchSwitchCell
            cell.configure(node: item.node, detailText: item.detailText)
            return cell
        case .selectionOption, .checkboxOption:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DebugAssistiveTouchActionCell.reuseIdentifier,
                for: indexPath
            ) as! DebugAssistiveTouchActionCell
            cell.configure(node: item.node, detailText: item.detailText)
            cell.accessoryType = item.node.isOn ? .checkmark : .none
            return cell
        default:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: DebugAssistiveTouchActionCell.reuseIdentifier,
                for: indexPath
            ) as! DebugAssistiveTouchActionCell
            cell.configure(node: item.node, detailText: item.detailText)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        header.contentView.clipsToBounds = true

        searchField.frame = CGRect(x: 10, y: 7, width: max(0, tableView.bounds.width - 20), height: 36)
        header.contentView.addSubview(searchField)

        if currentNode.parent != nil {
            let button = UIButton(type: .system)
            button.setTitle("返回", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
            button.frame = CGRect(x: 12, y: 50, width: 64, height: 44)
            button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            header.contentView.addSubview(button)

            let titleLabel = UILabel(frame: CGRect(x: 84, y: 50, width: max(0, tableView.bounds.width - 104), height: 44))
            titleLabel.text = currentNode.title
            titleLabel.textColor = .white
            titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            header.contentView.addSubview(titleLabel)
        }

        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        currentNode.parent == nil ? 50 : 94
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = visibleNodes[indexPath.row].node
        switch node.kind {
        case .group, .selectionGroup, .checkboxGroup:
            searchField.text = nil
            searchResults = []
            currentNode = node
            refresh()
        case .action(let action):
            onActionSelected?()
            action(node)
        case .info:
            tableView.deselectRow(at: indexPath, animated: true)
        case .selectionOption(let action):
            node.refreshStateIfNeeded()
            action(node)
            tableView.reloadData()
        case .toggle(let action):
            node.refreshStateIfNeeded()
            node.isOn.toggle()
            action(node)
            tableView.reloadRows(at: [indexPath], with: .none)
        case .checkboxOption(let action):
            node.refreshStateIfNeeded()
            node.isOn.toggle()
            action(node)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endEditing(true)
    }

    private var visibleNodes: [(node: DebugMenuNode, detailText: String?)] {
        if let text = searchField.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return searchResults.map { ($0.node, $0.pathText) }
        }
        return currentNode.children.map { ($0, $0.detailText) }
    }

    private func initializeViews() {
        addSubview(backgroundView)

        tableView.backgroundColor = .clear
        tableView.separatorColor = UIColor.white.withAlphaComponent(0.16)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        tableView.register(DebugAssistiveTouchActionCell.self, forCellReuseIdentifier: DebugAssistiveTouchActionCell.reuseIdentifier)
        tableView.register(DebugAssistiveTouchSwitchCell.self, forCellReuseIdentifier: DebugAssistiveTouchSwitchCell.switchReuseIdentifier)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        addSubview(tableView)

        searchField.delegate = self
        searchField.textColor = .white
        searchField.tintColor = .white
        searchField.font = .systemFont(ofSize: 16, weight: .regular)
        searchField.backgroundColor = UIColor.black.withAlphaComponent(0.18)
        searchField.borderStyle = .none
        searchField.layer.cornerRadius = 18
        searchField.layer.borderWidth = 0.5
        searchField.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        searchField.layer.masksToBounds = true
        searchField.clearButtonMode = .whileEditing
        searchField.returnKeyType = .search
        searchField.attributedPlaceholder = NSAttributedString(
            string: "搜索（支持拼音、首字母、identifier）",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.45)]
        )
        searchField.leftViewMode = .always

        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 42, height: 36))
        if #available(iOS 13.0, *) {
            let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            imageView.tintColor = UIColor.white.withAlphaComponent(0.64)
            imageView.frame = CGRect(x: 15, y: 8, width: 20, height: 20)
            iconContainer.addSubview(imageView)
        }
        searchField.leftView = iconContainer
        searchField.addTarget(self, action: #selector(searchTextDidChange), for: .editingChanged)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func searchTextDidChange() {
        searchResults = touch.search(searchField.text ?? "")
        tableView.reloadData()
    }

    @objc private func backButtonTapped() {
        guard let parent = currentNode.parent else {
            return
        }
        currentNode = parent
        refresh()
    }
}
