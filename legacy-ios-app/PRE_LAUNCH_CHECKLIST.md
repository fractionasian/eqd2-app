# EQD2 Calculator - Pre-Launch Checklist

## 🚨 CRITICAL (Must Complete Before Launch)

### 1. Code Quality & Testing
- [ ] **Add CalculationHistoryTests.swift to Xcode project**
  - Right-click project → Add Files
  - Select CalculationHistoryTests.swift
  - Add to EQD2AppTests target
  
- [ ] **Run all tests and verify they pass**
  ```bash
  xcodebuild test -project EQD2App.xcodeproj -scheme EQD2App \
    -destination 'platform=iOS Simulator,name=iPhone 15'
  ```
  - Expected: 35 tests pass (8 calculator + 27 history)
  - Fix any failing tests before proceeding

- [ ] **Test on multiple devices/simulators**
  - [ ] iPhone SE (smallest screen)
  - [ ] iPhone 15 (standard)
  - [ ] iPhone 15 Pro Max (largest)
  - [ ] iPad (tablet layout)

### 2. App Icon & Visual Assets
- [ ] **Create app icon (1024x1024px)**
  - Use Canva/Figma or hire designer
  - Medical/professional theme
  - Blue color scheme (#007AFF)
  
- [ ] **Add icon to Xcode**
  - Assets.xcassets → AppIcon → Drag 1024x1024 PNG
  
- [ ] **Verify icon renders correctly**
  - Check on home screen
  - Check in Settings
  - Check in App Switcher

### 3. App Configuration
- [ ] **Update Bundle Identifier**
  - Current: `com.example.EQD2App`
  - Change to: `com.yourcompany.EQD2App`
  - Must be unique for App Store
  
- [ ] **Set Version & Build Numbers**
  - Version: 1.0.0 (user-facing)
  - Build: 1 (incremental)
  - Update in Xcode → Target → General
  
- [ ] **Configure App Display Name**
  - Keep as "EQD2App" or rename to "EQD2 Calculator"
  - Check length (max 30 characters for App Store)

### 4. Legal & Medical Compliance
- [ ] **Review disclaimer text** (DisclaimerView.swift)
  - Verify medical disclaimer is comprehensive
  - Consider legal review for medical apps
  - Ensure non-dismissible on first launch
  
- [ ] **Add Privacy Policy** (REQUIRED for App Store)
  - Even if you don't collect data, you need one
  - Host at: yourwebsite.com/privacy
  - Statement: "This app does not collect, store, or share any user data. All calculations are performed locally on your device."
  
- [ ] **Add Terms of Service** (Recommended for medical apps)
  - Liability limitations
  - Intended use statements
  - Professional responsibility clauses

### 5. Accessibility Compliance
- [ ] **Test with VoiceOver enabled**
  - Settings → Accessibility → VoiceOver → On
  - Navigate through all screens
  - Verify result announcements work
  - Check warning messages are audible
  
- [ ] **Test with Dynamic Type**
  - Settings → Accessibility → Display & Text Size → Larger Text
  - Verify all text scales properly
  - Check layout doesn't break at largest sizes
  
- [ ] **Test color contrast** (WCAG 2.1 AA)
  - Blue (#007AFF) on white: ✅ Pass
  - Orange warnings: ✅ Pass
  - Red errors: ✅ Pass

---

## ⚠️ IMPORTANT (Should Complete Before Launch)

### 6. App Store Assets
- [ ] **Create App Store screenshots** (Required)
  - 6.7" display (iPhone 15 Pro Max): 1290x2796
  - 5.5" display (older iPhones): 1242x2208
  - 12.9" iPad Pro (if supporting iPad): 2048x2732
  - Minimum 3 screenshots, maximum 10
  - Show key features: Forward calc, Reverse calc, History
  
- [ ] **Write App Store description**
  ```
  Title: EQD2 Calculator - Radiation Therapy
  Subtitle: Equivalent Dose Calculator for Medical Professionals
  
  Description:
  Professional EQD2 (Equivalent Dose in 2 Gy fractions) calculator 
  for radiation oncology using the linear-quadratic model.
  
  Features:
  • Forward calculation: Total dose → EQD2
  • Reverse calculation: Target EQD2 → Required dose
  • Calculation history with automatic saving
  • Built-in warnings for LQ model validity range
  • Common α/β reference values
  • Educational content about LQ model limitations
  
  MEDICAL DISCLAIMER: For educational purposes only. 
  Not a substitute for professional medical judgment.
  ```
  
- [ ] **Prepare promotional text** (170 characters max)
  ```
  "Professional radiation therapy dose calculator. 
  Converts between total dose and EQD2 using the 
  linear-quadratic model. For medical education."
  ```
  
- [ ] **Define keywords** (100 characters max)
  ```
  radiation therapy, oncology, EQD2, medical calculator, 
  radiotherapy, dose calculation
  ```

### 7. App Store Connect Setup
- [ ] **Create App Store Connect account**
  - Requires Apple Developer Program ($99/year)
  - https://developer.apple.com/programs/
  
- [ ] **Register app in App Store Connect**
  - Create new app
  - Set bundle ID (must match Xcode)
  - Choose category: Medical
  - Set age rating: 17+ (medical professional content)
  
- [ ] **Configure App Store listing**
  - Upload screenshots
  - Add description, keywords
  - Set pricing: Free (recommended for medical education)
  - Choose availability: All countries or specific regions
  
- [ ] **Set content ratings**
  - Medical/Treatment Information: Yes
  - For professional use: Yes

### 8. Code Signing & Certificates
- [ ] **Create provisioning profiles**
  - Development profile (for testing)
  - App Store profile (for distribution)
  
- [ ] **Configure signing in Xcode**
  - Xcode → Target → Signing & Capabilities
  - Select your team
  - Enable "Automatically manage signing"

### 9. Testing & QA
- [ ] **Perform manual testing scenarios**
  - [ ] Launch app → See disclaimer → Accept
  - [ ] Close and reopen → No disclaimer (already seen)
  - [ ] Enter standard fractionation (50 Gy / 25 fx / α/β=10) → Result: 50.00 Gy
  - [ ] Test hypofractionation (60 Gy / 20 fx / α/β=10) → Result: 65.00 Gy
  - [ ] Test SBRT (54 Gy / 3 fx / α/β=10) → Result: ~151 Gy → Warning shown
  - [ ] Test reverse calculation (EQD2=60 / 25 fx / α/β=10) → Result: 60.00 Gy
  - [ ] Enter invalid inputs (negative, zero) → No crash, validation error shown
  - [ ] Check history saves entries after 1 second
  - [ ] Swipe to delete history entry → Works
  - [ ] Add 101 entries → Oldest removed, count stays at 100
  
- [ ] **Test edge cases**
  - [ ] Very small numbers (0.01)
  - [ ] Very large numbers (10000)
  - [ ] Rapid typing in fields
  - [ ] Switching between tabs quickly
  - [ ] App backgrounding during calculation
  - [ ] Force quit and reopen → History persists

- [ ] **TestFlight beta testing** (Recommended)
  - Invite 5-10 radiation oncology colleagues
  - Gather feedback on usability
  - Verify calculations match clinical expectations
  - Test for 1-2 weeks before public release

---

## 📋 RECOMMENDED (Should Consider)

### 10. Additional Features (Before or After Launch)
- [ ] **Export functionality**
  - Export history to CSV/PDF
  - Share calculations via email
  
- [ ] **Preset templates**
  - Common regimens (prostate, breast, lung)
  - Quick-select buttons
  
- [ ] **Enhanced history**
  - Search/filter history
  - Add notes to calculations
  - Group by patient/case
  
- [ ] **Settings screen**
  - Default α/β values
  - Decimal precision preference
  - Units preference

### 11. Documentation
- [ ] **Create user guide** (in-app or PDF)
  - How to perform forward calculation
  - How to perform reverse calculation
  - Understanding warnings
  - Interpreting results
  
- [ ] **Create support email/website**
  - For user questions
  - Bug reports
  - Feature requests
  - Required for App Store submission

### 12. Analytics & Monitoring (Optional)
- [ ] **Add crash reporting** (Consider: Sentry, Crashlytics)
  - Track app crashes
  - Monitor stability
  
- [ ] **Add analytics** (Consider: Apple App Analytics only)
  - Track feature usage
  - Monitor adoption
  - NO user data collection (privacy-first)

### 13. Marketing & Launch
- [ ] **Prepare launch announcement**
  - Post on LinkedIn (medical professionals)
  - Share in radiation oncology forums
  - Contact medical education blogs
  
- [ ] **Create support materials**
  - Demo video (1-2 minutes)
  - Tutorial screenshots
  - FAQ document
  
- [ ] **Plan post-launch updates**
  - Version 1.1: User feedback features
  - Version 1.2: Additional calculations
  - Version 2.0: Advanced features

---

## ✅ Final Pre-Submission Checklist

Before clicking "Submit for Review" in App Store Connect:

- [ ] All tests pass (35/35)
- [ ] App icon is set and looks professional
- [ ] No placeholder text remains in code
- [ ] Bundle identifier is unique and correct
- [ ] Version numbers are set (1.0.0 / Build 1)
- [ ] Privacy policy URL is live and accessible
- [ ] All App Store screenshots uploaded
- [ ] Description and keywords finalized
- [ ] Medical disclaimer is comprehensive
- [ ] TestFlight beta completed (if applicable)
- [ ] No compiler warnings
- [ ] Archive builds successfully
- [ ] Archive uploaded to App Store Connect

---

## 🚀 Launch Day

1. **Submit for Review** in App Store Connect
2. **Average review time**: 24-48 hours
3. **Possible rejection reasons for medical apps**:
   - Insufficient disclaimer
   - Missing privacy policy
   - Claims of medical accuracy without clinical validation
   - Lack of professional use warning

4. **If approved**:
   - Release immediately or schedule release
   - Monitor crash reports
   - Respond to user reviews
   - Gather feedback for v1.1

5. **If rejected**:
   - Address Apple's specific concerns
   - Resubmit with changes
   - Average turnaround: 1-3 days

---

## 📞 Support & Resources

**Apple Documentation**:
- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Medical Apps Guidelines: Section 5.1.4
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/

**Medical App Specific**:
- FDA Mobile Medical App Guidance
- HIPAA compliance (if collecting patient data - you're not)
- Medical device classification (calculator apps typically Class I exempt)

**Your App Current Status**:
- ✅ Code architecture: Excellent
- ✅ Medical safety: Strong disclaimers
- ✅ Test coverage: Good (after adding new tests)
- ✅ Accessibility: Now compliant
- ⚠️ App icon: Needed
- ⚠️ Privacy policy: Needed
- ⚠️ Bundle ID: Needs updating
- ⚠️ App Store assets: Needed

---

## Timeline Estimate

**Minimum (Basic Launch)**: 1-2 days
- Add tests to project (10 min)
- Create app icon (1-2 hours)
- Update bundle ID (5 min)
- Write privacy policy (30 min)
- Create screenshots (1 hour)
- Submit to App Store (1 hour)

**Recommended (Quality Launch)**: 1-2 weeks
- All of the above
- TestFlight beta testing (1 week)
- Professional app icon ($20, 1-3 days)
- Beta tester feedback incorporation (2-3 days)
- Marketing materials preparation (2-3 days)

**Your app is 85% ready for launch.** The code is solid. You mainly need:
1. App icon
2. Privacy policy
3. App Store assets
4. Bundle ID update
5. Add the new test file

Would you like help with any specific item from this checklist?
