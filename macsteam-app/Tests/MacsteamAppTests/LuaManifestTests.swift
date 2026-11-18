import XCTest
@testable import MacsteamApp

final class LuaManifestTests: XCTestCase {
    private let key = String(repeating: "ab", count: 32)

    func testKeylessScript() {
        let s = LuaManifestParser.parse("""
        -- Game (AppID: 100)
        addappid(100)
        """)
        XCTAssertEqual(s.mainAppID, 100)
        XCTAssertTrue(s.depotKeys.isEmpty)
        XCTAssertTrue(s.dlcAppIDs.isEmpty)
    }

    func testDepotKeyAndOwner() {
        let s = LuaManifestParser.parse("""
        addappid(100)
        addappid(101, 1, "\(key.uppercased())")
        addappid(200) -- DLC
        addappid(201, 1, "\(key)")
        """)
        XCTAssertEqual(s.depotKeys.map(\.depotID), [101, 201])
        XCTAssertEqual(s.depotKeys[0].key, key)             // lowercased
        XCTAssertEqual(s.dlcAppIDs, [200])
        XCTAssertEqual(s.depotOwner[101], 100)
        XCTAssertEqual(s.depotOwner[201], 200)              // follows the DLC above it
        XCTAssertEqual(s.parentByApp[200], 100)
    }

    func testManifestGIDs() {
        let s = LuaManifestParser.parse(#"setManifestid(101, "123456789", 0)"#)
        XCTAssertEqual(s.manifests.count, 1)
        XCTAssertEqual(s.manifests[0].depotID, 101)
        XCTAssertEqual(s.manifests[0].manifestGID, "123456789")
    }

    func testNamesFromHeadingAndComment() {
        let s = LuaManifestParser.parse("""
        addappid(100) -- Main Game
        -- Cool DLC (AppID: 200)
        addappid(200)
        """)
        XCTAssertEqual(s.appNames[100], "Main Game")
        XCTAssertEqual(s.appNames[200], "Cool DLC")
    }

    func testMalformedInputDoesNotCrash() {
        XCTAssertNil(LuaManifestParser.parse("").mainAppID)
        XCTAssertNil(LuaManifestParser.parse("addappid(abc)\n-- (AppID:").mainAppID)
        XCTAssertTrue(LuaManifestParser.parse(#"addappid(1, 1, "zz")"#).depotKeys.isEmpty)
    }

    func testSteamVersionParse() {
        XCTAssertEqual(MacCrab.parseVersion("{\n  \"version\" \"1794536281\"\n}"), "1794536281")
        XCTAssertNil(MacCrab.parseVersion("nothing here"))
    }

    func testDiagnosticsRedactsHomeAndHasNoKeys() {
        let r = Diagnostics.report()
        XCTAssertFalse(r.contains(NSHomeDirectory()))
        XCTAssertTrue(r.contains("Supported Steam build: \(MacCrab.supportedVersion)"))
    }
}
