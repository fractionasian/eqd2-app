import './DisclaimerModal.css';
import { useDisclaimer } from './DisclaimerContext';

export function DisclaimerModal() {
    const { isDisclaimerVisible, hideDisclaimer } = useDisclaimer();

    if (!isDisclaimerVisible) return null;

    return (
        <div className="disclaimer-overlay">
            <div className="disclaimer-modal">
                <div className="disclaimer-header">
                    <span className="disclaimer-icon">⚠️</span>
                    <h2 className="disclaimer-title">Medical Disclaimer</h2>
                </div>

                <div className="disclaimer-content">
                    <p className="disclaimer-intro">
                        This EQD2 calculator is provided for educational and informational
                        purposes only.
                    </p>

                    <h3 className="disclaimer-section-title">Important Notice:</h3>
                    <ul className="disclaimer-list">
                        <li>This tool does NOT constitute medical advice</li>
                        <li>All calculations should be independently verified</li>
                        <li>
                            Treatment decisions should be made by qualified healthcare
                            professionals
                        </li>
                        <li>The developers assume no liability for clinical use</li>
                        <li>
                            This calculator uses the linear-quadratic model which has
                            limitations
                        </li>
                    </ul>

                    <h3 className="disclaimer-section-title">
                        By using this application, you acknowledge that:
                    </h3>
                    <ul className="disclaimer-list">
                        <li>
                            You understand the limitations of the linear-quadratic model
                        </li>
                        <li>You will verify all calculations independently</li>
                        <li>
                            You will not use this as the sole basis for treatment planning
                        </li>
                        <li>You accept full responsibility for any clinical decisions</li>
                    </ul>
                </div>

                <button className="disclaimer-button" onClick={hideDisclaimer}>
                    I Understand and Agree
                </button>
            </div>
        </div>
    );
}


