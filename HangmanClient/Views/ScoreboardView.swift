//
//  ScoreboardView.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 05/01/2021.
//

import SwiftUI

struct ScoreboardView: View {

    let viewModel: ScoreboardViewModel

    @State
    private var selection = Set<PlayerScoreboard>()

    var body: some View {
        VStack {
            Text("Wyniki")
                .font(.title)
                .fontWeight(.bold)

            List(viewModel.scoreboard, id: \.self, selection: $selection) { player in
                VStack {
                    HStack(alignment: .center, spacing: 8.0) {
                        VStack(alignment: .leading, spacing: 0.0) {
                            Text("Gracz:")
                                .font(.caption)
                            HStack {
                                Text(player.nick)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Text("(#" + String(player.id) + ")")
                                    .font(.caption)
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 0.0) {
                            Text("Punkty:")
                                .font(.caption)
                            Text(String(player.points))
                                .font(.headline)
                        }
                    }
                    .padding(.horizontal, 16.0)
                    .padding(.vertical, 4.0)
                    Divider()
                }
            }
        }
        .padding()
    }
}

struct ScoreboardView_Previews: PreviewProvider {

    static let players = [
        PlayerScoreboard(id: 1, nick: "First", points: 1200),
        PlayerScoreboard(id: 2, nick: "Second", points: 1000),
        PlayerScoreboard(id: 3, nick: "Third", points: 800),
        PlayerScoreboard(id: 4, nick: "Fourth", points: 600)
    ]

    static var previews: some View {
        ScoreboardView(viewModel: ScoreboardViewModel(
                        Connection(hostname: "127.0.0.1", port: 1234),
                        scoreboard: players))
            .frame(width: 800, height: 600.0)
    }
}
