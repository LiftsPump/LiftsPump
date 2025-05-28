//
//  NumberTextbox.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 5/27/25.
//

import SwiftUI

extension NumberFormatter {
    static var integer: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }
}

struct NumberTextbox: View {
    var title: String
    var placeHolder: String
    @Binding var info: Int

    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(Theme.Fonts.Body4)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .padding(.horizontal, 10)
                Spacer()
            }
            TextField(placeHolder, value: $info, formatter: NumberFormatter.integer)
                .padding(.horizontal, 15)
                .frame(height: 40)
                .background(Theme.Colors.NeutralDark2)
                .cornerRadius(4)
                .autocorrectionDisabled(true)
                .keyboardType(.numberPad)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Theme.Colors.Primary1, lineWidth: 1)
                )
                .padding(.horizontal, 10)
        }
        .padding(.vertical)
    }
}
