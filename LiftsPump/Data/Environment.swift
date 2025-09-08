import Foundation

enum Environment {
    static func load() {
        guard let url = Bundle.main.url(forResource: ".env", withExtension: nil),
              let data = try? String(contentsOf: url) else { return }
        for line in data.split(whereSeparator: { $0.isNewline }) {
            let parts = line.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                let key = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                let value = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                setenv(key, value, 1)
            }
        }
    }
}
