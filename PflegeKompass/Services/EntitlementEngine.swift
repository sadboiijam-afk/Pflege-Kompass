import Foundation

protocol EntitlementEvaluating {
    func evaluate(profile: Pflegeprofil) -> [BenefitResult]
}

/// Cautious orientation rules, not a legal entitlement decision engine.
struct EntitlementEngine: EntitlementEvaluating {
    func evaluate(profile: Pflegeprofil) -> [BenefitResult] {
        let reviewed = Date.now
        guard profile.pflegegrad != .unbekannt else {
            return [make(
                .pflegeberatung, .aktuellUnklar,
                "Für eine gezieltere Einordnung fehlt der Pflegegrad noch.",
                "Bescheid bereitlegen oder bei der Pflegekasse nach dem Stand fragen.",
                ["Antrag oder Bescheid der Pflegekasse"], reviewed
            )]
        }

        var results = [BenefitResult]()
        results.append(make(
            .pflegeberatung, status(for: .pflegeberatung, profile: profile, otherwise: .bittePruefen),
            profile.vorhandeneLeistungen.contains(.pflegeberatung)
                ? "Sie haben Pflegeberatung als vorhanden markiert. Prüfen Sie, ob die Beratung noch zu Ihrer aktuellen Situation passt."
                : "Eine persönliche Beratung könnte helfen, die nächsten Schritte in Ihrer Situation zu sortieren.",
            "Beratung bei der Pflegekasse anfragen und offene Fragen notieren.",
            ["Aktueller Pflegegrad-Bescheid", "Liste offener Fragen"], reviewed
        ))

        if profile.pflegegrad.rawValue >= 1 {
            results.append(make(
                .entlastungsbetrag, status(for: .entlastungsbetrag, profile: profile, otherwise: .bittePruefen),
                profile.vorhandeneLeistungen.contains(.entlastungsbetrag)
                    ? "Sie haben diese Unterstützung als vorhanden markiert. Prüfen Sie Abrechnung und passende anerkannte Angebote."
                    : "Unterstützung zur Entlastung im Alltag könnte für den Pflegealltag relevant sein.",
                "Bei der Pflegekasse nach passenden anerkannten Angeboten vor Ort fragen.",
                ["Pflegegrad-Bescheid", "Informationen zum Unterstützungsbedarf"], reviewed
            ))
            results.append(make(
                .pflegehilfsmittel, status(for: .pflegehilfsmittel, profile: profile, otherwise: .bittePruefen),
                "Hilfsmittel für die Pflege zu Hause könnten relevant sein, wenn sie den Pflegealltag erleichtern.",
                "Bedarf notieren und Ablauf mit der Pflegekasse prüfen.",
                ["Pflegegrad-Bescheid", "Liste der benötigten Hilfsmittel"], reviewed
            ))
        }

        guard profile.pflegeort == .zuhause else {
            if profile.pflegeort == .krankenhausEntlassung {
                results.append(make(
                    .pflegeberatung, .bittePruefen,
                    "Bei einer Entlassung kann eine zügige Abstimmung der nächsten Versorgungsschritte wichtig sein.",
                    "Sozialdienst, Pflegekasse und Angehörige zu einem konkreten Entlassungsplan zusammenbringen.",
                    ["Entlassbrief", "Pflegegrad-Bescheid"], reviewed
                ))
            }
            return unique(results)
        }

        if profile.pflegegrad.isEligibleForCoreBenefits {
            let familyProvidesCare = profile.versorgungssetup == .angehoerige || profile.versorgungssetup == .gemischt
            let serviceProvidesCare = profile.versorgungssetup == .pflegedienst || profile.versorgungssetup == .gemischt
            results.append(make(
                .pflegegeld,
                status(for: .pflegegeld, profile: profile, otherwise: familyProvidesCare ? .wahrscheinlichRelevant : .bittePruefen),
                familyProvidesCare
                    ? "Bei überwiegend privater Pflege zu Hause könnte diese Leistung relevant sein."
                    : "Ob diese Leistung zur aktuellen Versorgungsform passt, ist anhand Ihrer Angaben nicht eindeutig.",
                "Mit der Pflegekasse klären, welche Voraussetzungen für Ihre konkrete Pflegesituation gelten.",
                ["Pflegegrad-Bescheid", "Kontaktdaten der Pflegeperson"], reviewed
            ))
            results.append(make(
                .pflegesachleistungen,
                status(for: .pflegesachleistungen, profile: profile, otherwise: serviceProvidesCare ? .wahrscheinlichRelevant : .bittePruefen),
                serviceProvidesCare
                    ? "Bei Unterstützung durch einen Pflegedienst könnten diese Leistungen relevant sein."
                    : "Professionelle Hilfe zu Hause könnte ergänzend relevant sein; prüfen Sie die passende Versorgungsform.",
                "Mit Pflegekasse und Pflegedienst klären, welche Unterstützung passt.",
                ["Pflegegrad-Bescheid", "Aktuelle Bedarfe im Alltag"], reviewed
            ))
            results.append(make(
                .verhinderungspflege, status(for: .verhinderungspflege, profile: profile, otherwise: .bittePruefen),
                "Wenn Angehörige regelmäßig unterstützen, kann eine Vertretung in Ausnahmesituationen relevant sein.",
                "Vor einer geplanten Vertretung Voraussetzungen und Ablauf mit der Pflegekasse prüfen.",
                ["Pflegegrad-Bescheid", "Geplanter Zeitraum der Vertretung"], reviewed
            ))
            results.append(make(
                .kurzzeitpflege, status(for: .kurzzeitpflege, profile: profile, otherwise: .bittePruefen),
                "Eine vorübergehende stationäre Entlastung könnte in bestimmten Situationen relevant sein.",
                "Frühzeitig Verfügbarkeit und Voraussetzungen mit Pflegekasse und Einrichtung prüfen.",
                ["Pflegegrad-Bescheid", "Voraussichtlicher Zeitraum"], reviewed
            ))
        }

        results.append(make(
            .wohnraumanpassung, status(for: .wohnraumanpassung, profile: profile, otherwise: .aktuellUnklar),
            "Wenn die Wohnsituation Pflege oder Mobilität erschwert, könnte eine Anpassung relevant sein.",
            "Konkretes Hindernis beschreiben und vor einer Maßnahme den Ablauf mit der Pflegekasse prüfen.",
            ["Fotos oder Skizze der Wohnsituation", "Kostenvoranschlag"], reviewed
        ))
        return unique(results)
    }

    private func status(for benefit: PflegeLeistung, profile: Pflegeprofil, otherwise: BenefitResult.Status) -> BenefitResult.Status {
        profile.vorhandeneLeistungen.contains(benefit) ? .bittePruefen : otherwise
    }

    private func make(_ benefit: PflegeLeistung, _ status: BenefitResult.Status, _ explanation: String, _ nextStep: String, _ documents: [String], _ reviewed: Date) -> BenefitResult {
        BenefitResult(benefit: benefit, status: status, explanation: explanation, nextStep: nextStep, helpfulDocuments: documents, sourcePlaceholder: "TODO: Vor Produktivstart gegen offizielle Quelle und Stand prüfen.", lastReviewed: reviewed)
    }

    private func unique(_ results: [BenefitResult]) -> [BenefitResult] {
        Dictionary(results.map { ($0.id, $0) }, uniquingKeysWith: { _, last in last }).values.sorted { $0.title < $1.title }
    }
}
