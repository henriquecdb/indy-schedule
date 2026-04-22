import Foundation

enum RaceStore {
    struct RemoteLoadResult {
        let races: [Race]
        let loadedFromAPI: Bool
    }

    static func loadRaces(bundle: Bundle = .main) -> [Race] {
        guard let url = bundle.url(forResource: "races", withExtension: "json") else {
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

    static func loadRacesFromAPI(bundle: Bundle = .main, session: URLSession = .shared) async -> [Race] {
        let result = await self.loadRacesFromAPIResult(bundle: bundle, session: session)
        return result.races
    }

    static func loadRacesFromAPIResult(bundle: Bundle = .main, session: URLSession = .shared) async -> RemoteLoadResult {
        guard let endpoint = self.racesAPIURL(bundle: bundle) else {
            return RemoteLoadResult(races: self.loadRaces(bundle: bundle), loadedFromAPI: false)
        }

        do {
            var request = URLRequest(url: endpoint)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.timeoutInterval = 15

            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpResponse.statusCode) else {
                return RemoteLoadResult(races: self.loadRaces(bundle: bundle), loadedFromAPI: false)
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Self.dateFormatter)

            let races = try decoder.decode([Race].self, from: data)
                .sorted { $0.date < $1.date }

            return RemoteLoadResult(races: races, loadedFromAPI: true)
        } catch {
            return RemoteLoadResult(races: self.loadRaces(bundle: bundle), loadedFromAPI: false)
        }
    }

    static func nextRace(from races: [Race], now: Date = .now, calendar: Calendar = .current) -> Race? {
        let startOfToday = calendar.startOfDay(for: now)
        return races.first { race in
            if let raceDateTime = self.raceDateTime(for: race, calendar: calendar) {
                return raceDateTime >= now
            }

            return race.date >= startOfToday
        }
    }

    static func raceDateTime(for race: Race, calendar: Calendar = .current) -> Date? {
        guard race.hasTime, let time = race.time?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }

        let parts = time.split(separator: ":")
        guard
            parts.count == 2,
            let hour = Int(parts[0]),
            let minute = Int(parts[1]),
            (0 ... 23).contains(hour),
            (0 ... 59).contains(minute)
        else {
            return nil
        }

        var components = calendar.dateComponents([.year, .month, .day], from: race.date)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.date(from: components)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static func racesAPIURL(bundle: Bundle) -> URL? {
        guard
            let endpoint = bundle.object(forInfoDictionaryKey: "RACES_API_URL") as? String,
            !endpoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return URL(string: "http://localhost:8081/races")
        }

        return URL(string: endpoint)
    }
}
