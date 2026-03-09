import SwiftUI
import WidgetKit

struct NextRaceEntry: TimelineEntry {
    let date: Date
    let nextRace: Race?
}

struct NextRaceProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextRaceEntry {
        NextRaceEntry(
            date: .now,
            nextRace: RaceStore.loadRaces().first
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (NextRaceEntry) -> Void) {
        completion(makeEntry(referenceDate: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextRaceEntry>) -> Void) {
        let entry = makeEntry(referenceDate: .now)
        let refreshDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: .now)) ?? .now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func makeEntry(referenceDate: Date) -> NextRaceEntry {
        let races = RaceStore.loadRaces()
        return NextRaceEntry(
            date: referenceDate,
            nextRace: RaceStore.nextRace(from: races, now: referenceDate)
        )
    }
}

struct IndyScheduleWidgetEntryView: View {
    var entry: NextRaceProvider.Entry

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.13, blue: 0.19), Color(red: 0.72, green: 0.07, blue: 0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 10) {
                Text("Proxima corrida")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.78))

                if let race = entry.nextRace {
                    Text(race.name)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .lineLimit(3)

                    Spacer(minLength: 0)

                    Label(RaceFormatting.widgetDate(race.date), systemImage: "calendar")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                } else {
                    Spacer(minLength: 0)

                    Text("Temporada encerrada")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("Atualize o JSON com o proximo calendario.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                }
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct IndyScheduleWidget: Widget {
    let kind = "IndyScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextRaceProvider()) { entry in
            IndyScheduleWidgetEntryView(entry: entry)
        }
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
