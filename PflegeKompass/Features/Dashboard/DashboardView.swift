import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var state: AppState
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Guten Überblick behalten").font(.largeTitle.weight(.bold)).foregroundStyle(PKTheme.ink)
                    Text("Für \(state.profile?.bezeichnung ?? "Ihre Situation")").font(.title3).foregroundStyle(.secondary)
                    if let profile = state.profile {
                        PKCard {
                            Text("Pflegeprofil").font(.headline)
                            ProfileSummaryRow(label: "Pflegegrad", value: profile.pflegegrad.title)
                            ProfileSummaryRow(label: "Pflegeort", value: profile.pflegeort.title)
                            ProfileSummaryRow(label: "Unterstützung", value: profile.versorgungssetup.title)
                        }
                    }
                    PKCard {
                        Label("Nächster sinnvoller Schritt", systemImage: "arrow.right.circle.fill").foregroundStyle(PKTheme.sage).font(.headline)
                        Text("Pflegegrad erhalten – was jetzt?").font(.title3.weight(.semibold)).padding(.top, 6)
                        Text("Wir führen Sie durch die wichtigsten ersten Punkte.").foregroundStyle(.secondary).padding(.top, 2)
                        NavigationLink("Jetzt starten") { NextStepsFlowView() }.font(.headline).padding(.top, 12)
                    }
                    PKInfoBanner(text: "Ihre Angaben bleiben in diesem MVP auf diesem Gerät. Es gibt keinen Cloud-Upload.")
                    Text("Ansprüche im Überblick").font(.title2.weight(.bold))
                    ForEach(BenefitResult.Status.allCases, id: \.rawValue) { status in
                        let count = state.benefits.filter { $0.status == status }.count
                        if count > 0 {
                            HStack { PKStatusBadge(status: status); Spacer(); Text("\(count) Thema\(count == 1 ? "" : "en")").foregroundStyle(.secondary) }
                                .padding(.horizontal, 4)
                        }
                    }
                    HStack { Text("Heute im Blick").font(.title2.weight(.bold)); Spacer(); Text("\(state.todos.filter { !$0.isDone }.count) offen").foregroundStyle(.secondary) }
                    ForEach(state.todos.filter { !$0.isDone }.prefix(3)) { todo in
                        NavigationLink { TodoListView() } label: { TodoRow(todo: todo) }.buttonStyle(.plain)
                    }
                    NavigationLink { BenefitCheckView() } label: {
                        PKCard { Label("Ansprüche orientierend prüfen", systemImage: "checkmark.seal").font(.headline); Text("\(state.benefits.count) Themen könnten Sie prüfen.").foregroundStyle(.secondary).padding(.top, 4) }
                    }.buttonStyle(.plain)
                }.padding(20)
            }.background(PKTheme.background).navigationTitle("Übersicht")
        }
    }
}

private struct ProfileSummaryRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.medium).multilineTextAlignment(.trailing)
        }.padding(.top, 8)
    }
}

struct NextStepsFlowView: View {
    @EnvironmentObject private var state: AppState
    @State private var page = 0
    private let steps = [
        ("Bescheid verstehen", "Prüfen Sie Pflegegrad, Datum und Hinweise am Ende des Bescheids."),
        ("Unterstützung sortieren", "Notieren Sie, was im Alltag gut gelingt und wo regelmäßig Hilfe nötig ist."),
        ("Pflegekasse einbeziehen", "Klären Sie mit der Pflegekasse, welche Unterstützung für Ihre konkrete Situation zu prüfen ist.")
    ]
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Pflegegrad erhalten – was jetzt?").font(.largeTitle.weight(.bold)).foregroundStyle(PKTheme.ink)
            Text("Schritt \(page + 1) von \(steps.count)").foregroundStyle(.secondary)
            PKCard { Text(steps[page].0).font(.title2.weight(.bold)); Text(steps[page].1).foregroundStyle(.secondary).padding(.top, 8) }
            Spacer()
            PKInfoBanner(text: "Orientierung, keine verbindliche Rechtsberatung.")
            PKPrimaryButton(title: page == steps.count - 1 ? "Zur Übersicht" : "Weiter") {
                if page < steps.count - 1 { page += 1 }
            }
        }.padding(24).background(PKTheme.background).navigationTitle("Erste Schritte").navigationBarTitleDisplayMode(.inline)
    }
}
