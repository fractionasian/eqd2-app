import { Suspense, lazy } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { TabNavigation } from './components/TabNavigation';
import { DisclaimerModal } from './components/DisclaimerModal';
import { ReloadPrompt } from './components/ReloadPrompt';
import './App.css';
import { DisclaimerProvider } from './components/DisclaimerContext';

// Lazy load pages
const ForwardEQD2 = lazy(() => import('./pages/ForwardEQD2').then(module => ({ default: module.ForwardEQD2 })));
const ReverseEQD2 = lazy(() => import('./pages/ReverseEQD2').then(module => ({ default: module.ReverseEQD2 })));
const History = lazy(() => import('./pages/History').then(module => ({ default: module.History })));
const About = lazy(() => import('./pages/About').then(module => ({ default: module.About })));

function LoadingSpinner() {
  return (
    <div style={{
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      height: '100%',
      color: 'var(--text-tertiary)'
    }}>
      Loading...
    </div>
  );
}

function App() {
  return (
    <DisclaimerProvider>
      <BrowserRouter>
        <div className="app">
          <DisclaimerModal />
          <ReloadPrompt />
          <main className="main-content">
            <Suspense fallback={<LoadingSpinner />}>
              <Routes>
                <Route path="/" element={<ForwardEQD2 />} />
                <Route path="/reverse" element={<ReverseEQD2 />} />
                <Route path="/history" element={<History />} />
                <Route path="/about" element={<About />} />
              </Routes>
            </Suspense>
          </main>
          <TabNavigation />
        </div>
      </BrowserRouter>
    </DisclaimerProvider>
  );
}

export default App;
