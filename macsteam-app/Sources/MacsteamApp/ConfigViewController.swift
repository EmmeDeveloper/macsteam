// Mac-friendly editor for config.yaml.

import AppKit

final class ConfigViewController: NSViewController {
    let store: ConfigStore

    private var detailContainer: NSView!
    private var currentSection: Section = .settings

    var hideWhatsNewSwitch: NSSwitch!
    private var hideCloudErrorsSwitch: NSSwitch!

    private var appsCardList: AppCardListView?

    enum Section: String, CaseIterable {
        case settings = "macSteam Settings"
        case apps = "Apps"

        var symbol: String {
            switch self {
            case .settings:  return "gearshape"
            case .apps:      return "app.badge"
            }
        }

        var title: String { L10n.text(rawValue) }
    }

    init(store: ConfigStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - View

    override func loadView() {
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 540, height: 520))
        root.translatesAutoresizingMaskIntoConstraints = false
        detailContainer = root
        view = root
        showDetail(for: currentSection)
    }

    func select(section: Section) {
        _ = view   // force loadView() if the pane has never been shown
        showDetail(for: section)
    }

    func reloadFromStore() {
        if isViewLoaded {
            showDetail(for: currentSection)
        }
    }

    private func persisting(_ work: () throws -> Void) {
        do {
            try work()
        } catch {
            NSSound.beep()
            presentAlert(L10n.text("Couldn’t save config"), error.localizedDescription, style: .warning)
        }
    }

    private func confirmDestructive(_ message: String, informative: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = informative
        alert.alertStyle = .warning
        alert.addButton(withTitle: L10n.text("Remove"))     // .alertFirstButtonReturn
        alert.addButton(withTitle: L10n.text("Cancel"))     // .alertSecondButtonReturn
        return alert.runModal() == .alertFirstButtonReturn
    }

    // MARK: - Detail routing

    private func showDetail(for section: Section) {
        currentSection = section
        appsCardList = nil

        detailContainer.subviews.forEach { $0.removeFromSuperview() }

        let content: NSView
        switch section {
        case .settings:  content = buildSettingsDetail()
        case .apps:      content = buildAppsDetail()
        }
        content.translatesAutoresizingMaskIntoConstraints = false

        detailContainer.addSubview(content)
        let m = Metrics.paneMargin
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: detailContainer.topAnchor, constant: m),
            content.leadingAnchor.constraint(equalTo: detailContainer.leadingAnchor, constant: m),
            content.trailingAnchor.constraint(equalTo: detailContainer.trailingAnchor, constant: -m),
            content.bottomAnchor.constraint(equalTo: detailContainer.bottomAnchor, constant: -m),
        ])
    }

    private func buildSettingsDetail() -> NSView {
        hideWhatsNewSwitch = NSSwitch()
        hideWhatsNewSwitch.state = store.config.hideWhatsNew ? .on : .off
        hideWhatsNewSwitch.target = self
        hideWhatsNewSwitch.action = #selector(settingsChanged)
        hideWhatsNewSwitch.setAccessibilityLabel(L10n.text("Hide What's New shelf"))

        hideCloudErrorsSwitch = NSSwitch()
        hideCloudErrorsSwitch.state = store.config.hideCloudErrors ? .on : .off
        hideCloudErrorsSwitch.target = self
        hideCloudErrorsSwitch.action = #selector(cloudErrorsChanged)
        hideCloudErrorsSwitch.setAccessibilityLabel(L10n.text("Hide Steam Cloud errors"))

        let togglesCard = SettingsCard(rows: [
            SettingRow(title: L10n.text("Hide What's New shelf"),
                       subtitle: nil,
                       control: hideWhatsNewSwitch),
            SettingRow(title: L10n.text("Hide Steam Cloud errors"),
                       subtitle: L10n.text("Hide error indicators and notifications; skip launch warnings. Cloud sync stays on. Restart Steam to apply."),
                       control: hideCloudErrorsSwitch),
        ])

        let generalHeader = settingsGroupLabel(L10n.text("General"))

        let copyBtn = NSButton(title: L10n.text("Copy Diagnostics"), target: self,
                               action: #selector(copyDiagnostics))
        copyBtn.bezelStyle = .rounded
        let diagCard = SettingsCard(rows: [
            SettingRow(title: L10n.text("Copy diagnostics for a bug report"),
                       subtitle: L10n.text("Versions, status and recent Steam log lines. No keys."),
                       control: copyBtn),
        ])
        let diagHeader = settingsGroupLabel("Support")

        let stack = NSStackView(views: [generalHeader, togglesCard, diagHeader, diagCard])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 6
        stack.setCustomSpacing(6, after: generalHeader)
        stack.translatesAutoresizingMaskIntoConstraints = false
        togglesCard.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        diagCard.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        stack.setCustomSpacing(20, after: togglesCard)

        let root = NSView()
        root.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(stack)
        let m = Metrics.paneMargin
        let maxWidth = stack.widthAnchor.constraint(lessThanOrEqualToConstant: Metrics.formColumnWidth)
        let wantWidth = stack.widthAnchor.constraint(equalToConstant: Metrics.formColumnWidth)
        wantWidth.priority = .defaultHigh
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: root.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: root.centerXAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: root.leadingAnchor, constant: m),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: root.trailingAnchor, constant: -m),
            maxWidth,
            wantWidth,
        ])
        return root
    }

    @objc private func settingsChanged() {
        persisting { try store.setHideWhatsNew(hideWhatsNewSwitch.state == .on) }
    }

    @objc private func cloudErrorsChanged() {
        persisting { try store.setHideCloudErrors(hideCloudErrorsSwitch.state == .on) }
    }

    @objc private func copyDiagnostics() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(Diagnostics.report(), forType: .string)
        presentAlert("Diagnostics copied", "Paste it into your GitHub issue.")
    }

    // MARK: Apps detail (Steam game cards)

    private func buildAppsDetail() -> NSView {
        let list = AppCardListView(store: store)
        list.performRemoval = { [weak self] ids in
            guard let self else { return false }
            var ok = true
            self.persisting {
                do { try self.store.removeApps(ids) }
                catch { ok = false; throw error }
            }
            return ok
        }
        list.confirmRemoval = { [weak self, weak list] removed in
            guard let self, let list else { return true }
            let baseGames = removed.filter { list.dlcCount(for: $0) > 0 }
            if let game = baseGames.first, removed.count > 1 {
                let n = list.dlcCount(for: game)
                return self.confirmDestructive(
                    L10n.format("Remove %1$@ and its %2$@ DLC?", list.displayName(for: game), n),
                    informative: L10n.text("This removes the game and its DLC from the macSteam configuration. macSteam will no longer unlock the title."))
            }
            let formatter = ListFormatter()
            formatter.locale = L10n.locale()
            let displayNames = removed.map { list.displayName(for: $0) }
            let names = formatter.string(from: displayNames) ?? displayNames.joined(separator: ", ")
            let titleNoun = removed.count > 1 ? L10n.text("these titles") : L10n.text("the title")
            return self.confirmDestructive(
                L10n.format("Remove %1$@?", names),
                informative: L10n.format("This removes %1$@ from the macSteam configuration. macSteam will no longer unlock %2$@.", names, titleNoun))
        }
        appsCardList = list
        return list.listView
    }

}
