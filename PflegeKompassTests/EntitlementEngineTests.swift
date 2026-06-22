import XCTest
@testable import PflegeKompass

final class EntitlementEngineTests: XCTestCase {
    private let engine = EntitlementEngine()

    func testHomeCareWithGradeThreeAndFamilySupportShowsLikelyCareAllowance() {
        let result = engine.evaluate(profile: homeProfile(provider: .angehoerige)).first { $0.benefit == .pflegegeld }
        XCTAssertEqual(result?.status, .wahrscheinlichRelevant)
    }

    func testHomeCareWithGradeThreeAndServiceShowsLikelyInKindBenefits() {
        let result = engine.evaluate(profile: homeProfile(provider: .pflegedienst)).first { $0.benefit == .pflegesachleistungen }
        XCTAssertEqual(result?.status, .wahrscheinlichRelevant)
    }

    func testExistingBenefitIsMarkedForCheckingNotPromisedAgain() {
        var profile = homeProfile(provider: .angehoerige)
        profile.vorhandeneLeistungen = [.pflegegeld]
        let result = engine.evaluate(profile: profile).first { $0.benefit == .pflegegeld }
        XCTAssertEqual(result?.status, .bittePruefen)
    }

    func testUnknownGradeRequestsClarificationInsteadOfClaimingBenefits() {
        let profile = Pflegeprofil(id: UUID(), bezeichnung: "Testperson", pflegegrad: .unbekannt, pflegeort: .unbekannt, versorgungssetup: .unbekannt, vorhandeneLeistungen: [], createdAt: .now)
        let results = engine.evaluate(profile: profile)
        XCTAssertEqual(results.first?.status, .aktuellUnklar)
        XCTAssertFalse(results.contains { $0.benefit == .pflegegeld })
    }

    func testCommonHomeCareCaseReturnsAtLeastFiveOrientationTopics() {
        let results = engine.evaluate(profile: homeProfile(provider: .gemischt))
        XCTAssertGreaterThanOrEqual(results.count, 5)
        XCTAssertTrue(results.allSatisfy { !$0.explanation.isEmpty && !$0.nextStep.isEmpty })
    }

    func testHospitalDischargeDoesNotClaimHomeCareAllowance() {
        var profile = homeProfile(provider: .angehoerige)
        profile.pflegeort = .krankenhausEntlassung
        let results = engine.evaluate(profile: profile)
        XCTAssertFalse(results.contains { $0.benefit == .pflegegeld })
        XCTAssertTrue(results.contains { $0.benefit == .pflegeberatung })
    }

    func testParserDoesNotInventDeadlineDate() {
        let analysis = LocalDocumentParser().analyze(text: "Bitte beachten Sie die Frist innerhalb eines Monats.")
        XCTAssertTrue(analysis.deadlineHint?.contains("genaue Datum ist noch nicht eindeutig") == true)
    }

    func testParserRecognizesExplicitGermanDateAndObjectionHint() {
        let analysis = LocalDocumentParser().analyze(text: "Widerspruch ist bis zum 12.06.2026 möglich.")
        XCTAssertTrue(analysis.deadlineHint?.contains("12.06.2026") == true)
        XCTAssertEqual(analysis.type, .widerspruchHinweis)
    }

    private func homeProfile(provider: Versorgungssetup) -> Pflegeprofil {
        Pflegeprofil(id: UUID(), bezeichnung: "Testperson", pflegegrad: .drei, pflegeort: .zuhause, versorgungssetup: provider, vorhandeneLeistungen: [], createdAt: .now)
    }
}
