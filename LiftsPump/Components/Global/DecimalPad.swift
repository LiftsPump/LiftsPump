//
//  DecimalPad.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 11/5/25.
//


import SwiftUI

public extension View {
    func decimalPadDone(onSubmit: (() -> Void)? = nil) -> some View {
        self
            .keyboardType(.decimalPad)
            .submitLabel(.done)
            .onSubmit {
                onSubmit?()
                dismissKeyboard()
            }
    }
}

fileprivate func dismissKeyboard() {
    #if canImport(UIKit)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    #endif
}
