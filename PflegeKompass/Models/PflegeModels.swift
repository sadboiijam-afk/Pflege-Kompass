import Foundation

enum Pflegegrad: Int, Codable, CaseIterable, Identifiable {
    case unbekannt = 0, eins, zwei, drei, vier, fuenf

    var id: Int { rawValue }
    var title: String { self == .unbekannt ? "Noch unbekannt" : "Pflegegrad \(rawValue)" }
    var isEligibleForCoreBenefits: Bool { rawValue >= 2 }
}

enum Pflegeort: String, Codable, CaseIterable, Identifiable {
    case zuhause, pflegeheim, krankenhausEntlassung, unbekannt

    var id: String { rawValue }
    var title: String {
        switch self {
        case .zuhause: "Zu Hause"
        case .pflegeheim: "Pflegeheim"
        case .krankenhausEntlassung: "Krankenhaus / Entlassung"
        case .unbekannt: "Noch offen"
        }
    }
}

enum Versorgungssetup: String, Codable, CaseIterable, Identifiable {
    case angehoerige, pflegedienst, gemischt, unbekannt

    var id: String { rawValue }
    var title: String {
        switch self {
        case .angehoerige: "Angehörige"
        case .pflegedienst: "Pflegedienst"
        case .gemischt: "Gemischt"
        case .unbekannt: "Noch offen"
        }
    }
}

enum PflegeLeistung: String, Codable, CaseIterable, Identifiable, Hashable {
    case pflegegeld, pflegesachleistungen, entlastungsbetrag, pflegehilfsmittel
    case verhinderungspflege, kurzzeitpflege, wohnraumanpassung, pflegeberatung, keineAhnung

    var id: String { rawValue }
    var title: String {
        switch self {
        case .pflegegeld: "Pflegegeld"
        case .pflegesachleistungen: "Pflegesachleistungen"
        case .entlastungsbetrag: "Entlastungsbetrag"
        case .pflegehilfsmittel: "Pflegehilfsmittel"
        case .verhinderungspflege: "Verhinderungspflege"
        case .kurzzeitpflege: "Kurzzeitpflege"
        case .wohnraumanpassung: "Wohnraumanpassung"
        case .pflegeberatung: "Pflegeberatung"
        case .keineAhnung: "Keine Ahnung"
        }
    }

    static var checklistCases: [PflegeLeistung] { allCases.filter { $0 != .keineAhnung } }
}

struct Pflegeprofil: Codable, Equatable, Identifiable {
    let id: UUID
    var bezeichnung: String
    var pflegegrad: Pflegegrad
    var pflegeort: Pflegeort
    var versorgungssetup: Versorgungssetup
    var vorhandeneLeistungen: Set<PflegeLeistung>
    var createdAt: Date

    static let demo = Pflegeprofil(
        id: UUID(),
        bezeichnung: "Mutter",
        pflegegrad: .drei,
        pflegeort: .zuhause,
        versorgungssetup: .angehoerige,
        vorhandeneLeistungen: [.pflegegeld],
        createdAt: .now
    )
}

struct BenefitResult: Identifiable, Equatable {
    enum Status: String, Codable, CaseIterable {
        case wahrscheinlichRelevant
        case bittePruefen
        case aktuellUnklar

        var title: String {
            switch self {
            case .wahrscheinlichRelevant: "Wahrscheinlich relevant"
            case .bittePruefen: "Bitte prüfen"
            case .aktuellUnklar: "Aktuell unklar"
            }
        }
    }

    let benefit: PflegeLeistung
    let status: Status
    let explanation: String
    let nextStep: String
    let helpfulDocuments: [String]
    let sourcePlaceholder: String
    let lastReviewed: Date

    var id: String { benefit.id }
    var title: String { benefit.title }
}

struct PflegeTodo: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var detail: String
    var dueDate: Date?
    var isDone: Bool
    var origin: Origin

    enum Origin: String, Codable { case starter, benefitCheck, document }
}

struct DocumentItem: Identifiable, Codable, Equatable {
    let id: UUID
    let type: Dokumenttyp
    let displayName: String
    let createdAt: Date
}

struct ApplicationTemplate: Identifiable, Equatable {
    let id: String
    let title: String
    let body: String
}

enum Dokumenttyp: String, Codable, CaseIterable, Identifiable {
    case pflegegradBescheid, mdGutachten, unterlagenAnforderung, widerspruchHinweis, pflegekassenBrief, rechnung, unbekannt

    var id: String { rawValue }
    var title: String {
        switch self {
        case .pflegegradBescheid: "Pflegegrad-Bescheid"
        case .mdGutachten: "MD-Gutachten"
        case .unterlagenAnforderung: "Bitte um Unterlagen"
        case .widerspruchHinweis: "Widerspruch- oder Frist-Hinweis"
        case .pflegekassenBrief: "Pflegekassen-Brief"
        case .rechnung: "Rechnung"
        case .unbekannt: "Anderes Dokument"
        }
    }
}

struct DokumentAnalyse: Equatable {
    let type: Dokumenttyp
    let confidence: Double
    let summary: String
    let deadlineHint: String?
    let nextStep: String
}

// English domain aliases make backend/API mapping explicit while preserving a German-first app domain.
typealias CareCase = Pflegeprofil
typealias CareGrade = Pflegegrad
typealias CareLocation = Pflegeort
typealias CareProviderSetup = Versorgungssetup
typealias Benefit = PflegeLeistung
typealias BenefitStatus = BenefitResult.Status
typealias TaskItem = PflegeTodo
