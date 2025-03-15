#!/bin/bash

# Comprehensive script to check for AR-related issues in the app logs
# This script checks for material errors, video texture allocator issues, and AR tracking status

echo "Checking app logs for AR-related issues..."

# Get the app's process ID
APP_PID=$(pgrep -f "FaceTracker")

if [ -z "$APP_PID" ]; then
    echo "FaceTracker app is not running. Please start the app first."
    exit 1
fi

echo "FaceTracker app is running with PID: $APP_PID"

# Check for material errors in the system log
echo "Checking for material errors in the system log..."
MATERIAL_ERRORS=$(log show --predicate 'process == "FaceTracker"' --last 5m | grep -i "Could not resolve material")

if [ -z "$MATERIAL_ERRORS" ]; then
    echo "✅ No material errors found in the logs. The material fixes appear to be working!"
else
    echo "❌ Material errors found in the logs:"
    echo "$MATERIAL_ERRORS"
    echo "The material fixes may not be working completely."
fi

# Check for video texture allocator issues
echo "Checking for video texture allocator issues..."
TEXTURE_ERRORS=$(log show --predicate 'process == "FaceTracker"' --last 5m | grep -i "Video texture allocator is not initialized")

if [ -z "$TEXTURE_ERRORS" ]; then
    echo "✅ No video texture allocator issues found. The texture allocator fixes appear to be working!"
else
    echo "❌ Video texture allocator issues found:"
    echo "$TEXTURE_ERRORS"
    echo "The video texture allocator fixes may not be working completely."
fi

# Check for VideoLightSpill issues
echo "Checking for VideoLightSpill issues..."
LIGHT_SPILL_ERRORS=$(log show --predicate 'process == "FaceTracker"' --last 5m | grep -i "VideoLightSpillGenerator")

if [ -z "$LIGHT_SPILL_ERRORS" ]; then
    echo "✅ No VideoLightSpill issues found. The VideoLightSpill fixes appear to be working!"
else
    echo "❌ VideoLightSpill issues found:"
    echo "$LIGHT_SPILL_ERRORS"
    echo "The VideoLightSpill fixes may not be working completely."
fi

# Check for successful AR tracking
echo "Checking for successful AR tracking..."
AR_TRACKING=$(log show --predicate 'process == "FaceTracker"' --last 5m | grep -i "ARSession")

if [ -n "$AR_TRACKING" ]; then
    echo "✅ AR session logs found:"
    echo "$AR_TRACKING"
    echo "AR tracking appears to be initialized."
    
    # Check for face tracking specifically
    FACE_TRACKING=$(log show --predicate 'process == "FaceTracker"' --last 5m | grep -i "face tracking")
    
    if [ -n "$FACE_TRACKING" ]; then
        echo "✅ Face tracking logs found:"
        echo "$FACE_TRACKING"
        echo "Face tracking appears to be working."
    else
        echo "⚠️ No face tracking logs found. Face tracking may not be working properly."
    fi
else
    echo "❌ No AR session logs found. AR tracking may not be initialized properly."
fi

# Check for CoreRE framework issues
echo "Checking for CoreRE framework issues..."
CORE_RE_ISSUES=$(log show --predicate 'process == "FaceTracker"' --last 5m | grep -i "CoreRE.framework")

if [ -z "$CORE_RE_ISSUES" ]; then
    echo "✅ No CoreRE framework issues found."
else
    echo "⚠️ CoreRE framework messages found:"
    echo "$CORE_RE_ISSUES"
    echo "These may be informational and not necessarily errors."
fi

echo "Log check complete."
echo "If you're still experiencing issues, try rebuilding the app with the fix_video_texture_allocator.sh script."