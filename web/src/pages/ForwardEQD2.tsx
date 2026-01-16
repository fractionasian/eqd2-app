import { useState, useEffect, useRef } from 'react';
import { InputFieldRow } from '../components/InputFieldRow';
import { calculateForward } from '../lib/eqd2-calculator';
import { useCalculationHistory } from '../hooks/use-calculation-history';
import { MathFormula } from '../components/MathFormula';
import { CalculatorLayout } from '../components/CalculatorLayout';
import './ForwardEQD2.css';

export function ForwardEQD2() {
    const [totalDose, setTotalDose] = useState('');
    const [numberOfFractions, setNumberOfFractions] = useState('');
    const [alphaBeta, setAlphaBeta] = useState('10');
    const { addEntry } = useCalculationHistory();
    const lastSavedResult = useRef<number | null>(null);

    // Calculate dose per fraction
    const dosePerFraction =
        totalDose && numberOfFractions
            ? parseFloat(totalDose) / parseFloat(numberOfFractions)
            : null;

    // Calculate EQD2
    const eqd2Result =
        totalDose && numberOfFractions && alphaBeta
            ? calculateForward(
                parseFloat(totalDose),
                parseFloat(numberOfFractions),
                parseFloat(alphaBeta)
            )
            : null;

    // Input validation
    const getValidationMessage = (): string | null => {
        if (totalDose && isNaN(parseFloat(totalDose))) {
            return 'Total dose must be a valid number';
        }
        if (totalDose && parseFloat(totalDose) <= 0) {
            return 'Total dose must be positive';
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
    const isReadyToSave = eqd2Result !== null;

    useEffect(() => {
        if (!isReadyToSave) return;

        const timer = setTimeout(() => {
            // Only save if result hasn't changed to null/invalid in the meantime
            // and if it's different (logic handled by history hook or just standard check)
            // Actually, the simplest check for this specific app is:
            if (eqd2Result !== lastSavedResult.current) {
                lastSavedResult.current = eqd2Result;
                addEntry(
                    'EQD2',
                    `D=${totalDose} Gy, n=${numberOfFractions}, α/β=${alphaBeta}`,
                    `${eqd2Result.toFixed(2)} Gy`
                );
            }
        }, 1000);

        return () => clearTimeout(timer);
    }, [eqd2Result, totalDose, numberOfFractions, alphaBeta, addEntry, isReadyToSave]);

    return (
        <CalculatorLayout
            title={<>EQD<sub>2</sub></>}
            validationMessage={validationMessage}
            result={eqd2Result !== null ? { label: <>EQD<sub>2</sub></>, value: eqd2Result, unit: 'Gy' } : null}
            dosePerFraction={dosePerFraction}
            formulaTex="EQD_2 = D \cdot \frac{d + (\alpha/\beta)}{2\ \text{Gy} + (\alpha/\beta)}"
            formulaDescription={
                <>
                    <MathFormula tex="D" /> = total dose, <MathFormula tex="d" /> = dose per fraction
                </>
            }
        >
            <InputFieldRow
                label="Total Dose"
                placeholder="50"
                unit="Gy"
                value={totalDose}
                onChange={setTotalDose}
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
