import { useDisclaimerState } from '../components/DisclaimerModal';
import './About.css';

interface LimitationRowProps {
    icon: string;
    color: string;
    title: string;
    description: string;
}

function LimitationRow({ icon, color, title, description }: LimitationRowProps) {
    return (
        <div className="limitation-row">
            <span className="limitation-icon" style={{ color }}>{icon}</span>
            <div className="limitation-content">
                <strong>{title}</strong>
                <p>{description}</p>
            </div>
        </div>
    );
}

interface AlphaBetaRowProps {
    tissue: string;
    value: string;
}

function AlphaBetaRow({ tissue, value }: AlphaBetaRowProps) {
    return (
        <div className="alpha-beta-row">
            <span className="tissue-name">{tissue}</span>
            <span className="tissue-value">{value}</span>
        </div>
    );
}

export function About() {
    const { showDisclaimer } = useDisclaimerState();

    return (
        <div className="page">
            <header className="page-header">
                <h1 className="page-title">About</h1>
            </header>

            <main className="page-content">
                <section className="about-hero">
                    <span className="about-icon">⚕️</span>
                    <h2 className="about-app-name">EQD2 Calculator</h2>
                    <p className="about-version">Version 1.0</p>
                </section>

                <section className="about-section">
                    <h3 className="about-section-title">About</h3>
                    <div className="about-section-content">
                        <p>
                            This calculator computes the Equivalent Dose in 2 Gy fractions
                            (EQD2) using the linear-quadratic (LQ) model.
                        </p>
                        <p>
                            The LQ model describes the biological effect of radiation based on
                            the dose per fraction and tissue-specific radiosensitivity (α/β
                            ratio).
                        </p>
                    </div>
                </section>

                <section className="about-section">
                    <h3 className="about-section-title">Formula</h3>
                    <div className="about-section-content">
                        <code className="formula-display">
                            EQD2 = D × [(d + α/β) / (2 + α/β)]
                        </code>
                        <p className="formula-legend"><strong>Where:</strong></p>
                        <ul className="formula-vars">
                            <li>D = total dose (Gy)</li>
                            <li>d = dose per fraction (Gy)</li>
                            <li>α/β = tissue-specific ratio</li>
                        </ul>
                    </div>
                </section>

                <section className="about-section">
                    <h3 className="about-section-title">Important Limitations</h3>
                    <div className="about-section-content limitations">
                        <LimitationRow
                            icon="⚠️"
                            color="#f59e0b"
                            title="Dose Per Fraction Range"
                            description="The linear-quadratic model is most accurate for doses of 1-6 Gy per fraction. Use with caution outside this range, particularly for stereotactic ablative radiotherapy (SABR/SBRT) where doses exceed 6 Gy per fraction."
                        />
                        <LimitationRow
                            icon="⏱️"
                            color="#3b82f6"
                            title="Time Factor"
                            description="The basic LQ model does not account for overall treatment time, tumor repopulation, or interfraction repair."
                        />
                        <LimitationRow
                            icon="📈"
                            color="#a855f7"
                            title="High Dose Limitations"
                            description="At very high doses per fraction (>10 Gy), the LQ model may overestimate biological effect. Alternative models should be considered for SBRT."
                        />
                    </div>
                </section>

                <section className="about-section">
                    <h3 className="about-section-title">Common α/β Values</h3>
                    <div className="about-section-content alpha-beta-table">
                        <AlphaBetaRow tissue="Early-reacting tissues (acute effects)" value="10 Gy" />
                        <AlphaBetaRow tissue="Late-reacting tissues (CNS, lung)" value="3 Gy" />
                        <AlphaBetaRow tissue="Prostate cancer" value="1.5 Gy" />
                        <AlphaBetaRow tissue="Melanoma" value="0.6 Gy" />
                    </div>
                </section>

                <section className="about-section disclaimer-section">
                    <h3 className="about-section-title">Medical Disclaimer</h3>
                    <div className="about-section-content">
                        <span className="disclaimer-icon-large">🛡️</span>
                        <p className="disclaimer-highlight">
                            This tool is for educational purposes only and does not constitute
                            medical advice.
                        </p>
                        <p className="disclaimer-text">
                            All calculations must be independently verified. Treatment planning
                            decisions should only be made by qualified radiation oncology
                            professionals.
                        </p>
                        <button className="view-disclaimer-button" onClick={showDisclaimer}>
                            View Full Disclaimer
                            <span>→</span>
                        </button>
                    </div>
                </section>

                <section className="about-section">
                    <h3 className="about-section-title">References</h3>
                    <div className="about-section-content references">
                        <p>
                            1. Fowler JF. The linear-quadratic formula and progress in
                            fractionated radiotherapy. Br J Radiol. 1989;62(740):679-694.
                        </p>
                        <p>
                            2. Joiner MC, van der Kogel AJ. Basic Clinical Radiobiology. 4th
                            ed. CRC Press; 2009.
                        </p>
                        <p>
                            3. AAPM TG-101: Stereotactic Body Radiation Therapy. Med Phys.
                            2010.
                        </p>
                    </div>
                </section>
            </main>
        </div>
    );
}
