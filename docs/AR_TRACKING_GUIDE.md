# AR Tracking Initialization Guide for FaceTracker

This guide provides instructions for properly initializing AR tracking in your FaceTracker app. Follow these steps to ensure that ARKit is correctly set up and functioning.

## Overview of Issues Fixed

We've successfully fixed the following issues:

1. ✅ Missing material files (`arKitPassthrough.rematerial`, `arSegmentationComposite.rematerial`, etc.)
2. ✅ Video texture allocator initialization
3. ✅ VideoLightSpill generator issues

However, AR tracking is still not being properly initialized. This requires changes to your Swift code.

## Steps to Fix AR Tracking

### 1. Locate Your Main View Controller

First, identify the main view controller that should handle AR tracking. This is likely a file named something like `FaceTrackingViewController.swift` or similar.

### 2. Import ARKit

Ensure that ARKit is imported at the top of your view controller file:

```swift
import ARKit
import UIKit
```

### 3. Add ARKit Session and Configuration

Add the following properties to your view controller class:

```swift
// ARKit session
private let arSession = ARSession()

// Configuration for face tracking
private let faceTrackingConfiguration = ARFaceTrackingConfiguration()

// AR view to display camera feed
private var arSceneView: ARSCNView!
```

### 4. Initialize ARKit in viewDidLoad

Add the following code to your `viewDidLoad()` method:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set up AR scene view
    arSceneView = ARSCNView(frame: view.bounds)
    arSceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(arSceneView)
    
    // Set the view's delegate
    arSceneView.delegate = self
    
    // Set the session
    arSceneView.session = arSession
    
    // Create a new scene
    let scene = SCNScene()
    arSceneView.scene = scene
    
    // Check if face tracking is supported
    guard ARFaceTrackingConfiguration.isSupported else {
        print("Face tracking is not supported on this device")
        // Show an alert to the user
        let alert = UIAlertController(
            title: "Face Tracking Not Supported",
            message: "This device does not support face tracking.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        return
    }
    
    // Configure face tracking
    setupFaceTracking()
}
```

### 5. Add Face Tracking Setup Method

Add this method to set up face tracking:

```swift
private func setupFaceTracking() {
    // Configure the AR session
    faceTrackingConfiguration.isLightEstimationEnabled = true
    
    // Set maximum number of faces to track
    if #available(iOS 13.0, *) {
        faceTrackingConfiguration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
    } else {
        // Prior to iOS 13, only one face can be tracked
        faceTrackingConfiguration.maximumNumberOfTrackedFaces = 1
    }
    
    // Print debug info
    print("ARKit face tracking session starting...")
    
    // Run the AR session
    arSession.run(faceTrackingConfiguration, options: [.resetTracking, .removeExistingAnchors])
}
```

### 6. Implement ARSCNViewDelegate

Make your view controller conform to ARSCNViewDelegate:

```swift
extension YourViewController: ARSCNViewDelegate {
    
    // Called when a new node has been mapped to the given anchor
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("AR face anchor added")
        
        // Handle face anchor
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        // Here you can add your face tracking logic
        // For example, adding a face mesh:
        let faceGeometry = ARSCNFaceGeometry(device: arSceneView.device!)
        let faceNode = SCNNode(geometry: faceGeometry)
        faceNode.geometry?.firstMaterial?.fillMode = .lines
        faceNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        node.addChildNode(faceNode)
    }
    
    // Called when a node has been updated with data from the given anchor
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Handle face anchor update
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let faceGeometry = node.childNodes.first?.geometry as? ARSCNFaceGeometry else { return }
        
        // Update the face geometry with the anchor data
        faceGeometry.update(from: faceAnchor.geometry)
        
        // Here you can handle facial expressions and tracking
        print("Face tracking updated")
    }
}
```

### 7. Handle App Lifecycle

Add these methods to handle app lifecycle events:

```swift
override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Resume the AR session when the view appears
    if ARFaceTrackingConfiguration.isSupported {
        arSession.run(faceTrackingConfiguration, options: [.resetTracking, .removeExistingAnchors])
        print("ARKit session resumed")
    }
}

override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the AR session when the view disappears
    arSession.pause()
    print("ARKit session paused")
}
```

### 8. Add Privacy Usage Descriptions

Ensure your Info.plist has the necessary privacy usage descriptions:

- NSCameraUsageDescription: "This app needs camera access for AR face tracking."
- NSFaceIDUsageDescription: "This app needs Face ID permission for AR face tracking."

(These should already be added by our scripts)

### 9. Add ARKit as a Required Device Capability

Ensure your Info.plist has ARKit listed as a required device capability:

```xml
<key>UIRequiredDeviceCapabilities</key>
<array>
    <string>arkit</string>
</array>
```

(This should already be added by our scripts)

## Testing AR Tracking

After implementing these changes:

1. Rebuild and run your app
2. Check the console logs for "ARKit face tracking session starting..." and other AR-related logs
3. Run the `check_ar_issues.sh` script to verify that AR tracking is now working

## Troubleshooting

If AR tracking is still not working:

1. Ensure you're testing on a device with a TrueDepth camera (iPhone X or newer)
2. Check that your app has camera permissions
3. Look for any errors in the Xcode console related to ARKit
4. Verify that your view hierarchy is set up correctly and the ARSCNView is visible

## Additional Resources

- [Apple ARKit Documentation](https://developer.apple.com/documentation/arkit)
- [ARKit Face Tracking Guide](https://developer.apple.com/documentation/arkit/content_anchors/tracking_and_visualizing_faces)
- Sample code in `Resources/ARKit/Reference/ARKitInitialization.swift`