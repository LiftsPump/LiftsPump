//
//  BackButton.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/30/24.
//

import SwiftUI

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body : some View { Button(action: {
            self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    .foregroundColor(Theme.Colors.NeutralLight1)
                Text("Back")
                        .foregroundStyle(Theme.Colors.NeutralLight1)
                        .font(Theme.Fonts.Body4)
                }
            }
        }
}

#Preview {
    BackButton()
}
