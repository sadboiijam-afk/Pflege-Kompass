import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var state: AppState
    @State private var showResetConfirmation = false
    var body: some View {
        NavigationStack {
            List {
                Section("Vorlagen") { NavigationLink("Antrag und Schreiben") { TemplatesView() } }
                Section("Datenschutz und Grenzen") {
                    NavigationLink("So gehen wir mit Daten um") { PrivacyView() }
                    NavigationLink("Hinweise zur Orientierung") { DisclaimerView() }
                }
                Section("PflegeKompass Plus") { Label("Premium-Funktionen folgen später", systemImage: "sparkles").foregroundStyle(.secondary) }
                Section("Lokale Daten") { Button("Demo-Daten auf diesem Gerät löschen", role: .destructive) { showResetConfirmation = true } }
            }.scrollContentBackground(.hidden).background(PKTheme.background).navigationTitle("Mehr")
        }.alert("Demo-Daten löschen?", isPresented: $showResetConfirmation) { Button("Löschen", role: .destructive) { state.resetAllData() }; Button("Abbrechen", role: .cancel) {} } message: { Text("Pflegeprofil und To-dos werden aus dieser App gelöscht.") }
    }
}

struct TemplatesView: View {
    let templates = [
        ApplicationTemplate(id: "hilfsmittel", title: "Antrag Pflegehilfsmittel", body: "Bitte informieren Sie mich über den Ablauf für Pflegehilfsmittel in unserer Pflegesituation und die dafür benötigten Unterlagen."),
        ApplicationTemplate(id: "beratung", title: "Bitte um Pflegeberatung", body: "Bitte informieren Sie mich über passende Pflegeberatung und die nächsten Schritte für unsere Pflegesituation."),
        ApplicationTemplate(id: "entlastung", title: "Erstattung Entlastungsbetrag", body: "Bitte teilen Sie mir mit, welche Unterlagen für die Prüfung einer Erstattung im Zusammenhang mit Entlastungsleistungen benötigt werden."),
        ApplicationTemplate(id: "widerspruch", title: "Widerspruch vorbereiten", body: "Bitte erläutern Sie mir die im Bescheid genannten Hinweise, Fristen und Unterlagen. Ich möchte die Situation zunächst prüfen lassen.")
    ]
    var body: some View { List(templates) { item in VStack(alignment: .leading, spacing: 8) { Text(item.title).font(.headline); Text(item.body).foregroundStyle(.secondary); ShareLink(item: item.body) { Label("Text teilen", systemImage: "square.and.arrow.up") }.font(.subheadline) }.padding(.vertical, 6) }.navigationTitle("Vorlagen") }
}

struct PrivacyView: View {
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 18) { Text("Privat by Design").font(.largeTitle.weight(.bold)); PKCard { Text("Auf diesem Gerät").font(.headline); Text("Profil und To-dos werden in dieser MVP-App lokal gespeichert. Dokumente und erkannter Text werden nicht automatisch in eine Cloud übertragen.").foregroundStyle(.secondary).padding(.top, 6) }; PKCard { Text("Scan und KI").font(.headline); Text("Der Prototyp verwendet Apple Vision auf dem Gerät. Eine externe KI-Erklärung ist nicht aktiviert; sie wäre nur über eine serverseitige Schnittstelle mit ausdrücklicher Einwilligung möglich.").foregroundStyle(.secondary).padding(.top, 6) }; PKCard { Text("Löschen").font(.headline); Text("Unter „Mehr“ können Sie die lokalen Demo-Daten löschen.").foregroundStyle(.secondary).padding(.top, 6) } }.padding(20) }.background(PKTheme.background).navigationTitle("Datenschutz").navigationBarTitleDisplayMode(.inline) }
}

struct DisclaimerView: View {
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 16) { Text("Wichtige Hinweise").font(.largeTitle.weight(.bold)); Text("PflegeKompass dient der Orientierung und Organisation. Die App stellt keine Diagnose, medizinische Empfehlung oder verbindliche Rechtsberatung dar."); Text("Leistungen und Fristen sind stets mit der Pflegekasse, einer Pflegeberatung oder einer qualifizierten Stelle zu prüfen."); PKInfoBanner(text: "Formulierungen wie „möglicherweise relevant“ und „wahrscheinlich relevant“ sind bewusst keine Zusage.") }.padding(20) }.background(PKTheme.background).navigationTitle("Hinweise").navigationBarTitleDisplayMode(.inline) }
}
