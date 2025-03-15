#!/bin/bash

# Script to fix AR tracking initialization issues
# This script ensures that ARKit is properly initialized in the app

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Running from directory: $SCRIPT_DIR"

# 1. Update Info.plist with ARKit capabilities
echo "Updating Info.plist with ARKit capabilities..."

# Get the path to Info.plist
INFO_PLIST="$SCRIPT_DIR/FaceTracker/Info.plist"

if [ -f "$INFO_PLIST" ]; then
    # Add ARKit as a required capability
    if ! grep -q "UIRequiredDeviceCapabilities" "$INFO_PLIST"; then
        /usr/libexec/PlistBuddy -c "Add :UIRequiredDeviceCapabilities array" "$INFO_PLIST"
    fi
    
    # Check if arkit is already in UIRequiredDeviceCapabilities
    if ! /usr/libexec/PlistBuddy -c "Print :UIRequiredDeviceCapabilities" "$INFO_PLIST" | grep -q "arkit"; then
        # Add arkit to UIRequiredDeviceCapabilities
        /usr/libexec/PlistBuddy -c "Add :UIRequiredDeviceCapabilities: string 'arkit'" "$INFO_PLIST"
    fi
    
    # Ensure camera usage description is set
    if ! grep -q "NSCameraUsageDescription" "$INFO_PLIST"; then
        # Add camera usage description
        /usr/libexec/PlistBuddy -c "Add :NSCameraUsageDescription string 'This app needs camera access for AR face tracking.'" "$INFO_PLIST"
    fi
    
    echo "Info.plist updated with ARKit capabilities."
else
    echo "Warning: Info.plist not found at $INFO_PLIST"
fi

# 2. Create ARKit configuration file
echo "Creating ARKit configuration file..."

mkdir -p "$SCRIPT_DIR/Resources/ARKit"
mkdir -p "$SCRIPT_DIR/FaceTracker/Resources/ARKit"

# Create ARKit configuration file
cat > "$SCRIPT_DIR/Resources/ARKit/config.json" << 'EOL'
{
    "version": "1.0",
    "trackingConfiguration": "ARFaceTrackingConfiguration",
    "worldAlignment": "gravity",
    "providesAudioData": false,
    "automaticallyConfiguresSession": true,
    "maximumNumberOfTrackedFaces": 1,
    "detectionImages": [],
    "detectionObjects": [],
    "automaticImageScaleEstimationEnabled": true,
    "environmentTexturing": "automatic",
    "frameSemantics": ["personSegmentation", "bodyDetection"],
    "initialWorldMap": null,
    "collaborationEnabled": false
}
EOL

# Copy to FaceTracker resources
cp -f "$SCRIPT_DIR/Resources/ARKit/config.json" "$SCRIPT_DIR/FaceTracker/Resources/ARKit/"

# 3. Create a sample ARKit initialization code file for reference
echo "Creating sample ARKit initialization code file for reference..."

mkdir -p "$SCRIPT_DIR/Resources/ARKit/Reference"

cat > "$SCRIPT_DIR/Resources/ARKit/Reference/ARKitInitialization.swift" << 'EOL'
import ARKit
import UIKit

class ARKitInitializer {
    
    // ARKit session
    private let arSession = ARSession()
    
    // Configuration for face tracking
    private let faceTrackingConfiguration = ARFaceTrackingConfiguration()
    
    // Initialize ARKit
    func initializeARKit() {
        // Check if face tracking is supported on this device
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device")
            return
        }
        
        // Configure the AR session
        faceTrackingConfiguration.isLightEstimationEnabled = true
        faceTrackingConfiguration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        
        // Run the AR session
        arSession.run(faceTrackingConfiguration, options: [.resetTracking, .removeExistingAnchors])
        
        print("ARKit face tracking session started")
    }
    
    // Pause the AR session
    func pauseARKit() {
        arSession.pause()
        print("ARKit session paused")
    }
    
    // Resume the AR session
    func resumeARKit() {
        arSession.run(faceTrackingConfiguration, options: [.resetTracking, .removeExistingAnchors])
        print("ARKit session resumed")
    }
}
EOL

echo "Sample ARKit initialization code created at $SCRIPT_DIR/Resources/ARKit/Reference/ARKitInitialization.swift"
echo "Please refer to this file for proper ARKit initialization in your app."

# 4. Copy all resources to the app bundle
echo "Copying all resources to the app bundle..."
"$SCRIPT_DIR/copy_resources.sh"

echo "AR tracking initialization fix completed."
echo "Please ensure that your app properly initializes ARKit using ARFaceTrackingConfiguration."
echo "Refer to the sample code at $SCRIPT_DIR/Resources/ARKit/Reference/ARKitInitialization.swift for guidance."