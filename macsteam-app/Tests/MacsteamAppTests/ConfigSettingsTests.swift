import XCTest
@testable import MacsteamApp

final class ConfigSettingsTests: XCTestCase {
    func testCloudErrorsDefaultsOffAndRoundTrips() {
        XCTAssertFalse(MacsteamConfig.parse("HideWhatsNew: yes\n").hideCloudErrors)
        for value in ["yes", "true", "1"] {
            let config = MacsteamConfig.parse("HideCloudErrors: \(value)\nApps:\n  - 100\n")
            XCTAssertTrue(config.hideCloudErrors)
            XCTAssertEqual(MacsteamConfig.parse(config.serialize()), config)
        }
        XCTAssertFalse(MacsteamConfig.parse("HideCloudErrors: no\n").hideCloudErrors)
        XCTAssertFalse(MacsteamConfig.parse("HideCloudErrorsExtra: yes\n").hideCloudErrors)
    }

    func testCloudSettingPersistsWithoutLosingOtherConfiguration() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let file = root.appendingPathComponent("config.yaml")
        try "HideWhatsNew: yes\nApps:\n  - 100\n".write(to: file, atomically: true, encoding: .utf8)
        let store = ConfigStore(configFile: file, backupDir: root.appendingPathComponent("backups"))
        store.load()
        try store.setHideCloudErrors(true)
        store.load()
        XCTAssertTrue(store.config.hideCloudErrors)
        XCTAssertTrue(store.config.hideWhatsNew)
        XCTAssertEqual(store.config.apps, [100])
        try store.setHideCloudErrors(false)
        store.load()
        XCTAssertFalse(store.config.hideCloudErrors)
        XCTAssertTrue(store.config.hideWhatsNew)
        XCTAssertEqual(store.config.apps, [100])
    }
}
