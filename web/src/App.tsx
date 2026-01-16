import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { TabNavigation } from './components/TabNavigation';
import { DisclaimerModal } from './components/DisclaimerModal';
import { ReloadPrompt } from './components/ReloadPrompt';
import { ForwardEQD2 } from './pages/ForwardEQD2';
import { ReverseEQD2 } from './pages/ReverseEQD2';
import { History } from './pages/History';
import { About } from './pages/About';
import './App.css';

import { DisclaimerProvider } from './components/DisclaimerContext';

function App() {
  return (
    <DisclaimerProvider>
      <BrowserRouter>
        <div className="app">
          <DisclaimerModal />
          <ReloadPrompt />
          <main className="main-content">
            <Routes>
              <Route path="/" element={<ForwardEQD2 />} />
              <Route path="/reverse" element={<ReverseEQD2 />} />
              <Route path="/history" element={<History />} />
              <Route path="/about" element={<About />} />
            </Routes>
          </main>
          <TabNavigation />
        </div>
      </BrowserRouter>
    </DisclaimerProvider>
  );
}

export default App;
