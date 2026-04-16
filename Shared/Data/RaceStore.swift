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
            let (data, response) = try await session.data(from: endpoint)

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
        return races.first { $0.date >= startOfToday }
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
