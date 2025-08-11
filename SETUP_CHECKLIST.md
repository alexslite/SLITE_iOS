# Slite iOS App - Setup Checklist

## 🚀 Pre-Setup Requirements
- [ ] macOS 14.0 (Sonoma) or later
- [ ] Xcode 15.0 or later
- [ ] Apple Developer Account
- [ ] iOS 17.0+ device for testing

## ⚙️ Configuration Setup

### 1. Update ExportOptions.plist
- [ ] Open `ExportOptions.plist`
- [ ] Replace `YOUR_TEAM_ID` with your actual Apple Developer Team ID
- [ ] Verify signing method is appropriate for your distribution needs

### 2. Populate Configuration.swift
- [ ] Add your actual Firebase configuration
- [ ] Add your Sentry DSN
- [ ] Add your Mixpanel token
- [ ] Update API endpoints for your environment
- [ ] Verify Bluetooth configuration settings

### 3. App Signing & Capabilities
- [ ] Open `Slite.xcodeproj` in Xcode
- [ ] Select your team in project settings
- [ ] Verify bundle identifier matches your provisioning profile
- [ ] Ensure all entitlements are properly configured
- [ ] Check that background modes are enabled for Bluetooth

## 🔧 Build & Test

### 1. Initial Build
- [ ] Clean build folder: `./build.sh clean`
- [ ] Build project: `./build.sh build`
- [ ] Resolve any build errors
- [ ] Verify all dependencies are resolved

### 2. Device Testing
- [ ] Connect iOS 17.0+ device
- [ ] Build and run on device
- [ ] Test Bluetooth connectivity with Slite LED panels
- [ ] Verify all privacy permissions work correctly
- [ ] Test app lifecycle (background/foreground)

### 3. Analytics Verification
- [ ] Confirm Sentry is capturing events
- [ ] Verify Mixpanel analytics are working
- [ ] Check Firebase integration
- [ ] Test crash reporting (if applicable)

## 📱 Distribution Preparation

### 1. Archive Build
- [ ] Run: `./build.sh archive`
- [ ] Verify archive is created successfully
- [ ] Check archive contents in Xcode Organizer

### 2. Export IPA
- [ ] Run: `./build.sh export`
- [ ] Verify IPA is created
- [ ] Test IPA installation on device

### 3. App Store Connect
- [ ] Upload archive to App Store Connect
- [ ] Verify all metadata is correct
- [ ] Ensure privacy descriptions are complete
- [ ] Submit for review

## 🧪 Testing Checklist

### Core Functionality
- [ ] Bluetooth device discovery
- [ ] LED panel connection
- [ ] Color control and effects
- [ ] Scene creation and management
- [ ] Firmware updates (if applicable)

### iOS 17+ Features
- [ ] Background Bluetooth modes
- [ ] Enhanced privacy permissions
- [ ] Modern app lifecycle
- [ ] Performance improvements

### Security & Privacy
- [ ] All permission dialogs appear
- [ ] Privacy descriptions are clear
- [ ] Bluetooth security features
- [ ] Data encryption (if applicable)

## 🚨 Common Issues & Solutions

### Build Errors
- **Swift version mismatch**: Ensure Xcode 15.0+ is installed
- **Deployment target**: Verify iOS 17.0+ is set
- **Dependencies**: Clean and rebuild if SPM issues occur

### Bluetooth Issues
- **Permission denied**: Check Info.plist privacy descriptions
- **Connection fails**: Verify device compatibility
- **Background mode**: Ensure entitlements are correct

### Signing Issues
- **Provisioning profile**: Verify team ID and bundle identifier
- **Capabilities**: Check that all required capabilities are enabled
- **Certificates**: Ensure certificates are valid and not expired

## 📋 Final Verification

### Before Distribution
- [ ] App builds without warnings
- [ ] All tests pass
- [ ] Privacy policy is updated
- [ ] App Store metadata is complete
- [ ] Screenshots are current
- [ ] Version and build numbers are correct

### Post-Launch
- [ ] Monitor crash reports in Sentry
- [ ] Track user analytics in Mixpanel
- [ ] Monitor Firebase performance
- [ ] Gather user feedback
- [ ] Plan future iOS updates

## 🎯 Success Criteria

Your Slite iOS app is ready when:
- ✅ Builds successfully on Xcode 15.0+
- ✅ Runs on iOS 17.0+ devices
- ✅ Connects to Slite LED panels via Bluetooth
- ✅ All privacy permissions work correctly
- ✅ Analytics and crash reporting are functional
- ✅ App can be archived and exported
- ✅ Ready for App Store submission

---

**Need Help?**
- Check the `README.md` for detailed setup instructions
- Use `./build.sh help` for build script options
- Review `UPGRADE_SUMMARY.md` for complete update details
- Contact your development team for technical support