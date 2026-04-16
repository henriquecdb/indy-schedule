import Foundation

struct Race: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let date: Date
    let time: String?

    var hasTime: Bool {
        guard let time else { return false }
        return !time.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
