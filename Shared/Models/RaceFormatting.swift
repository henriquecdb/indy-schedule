import Foundation

enum RaceFormatting {
    static func raceDate(_ date: Date) -> String {
        self.raceDateFormatter.string(from: date)
    }

    static func raceTime(_ time: String?, placeholder: String = "Horário a definir") -> String {
        guard let time, !time.isEmpty else { return placeholder }
        return time
    }

    static func widgetDate(_ date: Date) -> String {
        self.widgetDateFormatter.string(from: date)
    }

    private static let raceDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "d 'de' MMMM"
        return formatter
    }()

    private static let widgetDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "d MMM"
        return formatter
    }()
}
