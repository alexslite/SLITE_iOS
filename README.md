# Slite iOS App

A modern iOS application for controlling Slite LED light panels, designed for content creators on the go.

## Features

- **Bluetooth LE Control**: Connect to and control multiple Slite LED panels
- **Color Management**: Advanced color wheel and hex color input
- **Scene Creation**: Save and manage custom lighting scenes
- **Firmware Updates**: Over-the-air firmware updates for your devices
- **Modern UI**: Built with SwiftUI and UIKit for optimal performance

## Requirements

- **iOS**: 17.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **macOS**: 14.0 (Sonoma) or later for development

## Installation

### Prerequisites

1. Install Xcode 15.0+ from the Mac App Store
2. Ensure you have a valid Apple Developer account
3. Clone this repository

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/slite-ios.git
   cd slite-ios
   ```

2. **Open the project**
   ```bash
   open Slite.xcodeproj
   ```

3. **Configure signing**
   - Select your team in the project settings
   - Update the bundle identifier if needed
   - Ensure your provisioning profile includes the necessary capabilities

4. **Install dependencies**
   - The project uses Swift Package Manager for dependencies
   - Dependencies will be automatically resolved when you build

5. **Build and run**
   - Select your target device (iOS 17.0+)
   - Press Cmd+R to build and run

## Dependencies

- **Firebase**: Analytics, crash reporting, and remote configuration
- **Sentry**: Error tracking and performance monitoring
- **Mixpanel**: User analytics and event tracking
- **SwiftUIX**: Extended SwiftUI components

## Architecture

The app follows a modern iOS architecture pattern:

- **MVVM**: Model-View-ViewModel pattern for UI logic
- **Combine**: Reactive programming for data flow
- **Core Bluetooth**: Bluetooth LE device management
- **SwiftUI + UIKit**: Hybrid approach for optimal performance

## Key Components

- **BLEService**: Manages Bluetooth connections and device communication
- **SceneDelegate**: Handles app lifecycle and scene management
- **RootCoordinator**: Manages navigation and app flow
- **SwiftUI Views**: Modern, responsive user interface

## Privacy & Permissions

The app requires the following permissions:

- **Bluetooth**: To connect to and control Slite devices
- **Camera**: To detect colors from your surroundings
- **Photo Library**: To save and load custom color palettes
- **Location**: To optimize Bluetooth connections (optional)

## Security Features

- Secure Bluetooth connections with encryption
- Privacy-focused analytics
- Secure API key management
- Modern iOS security best practices

## Building for Distribution

1. **Archive the app**
   - Select "Any iOS Device" as the target
   - Go to Product > Archive

2. **Upload to App Store Connect**
   - Use the Organizer to upload your archive
   - Ensure all privacy descriptions are properly configured

## Troubleshooting

### Common Issues

1. **Bluetooth not working**
   - Ensure Bluetooth is enabled on your device
   - Check that the app has Bluetooth permissions
   - Verify your device supports Bluetooth LE

2. **Build errors**
   - Clean the build folder (Product > Clean Build Folder)
   - Update Xcode to the latest version
   - Ensure all dependencies are properly resolved

3. **Signing issues**
   - Verify your Apple Developer account is active
   - Check that your provisioning profile includes the necessary capabilities
   - Ensure your bundle identifier matches your provisioning profile

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is proprietary software. All rights reserved.

## Support

For support, visit [www.slite.co](https://www.slite.co) or contact our support team.

---

**Note**: This app requires iOS 17.0 or later and is optimized for modern iOS devices with advanced Bluetooth capabilities.
