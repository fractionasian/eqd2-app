import type { ReactNode } from 'react';
import { MathFormula } from './MathFormula';

interface CalculatorLayoutProps {
    title: ReactNode;
    children: ReactNode;
    validationMessage: string | null;
    result: {
        label: ReactNode;
        value: number;
        unit: string;
    } | null;
    dosePerFraction: number | null;
    formulaTex: string;
    formulaDescription: ReactNode;
}

export function CalculatorLayout({
    title,
    children,
    validationMessage,
    result,
    dosePerFraction,
    formulaTex,
    formulaDescription,
}: CalculatorLayoutProps) {
    return (
        <div className="page">
            <header className="page-header">
                <h1 className="page-title">{title}</h1>
            </header>

            <main className="page-content">
                <section className="input-section">
                    {children}
                </section>

                {validationMessage && (
                    <section className="validation-section">
                        <div className="validation-message">
                            <span className="validation-icon">⚠️</span>
                            <span>{validationMessage}</span>
                        </div>
                    </section>
                )}

                {result && (
                    <section className="result-section">
                        <div className="result-row primary">
                            <span className="result-label">{result.label}</span>
                            <span className="result-value">
                                {result.value.toFixed(2)} {result.unit}
                            </span>
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
                    <MathFormula tex={formulaTex} block />
                    <p className="formula-description">
                        {formulaDescription}
                    </p>
                </section>
            </main>
        </div>
    );
}
