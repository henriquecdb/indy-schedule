import Foundation

enum RaceStore {
    static func loadRaces() -> [Race] {
        guard let url = Bundle.main.url(forResource: "races", withExtension: "json") else {
            assertionFailure("Missing races.json in bundle")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Self.dateFormatter)

            return try decoder.decode([Race].self, from: data)
                .sorted { $0.date < $1.date }
        } catch {
            assertionFailure("Failed to load races.json: \(error)")
            return []
        }
    }

    static func nextRace(from races: [Race], now: Date = .now, calendar: Calendar = .current) -> Race? {
        let startOfToday = calendar.startOfDay(for: now)
        return races.first { $0.date >= startOfToday }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
