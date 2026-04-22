import SwiftUI
import WidgetKit

struct NextRaceEntry: TimelineEntry {
    let date: Date
    let nextRace: Race?
}

struct NextRaceProvider: TimelineProvider {
    func placeholder(in _: Context) -> NextRaceEntry {
        NextRaceEntry(
            date: .now,
            nextRace: RaceStore.loadRaces().first,
        )
    }

    func getSnapshot(in _: Context, completion: @escaping (NextRaceEntry) -> Void) {
        Task {
            let entry = await self.makeEntry(referenceDate: .now)
            completion(entry)
        }
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<NextRaceEntry>) -> Void) {
        Task {
            let entry = await self.makeEntry(referenceDate: .now)
            let refreshDate = self.nextRefreshDate(from: entry, now: .now)
            completion(Timeline(entries: [entry], policy: .after(refreshDate)))
        }
    }

    private func makeEntry(referenceDate: Date) async -> NextRaceEntry {
        let races = await RaceStore.loadRacesFromAPI()
        return NextRaceEntry(
            date: referenceDate,
            nextRace: RaceStore.nextRace(from: races, now: referenceDate),
        )
    }

    private func nextRefreshDate(from entry: NextRaceEntry, now: Date) -> Date {
        if let nextRace = entry.nextRace,
           let raceDateTime = RaceStore.raceDateTime(for: nextRace),
           raceDateTime > now
        {
            return min(raceDateTime.addingTimeInterval(60), now.addingTimeInterval(3600))
        }

        return now.addingTimeInterval(3600)
    }
}

struct IndyScheduleWidgetEntryView: View {
    var entry: NextRaceProvider.Entry
    @Environment(\.widgetRenderingMode) private var renderingMode

    private var isFullColor: Bool {
        self.renderingMode == .fullColor
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Proxima corrida")
                .font(.caption.weight(.semibold))
                .foregroundStyle(self.isFullColor ? .white.opacity(0.78) : .secondary)

            if let race = entry.nextRace {
                Text(race.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(self.isFullColor ? .white : .primary)
                    .lineLimit(3)

                Spacer(minLength: 0)

                Label(RaceFormatting.widgetDate(race.date), systemImage: "calendar")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(self.isFullColor ? .white : .primary)

                if race.hasTime {
                    Label(RaceFormatting.raceTime(race.time), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(self.isFullColor ? .white.opacity(0.85) : .secondary)
                }
            } else {
                Spacer(minLength: 0)

                Text("Temporada encerrada")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(self.isFullColor ? .white : .primary)

                Text("Atualize o JSON com o proximo calendario.")
                    .font(.subheadline)
                    .foregroundStyle(self.isFullColor ? .white.opacity(0.82) : .secondary)
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            if self.isFullColor {
                LinearGradient(
                    colors: [Color(red: 0.12, green: 0.13, blue: 0.19), Color(red: 0.72, green: 0.07, blue: 0.10)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing,
                )
            } else {
                Color.black.opacity(0.10)
            }
        }
    }
}

struct IndyScheduleWidget: Widget {
    let kind = "IndyScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: self.kind, provider: NextRaceProvider()) { entry in
            IndyScheduleWidgetEntryView(entry: entry)
        }
        .containerBackgroundRemovable(false)
        .configurationDisplayName("Proxima corrida da Indy")
        .description("Mostra a proxima etapa do calendario em um widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct IndyScheduleWidgetBundle: WidgetBundle {
    var body: some Widget {
        IndyScheduleWidget()
    }
}
