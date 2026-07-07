import SwiftUI

@main
struct DepboardApp: App {
    @StateObject private var store = Store()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchases)
                .onAppear {
                    store.isPro = purchases.isPurchased
                }
                .onChange(of: purchases.isPurchased) { _, newValue in
                    store.isPro = newValue
                }
        }
    }
}
