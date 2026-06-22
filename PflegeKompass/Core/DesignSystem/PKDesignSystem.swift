import SwiftUI

enum PKTheme {
    static let background = Color(red: 0.97, green: 0.95, blue: 0.90)
    static let ink = Color(red: 0.10, green: 0.19, blue: 0.16)
    static let sage = Color(red: 0.35, green: 0.49, blue: 0.40)
    static let gold = Color(red: 0.68, green: 0.53, blue: 0.27)
    static let card = Color.white.opacity(0.82)
}

struct PKCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content.padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .background(PKTheme.card, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(PKTheme.ink.opacity(0.08)))
    }
}

struct PKPrimaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) { Text(title).font(.headline).frame(maxWidth: .infinity).padding(.vertical, 16) }
            .buttonStyle(.plain).foregroundStyle(.white).background(PKTheme.ink, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .accessibilityHint("Öffnet den nächsten Schritt")
    }
}

struct PKStatusBadge: View {
    let status: BenefitResult.Status
    var body: some View {
        Text(status.title).font(.caption.weight(.semibold)).padding(.horizontal, 10).padding(.vertical, 6)
            .foregroundStyle(PKTheme.ink).background(status == .wahrscheinlichRelevant ? PKTheme.gold.opacity(0.24) : PKTheme.sage.opacity(0.17), in: Capsule())
            .accessibilityLabel("Einordnung: \(status.title)")
    }
}

struct PKInfoBanner: View {
    let text: String
    var body: some View {
        Label(text, systemImage: "checkmark.shield").font(.subheadline).foregroundStyle(PKTheme.ink)
            .padding(14).frame(maxWidth: .infinity, alignment: .leading).background(PKTheme.sage.opacity(0.13), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct PKSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3).foregroundStyle(isSelected ? PKTheme.sage : PKTheme.ink.opacity(0.55))
                Text(title).font(.body.weight(.medium)).foregroundStyle(PKTheme.ink)
                Spacer()
            }
            .padding(16)
            .background(isSelected ? PKTheme.sage.opacity(0.12) : PKTheme.card, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(isSelected ? PKTheme.sage : PKTheme.ink.opacity(0.08)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "Ausgewählt" : "Nicht ausgewählt")
    }
}
