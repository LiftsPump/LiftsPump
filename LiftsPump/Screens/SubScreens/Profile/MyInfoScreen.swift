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
    @AppStorage("USERNAME_KEY") var username: String = ""
    @AppStorage("HEIGHT_KEY") var height: Int = 0
    @AppStorage("WEIGHT_KEY") var weight: Int = 0
    @AppStorage("DOB_KEY") var dob: Double = Date().timeIntervalSince1970
    @AppStorage("LS_KEY") private var last_synced: Double = Date().timeIntervalSince1970
    
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Birth date")
                            .font(Theme.Fonts.Body4)
                            .foregroundStyle(Theme.Colors.NeutralLight1)
                            .padding(.horizontal, 10)
                        DatePicker("Start date", selection: Binding(
                            get: { Date(timeIntervalSince1970: dob) },
                            set: { dob = $0.timeIntervalSince1970 }
                        ), displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding(10)
                            .frame(width: .infinity)
                            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.green))
                            .scaleEffect(0.7)
                            .edgesIgnoringSafeArea(.all)
                    }.frame(width: .infinity)
                    NumberTextbox(title: "Height (In)", placeHolder: "74\"", info: $height)
                    NumberTextbox(title: "Weight (Lb)", placeHolder: "170", info: $weight)
                }
                GeneralButton(text: "Save profile data", color: Theme.Colors.Primary1, image: "square.and.arrow.down")
                    .padding(.vertical)
                    .onTapGesture {
                        SupaBaseManager.saveProfile(first_name: firstName, last_name: lastName, phone_number: "", height: height, weight: weight, dob: Date(timeIntervalSince1970: dob), last_synced: Date(timeIntervalSince1970: last_synced), username: username)
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
