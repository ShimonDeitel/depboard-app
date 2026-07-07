import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("depboard_notifyEnabled") private var notifyEnabled = true
    @AppStorage("depboard_sortNewestFirst") private var sortNewestFirst = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Notifications", isOn: $notifyEnabled)
                        .accessibilityIdentifier("notificationsToggle")
                    Toggle("Sort Newest First", isOn: $sortNewestFirst)
                        .accessibilityIdentifier("sortToggle")
                }

                Section("Departure Board Pro") {
                    if purchases.isPurchased {
                        Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                    } else {
                        Button("Upgrade to Pro") {
                            showPaywall = true
                        }
                        .accessibilityIdentifier("upgradeButton")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("restorePurchasesButton")
                }

                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/depboard-app/privacy.html")!)
                        .accessibilityIdentifier("privacyPolicyLink")
                    Text("Version 1.0")
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    @State private var showPaywall = false
}
