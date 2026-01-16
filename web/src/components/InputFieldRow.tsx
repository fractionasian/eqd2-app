import { useRef, useId } from 'react';
import './InputFieldRow.css';

interface InputFieldRowProps {
    label: string;
    placeholder: string;
    unit?: string;
    value: string;
    onChange: (value: string) => void;
    type?: 'decimal' | 'integer';
}

export function InputFieldRow({
    label,
    placeholder,
    unit,
    value,
    onChange,
    type = 'decimal',
}: InputFieldRowProps) {
    const inputRef = useRef<HTMLInputElement>(null);
    const id = useId();

    const handleRowClick = () => {
        if (inputRef.current) {
            inputRef.current.focus();
            inputRef.current.select();
        }
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const newValue = e.target.value;

        // Allow empty value or valid numeric input
        if (newValue === '' || newValue === '-') {
            onChange(newValue);
            return;
        }

        // Validate based on type
        if (type === 'integer') {
            if (/^\d*$/.test(newValue)) {
                onChange(newValue);
            }
        } else {
            // Allow decimal numbers
            if (/^-?\d*\.?\d*$/.test(newValue)) {
                onChange(newValue);
            }
        }
    };

    return (
        <div className="input-field-row" onClick={handleRowClick}>
            <label htmlFor={id} className="input-field-label">
                {label}
            </label>
            <div className="input-field-wrapper">
                <input
                    ref={inputRef}
                    id={id}
                    type="text"
                    inputMode={type === 'integer' ? 'numeric' : 'decimal'}
                    className="input-field-input"
                    placeholder={placeholder}
                    value={value}
                    onChange={handleChange}
                    pattern="[0-9]*"
                />
                {unit && <span className="input-field-unit">{unit}</span>}
            </div>
        </div>
    );
}
