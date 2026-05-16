# ✦ Vyshu Content Studio

AI-powered content creator app for YouTube & Instagram — built with Flutter.

## 📱 Features
- **3 Channels**: Insta Life Journey, YouTube AI Journey, Vyshu AI Influencer
- **AI Generation**: Script + Image Prompts + Caption per video
- **7-Day Storage**: Auto memory cleanup after 7 days
- **100% Free**: Uses free AI tools & APIs

## 🚀 Setup

### 1. Install Flutter
```bash
# macOS
brew install flutter

# Or download from https://flutter.dev/docs/get-started/install
```

### 2. Clone the repo
```bash
git clone https://github.com/YOUR_USERNAME/vyshu_content_studio.git
cd vyshu_content_studio
```

### 3. Add your Claude API key
Open `lib/services/claude_service.dart` and replace:
```dart
static const String _apiKey = 'YOUR_CLAUDE_API_KEY_HERE';
```
with your key from https://console.anthropic.com

### 4. Install dependencies
```bash
flutter pub get
```

### 5. Run on Android device / emulator
```bash
flutter run
```

### 6. Build APK
```bash
flutter build apk --release
# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

## 🛠 Free Tools Workflow

| Step | Tool | Cost |
|------|------|------|
| Script + Prompts | Claude API ($25 free credits) | Free |
| Image generation | Pollinations.AI / Hugging Face | Free |
| Short video clips | PixVerse / Kling AI / Hailuo | Free |
| Video editing | CapCut | Free |

## 📁 Project Structure
```
lib/
├── main.dart
├── models/
│   ├── content_item.dart     # Data model
│   └── channel_data.dart     # Channel config
├── services/
│   ├── claude_service.dart   # AI API calls
│   └── storage_service.dart  # 7-day local storage
└── screens/
    ├── home_screen.dart      # Channel selector
    ├── generate_screen.dart  # Content generation
    └── history_screen.dart   # 7-day history viewer
```

## 💾 7-Day Storage
- All generated content auto-saved locally
- Items older than 7 days are **automatically deleted** on app launch
- Manual delete per item or bulk clear available
- Daily stats shown in history tab

---
Built for Vyshu · 3 videos/day · 0 rupees/day 🚀
