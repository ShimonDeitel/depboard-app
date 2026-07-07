import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "star.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.accent)
                .accessibilityHidden(true)

            Text("Departure Board Pro")
                .font(Theme.titleFont)
                .foregroundStyle(Theme.textPrimary)

            Text("Unlimited flights, delay-pattern stats, and compensation claim notes")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let product = purchases.product {
                Button {
                    Task { await purchases.purchase() }
                } label: {
                    Text("Unlock for \(product.displayPrice)")
                        .font(Theme.headlineFont)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .accessibilityIdentifier("purchaseButton")
                .padding(.horizontal, 32)
            } else {
                ProgressView()
            }

            Button("Restore Purchases") {
                Task { await purchases.restore() }
            }
            .accessibilityIdentifier("restoreButton")
            .font(Theme.captionFont)
            .foregroundStyle(Theme.textSecondary)

            Spacer()

            Button("Not Now") { dismiss() }
                .accessibilityIdentifier("dismissPaywallButton")
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textSecondary)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
        .onChange(of: purchases.isPurchased) { _, newValue in
            if newValue { dismiss() }
        }
    }
}
