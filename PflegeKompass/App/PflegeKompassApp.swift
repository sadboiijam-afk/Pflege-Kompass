import SwiftUI

@main
struct PflegeKompassApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        WindowGroup {
            RootView().environmentObject(state).tint(PKTheme.ink)
        }
    }
}

struct RootView: View {
    @EnvironmentObject private var state: AppState
    var body: some View {
        Group {
            if state.profile == nil { OnboardingView() }
            else { MainTabView() }
        }.background(PKTheme.background.ignoresSafeArea())
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView().tabItem { Label("Übersicht", systemImage: "house") }
            BenefitCheckView().tabItem { Label("Ansprüche", systemImage: "checklist") }
            DocumentScanView().tabItem { Label("Brief", systemImage: "doc.text.viewfinder") }
            TodoListView().tabItem { Label("To-dos", systemImage: "checkmark.circle") }
            SettingsView().tabItem { Label("Mehr", systemImage: "ellipsis.circle") }
        }
    }
}
