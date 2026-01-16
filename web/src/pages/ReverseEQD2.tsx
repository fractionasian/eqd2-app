import { useState, useEffect, useRef } from 'react';
import { InputFieldRow } from '../components/InputFieldRow';
import { calculateReverse } from '../lib/eqd2-calculator';
import { useCalculationHistory } from '../hooks/use-calculation-history';
import { MathFormula } from '../components/MathFormula';
import { CalculatorLayout } from '../components/CalculatorLayout';
import './ForwardEQD2.css'; // Reuse same styles

export function ReverseEQD2() {
    const [targetEQD2, setTargetEQD2] = useState('');
    const [numberOfFractions, setNumberOfFractions] = useState('');
    const [alphaBeta, setAlphaBeta] = useState('10');
    const { addEntry } = useCalculationHistory();
    const lastSavedResult = useRef<number | null>(null);

    // Calculate total dose
    const totalDose =
        targetEQD2 && numberOfFractions && alphaBeta
            ? calculateReverse(
                parseFloat(targetEQD2),
                parseFloat(numberOfFractions),
                parseFloat(alphaBeta)
            )
            : null;

    // Calculate dose per fraction
    const dosePerFraction =
        totalDose && numberOfFractions
            ? totalDose / parseFloat(numberOfFractions)
            : null;

    // Input validation
    const getValidationMessage = (): string | null => {
        if (targetEQD2 && isNaN(parseFloat(targetEQD2))) {
            return 'Target EQD2 must be a valid number';
        }
        if (targetEQD2 && parseFloat(targetEQD2) <= 0) {
            return 'Target EQD2 must be positive';
        }
        if (numberOfFractions && isNaN(parseFloat(numberOfFractions))) {
            return 'Number of fractions must be a valid number';
        }
        if (numberOfFractions && parseFloat(numberOfFractions) <= 0) {
            return 'Number of fractions must be positive';
        }
        if (alphaBeta && isNaN(parseFloat(alphaBeta))) {
            return 'α/β ratio must be a valid number';
        }
        if (alphaBeta && parseFloat(alphaBeta) <= 0) {
            return 'α/β ratio must be positive';
        }
        return null;
    };

    const validationMessage = getValidationMessage();

    // Debounced save to history
    const isReadyToSave = totalDose !== null;

    useEffect(() => {
        if (!isReadyToSave) return;

        const timer = setTimeout(() => {
            if (totalDose !== lastSavedResult.current) {
                lastSavedResult.current = totalDose;
                addEntry(
                    'Reverse',
                    `EQD2=${targetEQD2} Gy, n=${numberOfFractions}, α/β=${alphaBeta}`,
                    `${totalDose.toFixed(2)} Gy`
                );
            }
        }, 1000);

        return () => clearTimeout(timer);
    }, [totalDose, targetEQD2, numberOfFractions, alphaBeta, addEntry, isReadyToSave]);

    return (
        <CalculatorLayout
            title="Reverse EQD2"
            validationMessage={validationMessage}
            result={totalDose !== null ? { label: 'Total Dose', value: totalDose, unit: 'Gy' } : null}
            dosePerFraction={dosePerFraction}
            formulaTex="EQD_2 = D \cdot \frac{d + (\alpha/\beta)}{2\text{Gy} + (\alpha/\beta)}"
            formulaDescription={
                <>
                    Solves for <MathFormula tex="D" /> (total dose) given target <MathFormula tex="EQD_2" />
                </>
            }
        >
            <InputFieldRow
                label="Target EQD2"
                placeholder="60"
                unit="Gy"
                value={targetEQD2}
                onChange={setTargetEQD2}
            />
            <InputFieldRow
                label="Fractions"
                placeholder="25"
                value={numberOfFractions}
                onChange={setNumberOfFractions}
                type="integer"
                unit="#"
            />
            <InputFieldRow
                label="α/β Ratio"
                placeholder="10"
                value={alphaBeta}
                onChange={setAlphaBeta}
                unit="Gy"
            />
        </CalculatorLayout>
    );
}
