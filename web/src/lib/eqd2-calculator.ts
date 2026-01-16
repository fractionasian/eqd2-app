/**
 * EQD2 Calculator - Core calculation logic
 * Ported from iOS EQD2Calculator.swift
 * 
 * CRITICAL: This is used for medical treatment planning.
 * Any changes must maintain mathematical accuracy.
 */

/**
 * Calculate EQD2 (Equivalent Dose in 2 Gy fractions)
 * Formula: EQD2 = D × [(d + α/β) / (2 + α/β)]
 * 
 * @param totalDose - Total radiation dose in Gray
 * @param numberOfFractions - Number of treatment fractions
 * @param alphaBeta - Alpha/beta ratio for tissue type
 * @returns EQD2 value in Gray, or null if inputs are invalid
 */
export function calculateForward(
  totalDose: number,
  numberOfFractions: number,
  alphaBeta: number
): number | null {
  if (totalDose <= 0 || numberOfFractions <= 0 || alphaBeta <= 0) {
    return null;
  }

  const dosePerFraction = totalDose / numberOfFractions;

  // EQD2 formula: D × [(d + α/β) / (2 + α/β)]
  return totalDose * ((dosePerFraction + alphaBeta) / (2 + alphaBeta));
}

/**
 * Calculate total dose required to achieve a target EQD2
 * Solves quadratic: n × d² + n × α/β × d - EQD2 × (2 + α/β) = 0
 * 
 * @param targetEQD2 - Desired EQD2 value in Gray
 * @param numberOfFractions - Number of treatment fractions
 * @param alphaBeta - Alpha/beta ratio for tissue type
 * @returns Total dose in Gray, or null if calculation fails
 */
export function calculateReverse(
  targetEQD2: number,
  numberOfFractions: number,
  alphaBeta: number
): number | null {
  if (targetEQD2 <= 0 || numberOfFractions <= 0 || alphaBeta <= 0) {
    return null;
  }

  // Solving quadratic: n × d² + n × α/β × d - EQD2 × (2 + α/β) = 0
  const a = numberOfFractions;
  const b = numberOfFractions * alphaBeta;
  const c = -targetEQD2 * (2 + alphaBeta);

  // Quadratic formula: d = (-b + sqrt(b² - 4ac)) / 2a
  const discriminant = b * b - 4 * a * c;

  if (discriminant < 0) {
    return null;
  }

  const dosePerFraction = (-b + Math.sqrt(discriminant)) / (2 * a);

  if (dosePerFraction <= 0) {
    return null;
  }

  return dosePerFraction * numberOfFractions;
}
