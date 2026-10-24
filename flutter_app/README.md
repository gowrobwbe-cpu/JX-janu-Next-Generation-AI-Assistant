# JX AI Companion — Primary Android Mobile App

An anime-inspired Android AI companion application created by **Gowrob** for real-time conversation in Bengali & English, featuring local SQLite memory, 3D VRM anime avatar presentation, voice synthesis/recognition, full native Android OS & app control tools, JX Accessibility Service automation, and the 22-test Device Test Center.

---

## 📱 Compiling into an Android APK

### 1. Build Debug APK (For direct installation on physical test phones)
```bash
cd flutter_app
flutter pub get
flutter build apk --debug
```
**Debug APK Output Path:**
`flutter_app/build/app/outputs/flutter-apk/app-debug.apk`

---

### 2. Build Release APK (Optimized production build)
```bash
cd flutter_app
flutter pub get
flutter build apk --release
```
**Release APK Output Path:**
`flutter_app/build/app/outputs/flutter-apk/app-release.apk`

---

### 3. Direct Installation on Physical Android Phone via ADB
```bash
# Verify phone is connected via USB with USB Debugging enabled:
adb devices

# Install APK onto phone:
adb install -r flutter_app/build/app/outputs/flutter-apk/app-debug.apk
```

---

## 🚀 Key Android Features & Architecture
- **Gemini Agentic AI**: Multi-turn conversation with structured function calling in Bengali & English.
- **22-Test Device Test Center**: Automated & individual verification suite for all Android hardware, permissions, and tool mechanisms.
- **Native Android Tools Engine**: App launcher (YouTube, WhatsApp, Browser), phone dialer, contact search, volume control.
- **JX Accessibility Service**: System navigation (Back, Home, Recents), UI hierarchy inspection, and touch automation.
- **Voice System**: Speech-To-Text (STT) and Text-To-Speech (TTS) with cute pitch modulation.
- **Security & Keystore**: Biometrics (Fingerprint/PIN) and encrypted Android Keystore for the Gemini API key.
- **Local SQLite Memory**: Persistent multi-session memory, chat logs, and preferences.
- **3D VRM Anime Avatar**: Reactive facial expressions, lip-sync, blinking, and emotion states.
