import { useState, useEffect, useCallback, useRef } from 'react';

export interface CalculationEntry {
    id: string;
    timestamp: Date;
    type: 'EQD2' | 'Reverse';
    inputs: string;
    result: string;
}

interface StoredEntry {
    id: string;
    timestamp: string;
    type: 'EQD2' | 'Reverse';
    inputs: string;
    result: string;
}

const STORAGE_KEY = 'calculationHistory';
const MAX_ENTRIES = 100;
const DEBOUNCE_MS = 1000;

export function useCalculationHistory() {
    const [entries, setEntries] = useState<CalculationEntry[]>([]);
    const debounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

    // Load history from localStorage on mount
    useEffect(() => {
        try {
            const stored = localStorage.getItem(STORAGE_KEY);
            if (stored) {
                const parsed: StoredEntry[] = JSON.parse(stored);
                const hydrated = parsed.map((entry) => ({
                    ...entry,
                    timestamp: new Date(entry.timestamp),
                }));
                setEntries(hydrated);
            }
        } catch (error) {
            console.error('Failed to load calculation history:', error);
            setEntries([]);
        }
    }, []);

    // Save to localStorage (debounced)
    const saveToStorage = useCallback((newEntries: CalculationEntry[]) => {
        if (debounceRef.current) {
            clearTimeout(debounceRef.current);
        }

        debounceRef.current = setTimeout(() => {
            try {
                const toStore: StoredEntry[] = newEntries.map((entry) => ({
                    ...entry,
                    timestamp: entry.timestamp.toISOString(),
                }));
                localStorage.setItem(STORAGE_KEY, JSON.stringify(toStore));
            } catch (error) {
                console.error('Failed to save calculation history:', error);
            }
        }, DEBOUNCE_MS);
    }, []);

    const addEntry = useCallback(
        (type: 'EQD2' | 'Reverse', inputs: string, result: string) => {
            const entry: CalculationEntry = {
                id: crypto.randomUUID(),
                timestamp: new Date(),
                type,
                inputs,
                result,
            };

            setEntries((prev) => {
                const newEntries = [entry, ...prev].slice(0, MAX_ENTRIES);
                saveToStorage(newEntries);
                return newEntries;
            });
        },
        [saveToStorage]
    );

    const deleteEntry = useCallback(
        (id: string) => {
            setEntries((prev) => {
                const newEntries = prev.filter((entry) => entry.id !== id);
                saveToStorage(newEntries);
                return newEntries;
            });
        },
        [saveToStorage]
    );

    const clearAll = useCallback(() => {
        setEntries([]);
        localStorage.removeItem(STORAGE_KEY);
    }, []);

    return {
        entries,
        addEntry,
        deleteEntry,
        clearAll,
    };
}
