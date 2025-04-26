//
//  EllipsisView.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 4/26/25.
//

import SwiftUI

struct EllipsisView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var modalType: ModalPopUp?

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "xmark")
                    .padding()
                    .font(.system(size: 24))
                    .onTapGesture {
                        dismiss()
                    }
            }.padding(.bottom, 40)
            VStack {
                GeneralButton(text: "Add collaborators", color: Theme.Colors.Primary1, image: "plus")
                    .onTapGesture {
                        modalType = .Friends
                    }
                Text("or")
                    .font(Theme.Fonts.SubHeading5)
                    .padding()
                GeneralButton(text: "Schedule workout", color: Theme.Colors.NeutralGray1, image: "calendar")
                    .onTapGesture {
                        modalType = .Schedule
                    }
            }
            Spacer()
        } .background(Theme.Colors.NeutralDark)
    }
}

#Preview {
    EllipsisView(modalType: .constant(.Exercise))
}
