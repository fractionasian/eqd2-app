import { useState, useEffect, useRef } from 'react';
import { InputFieldRow } from '../components/InputFieldRow';
import { calculateReverse } from '../lib/eqd2-calculator';
import { useCalculationHistory } from '../hooks/use-calculation-history';
import { MathFormula } from '../components/MathFormula';
import './ForwardEQD2.css'; // Reuse same styles

export function ReverseEQD2() {
    const [targetEQD2, setTargetEQD2] = useState('');
    const [numberOfFractions, setNumberOfFractions] = useState('');
    const [alphaBeta, setAlphaBeta] = useState('10');
    const { addEntry } = useCalculationHistory();
    const lastSavedResult = useRef<number | null>(null);
    const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

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
    useEffect(() => {
        if (totalDose !== null && totalDose !== lastSavedResult.current) {
            if (debounceRef.current) {
                clearTimeout(debounceRef.current);
            }

            debounceRef.current = setTimeout(() => {
                lastSavedResult.current = totalDose;
                addEntry(
                    'Reverse',
                    `EQD2=${targetEQD2} Gy, n=${numberOfFractions}, α/β=${alphaBeta}`,
                    `${totalDose.toFixed(2)} Gy`
                );
            }, 1000);
        }

        return () => {
            if (debounceRef.current) {
                clearTimeout(debounceRef.current);
            }
        };
    }, [totalDose, targetEQD2, numberOfFractions, alphaBeta, addEntry]);

    return (
        <div className="page">
            <header className="page-header">
                <h1 className="page-title">Reverse EQD2</h1>
            </header>

            <main className="page-content">
                <section className="input-section">
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
                </section>

                {validationMessage && (
                    <section className="validation-section">
                        <div className="validation-message">
                            <span className="validation-icon">⚠️</span>
                            <span>{validationMessage}</span>
                        </div>
                    </section>
                )}

                {totalDose !== null && (
                    <section className="result-section">
                        <div className="result-row primary">
                            <span className="result-label">Total Dose</span>
                            <span className="result-value">{totalDose.toFixed(2)} Gy</span>
                        </div>

                        {dosePerFraction !== null && (
                            <>
                                <div className="result-row secondary">
                                    <span className="result-label">Dose/fraction</span>
                                    <span className="result-value">
                                        {dosePerFraction.toFixed(2)} Gy
                                    </span>
                                </div>

                                {(dosePerFraction < 1 || dosePerFraction > 6) && (
                                    <div className="warning-box">
                                        <span className="warning-icon">⚠️</span>
                                        <div className="warning-content">
                                            <strong>Outside Typical Range</strong>
                                            <p>
                                                The linear-quadratic model is most accurate for doses of
                                                1-6 Gy per fraction. Use with caution outside this
                                                range.
                                            </p>
                                        </div>
                                    </div>
                                )}
                            </>
                        )}
                    </section>
                )}

                <section className="formula-section">
                    <MathFormula tex="EQD_2 = D \times \frac{d + \alpha/\beta}{2 + \alpha/\beta}" block />
                    <p className="formula-description">
                        Solves for <MathFormula tex="D" /> (total dose) given target <MathFormula tex="EQD_2" />
                    </p>
                </section>
            </main>
        </div>
    );
}
