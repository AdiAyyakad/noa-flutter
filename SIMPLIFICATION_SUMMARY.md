# Noa Flutter App Simplification

## Changes Made

### 1. Removed Android Platform Support
- Deleted entire `android/` directory to focus on iOS only
- Updated `pubspec.yaml` to remove Android launcher icons

### 2. Removed Authentication System
- Deleted `lib/pages/login.dart` 
- Deleted `lib/pages/account.dart`
- Deleted `lib/util/sign_in.dart`
- Removed Google Sign In and Apple Sign In dependencies
- Removed user authentication flows from state machine

### 3. Simplified App Flow
- App now starts directly with device scanning (no login required)
- Splash screen transitions directly to device pairing page
- Removed complex user settings and API authentication

### 4. Removed Unnecessary Dependencies
- Removed: `http`, `google_sign_in`, `flutter_dotenv`, `geolocator`, `geocoding`, `sign_in_with_apple`, `url_launcher`, `webview_flutter`, `saver_gallery`, `flutter_foreground_task`
- Kept essential: `flutter_blue_plus`, `flutter_riverpod`, `logging`, `image`, `archive`, `shared_preferences`, `just_audio`, `path_provider`, `audio_session`

### 5. Simplified UI Components
- Removed bottom navigation bar
- Removed tune, hack, regulatory pages
- Simplified pairing page to focus on device connection
- Added text input to chat page for sending messages

### 6. Core Bluetooth Functionality Preserved
- Complete bluetooth scanning and connection logic maintained
- Firmware update capabilities preserved
- Device communication protocols intact
- Lua script uploading functionality kept

### 7. Enhanced Chat Features
- Added text input for sending messages to glasses
- Implemented special commands:
  - "camera" - triggers picture taking on glasses
  - "microphone" - triggers 1-minute audio recording
- Messages are displayed on glasses screen via bluetooth

### 8. Simplified API Layer
- Removed external API calls and server communication
- Kept local messaging functionality
- Removed user account management
- Simplified NoaUser class for basic local data

## Current App Flow

1. **Splash Screen** (1.5 seconds) → **Device List**
2. **Device List** - Automatically scans for nearby glasses
3. **Connection** - User selects device and pairs
4. **Chat Interface** - Send messages, use camera/microphone commands

## Special Commands

- Type "camera" → Takes a picture with glasses
- Type "microphone" → Records audio for 1 minute
- Any other text → Displays message on glasses screen

## Files Removed

### Pages
- `lib/pages/login.dart`
- `lib/pages/account.dart`
- `lib/pages/tune.dart`
- `lib/pages/hack.dart`
- `lib/pages/regulatory.dart`

### Utilities
- `lib/util/sign_in.dart`
- `lib/util/location.dart`
- `lib/util/foreground_service.dart`
- `lib/util/show_toast.dart`
- `lib/util/alert_dialog.dart`
- `lib/util/bytes_to_wav.dart`

### Widgets
- `lib/widgets/bottom_nav_bar.dart`

### Platform
- `android/` (entire directory)
- `.env.template`

## Files Modified

- `lib/main.dart` - Removed login dependencies, simplified app initialization
- `lib/models/app_logic_model.dart` - Removed login states, simplified state machine
- `lib/noa_api.dart` - Removed external API calls, kept local messaging
- `lib/pages/splash.dart` - Skip login, go directly to device pairing
- `lib/pages/pairing.dart` - Simplified device connection UI
- `lib/pages/noa.dart` - Added text input for chat functionality
- `lib/widgets/top_title_bar.dart` - Simplified without account access
- `pubspec.yaml` - Removed unnecessary dependencies, iOS-only configuration

The app is now a basic bluetooth chat interface for smart glasses with camera and microphone commands.