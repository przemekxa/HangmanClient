//
//  InRoomView.swift
//  ExampleUI
//
//  Created by Przemek Ambroży on 04/12/2020.
//

import SwiftUI

struct InRoomView: View {

    @State
    private var players = ["Jeden", "Dwa"]

    @State
    private var ready = false

    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {

            VStack(alignment: .leading, spacing: 16.0) {

                GroupBox(label: Text("PIN"), content: {
                    Text("123456")
                        .kerning(8.0)
                        .font(.system(size: 32.0, weight: .semibold, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(4.0)
                })

                GroupBox(label: Text("Ustawienia pokoju")) {
                    HStack(alignment: .center, spacing: 16.0) {
                        Text(["🌐 Język",
                              "🔢 Długość słowa",
                              "⏰ Długość gry",
                              "❤️ Punkty zdrowia",
                              "👤 Max. graczy"].joined(separator: "\n"))
                            .lineSpacing(8.0)
                            .multilineTextAlignment(.trailing)

                        Divider()

                        Text(["🇵🇱 Polski",
                              "10 liter",
                              "2:40",
                              "2 punkty zdrowia",
                              "2 graczy"].joined(separator: "\n"))
                            .lineSpacing(8.0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(8.0)
                }

                VStack(alignment: .center, spacing: 8.0) {
                    Text("Gotowy do gry?")
                        .font(.headline)

                    Picker(selection: $ready, label: EmptyView()) {
                        Text("❌ Nie gotowy").tag(false)
                        Text("✅ Gotowy").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Spacer()

                HStack {
                    Button("Opuść pokój", action: {})
                    Button(action: {}, label: {
                        Text("🎮 Graj")
                            .fontWeight(.semibold)
                    })
                    .padding(.leading, 4.0)
                }
            }
            

            GroupBox(label: Text("Gracze")) {
                ScrollView {
                    ForEach(players, id: \.self) { p in
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(p)
                                    .font(.headline)
                                Text(p == "Jeden" ? "✅ Gotowy" : "❌ Nie gotowy")
                                    .font(.caption)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 8) {
                                Button("Wyrzuć", action: {
                                    print("Wyrzucam gracza \(p)")
                                })
                                Button("Zarządzaj", action: {
                                    print("Gracz \(p) zostaje zarządcą")
                                })
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8.0)
                        .padding(.horizontal, 16.0)
                        Divider()
                    }
                }
            }
            .transition(.identity)



        }
        .padding(16.0)
    }
}

struct InRoomView_Previews: PreviewProvider {
    static var previews: some View {
        InRoomView()
            .frame(width: 800, height: 600.0)
    }
}
