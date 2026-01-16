import { useState, useEffect, useRef } from 'react';
import { InputFieldRow } from '../components/InputFieldRow';
import { calculateForward } from '../lib/eqd2-calculator';
import { useCalculationHistory } from '../hooks/use-calculation-history';
import { MathFormula } from '../components/MathFormula';
import './ForwardEQD2.css';

export function ForwardEQD2() {
    const [totalDose, setTotalDose] = useState('');
    const [numberOfFractions, setNumberOfFractions] = useState('');
    const [alphaBeta, setAlphaBeta] = useState('10');
    const { addEntry } = useCalculationHistory();
    const lastSavedResult = useRef<number | null>(null);
    const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

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
    useEffect(() => {
        if (eqd2Result !== null && eqd2Result !== lastSavedResult.current) {
            if (debounceRef.current) {
                clearTimeout(debounceRef.current);
            }

            debounceRef.current = setTimeout(() => {
                lastSavedResult.current = eqd2Result;
                addEntry(
                    'EQD2',
                    `D=${totalDose} Gy, n=${numberOfFractions}, α/β=${alphaBeta}`,
                    `${eqd2Result.toFixed(2)} Gy`
                );
            }, 1000);
        }

        return () => {
            if (debounceRef.current) {
                clearTimeout(debounceRef.current);
            }
        };
    }, [eqd2Result, totalDose, numberOfFractions, alphaBeta, addEntry]);

    return (
        <div className="page">
            <header className="page-header">
                <h1 className="page-title">EQD2</h1>
            </header>

            <main className="page-content">
                <section className="input-section">
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
                    />
                    <InputFieldRow
                        label="α/β Ratio"
                        placeholder="10"
                        value={alphaBeta}
                        onChange={setAlphaBeta}
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

                {eqd2Result !== null && (
                    <section className="result-section">
                        <div className="result-row primary">
                            <span className="result-label">EQD2</span>
                            <span className="result-value">{eqd2Result.toFixed(2)} Gy</span>
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
                        <MathFormula tex="D" /> = total dose, <MathFormula tex="d" /> = dose per fraction
                    </p>
                </section>
            </main>
        </div>
    );
}
