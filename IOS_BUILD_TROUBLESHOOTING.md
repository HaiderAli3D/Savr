# iOS Build Troubleshooting Guide

## Issue
Code signing error when building for iOS simulator:
```
Failed to codesign [...]/Flutter.framework/Flutter with identity -.
resource fork, Finder information, or similar detritus not allowed
```

## Root Cause
macOS Tahoe 26.2 with Xcode 17 and iOS SDK 26.2 adds extended attributes (resource forks/Finder metadata) to files during copy operations. These attributes interfere with code signing, even when signing is disabled for simulator builds.

## Changes Made to Project

### 1. Xcode Project Configuration (`ios/Runner.xcodeproj/project.pbxproj`)
- Disabled code signing for all build configurations (Debug, Release, Profile)
- Set `CODE_SIGNING_ALLOWED = NO`
- Set `CODE_SIGNING_REQUIRED = NO`
- Set `CODE_SIGN_IDENTITY = "-"`
- Added pre-build script phase to clean extended attributes

### 2. Podfile (`ios/Podfile`)
- Added post-install hook to disable code signing for all CocoaPods
- Automatically cleans extended attributes from Pods directory after installation

### 3. Build Script (`build.sh`)
- Created wrapper script that cleans Flutter engine cache before building
- Run with: `./build.sh`

## Current Workarounds

### Workaround 1: Manual Cleanup (Most Reliable)
Run these commands before each build:
```bash
# Clean Flutter engine
find /opt/homebrew/share/flutter/bin/cache/artifacts/engine/ios -type f -exec xattr -cr {} \; 2>/dev/null

# Clean project
flutter clean

# Build
flutter run -d <device-id>
```

### Workaround 2: System-Wide Extended Attributes Cleanup
```bash
# Clean entire Flutter installation (requires sudo)
sudo xattr -cr /opt/homebrew/share/flutter

# Then build normally
flutter run -d <device-id>
```

### Workaround 3: Use Older iOS Simulator
The issue may be less prevalent with older iOS versions. Try:
1. Open Xcode
2. Go to Window > Devices and Simulators
3. Create an iOS 17 or iOS 18 simulator
4. Use that simulator for development

### Workaround 4: Build via Xcode Directly
Sometimes building through Xcode IDE works better:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your simulator
3. Press Run (Cmd+R)

## Permanent Solutions to Try

### Solution 1: Build via Xcode with Custom Script
Since CLI builds fail, try building directly in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode (already open)
2. Select your simulator from the device dropdown
3. Go to Product > Clean Build Folder (Cmd+Shift+K)
4. Try Product > Run (Cmd+R)

### Solution 2: Downgrade Xcode (if possible)
If you have access to Xcode 16.x or earlier, that version may not have this issue.

### Solution 3: Use Physical Device Instead of Simulator
The issue seems more prevalent with simulator builds. Try:
```bash
# List devices
flutter devices

# Build for physical device (if available)
flutter run -d <physical-device-id>
```

### Solution 4: Update Flutter
Check for Flutter updates that may include fixes:
```bash
flutter upgrade
flutter doctor
```

### Solution 5: Wait for Official Fix
This is a known issue that will likely be addressed in future versions of:
- Flutter SDK (currently 3.38.9)
- Xcode 17.x
- macOS Tahoe 26.2

This is a **known bug** with the combination of:
- macOS Tahoe 26.2
- Xcode 17 (17C52)
- iOS SDK 26.2
- Flutter 3.38.9

The file system operations in this macOS version add extended attributes during copy operations, which the code signing tool rejects.

## Additional Notes
- The warnings about `subscriberCellularProvider` being deprecated are harmless
- The `IPHONEOS_DEPLOYMENT_TARGET` warning can be ignored for now
- All script phases showing "will be run during every build" is expected behavior

## Testing Checklist
- [ ] Extended attributes cleaned from Flutter engine
- [ ] Project cleaned with `flutter clean`
- [ ] Pods cleaned and reinstalled
- [ ] Build artifacts removed
- [ ] Correct simulator selected
- [ ] Xcode closed and reopened (if building via Xcode)

## Quick Reference Commands
```bash
# Clean everything and rebuild
./build.sh

# Check for extended attributes on a file
xattr -l <filepath>

# Remove extended attributes from a file
xattr -cr <filepath>

# List available simulators
flutter devices

# Check Flutter installation
flutter doctor -v
```

## Support
If none of these workarounds help, the issue may require:
1. A Flutter SDK update
2. An Xcode/macOS update
3. Filing a bug report with the Flutter team

Created: February 8, 2026
