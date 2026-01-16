import { createContext, useContext, useState, useEffect, type ReactNode } from 'react';

const STORAGE_KEY = 'hasSeenDisclaimer';

interface DisclaimerContextType {
    showDisclaimer: () => void;
    hideDisclaimer: () => void;
    isDisclaimerVisible: boolean;
}

const DisclaimerContext = createContext<DisclaimerContextType | undefined>(undefined);

export function DisclaimerProvider({ children }: { children: ReactNode }) {
    const [isDisclaimerVisible, setIsDisclaimerVisible] = useState(false);

    useEffect(() => {
        const hasSeenDisclaimer = localStorage.getItem(STORAGE_KEY);
        if (!hasSeenDisclaimer) {
            setIsDisclaimerVisible(true);
        }
    }, []);

    const showDisclaimer = () => {
        setIsDisclaimerVisible(true);
    };

    const hideDisclaimer = () => {
        localStorage.setItem(STORAGE_KEY, 'true');
        setIsDisclaimerVisible(false);
    };

    return (
        <DisclaimerContext.Provider value={{ showDisclaimer, hideDisclaimer, isDisclaimerVisible }}>
            {children}
        </DisclaimerContext.Provider>
    );
}

export function useDisclaimer() {
    const context = useContext(DisclaimerContext);
    if (context === undefined) {
        throw new Error('useDisclaimer must be used within a DisclaimerProvider');
    }
    return context;
}
