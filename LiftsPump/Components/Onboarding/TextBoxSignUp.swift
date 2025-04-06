//
//  SwiftUIView.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 10/4/24.
//

import SwiftUI

struct TextBoxSignUp: View {
    var placeHolder: String
    @Binding var info: String
    var password: Bool

    var body: some View {
        VStack {
            if password {
                SecureField(placeHolder, text: $info)
                    .textContentType(.password) // Improves security suggestions
                    .padding(.horizontal, 15)
                    .frame(height: 40)
                    .background(Theme.Colors.NeutralDark2)
                    .cornerRadius(4)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Theme.Colors.Primary1, lineWidth: 1)
                    )
                    .padding(.horizontal, 10)
            } else {
                TextField(placeHolder, text: $info)
                    .textContentType(.none) // Prevents autofill from suggesting sensitive data
                    .padding(.horizontal, 15)
                    .frame(height: 40)
                    .background(Theme.Colors.NeutralDark2)
                    .cornerRadius(4)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Theme.Colors.Primary1, lineWidth: 1)
                    )
                    .padding(.horizontal, 10)
            }
        }
        .padding(.vertical, 10)
    }
}
