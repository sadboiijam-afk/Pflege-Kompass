import Foundation
import UIKit
import Vision

protocol DocumentExplaining {
    func explain(text: String) async throws -> String
}

/// Deliberately has no implementation: document text must not leave the device until an approved backend and consent flow exist.
// TODO(OpenAI): Wire this only to a consent-gated server endpoint; never call an AI provider directly from the iOS app.
struct ServerSideDocumentExplanationService: DocumentExplaining {
    enum ServiceError: Error { case notConfigured }
    func explain(text: String) async throws -> String { throw ServiceError.notConfigured }
}

final class LocalOCRService {
    func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else { throw OCRFailure.invalidImage }
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNRecognizeTextRequest { request, error in
                    if let error { continuation.resume(throwing: error); return }
                    let lines = (request.results as? [VNRecognizedTextObservation])?.compactMap {
                        $0.topCandidates(1).first?.string
                    } ?? []
                    continuation.resume(returning: lines.joined(separator: "\n"))
                }
                request.recognitionLevel = .accurate
                request.recognitionLanguages = ["de-DE"]
                request.usesLanguageCorrection = true
                do { try VNImageRequestHandler(cgImage: cgImage).perform([request]) }
                catch { continuation.resume(throwing: error) }
            }
        }
    }

    enum OCRFailure: Error { case invalidImage }
}

struct LocalDocumentParser {
    func analyze(text: String) -> DokumentAnalyse {
        let normalized = text.lowercased()
        let type: Dokumenttyp
        if normalized.contains("widerspruch") || normalized.contains("innerhalb eines monats") { type = .widerspruchHinweis }
        else if normalized.contains("begutachtung") || normalized.contains("medizinischer dienst") || normalized.contains("md") { type = .mdGutachten }
        else if normalized.contains("pflegegrad") && (normalized.contains("bescheid") || normalized.contains("entscheidung")) { type = .pflegegradBescheid }
        else if normalized.contains("unterlagen") && (normalized.contains("bitte") || normalized.contains("nachreichen")) { type = .unterlagenAnforderung }
        else if normalized.contains("rechnung") || normalized.contains("betrag") { type = .rechnung }
        else if normalized.contains("pflegekasse") { type = .pflegekassenBrief }
        else { type = .unbekannt }

        let explicitDate = firstGermanDate(in: text)
        let deadlinePhrase = normalized.contains("frist") || normalized.contains("bis zum") || normalized.contains("innerhalb eines monats")
        let deadlineHint: String? = deadlinePhrase ? (explicitDate.map { "Mögliche Frist erkannt: \($0). Bitte im Brief prüfen und bestätigen." } ?? "Mögliche Frist erkannt. Das genaue Datum ist noch nicht eindeutig – bitte im Brief prüfen.") : nil
        let summary: String
        switch type {
        case .pflegegradBescheid: summary = "Der Brief wirkt wie ein Bescheid zum Pflegegrad. Prüfen Sie Entscheidung, Datum und die Hinweise am Ende des Schreibens."
        case .mdGutachten: summary = "Der Brief weist möglicherweise auf ein MD-Gutachten oder eine Begutachtung hin. Bereiten Sie Beispiele aus dem Pflegealltag vor."
        case .unterlagenAnforderung: summary = "Der Brief bittet möglicherweise um Unterlagen. Prüfen Sie genau, welche Nachweise und welches Datum genannt werden."
        case .widerspruchHinweis: summary = "Der Brief enthält möglicherweise einen Frist- oder Widerspruchshinweis. Lassen Sie die Angaben bei Bedarf professionell prüfen."
        case .pflegekassenBrief: summary = "Der Brief scheint von einer Pflegekasse zu stammen. Die wichtigen Angaben sind noch nicht vollständig eingeordnet."
        case .rechnung: summary = "Das Dokument wirkt wie eine Rechnung. Prüfen Sie Leistung, Zeitraum und ob eine Erstattung möglicherweise relevant sein könnte."
        case .unbekannt: summary = "Der Brief ist noch nicht eindeutig einordenbar. Prüfen Sie Absender, Betreff, Datum und hervorgehobene Fristen."
        }
        return DokumentAnalyse(type: type, confidence: type == .unbekannt ? 0.35 : 0.78, summary: summary, deadlineHint: deadlineHint, nextStep: "Originalbrief aufbewahren und wichtige Angaben vor dem Anlegen einer Frist selbst bestätigen.")
    }

    private func firstGermanDate(in text: String) -> String? {
        let pattern = "\\b[0-3]?\\d\\.[01]?\\d\\.\\d{4}\\b"
        guard let range = text.range(of: pattern, options: .regularExpression) else { return nil }
        return String(text[range])
    }
}
