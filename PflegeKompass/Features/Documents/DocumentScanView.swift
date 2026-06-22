import SwiftUI
import VisionKit

struct DocumentScanView: View {
    @EnvironmentObject private var state: AppState
    @State private var showScanner = false
    @State private var isProcessing = false
    @State private var analysis: DokumentAnalyse?
    @State private var errorMessage: String?
    private let ocr = LocalOCRService()
    private let parser = LocalDocumentParser()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Brief verstehen").font(.largeTitle.weight(.bold)).foregroundStyle(PKTheme.ink)
                    Text("Der Scan wird direkt auf diesem Gerät gelesen. Es wird nichts an KI-Dienste oder eine Cloud gesendet.").foregroundStyle(.secondary)
                    PKCard { Label("Lokaler Scan mit Apple Vision", systemImage: "lock.shield").font(.headline); Text("Bei schwer lesbaren Briefen können Sie die Einordnung prüfen und korrigieren.").foregroundStyle(.secondary).padding(.top, 6) }
                    if VNDocumentCameraViewController.isSupported {
                        PKPrimaryButton(title: "Dokument hinzufügen") { showScanner = true }
                    } else {
                        PKInfoBanner(text: "Der Kamera-Scan ist auf diesem Gerät nicht verfügbar. Sie können die Beispielanalyse ansehen.")
                    }
                    PKCard {
                        Text("Dokumenttypen").font(.headline)
                        Text("Sie können zum Beispiel einen Pflegegrad-Bescheid, ein MD-Gutachten, einen Pflegekassen-Brief oder eine Rechnung hinzufügen.").foregroundStyle(.secondary).padding(.top, 6)
                    }
                    Button("Beispielanalyse ansehen") { analyze(text: "Pflegekasse Beispielstadt\nBescheid zum Pflegegrad 3\nBitte beachten Sie die Frist innerhalb eines Monats.\nDatum: 12.06.2026") }.foregroundStyle(PKTheme.ink).frame(maxWidth: .infinity)
                    if isProcessing { ProgressView("Brief wird lokal gelesen …").frame(maxWidth: .infinity, alignment: .leading).padding() }
                    if let analysis { DocumentAnalysisCard(analysis: analysis, onAddTodo: { state.addDocumentTodo(title: "Brief prüfen: \(analysis.type.title)", detail: analysis.nextStep) }) }
                    if let errorMessage { PKInfoBanner(text: errorMessage) }
                }.padding(20)
            }.background(PKTheme.background).navigationTitle("Brief")
        }.sheet(isPresented: $showScanner) { DocumentScanner { image in recognize(image) } }
    }

    private func recognize(_ image: UIImage) {
        isProcessing = true
        Task {
            do { let text = try await ocr.recognizeText(in: image); analysis = parser.analyze(text: text); isProcessing = false }
            catch { errorMessage = "Der Brief konnte nicht zuverlässig gelesen werden. Bitte versuchen Sie es bei besserem Licht erneut."; isProcessing = false }
        }
    }
    private func analyze(text: String) { analysis = parser.analyze(text: text) }
}

struct DocumentAnalysisCard: View {
    let analysis: DokumentAnalyse
    let onAddTodo: () -> Void
    var body: some View {
        PKCard {
            Text(analysis.type.title).font(.title3.weight(.bold))
            Text(analysis.summary).foregroundStyle(.secondary).padding(.top, 6)
            if let hint = analysis.deadlineHint { Label(hint, systemImage: "exclamationmark.triangle").foregroundStyle(PKTheme.ink).padding(.top, 10) }
            Text("Nächster sinnvoller Schritt").font(.subheadline.weight(.bold)).padding(.top, 12)
            Text(analysis.nextStep).foregroundStyle(.secondary)
            Button("Als To-do merken", action: onAddTodo).font(.headline).padding(.top, 12)
        }
    }
}

struct DocumentScanner: UIViewControllerRepresentable {
    let onImage: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    func makeCoordinator() -> Coordinator { Coordinator(onImage: onImage, dismiss: dismiss) }
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController { let controller = VNDocumentCameraViewController(); controller.delegate = context.coordinator; return controller }
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onImage: (UIImage) -> Void; let dismiss: DismissAction
        init(onImage: @escaping (UIImage) -> Void, dismiss: DismissAction) { self.onImage = onImage; self.dismiss = dismiss }
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) { if scan.pageCount > 0 { onImage(scan.imageOfPage(at: 0)) }; dismiss() }
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) { dismiss() }
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) { dismiss() }
    }
}
