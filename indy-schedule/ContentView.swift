//
//  ContentView.swift
//  indy-schedule
//
//  Created by Henrique Junqueira on 02/03/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var races: [Race] = RaceStore.loadRaces(bundle: .main)
    @State private var isRefreshing = false
    @State private var didInitialRefresh = false

    @AppStorage("lastRacesFetchAttemptAt") private var lastFetchAttemptAt: Double = 0
    @AppStorage("lastRacesFetchSucceeded") private var lastFetchSucceeded = false
    @AppStorage("lastRacesSuccessfulFetchAt") private var lastSuccessfulFetchAt: Double = 0

    private let successfulAutoRefreshInterval: TimeInterval = 60 * 30
    private let failedAutoRefreshInterval: TimeInterval = 60 * 5

    var body: some View {
        let nextRace = RaceStore.nextRace(from: self.races)
        let startOfToday = Calendar.current.startOfDay(for: .now)

        NavigationStack {
            List {
                if let nextRace {
                    let round = (races.firstIndex(where: { $0.id == nextRace.id }) ?? 0) + 1
                    Section("Próxima corrida") {
                        NextRaceCard(race: nextRace, roundNumber: round)
                    }
                }

                Section("Calendário 2026") {
                    ForEach(Array(self.races.enumerated()), id: \.element.id) { index, race in
                        RaceRow(
                            race: race,
                            roundNumber: index + 1,
                            isNext: nextRace?.id == race.id,
                            isPast: self.isPastRace(race, startOfToday: startOfToday),
                        )
                    }
                }
            }
            .navigationTitle("Indy Schedule")
            .safeAreaInset(edge: .bottom) {
                TimelineView(.periodic(from: .now, by: 60)) { context in
                    HStack {
                        Text(self.lastUpdateDescription(relativeTo: context.date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                    .background(.ultraThinMaterial)
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await self.refreshRaces(force: true)
                        }
                    } label: {
                        if self.isRefreshing {
                            ProgressView()
                        } else {
                            Label("Atualizar", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(self.isRefreshing)
                }
            }
        }
        .task {
            guard !self.didInitialRefresh else { return }

            self.didInitialRefresh = true
            await self.refreshRaces(force: true)
        }
        .onChange(of: self.scenePhase) { _, newValue in
            guard newValue == .active else { return }

            Task {
                await self.refreshRaces(force: false)
            }
        }
    }

    private func isPastRace(_ race: Race, startOfToday: Date) -> Bool {
        if let raceDateTime = RaceStore.raceDateTime(for: race) {
            return raceDateTime < .now
        }

        return race.date < startOfToday
    }

    private func lastUpdateDescription(relativeTo now: Date) -> String {
        guard self.lastSuccessfulFetchAt > 0 else {
            return "Última atualização: ainda não sincronizado"
        }

        let date = Date(timeIntervalSince1970: self.lastSuccessfulFetchAt)
        let seconds = max(0, Int(now.timeIntervalSince(date)))

        if seconds < 5 {
            return "Última atualização: agora"
        }

        if seconds < 60 {
            return "Última atualização: há \(seconds)s"
        }

        if seconds < 3600 {
            return "Última atualização: há \(seconds / 60)min"
        }

        if seconds < 86400 {
            return "Última atualização: há \(seconds / 3600)h"
        }

        return "Última atualização: há \(seconds / 86400)d"
    }

    @MainActor
    private func refreshRaces(force: Bool) async {
        if self.isRefreshing {
            return
        }

        let now = Date().timeIntervalSince1970
        let autoRefreshInterval = self.lastFetchSucceeded ? self.successfulAutoRefreshInterval : self.failedAutoRefreshInterval
        if !force, now - self.lastFetchAttemptAt < autoRefreshInterval {
            return
        }

        self.isRefreshing = true

        let result = await RaceStore.loadRacesFromAPIResult(bundle: .main)
        self.races = result.races
        self.lastFetchAttemptAt = Date().timeIntervalSince1970
        self.lastFetchSucceeded = result.loadedFromAPI
        if result.loadedFromAPI {
            self.lastSuccessfulFetchAt = self.lastFetchAttemptAt
        }
        self.isRefreshing = false
    }
}

private struct NextRaceCard: View {
    let race: Race
    let roundNumber: Int

    private var daysUntil: Int {
        Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: .now),
            to: self.race.date,
        ).day ?? 0
    }

    private var countdown: String {
        switch self.daysUntil {
        case 0: "Hoje"
        case 1: "Amanhã"
        default: "em \(self.daysUntil) dias"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Etapa \(self.roundNumber)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(self.countdown)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)
            }
            Text(self.race.name)
                .font(.title3.weight(.semibold))
            Text(RaceFormatting.raceDate(self.race.date))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if self.race.hasTime {
                Label(RaceFormatting.raceTime(self.race.time), systemImage: "clock")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

private struct RaceRow: View {
    let race: Race
    let roundNumber: Int
    let isNext: Bool
    let isPast: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text("\(self.roundNumber)")
                .font(.caption.monospacedDigit().weight(.medium))
                .foregroundStyle(.tertiary)
                .frame(width: 20, alignment: .trailing)

            VStack(alignment: .leading, spacing: 2) {
                Text(self.race.name)
                    .font(.subheadline.weight(self.isNext ? .semibold : .regular))
                Text(RaceFormatting.raceDate(self.race.date))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if self.race.hasTime {
                    Text(RaceFormatting.raceTime(self.race.time))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            if self.isNext {
                Text("A seguir")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.red.opacity(0.12), in: Capsule())
                    .foregroundStyle(.red)
            } else if self.isPast {
                Text("Encerrada")
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.gray.opacity(0.15), in: Capsule())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
        .opacity(self.isPast ? 0.4 : 1)
    }
}

#Preview {
    ContentView()
}
