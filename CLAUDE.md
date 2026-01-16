# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EQD2 Calculator is a **Progressive Web App (PWA)** built with **Vite** and **React** (TypeScript). It calculates Equivalent Dose in 2 Gy fractions (EQD2) using the linear-quadratic model for radiation therapy planning.

**Legacy Note**: The original native iOS Swift code has been archived in `legacy-ios-app/`.

## Development

The web application is located in the `web/` directory.

### Prerequisites
- Node.js (v18+)
- npm

### Common Commands
Run these commands from the `web/` directory:

- **Start Dev Server**: `npm run dev`
- **Build for Production**: `npm run build`
- **Preview Production Build**: `npm run preview`
- **Lint Code**: `npm run lint`

## Architecture

### Tech Stack
- **Framework**: React 19 + Vite 7
- **Language**: TypeScript
- **Styling**: Vanilla CSS (CSS Variables for themes)
- **Routing**: React Router 7
- **PWA**: `vite-plugin-pwa` (Service Worker, Manifest)
- **Persistence**: `localStorage` (via custom hooks)

### Key Components
- **`src/pages/`**:
  - `ForwardEQD2.tsx`: Forward calculation (Dose/Fx → EQD2).
  - `ReverseEQD2.tsx`: Reverse calculation (Target EQD2 → Total Dose).
  - `History.tsx`: View saved calculations.
- **`src/hooks/`**:
  - `use-calculation-history.ts`: Manages history state and `localStorage` persistence.
- **`src/components/`**:
  - `CalculatorLayout.tsx`: Shared UI shell for calculator pages (promotes consistency).
  - `TabNavigation.tsx`: Fixed mobile-bottom navigation with backdrop blur.
  - `MathFormula.tsx`: KaTeX wrapper for rendering LaTeX formulas.
  - `InputFieldRow.tsx`: Standardized input row with label and unit.

### UI & Styling Patterns
- **Native-Like Feel**:
  - **Safe Areas**: Uses `env(safe-area-inset-bottom)` for iOS home bar clearance.
  - **Scrolling**: Implements a CSS spacer (`::after`) in content containers to robustly clear fixed navigation bars on mobile.
  - **Glassmorphism**: Backdrop filters used on navigation and overlays.
- **Typography**:
  - Medical terms must use proper formatting (e.g., `EQD₂` with subscript, not `EQD2`).
  - Font scaling respects user system settings but maintains layout integrity.

## Testing & Verification

### Medical Accuracy
- Calculations must maintain **0.01 Gy accuracy**.
- **Forward Formula**: `D × [(d + α/β) / (2 + α/β)]`
- **Reverse Formula**: Solves quadratic equation for Total Dose.
- Inputs must be validated (non-negative).
- Warning displayed if dose/fraction is outside 1-6 Gy range.

### PWA Verification
- Build output is in `dist/`.
- Manifest: `dist/manifest.webmanifest`.
- Service Worker: `dist/sw.js`.
- Verify offline capability using "Network -> Offline" in DevTools.
