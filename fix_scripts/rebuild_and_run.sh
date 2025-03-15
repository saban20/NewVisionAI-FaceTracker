#!/bin/bash

# Script to rebuild and run the FaceTracker app with all the fixes applied

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Running from directory: $SCRIPT_DIR"

# 1. Apply Metal resources fixes
echo "Applying Metal resources fixes..."
"$SCRIPT_DIR/fix_metal_resources.sh"

# 2. Apply video texture allocator fix
echo "Applying video texture allocator fix..."
"$SCRIPT_DIR/fix_video_texture_allocator.sh"

# 3. Apply AR tracking fix
echo "Applying AR tracking fix..."
"$SCRIPT_DIR/fix_ar_tracking.sh"

# 4. Clean the build
echo "Cleaning previous build..."
xcodebuild clean -project "$SCRIPT_DIR/FaceTracker.xcodeproj" -scheme FaceTracker

# 5. Copy resources again to ensure they're up to date
echo "Copying resources again..."
"$SCRIPT_DIR/copy_resources.sh"

# 6. Build the app
echo "Building the app..."
xcodebuild build -project "$SCRIPT_DIR/FaceTracker.xcodeproj" -scheme FaceTracker -destination "platform=iOS Simulator,name=iPhone 14 Pro"

# 7. Run the app in the simulator
echo "Running the app in the simulator..."
xcrun simctl launch booted com.saban.facetracker

echo "App has been rebuilt and launched. Check the simulator to see if the issues are resolved."
echo "If you're still seeing issues, check the Xcode console for detailed logs."