import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = VideoPersonaViewModel()
    @FocusState private var urlFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // URL input
                HStack(spacing: 8) {
                    TextField("Paste YouTube link (https://…)", text: $viewModel.youtubeURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled(true)
                        .submitLabel(.go)
                        .focused($urlFieldFocused)
                        .onSubmit { viewModel.startPipeline() }
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    Button(action: { viewModel.startPipeline() }) {
                        if viewModel.isProcessing {
                            ProgressView()
                        } else {
                            Image(systemName: "sparkles")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isProcessing || !viewModel.canStart)
                }
                
                // Status / Error
                if let status = viewModel.statusMessage, !status.isEmpty {
                    Text(status)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .transition(.opacity)
                }
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Persona header
                Group {
                    if let personaName = viewModel.personaDisplayName {
                        HStack(spacing: 12) {
                            Circle()
                                .fill(.blue.opacity(0.2))
                                .frame(width: 48, height: 48)
                                .overlay(Image(systemName: "person.fill").foregroundStyle(.blue))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(personaName)
                                    .font(.headline)
                                Text("Persona based on video presenter")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .background(Color(.systemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: viewModel.messages) { _, _ in
                        if let last = viewModel.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
                
                // Input bar
                HStack(spacing: 8) {
                    TextField("Type a message…", text: $viewModel.currentInput, axis: .vertical)
                        .lineLimit(1...4)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.send)
                        .onSubmit { viewModel.sendUserMessage() }
                        .padding(12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    Button {
                        viewModel.sendUserMessage()
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isProcessing || viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding()
            .navigationTitle("Video Persona Chat")
            .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { urlFieldFocused = false } } }
        }
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom) {
            if message.role == .assistant { Spacer(minLength: 40) }
            Text(message.text)
                .padding(12)
                .background(message.role == .user ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            if message.role == .user { Spacer(minLength: 40) }
        }
        .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
        .animation(.default, value: message.id)
    }
}

#Preview {
    ContentView()
}
