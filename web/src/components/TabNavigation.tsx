import { NavLink } from 'react-router-dom';
import './TabNavigation.css';

const tabs = [
    { path: '/', label: <>EQD<sub>2</sub></>, icon: '➡️' },
    { path: '/reverse', label: 'Reverse', icon: '⬅️' },
    { path: '/history', label: 'History', icon: '↺' },
    { path: '/about', label: 'About', icon: 'ℹ️' },
];

export function TabNavigation() {
    return (
        <nav className="tab-navigation">
            {tabs.map((tab) => (
                <NavLink
                    key={tab.path}
                    to={tab.path}
                    className={({ isActive }) =>
                        `tab-item ${isActive ? 'tab-item-active' : ''}`
                    }
                >
                    <span className="tab-icon">{tab.icon}</span>
                    <span className="tab-label">{tab.label}</span>
                </NavLink>
            ))}
        </nav>
    );
}
