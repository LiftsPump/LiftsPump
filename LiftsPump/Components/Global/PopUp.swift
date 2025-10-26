//
//  PopUp.swift
//  LiftsPump
//
//  Created by Ahmed Abushagur on 10/18/25.
//
// Definelty refactor ts

import SwiftUI

public struct PopUp: View {
    public var title: String
    public var message: String
    public var yesLabel: String
    public var noLabel: String
    public var onYes: () -> Void
    public var onNo: () -> Void
    @Binding public var isPresented: Bool
    
    public init(title: String,
                message: String,
                yesLabel: String = "Yes",
                noLabel: String = "No",
                isPresented: Binding<Bool>,
                onYes: @escaping () -> Void,
                onNo: @escaping () -> Void) {
        self.title = title
        self.message = message
        self.yesLabel = yesLabel
        self.noLabel = noLabel
        self._isPresented = isPresented
        self.onYes = onYes
        self.onNo = onNo
    }
    
    public var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.clear)
                .onTapGesture {
                    withAnimation { isPresented = false }
                }
            VStack(spacing: 20) {
                Text(title)
                    .font(.title2).bold()
                    .foregroundColor(.primary)
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                Divider()
                    .overlay(Color.white.opacity(0.25))
                    .blendMode(.overlay)
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation { isPresented = false }
                        onNo()
                    }) {
                        Text(noLabel)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(GlassButtonStyle(tint: .secondary))

                    Button(action: {
                        withAnimation { isPresented = false }
                        onYes()
                    }) {
                        Text(yesLabel)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(GlassButtonStyle(tint: Theme.Colors.Primary1))
                }
            }
            .padding(.vertical, 32)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.thinMaterial)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.45),
                                Color.white.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .shadow(color: Color.black.opacity(0.2), radius: 24, x: 0, y: 12)
                    .shadow(color: Color.white.opacity(0.06), radius: 1, x: 0, y: 1)
            )
            .padding(.horizontal, 36)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .contentShape(Rectangle())
        .animation(.spring(response: 0.16, dampingFraction: 0.82, blendDuration: 0.12), value: isPresented)
        .disabled(!isPresented)
    }
}

private struct GlassButtonStyle: ButtonStyle {
    var tint: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .overlay(
                // subtle tint glow for emphasis
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.12))
            )
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0.1 : 0.18), radius: configuration.isPressed ? 6 : 12, x: 0, y: configuration.isPressed ? 2 : 8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension View {
    func popUp(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        yesLabel: String = "Yes",
        noLabel: String = "No",
        onYes: @escaping () -> Void = {},
        onNo: @escaping () -> Void = {}
    ) -> some View {
        self.overlay(
            Group {
                if isPresented.wrappedValue {
                    PopUp(
                        title: title,
                        message: message,
                        yesLabel: yesLabel,
                        noLabel: noLabel,
                        isPresented: isPresented,
                        onYes: onYes,
                        onNo: onNo
                    )
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(999)
                }
            }
        )
    }
}

#if DEBUG
#Preview {
    StatefulPreviewWrapper(true) { isPresented in
        PopUp(
            title: "Delete Item",
            message: "Are you sure you want to permanently delete this item? This action cannot be undone.",
            yesLabel: "Delete",
            noLabel: "Cancel",
            isPresented: isPresented,
            onYes: {},
            onNo: {})
    }
}

// Preview helper
struct StatefulPreviewWrapper<Value: Equatable, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content
    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }
    var body: some View { content($value) }
}
#endif
