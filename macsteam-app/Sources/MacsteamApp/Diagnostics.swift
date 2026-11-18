// Plain-text diagnostics for bug reports. Never includes depot keys or config contents.
import Foundation

enum Diagnostics {
    static func report() -> String {
        let info = Bundle.main.infoDictionary
        let v = info?["CFBundleShortVersionString"] as? String ?? "dev"
        let b = info?["CFBundleVersion"] as? String ?? "?"
        let fm = FileManager.default

        var lines = [
            "macSteam \(v) (\(b))",
            "macOS \(ProcessInfo.processInfo.operatingSystemVersionString)",
            "Supported Steam build: \(MacCrab.supportedVersion)",
            "Detected Steam build: \(MacCrab.detectedVersion() ?? "none")",
            "Client status: \(MacCrab.status())",
            "Installer status: \(SteamInstaller.status())",
            "steam.cfg present: \(fm.fileExists(atPath: Paths.steamCfgRoot.path))",
            "depotcache files: \((try? fm.contentsOfDirectory(atPath: Paths.depotCache.path).count) ?? 0)",
            "",
            "--- last Steam content_log lines ---",
        ]
        let log = Paths.steamRoot.appendingPathComponent("logs/content_log.txt")
        if let text = try? String(contentsOf: log, encoding: .utf8) {
            lines += text.split(separator: "\n").suffix(20).map(String.init)
        } else {
            lines.append("(no content_log.txt)")
        }
        return redact(lines.joined(separator: "\n"))
    }

    // Keep the home directory (and so the username) out of pasted reports.
    static func redact(_ s: String) -> String {
        s.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }
}
