//
//  Weight.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 11/5/25.
//

import SwiftUI

struct Weight: View {
    @State private var entries: [WeightLog] = []

    @State private var newDate: Date = Date()
    @State private var newWeightText: String = ""
    @State private var newBodyFatText: String = ""

    private var newWeightLb: Double? {
        let cleaned = newWeightText
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(cleaned)
    }
    private var newBodyFat: Double? {
        guard !newBodyFatText.isEmpty else { return nil }
        return Double(newBodyFatText.replacingOccurrences(of: ",", with: "."))
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Weight")
                    .font(Theme.Fonts.Heading4)
                    .foregroundStyle(Theme.Colors.Primary1)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            HStack {
                Text("Entries:")
                    .font(Theme.Fonts.SubHeading7)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Spacer()
            }
            .padding(.horizontal)

            // Content
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(entries) { entry in
                        WeightCard(
                            dateText: dateFormatter.string(from: entry.created_at ?? Date()),
                            weightText: String(format: "%.1f lb", entry.weight_kg * 2.20462262185),
                            bodyFatText: entry.bf_percent.map { String(format: "%.1f%% BF", $0) }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            VStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.Colors.NeutralDark2)
                    .overlay(
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Add entry")
                                    .font(Theme.Fonts.SubHeading7)
                                    .foregroundStyle(Theme.Colors.NeutralLight1)
                                Spacer()
                            }

                            HStack(spacing: 10) {
                                HStack(spacing: 6) {
                                    TextField("lb", text: $newWeightText)
                                        .font(Theme.Fonts.Body2)
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 70)
                                        .decimalPadDone()
                                    Text("lb")
                                        .font(Theme.Fonts.Body2)
                                        .foregroundStyle(Theme.Colors.NeutralLight1)
                                        .frame(width: 20)
                                }

                                if let lb = newWeightLb {
                                    Text(String(format: "≈ %.1f kg", lb / 2.20462262185))
                                        .font(Theme.Fonts.Body2)
                                        .foregroundStyle(Theme.Colors.NeutralLight1)
                                }

                                Divider()
                                    .frame(height: 28)

                                Spacer()

                                Button {
                                    Task {
                                        do {
                                            guard let lb = newWeightLb else { return }
                                            let kg = lb / 2.20462262185
                                            try await WeightManager.logWeight(
                                                weightLog: WeightLog(
                                                    created_at: nil,
                                                    weight_kg: kg,
                                                    source: "Manual",
                                                    bf_percent: newBodyFat
                                                )
                                            )
                                            let logs = try await WeightManager.getWeightLogs()
                                            await MainActor.run {
                                                entries = logs
                                                // reset inputs after success
                                                newDate = Date()
                                                newWeightText = ""
                                                newBodyFatText = ""
                                            }
                                        } catch {
                                            // Optionally handle/log the error; keeping it simple for now
                                            print("Failed to log weight:", error)
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add")
                                    }
                                    .font(Theme.Fonts.Body2)
                                }
                                .buttonStyle(.plain)
                                .disabled(newWeightLb == nil)
                                .opacity(newWeightLb == nil ? 0.5 : 1.0)
                            }
                        }
                        .padding(14)
                    )
            }
            .padding(.horizontal)
            .padding(.bottom)
            .frame(height: 135)
        }
        .background(Theme.Colors.NeutralDark)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .onAppear {
            Task {
                let logs = try await WeightManager.getWeightLogs()
                await MainActor.run { entries = logs }
            }
        }
    }
}

private struct WeightCard: View {
    let dateText: String
    let weightText: String
    let bodyFatText: String?

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Theme.Colors.NeutralDark2)
            .frame(height: 70)
            .overlay(
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dateText)
                            .font(Theme.Fonts.Body2)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                            .padding(.top, -25)
                        Text(weightText)
                            .font(Theme.Fonts.Heading5)
                    }
                    Spacer()
                    if let bf = bodyFatText {
                        Text(bf)
                            .font(Theme.Fonts.Body2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerSize: .init(width: 8, height: 8))
                                    .fill(Theme.Colors.NeutralDark)
                                    .frame(height: 30)
                            )
                    } else {
                        Text("—")
                            .font(Theme.Fonts.Body2)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                    }
                }
                    .padding(14)
            )
            .shadow(radius: 2)
    }
}

#Preview {
    Weight()
}
