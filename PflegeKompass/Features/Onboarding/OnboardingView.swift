import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var state: AppState
    @State private var step = 0
    @State private var label = ""
    @State private var grade: Pflegegrad = .unbekannt
    @State private var location: Pflegeort = .unbekannt
    @State private var provider: Versorgungssetup = .unbekannt
    @State private var existingBenefits = Set<PflegeLeistung>()
    @State private var noIdea = false

    private let steps = ["Willkommen", "Situation", "Pflegegrad", "Pflegeort", "Versorgung", "Leistungen"]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                ProgressView(value: Double(step), total: Double(steps.count - 1)).tint(PKTheme.sage)
                    .accessibilityLabel("Fortschritt: Schritt \(step + 1) von \(steps.count)")
                Text("PflegeKompass").font(.title.weight(.bold)).foregroundStyle(PKTheme.ink)
                Text(headline).font(.title2.weight(.semibold)).foregroundStyle(PKTheme.ink)
                Text(subheadline).foregroundStyle(.secondary)

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) { stepContent }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                }
                Spacer(minLength: 0)
                if step == 0 {
                    PKPrimaryButton(title: "Situation erfassen") { step += 1 }
                    Button("Demo-Situation ansehen") { state.startDemo() }
                        .frame(maxWidth: .infinity).foregroundStyle(PKTheme.ink)
                } else {
                    PKPrimaryButton(title: step == steps.count - 1 ? "Meine Übersicht erstellen" : "Weiter") {
                        if step == steps.count - 1 { save() } else { step += 1 }
                    }
                    Button("Zurück") { step -= 1 }.frame(maxWidth: .infinity).foregroundStyle(PKTheme.ink)
                }
            }
            .padding(24)
            .background(PKTheme.background)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder private var stepContent: some View {
        switch step {
        case 0:
            PKCard {
                Label("Startpunkt: Pflegegrad erhalten", systemImage: "compass.drawing").font(.headline)
                Text("In wenigen Schritten sehen Sie, was Sie jetzt prüfen und erledigen können.").foregroundStyle(.secondary).padding(.top, 6)
            }
            PKInfoBanner(text: "Die Orientierung ersetzt keine Pflegeberatung, Rechtsberatung oder medizinische Beratung.")
        case 1:
            PKCard {
                Text("Für wen organisieren Sie Pflege?").font(.headline)
                TextField("z. B. Mutter", text: $label).textInputAutocapitalization(.words).padding(.top, 8)
            }
        case 2:
            ForEach(Pflegegrad.allCases) { value in PKSelectionRow(title: value.title, isSelected: grade == value) { grade = value } }
        case 3:
            ForEach(Pflegeort.allCases) { value in PKSelectionRow(title: value.title, isSelected: location == value) { location = value } }
        case 4:
            ForEach(Versorgungssetup.allCases) { value in PKSelectionRow(title: value.title, isSelected: provider == value) { provider = value } }
        default:
            Text("Was wird bereits genutzt?").font(.headline)
            ForEach(PflegeLeistung.checklistCases) { benefit in
                PKSelectionRow(title: benefit.title, isSelected: existingBenefits.contains(benefit)) {
                    noIdea = false
                    if existingBenefits.contains(benefit) { existingBenefits.remove(benefit) } else { existingBenefits.insert(benefit) }
                }
            }
            PKSelectionRow(title: PflegeLeistung.keineAhnung.title, isSelected: noIdea) {
                noIdea.toggle()
                if noIdea { existingBenefits.removeAll() }
            }
        }
    }

    private var headline: String {
        switch step {
        case 0: "Wir bringen Ordnung in die nächsten Schritte."
        case 1: "Wen unterstützen Sie?"
        case 2: "Welcher Pflegegrad liegt vor?"
        case 3: "Wo findet die Pflege statt?"
        case 4: "Wer unterstützt überwiegend?"
        default: "Was ist bereits organisiert?"
        }
    }

    private var subheadline: String {
        step == 5 ? "Sie können mehrere Punkte auswählen oder „Keine Ahnung“ wählen." : "Sie können Angaben jederzeit später anpassen."
    }

    private func save() {
        state.save(profile: Pflegeprofil(
            id: UUID(),
            bezeichnung: label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Pflegefall" : label,
            pflegegrad: grade,
            pflegeort: location,
            versorgungssetup: provider,
            vorhandeneLeistungen: existingBenefits,
            createdAt: .now
        ))
    }
}
