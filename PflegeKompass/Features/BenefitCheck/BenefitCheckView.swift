import SwiftUI

struct BenefitCheckView: View {
    @EnvironmentObject private var state: AppState
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Anspruchs-Check").font(.largeTitle.weight(.bold)).foregroundStyle(PKTheme.ink)
                    Text("Wir zeigen, was aufgrund Ihrer Angaben möglicherweise oder wahrscheinlich relevant sein könnte. Bitte mit der Pflegekasse prüfen.").foregroundStyle(.secondary)
                    ForEach(BenefitResult.Status.allCases, id: \.rawValue) { status in
                        let matchingBenefits = state.benefits.filter { $0.status == status }
                        if !matchingBenefits.isEmpty {
                            Text(status.title).font(.title3.weight(.bold)).padding(.top, 6)
                            ForEach(matchingBenefits) { benefit in BenefitCard(benefit: benefit) }
                        }
                    }
                    PKInfoBanner(text: "Keine verbindliche Leistungsentscheidung. Rechtliche Voraussetzungen können sich ändern.")
                }.padding(20)
            }.background(PKTheme.background).navigationTitle("Ansprüche")
        }
    }
}

struct BenefitCard: View {
    let benefit: BenefitResult
    @State private var showDetails = false
    var body: some View {
        PKCard {
            HStack(alignment: .top) { Text(benefit.title).font(.headline); Spacer(); PKStatusBadge(status: benefit.status) }
            Text(benefit.explanation).foregroundStyle(.secondary).padding(.top, 8)
            Button(showDetails ? "Details ausblenden" : "Was ist jetzt zu tun?") { showDetails.toggle() }.font(.subheadline.weight(.semibold)).padding(.top, 10)
            if showDetails {
                Divider().padding(.vertical, 6)
                Text("Nächster Schritt").font(.subheadline.weight(.bold)); Text(benefit.nextStep).foregroundStyle(.secondary)
                Text("Hilfreiche Unterlagen").font(.subheadline.weight(.bold)).padding(.top, 8)
                ForEach(benefit.helpfulDocuments, id: \.self) { Label($0, systemImage: "doc") .font(.subheadline) }
            }
        }
    }
}
