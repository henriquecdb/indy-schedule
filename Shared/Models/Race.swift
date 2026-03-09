import Foundation

struct Race: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let date: Date
}
