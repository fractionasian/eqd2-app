import XCTest
@testable import EQD2App

final class EQD2CalculatorTests: XCTestCase {

    // MARK: - Forward Calculation Tests

    func testForwardCalculation_StandardFractionation() {
        // Standard fractionation: 50 Gy in 25 fractions (2 Gy/fx), α/β = 10
        let result = EQD2Calculator.calculateForward(
            totalDose: 50,
            numberOfFractions: 25,
            alphaBeta: 10
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 50.0, accuracy: 0.01, "Standard 2 Gy fractions should equal the total dose")
    }

    func testForwardCalculation_Hypofractionation() {
        // Hypofractionation: 42.5 Gy in 16 fractions (2.656 Gy/fx), α/β = 10
        let result = EQD2Calculator.calculateForward(
            totalDose: 42.5,
            numberOfFractions: 16,
            alphaBeta: 10
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 45.84, accuracy: 0.01)
    }

    func testForwardCalculation_LateReactingTissue() {
        // 60 Gy in 30 fractions with α/β = 3 (late-reacting tissue)
        let result = EQD2Calculator.calculateForward(
            totalDose: 60,
            numberOfFractions: 30,
            alphaBeta: 3
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 60.0, accuracy: 0.01)
    }

    func testForwardCalculation_Stereotactic() {
        // SBRT: 54 Gy in 3 fractions, α/β = 10
        let result = EQD2Calculator.calculateForward(
            totalDose: 54,
            numberOfFractions: 3,
            alphaBeta: 10
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 151.2, accuracy: 0.1)
    }

    func testForwardCalculation_InvalidInputs() {
        XCTAssertNil(EQD2Calculator.calculateForward(totalDose: -50, numberOfFractions: 25, alphaBeta: 10))
        XCTAssertNil(EQD2Calculator.calculateForward(totalDose: 50, numberOfFractions: 0, alphaBeta: 10))
        XCTAssertNil(EQD2Calculator.calculateForward(totalDose: 50, numberOfFractions: 25, alphaBeta: -10))
        XCTAssertNil(EQD2Calculator.calculateForward(totalDose: 0, numberOfFractions: 0, alphaBeta: 0))
    }

    // MARK: - Reverse Calculation Tests

    func testReverseCalculation_StandardFractionation() {
        // Should return 50 Gy for EQD2=50, 25 fractions, α/β=10
        let result = EQD2Calculator.calculateReverse(
            targetEQD2: 50,
            numberOfFractions: 25,
            alphaBeta: 10
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 50.0, accuracy: 0.01)
    }

    func testReverseCalculation_Hypofractionation() {
        // EQD2=60 in 5 fractions with α/β=3
        let result = EQD2Calculator.calculateReverse(
            targetEQD2: 60,
            numberOfFractions: 5,
            alphaBeta: 3
        )

        XCTAssertNotNil(result)
        // Verify by checking forward calculation
        if let totalDose = result {
            let verification = EQD2Calculator.calculateForward(
                totalDose: totalDose,
                numberOfFractions: 5,
                alphaBeta: 3
            )
            XCTAssertEqual(verification!, 60.0, accuracy: 0.01)
        }
    }

    func testReverseCalculation_InvalidInputs() {
        XCTAssertNil(EQD2Calculator.calculateReverse(targetEQD2: -60, numberOfFractions: 5, alphaBeta: 3))
        XCTAssertNil(EQD2Calculator.calculateReverse(targetEQD2: 60, numberOfFractions: 0, alphaBeta: 3))
        XCTAssertNil(EQD2Calculator.calculateReverse(targetEQD2: 60, numberOfFractions: 5, alphaBeta: -3))
    }

    // MARK: - Bidirectional Consistency Tests

    func testBidirectionalConsistency_Case1() {
        // Forward then reverse should give same result
        let forward = EQD2Calculator.calculateForward(
            totalDose: 70,
            numberOfFractions: 35,
            alphaBeta: 10
        )

        XCTAssertNotNil(forward)

        let reverse = EQD2Calculator.calculateReverse(
            targetEQD2: forward!,
            numberOfFractions: 35,
            alphaBeta: 10
        )

        XCTAssertNotNil(reverse)
        XCTAssertEqual(reverse!, 70.0, accuracy: 0.01)
    }

    func testBidirectionalConsistency_Case2() {
        // Test with different parameters
        let forward = EQD2Calculator.calculateForward(
            totalDose: 45,
            numberOfFractions: 20,
            alphaBeta: 3
        )

        XCTAssertNotNil(forward)

        let reverse = EQD2Calculator.calculateReverse(
            targetEQD2: forward!,
            numberOfFractions: 20,
            alphaBeta: 3
        )

        XCTAssertNotNil(reverse)
        XCTAssertEqual(reverse!, 45.0, accuracy: 0.01)
    }

    func testBidirectionalConsistency_Stereotactic() {
        // Test SBRT regimen
        let forward = EQD2Calculator.calculateForward(
            totalDose: 30,
            numberOfFractions: 3,
            alphaBeta: 10
        )

        XCTAssertNotNil(forward)

        let reverse = EQD2Calculator.calculateReverse(
            targetEQD2: forward!,
            numberOfFractions: 3,
            alphaBeta: 10
        )

        XCTAssertNotNil(reverse)
        XCTAssertEqual(reverse!, 30.0, accuracy: 0.01)
    }

    // MARK: - Edge Cases

    func testSingleFraction() {
        let result = EQD2Calculator.calculateForward(
            totalDose: 10,
            numberOfFractions: 1,
            alphaBeta: 10
        )

        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result!, 10.0, "Single large fraction should have higher EQD2")
    }

    func testVerySmallAlphaBeta() {
        let result = EQD2Calculator.calculateForward(
            totalDose: 50,
            numberOfFractions: 10,
            alphaBeta: 0.5
        )

        XCTAssertNotNil(result)
    }

    func testVeryLargeAlphaBeta() {
        let result = EQD2Calculator.calculateForward(
            totalDose: 50,
            numberOfFractions: 25,
            alphaBeta: 100
        )

        XCTAssertNotNil(result)
        // With very large α/β, EQD2 should approach total dose
        XCTAssertEqual(result!, 50.0, accuracy: 1.0)
    }
}
