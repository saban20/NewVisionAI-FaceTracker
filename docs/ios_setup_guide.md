# iOS App Setup Guide

This guide provides instructions for setting up the NewVision AI iOS application.

## Prerequisites

- macOS 11.0 or higher
- Xcode 13.0 or higher
- iOS 15.0+ device with TrueDepth camera (for full functionality)
- Apple Developer account (for device deployment)
- CocoaPods (for dependency management)

## Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/saban20/NewVisionAI-FaceTracker.git
cd NewVisionAI-FaceTracker
```

### 2. Install Dependencies

First, ensure you have CocoaPods installed:

```bash
sudo gem install cocoapods
```

Then install the project dependencies:

```bash
cd iOS/FaceTracker
pod install
```

### 3. Open the Xcode Workspace

```bash
open FaceTracker.xcworkspace
```

> ⚠️ Important: Always open the `.xcworkspace` file, not the `.xcodeproj` file.

### 4. Configure API Endpoint

1. Open `FaceTracker/Config/APIConfig.swift`
2. Update the `baseURL` to point to your backend API:

```swift
struct APIConfig {
    static let baseURL = "http://localhost:5000/api/v1"
    static let timeout: TimeInterval = 30.0
}
```

### 5. Run the App

1. Select a simulator or connected device from the device dropdown in Xcode
2. Click the Run button (▶️) or press `Cmd+R`

> Note: For full functionality, use a physical device with TrueDepth camera (iPhone X or newer).

## Device Deployment

### 1. Configure Signing

1. In Xcode, select the FaceTracker project in the Project Navigator
2. Select the FaceTracker target
3. Go to the "Signing & Capabilities" tab
4. Select your Team and ensure "Automatically manage signing" is checked

### 2. Configure Bundle Identifier

Update the bundle identifier to a unique value:

1. In the "Signing & Capabilities" tab, change the Bundle Identifier (e.g., `com.yourcompany.newvision`)

### 3. Build and Run on Device

1. Connect your iOS device via USB
2. Select your device from the device dropdown
3. Click the Run button (▶️)

## App Capabilities

The app requires the following capabilities, which should be configured in Xcode:

1. **Camera Usage**: Required for face tracking
   - Ensure `NSCameraUsageDescription` is set in Info.plist

2. **Face ID Usage**: Required for TrueDepth camera access
   - Ensure `NSFaceIDUsageDescription` is set in Info.plist

## Project Structure

- `FaceTracker/`: Main app directory
  - `AppDelegate.swift` & `SceneDelegate.swift`: App lifecycle management
  - `ViewControllers/`: UI controllers
    - `FaceTrackingViewController.swift`: Main AR face tracking implementation
    - `MeasurementResultViewController.swift`: Displays measurement results
  - `Models/`: Data models
  - `Services/`: API and data services
  - `Utils/`: Utility functions and extensions
  - `Views/`: Custom UI components
  - `Resources/`: Assets and storyboards

## Customization

### API Configuration

To change the API endpoint:

1. Open `FaceTracker/Config/APIConfig.swift`
2. Update the `baseURL` constant

### Measurement Parameters

To adjust measurement parameters:

1. Open `FaceTracker/Utils/MeasurementCalculator.swift`
2. Modify the calculation constants and algorithms

### UI Customization

1. Open `FaceTracker/Resources/Main.storyboard` to edit the UI layout
2. Modify colors and styles in `FaceTracker/Utils/UITheme.swift`

## Testing

### Running Tests

1. In Xcode, press `Cmd+U` to run all tests
2. Or navigate to the test navigator and run specific tests

### UI Testing

UI tests are located in the `FaceTrackerUITests` target.

## Troubleshooting

### Common Issues

#### Build Errors

If you encounter build errors:

1. Clean the build folder (Shift+Cmd+K)
2. Clean the build cache (Option+Shift+Cmd+K)
3. Restart Xcode

#### Camera Access Issues

If the app can't access the camera:

1. Check that camera permissions are properly set in Info.plist
2. Verify the user has granted camera permissions
3. On simulators, use the simulated camera data

#### API Connection Issues

If the app can't connect to the API:

1. Verify the backend is running
2. Check the API URL in `APIConfig.swift`
3. Ensure network permissions are properly configured

#### TrueDepth Camera Issues

If face tracking isn't working:

1. Ensure you're using a device with TrueDepth camera
2. Check lighting conditions (good lighting is essential)
3. Make sure the camera view is not obstructed

## Distribution

### TestFlight

To distribute the app via TestFlight:

1. Configure App Store Connect
2. Archive the app (Product > Archive)
3. Upload to App Store Connect
4. Invite testers via TestFlight

### App Store

For App Store submission:

1. Prepare marketing materials
2. Complete App Store information
3. Submit for review through App Store Connect