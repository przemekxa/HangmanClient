//
//  GameView.swift
//  HangmanClient
//
//  Created by Przemek Ambroży on 03/01/2021.
//

import SwiftUI

struct GameView: View {

    @ObservedObject
    var viewModel: GameViewModel

    @State
    private var guessed = ""

    var body: some View {
        HStack(alignment: .center, spacing: 0.0) {

            List(viewModel.players.indices) { i in
                PlayerInGameCellView(player: $viewModel.players[i])
            }
            .listStyle(SidebarListStyle())
            .frame(maxWidth: 300.0)

            VStack(alignment: .center, spacing: 16.0) {
                Text("Gra")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack {
                    Text("Pozostały czas:")
                    Text(viewModel.remainingTime)
                        .font(.headline)
                }

                if viewModel.you.guessed {
                    guessedWord
                } else {
                    wordToBeGuessed
                    if viewModel.you.remainingHealth > 0 {
                        wordGuessing
                    } else {
                        noMoreHealth
                    }
                }

                yourStats

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
    }

    // Show word and empty fields
    private var wordToBeGuessed: some View {
        GroupBox(label: Text("Słowo do odgadnięcia")) {

            VStack(alignment: .center, spacing: 12.0) {
                Text("Puste pola oznaczają miejsca, w których brakuje liter.")

                WordView(chars: $viewModel.word)
                    .padding(8.0)
                    .cornerRadius(8.0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8.0)
                                    .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                    )
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8.0)

        }
    }

    // Show a field to enter a letter or a word
    private var wordGuessing: some View {
        GroupBox(label: Text("Odgadnij")) {

            VStack(alignment: .center, spacing: 12.0) {

                Text("Wpisz literę lub całe słowo, które chcesz odgadnąć")

                TextField("Odgadywana litera lub słowo", text: $guessed)

                Button(action: {
                    self.viewModel.guess(guessed)
                    self.guessed = ""
                }, label: {
                    Text(guessed.count <= 1 ? "Odgadnij literę" : "Odgadnij słowo")
                        .frame(minWidth: 100)
                })
                .disabled(guessed.count == 0)

            }
            .padding(8.0)
        }
    }

    // Show an information about no more health left
    private var noMoreHealth: some View {
        GroupBox(label: Text("Brak żyć"), content: {
            Text("Nie masz już żyć, aby grać dalej.")
                .frame(maxWidth: .infinity)
                .padding()
        })
    }

    // Show an information about winning the game
    private var guessedWord: some View {
        GroupBox(label: Text("Wygrana")) {

            VStack(alignment: .center, spacing: 12.0) {
                Text("Gratulacje!")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 16.0)
                Text("Udało Ci się odgadnąć słowo:")
                Text(String(viewModel.word.compactMap { $0 }))
                    .font(.system(size: 16.0, weight: .bold, design: .monospaced))
            }
            .padding(.vertical, 8.0)
            .frame(maxWidth: .infinity)

        }
    }

    // Show player statistics
    private var yourStats: some View {
        GroupBox(label: Text("Twoje statystyki")) {

            VStack(alignment: .leading, spacing: 12.0) {

                HStack {
                    Text("Punkty:")
                        .font(.headline)
                        .fontWeight(.regular)
                    Text(String(viewModel.you.points))
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }

                HStack {
                    Text("Życie:")
                        .font(.headline)
                        .fontWeight(.regular)
                    Text(String(repeating: "❤️", count: Int(viewModel.you.remainingHealth)))
                }
            }
            .padding(8.0)
        }
    }

}

struct GameView_Previews: PreviewProvider {

    static let players = [
        PlayerInGame(id: 123,
                     nick: "You",
                     points: 100,
                     remainingHealth: 4,
                     guessed: false),
        PlayerInGame(id: 456,
                     nick: "Player 2",
                     points: 201,
                     remainingHealth: 1,
                     guessed: false),
        PlayerInGame(id: 789,
                     nick: "Player 3",
                     points: 1000,
                     remainingHealth: 4,
                     guessed: true)
    ]

    static let status = GameStatus(endTime: Date().addingTimeInterval(45),
                                   players: players,
                                   word: ["a", "b", nil, nil, "e"])

    static var previews: some View {
        GameView(viewModel: GameViewModel(Connection(hostname: "127.0.0.1", port: 1234),
                                          playerID: 123,
                                          initialStatus: status))
            .frame(width: 800, height: 600.0)
    }
}
