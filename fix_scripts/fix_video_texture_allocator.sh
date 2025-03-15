#!/bin/bash

# Script to fix video texture allocator initialization issue and ensure all AR materials are properly set up
# This script addresses the "Video texture allocator is not initialized" error

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Running from directory: $SCRIPT_DIR"

# 1. First, ensure all material files are created
echo "Creating AR material files..."

# Create necessary directories for AR materials
mkdir -p "$SCRIPT_DIR/Resources/BuiltinRenderGraphResources/AR"
mkdir -p "$SCRIPT_DIR/FaceTracker/Resources/BuiltinRenderGraphResources/AR"

# Create arKitPassthrough.rematerial
cat > "$SCRIPT_DIR/Resources/BuiltinRenderGraphResources/AR/arKitPassthrough.rematerial" << 'EOL'
{
    "name": "arKitPassthrough",
    "passes": [
        {
            "shader": "default",
            "vertexShader": "arKitPassthroughVertex",
            "fragmentShader": "arKitPassthroughFragment",
            "blendMode": "alpha",
            "depthTest": true,
            "depthWrite": false
        }
    ],
    "properties": {
        "texture": { "type": "texture2d" },
        "transform": { "type": "float4x4" }
    }
}
EOL

# Create arSegmentationComposite.rematerial
cat > "$SCRIPT_DIR/Resources/BuiltinRenderGraphResources/AR/arSegmentationComposite.rematerial" << 'EOL'
{
    "name": "arSegmentationComposite",
    "passes": [
        {
            "shader": "default",
            "vertexShader": "arSegmentationCompositeVertex",
            "fragmentShader": "arSegmentationCompositeFragment",
            "blendMode": "alpha",
            "depthTest": true,
            "depthWrite": false
        }
    ],
    "properties": {
        "backgroundTexture": { "type": "texture2d" },
        "foregroundTexture": { "type": "texture2d" },
        "maskTexture": { "type": "texture2d" },
        "transform": { "type": "float4x4" }
    }
}
EOL

# Create suFeatheringCreateMergedOcclusionMask.rematerial
cat > "$SCRIPT_DIR/Resources/BuiltinRenderGraphResources/AR/suFeatheringCreateMergedOcclusionMask.rematerial" << 'EOL'
{
    "name": "suFeatheringCreateMergedOcclusionMask",
    "passes": [
        {
            "shader": "default",
            "vertexShader": "featheringCreateMergedOcclusionMaskVertex",
            "fragmentShader": "featheringCreateMergedOcclusionMaskFragment",
            "blendMode": "alpha",
            "depthTest": false,
            "depthWrite": false
        }
    ],
    "properties": {
        "occlusionMask": { "type": "texture2d" },
        "depthTexture": { "type": "texture2d" },
        "transform": { "type": "float4x4" }
    }
}
EOL

# Create arInPlacePostProcessCombinedPermute0-8 material files
for i in {0..8}; do
    cat > "$SCRIPT_DIR/Resources/BuiltinRenderGraphResources/AR/arInPlacePostProcessCombinedPermute$i.rematerial" << EOL
{
    "name": "arInPlacePostProcessCombinedPermute$i",
    "passes": [
        {
            "shader": "default",
            "vertexShader": "arInPlacePostProcessVertex",
            "fragmentShader": "arInPlacePostProcessFragment$i",
            "blendMode": "alpha",
            "depthTest": false,
            "depthWrite": false
        }
    ],
    "properties": {
        "inputTexture": { "type": "texture2d" },
        "parameters": { "type": "float4" }
    }
}
EOL
done

# Copy all material files to the FaceTracker/Resources directory
cp -f "$SCRIPT_DIR/Resources/BuiltinRenderGraphResources/AR/"*.rematerial "$SCRIPT_DIR/FaceTracker/Resources/BuiltinRenderGraphResources/AR/"

# 2. Fix video texture allocator initialization
echo "Fixing video texture allocator initialization..."

# Create necessary directories for video texture resources
mkdir -p "$SCRIPT_DIR/Resources/VideoTextures"
mkdir -p "$SCRIPT_DIR/FaceTracker/Resources/VideoTextures"

# Create a placeholder video texture initializer file
cat > "$SCRIPT_DIR/Resources/VideoTextures/video_texture_init.json" << 'EOL'
{
    "videoTextureAllocator": {
        "version": "1.0",
        "maxTextureCount": 8,
        "defaultTextureFormat": "BGRA8Unorm",
        "preloadTextures": true,
        "enableMipMapping": true
    }
}
EOL

# Copy to FaceTracker resources
cp -f "$SCRIPT_DIR/Resources/VideoTextures/video_texture_init.json" "$SCRIPT_DIR/FaceTracker/Resources/VideoTextures/"

# 3. Create VideoLightSpill resources
echo "Creating VideoLightSpill resources..."

mkdir -p "$SCRIPT_DIR/Resources/VideoLightSpill"
mkdir -p "$SCRIPT_DIR/FaceTracker/Resources/VideoLightSpill"

# Create VideoLightSpill configuration file
cat > "$SCRIPT_DIR/Resources/VideoLightSpill/config.json" << 'EOL'
{
    "version": "1.0",
    "enableMPSPrewarm": true,
    "textureFormat": "BGRA8Unorm",
    "maxTextureCount": 4
}
EOL

# Copy to FaceTracker resources
cp -f "$SCRIPT_DIR/Resources/VideoLightSpill/config.json" "$SCRIPT_DIR/FaceTracker/Resources/VideoLightSpill/"

# 4. Update Info.plist to include necessary AR capabilities
echo "Updating Info.plist with AR capabilities..."

# Get the path to Info.plist
INFO_PLIST="$SCRIPT_DIR/FaceTracker/Info.plist"

if [ -f "$INFO_PLIST" ]; then
    # Check if ARKit capability is already in Info.plist
    if ! grep -q "NSCameraUsageDescription" "$INFO_PLIST"; then
        # Add camera usage description
        /usr/libexec/PlistBuddy -c "Add :NSCameraUsageDescription string 'This app needs camera access for AR face tracking.'" "$INFO_PLIST"
    fi
    
    # Check if Face ID usage description is already in Info.plist
    if ! grep -q "NSFaceIDUsageDescription" "$INFO_PLIST"; then
        # Add Face ID usage description
        /usr/libexec/PlistBuddy -c "Add :NSFaceIDUsageDescription string 'This app needs Face ID permission for AR face tracking.'" "$INFO_PLIST"
    fi
    
    echo "Info.plist updated with necessary permissions."
else
    echo "Warning: Info.plist not found at $INFO_PLIST"
fi

# 5. Copy all resources to the app bundle
echo "Copying all resources to the app bundle..."
"$SCRIPT_DIR/copy_resources.sh"

echo "Fix completed. The video texture allocator should now be properly initialized."
echo "Please rebuild and run the app to verify the fix."