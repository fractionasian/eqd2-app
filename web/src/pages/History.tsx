import type { CalculationEntry } from '../hooks/use-calculation-history';
import { useCalculationHistory } from '../hooks/use-calculation-history';
import './History.css';

function formatRelativeTime(date: Date): string {
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffSeconds = Math.floor(diffMs / 1000);
    const diffMinutes = Math.floor(diffSeconds / 60);
    const diffHours = Math.floor(diffMinutes / 60);
    const diffDays = Math.floor(diffHours / 24);

    if (diffSeconds < 60) return 'Just now';
    if (diffMinutes < 60) return `${diffMinutes}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;

    return date.toLocaleDateString();
}

function HistoryEntry({ entry, onDelete }: { entry: CalculationEntry; onDelete: () => void }) {
    return (
        <div className="history-entry">
            <div className="history-entry-header">
                <span className={`history-entry-type ${entry.type === 'EQD2' ? 'type-forward' : 'type-reverse'}`}>
                    {entry.type === 'EQD2' ? <>EQD<sub>2</sub></> : entry.type}
                </span>
                <span className="history-entry-time">{formatRelativeTime(entry.timestamp)}</span>
            </div>
            <p className="history-entry-inputs">{entry.inputs}</p>
            <div className="history-entry-footer">
                <div className="history-entry-result">
                    <span className="result-label">Result:</span>
                    <span className="result-value">{entry.result}</span>
                </div>
                <button
                    className="history-entry-delete"
                    onClick={onDelete}
                    aria-label="Delete entry"
                >
                    ✕
                </button>
            </div>
        </div>
    );
}

export function History() {
    const { entries, deleteEntry, clearAll } = useCalculationHistory();

    return (
        <div className="page">
            <header className="page-header">
                <h1 className="page-title">History</h1>
                {entries.length > 0 && (
                    <button className="clear-all-button" onClick={clearAll}>
                        Clear All
                    </button>
                )}
            </header>

            <main className="page-content">
                {entries.length === 0 ? (
                    <div className="empty-state">
                        <span className="empty-state-icon">⏱</span>
                        <h2 className="empty-state-title">No calculations yet</h2>
                        <p className="empty-state-description">
                            Your calculation history will appear here
                        </p>
                    </div>
                ) : (
                    <div className="history-list">
                        {entries.map((entry) => (
                            <HistoryEntry
                                key={entry.id}
                                entry={entry}
                                onDelete={() => deleteEntry(entry.id)}
                            />
                        ))}
                    </div>
                )}
            </main>
        </div>
    );
}
