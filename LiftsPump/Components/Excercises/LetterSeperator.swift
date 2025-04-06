//
//  LetterSeperator.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/30/24.
//

import SwiftUI

struct LetterSeperator: View {
    var letter: String
    
    var body: some View {
        VStack {
            HStack {
                Text("\(letter)")
                    .font(Theme.Fonts.Heading5)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                    .padding(.horizontal, 40)
                Spacer()
            }
            Rectangle()
                .fill(Theme.Colors.Primary1)
                .frame(width: .infinity, height: 2)
                .edgesIgnoringSafeArea(.horizontal)
                .padding(.horizontal)
                .padding(.top, -15)
        }
        
    }
}

#Preview {
    LetterSeperator(letter: "A")
}
