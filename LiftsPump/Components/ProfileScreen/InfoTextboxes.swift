//
//  InfoTextboxes.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 10/1/24.
//

import SwiftUI

struct InfoTextboxes: View {
    var title: String
    var placeHolder: String
    @Binding var info: String
    
    var body: some View {
        VStack {
            HStack {
                Text("\(title)")
                    .font(Theme.Fonts.Body4)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .padding(.horizontal, 10)
                Spacer()
            }
            TextField("\(placeHolder)", text: $info)
                .padding(.horizontal, 15) // Add padding inside the text field
                .frame(height: 40)
                .background(Theme.Colors.NeutralDark2)
                .cornerRadius(4)
                .autocorrectionDisabled(true)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Theme.Colors.Primary1, lineWidth: 1)
                )
                .padding(.horizontal, 10) // Add external padding for spacing
        } .padding(.vertical)
    }
}
