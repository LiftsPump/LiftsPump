//
//  MyInfoScreen.swift
//  MyFitrack
//
//  Created by Ahmed Abushagur on 10/1/24.
//

import SwiftUI

struct MyInfoScreen: View {
    @State private var randomString: String = ""
    @AppStorage("FIRSTNAME_KEY") var firstName: String = ""
    @AppStorage("LASTNAME_KEY") var lastName: String = ""
    @AppStorage("EMAIL_KEY") var email: String = ""
    var body: some View {
        ScrollView {
            HStack {
                Text("My info")
                    .font(Theme.Fonts.SubHeading4)
                    .padding(.horizontal)
                    .foregroundStyle(Theme.Colors.NeutralLight1)
                Spacer()
            }
            VStack {
                HStack{
                    InfoTextboxes(title: "First name", placeHolder: "First", info: $firstName)
                    InfoTextboxes(title: "Last name", placeHolder: "Last", info: $lastName)
                }
                
                InfoTextboxes(title: "Email Address", placeHolder: "Email", info: $email)
                InfoTextboxes(title: "Password", placeHolder: "Password", info: $randomString)
                InfoTextboxes(title: "Country/Region", placeHolder: "United States", info: $randomString)
                HStack{
                    InfoTextboxes(title: "Date of Birth", placeHolder: "12/01/1999", info: $randomString)
                    InfoTextboxes(title: "Height", placeHolder: "6'2\"", info: $randomString)
                    InfoTextboxes(title: "Weight", placeHolder: "170", info: $randomString)
                }
            }
        } .background(Theme.Colors.NeutralDark)
            .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
    }
}

#Preview {
    MyInfoScreen()
}
