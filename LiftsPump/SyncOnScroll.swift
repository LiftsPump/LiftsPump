import SwiftUI
import SwiftData

private struct ScrollSyncOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct SyncOnScrollModifier: ViewModifier {
    @Environment(\.modelContext) private var defaultContext
    var modelContext: ModelContext?

    @State private var lastOffset: CGFloat = 0
    @State private var lastSyncTime: Date = .distantPast

    func body(content: Content) -> some View {
        ScrollViewReader { _ in
            content
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: ScrollSyncOffsetKey.self, value: proxy.frame(in: .named("SyncScrollSpace")).minY)
                    }
                )
                .coordinateSpace(name: "SyncScrollSpace")
                .onPreferenceChange(ScrollSyncOffsetKey.self) { newOffset in
                    let delta = newOffset - lastOffset
                    if delta < -12 { // scrolling down
                        Task { await trySync() }
                    }
                    lastOffset = newOffset
                }
                .refreshable {
                    await trySync()
                }
        }
    }

    @MainActor
    private func trySync() async {
        if Date().timeIntervalSince(lastSyncTime) < 15 { return }
        lastSyncTime = Date()
        let ctx = modelContext ?? defaultContext
        let mgr = SupaBaseManager(context: ctx)
        do { try await mgr.initSync() } catch { print("Sync error: \(error)") }
    }
}

extension View {
    func syncOnScroll(modelContext: ModelContext? = nil) -> some View {
        modifier(SyncOnScrollModifier(modelContext: modelContext))
    }
}
