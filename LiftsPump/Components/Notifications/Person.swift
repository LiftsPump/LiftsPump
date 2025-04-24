//
//  Person.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 9/19/24.
//

import SwiftUI

struct Person: View {
    var image: String
    var action: String
    var text: String
    var profileImage: String
    
    var body: some View {
        HStack {
            Image(systemName: "\(profileImage)")
                .font(.system(size: 28))
            Text("\(text)")
                .padding()
                .font(Theme.Fonts.Body3)
                .frame(width: UIScreen.screenWidth * 0.55, alignment: .leading)
            Button(action: {
                            
                        }) {
                            HStack {
                                Image(systemName: "\(image)")
                                    .padding(.leading, 4)
                                    .font(.system(size: 20))
                                Text("\(action)")
                                    .font(Theme.Fonts.Body5)
                                    .padding(10)
                                    .padding(.leading, -12)
                            }
                                .background(Color.clear)
                                .foregroundColor(Theme.Colors.Primary1)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Theme.Colors.Primary1, lineWidth: 2)
                                )
                        }
        }
        .padding(.horizontal)
    }
}

#Preview {
    Person(image: "eye", action: "View", text: "Some nonsense about adding this confirming this wtv", profileImage: "person.crop.circle")
}
