import 'katex/dist/katex.min.css';
import katex from 'katex';
import { useEffect, useRef } from 'react';
import './MathFormula.css';

interface MathFormulaProps {
    tex: string;
    block?: boolean;
}

export function MathFormula({ tex, block = false }: MathFormulaProps) {
    const containerRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        if (containerRef.current) {
            katex.render(tex, containerRef.current, {
                throwOnError: false,
                displayMode: block
            });
        }
    }, [tex, block]);

    return <div ref={containerRef} className={`math-formula ${block ? 'block' : 'inline'}`} />;
}
