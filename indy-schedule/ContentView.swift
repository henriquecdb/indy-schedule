//
//  ContentView.swift
//  indy-schedule
//
//  Created by Henrique Junqueira on 02/03/26.
//

import SwiftUI

struct ContentView: View {
    private let races = RaceStore.loadRaces()

    var body: some View {
        let nextRace = RaceStore.nextRace(from: races)

        NavigationStack {
            List {
                if let nextRace {
                    Section("Proxima corrida") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(nextRace.name)
                                .font(.title3.weight(.semibold))
                            Text(RaceFormatting.raceDate(nextRace.date))
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }

                Section("Calendario 2026") {
                    ForEach(races) { race in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(race.name)
                                    .font(.headline)
                                Text(RaceFormatting.raceDate(race.date))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer(minLength: 8)

                            if nextRace?.id == race.id {
                                Text("A seguir")
                                    .font(.caption.weight(.bold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(.red.opacity(0.14), in: Capsule())
                                    .foregroundStyle(.red)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Indy Schedule")
        }
    }
}

#Preview {
    ContentView()
}
