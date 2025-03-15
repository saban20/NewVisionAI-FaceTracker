# NewVision AI FaceTracker

This repository contains fixes for common AR face tracking issues in iOS applications, specifically addressing material errors, video texture allocator initialization problems, and AR tracking setup.

## Issues Addressed

1. **Material File Errors**
   - Missing material files (`arKitPassthrough.rematerial`, `arSegmentationComposite.rematerial`, etc.)
   - "Could not resolve material name" errors

2. **Video Texture Allocator Issues**
   - "Video texture allocator is not initialized" error
   - VideoLightSpill generator failures

3. **AR Tracking Configuration**
   - ARKit initialization and configuration
   - Face tracking setup

## Fix Scripts

This repository includes several scripts to automate the fixing process:

- `fix_metal_resources.sh`: Creates and sets up all necessary material files
- `fix_video_texture_allocator.sh`: Fixes video texture allocator initialization issues
- `fix_ar_tracking.sh`: Sets up proper ARKit configuration
- `check_ar_issues.sh`: Checks app logs for AR-related issues
- `rebuild_and_run.sh`: Rebuilds and runs the app with all fixes applied

## Documentation

- `AR_TRACKING_GUIDE.md`: Comprehensive guide for properly initializing AR tracking in your app

## Usage

1. Clone this repository
2. Run the appropriate fix scripts for your issues
3. Follow the AR tracking guide to implement proper ARKit initialization
4. Rebuild and run your app

## Requirements

- macOS 11.0 or higher
- Xcode 13.0 or higher
- iOS 15.0+ device with TrueDepth camera (for full functionality)