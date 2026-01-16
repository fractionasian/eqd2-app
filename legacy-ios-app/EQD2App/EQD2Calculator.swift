import Foundation

/// Core EQD2 calculation logic extracted for testing
struct EQD2Calculator {

    /// Calculate EQD2 (Equivalent Dose in 2 Gy fractions)
    /// - Parameters:
    ///   - totalDose: Total radiation dose in Gray
    ///   - numberOfFractions: Number of treatment fractions
    ///   - alphaBeta: Alpha/beta ratio for tissue type
    /// - Returns: EQD2 value in Gray, or nil if inputs are invalid
    static func calculateForward(totalDose: Double, numberOfFractions: Double, alphaBeta: Double) -> Double? {
        guard totalDose > 0, numberOfFractions > 0, alphaBeta > 0 else {
            return nil
        }

        let dosePerFraction = totalDose / numberOfFractions

        // EQD2 formula: D × [(d + α/β) / (2 + α/β)]
        return totalDose * ((dosePerFraction + alphaBeta) / (2 + alphaBeta))
    }

    /// Calculate total dose required to achieve a target EQD2
    /// - Parameters:
    ///   - targetEQD2: Desired EQD2 value in Gray
    ///   - numberOfFractions: Number of treatment fractions
    ///   - alphaBeta: Alpha/beta ratio for tissue type
    /// - Returns: Total dose in Gray, or nil if calculation fails
    static func calculateReverse(targetEQD2: Double, numberOfFractions: Double, alphaBeta: Double) -> Double? {
        guard targetEQD2 > 0, numberOfFractions > 0, alphaBeta > 0 else {
            return nil
        }

        // Solving quadratic: n × d² + n × α/β × d - EQD2 × (2 + α/β) = 0
        let a = numberOfFractions
        let b = numberOfFractions * alphaBeta
        let c = -targetEQD2 * (2 + alphaBeta)

        // Quadratic formula: d = (-b + sqrt(b² - 4ac)) / 2a
        let discriminant = b * b - 4 * a * c

        guard discriminant >= 0 else {
            return nil
        }

        let dosePerFraction = (-b + sqrt(discriminant)) / (2 * a)

        guard dosePerFraction > 0 else {
            return nil
        }

        return dosePerFraction * numberOfFractions
    }
}
