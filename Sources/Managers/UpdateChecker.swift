import AppKit
import Foundation

@MainActor
final class UpdateChecker {
    private let owner = "jinsh1210"
    private let repo = "YTMusicMac"

    func checkForUpdates() {
        Task {
            await performCheck()
        }
    }

    private func performCheck() async {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/releases/latest"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        guard let (data, _) = try? await URLSession.shared.data(for: request),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tagName = json["tag_name"] as? String
        else {
            showAlert(title: "업데이트 확인 실패", message: "서버에 연결할 수 없습니다. 잠시 후 다시 시도해 주세요.")
            return
        }

        let latestVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

        if isNewer(latestVersion, than: currentVersion) {
            let htmlURL = json["html_url"] as? String ?? "https://github.com/\(owner)/\(repo)/releases"
            showUpdateAvailable(current: currentVersion, latest: latestVersion, releaseURL: htmlURL)
        } else {
            showAlert(title: "최신 버전입니다", message: "현재 버전 \(currentVersion)은 최신 버전입니다.")
        }
    }

    private func showUpdateAvailable(current: String, latest: String, releaseURL: String) {
        let alert = NSAlert()
        alert.messageText = "새 버전이 있습니다"
        alert.informativeText = "현재 버전: \(current)\n최신 버전: \(latest)\n\nGitHub에서 최신 버전을 다운로드할 수 있습니다."
        alert.addButton(withTitle: "GitHub에서 다운로드")
        alert.addButton(withTitle: "나중에")

        if alert.runModal() == .alertFirstButtonReturn, let url = URL(string: releaseURL) {
            NSWorkspace.shared.open(url)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "확인")
        alert.runModal()
    }

    private func isNewer(_ latest: String, than current: String) -> Bool {
        let l = latest.split(separator: ".").compactMap { Int($0) }
        let c = current.split(separator: ".").compactMap { Int($0) }
        let count = max(l.count, c.count)
        for i in 0 ..< count {
            let lv = i < l.count ? l[i] : 0
            let cv = i < c.count ? c[i] : 0
            if lv != cv { return lv > cv }
        }
        return false
    }
}
