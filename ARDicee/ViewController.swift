//
//  ViewController.swift
//  ARDicee
//
//  Created by Jeff Patterson on 4/7/25.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    /// The IBOutlet connects the storyboard with the AR code content.
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Show the debgug options such as feature points and world origin the SceneKit uses for
        /// locating a plane in the real world.
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints /*, ARSCNDebugOptions.showWorldOrigin*/]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        /// Create a new scene that is in fact, a simple cube
        //let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        //let sphere = SCNSphere(radius: 0.2)
        
        /// Material is the surface of the object.
        //let material = SCNMaterial()
        //material.diffuse.contents = UIColor.red
        //material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        
        /// Attach the material to the cube.
        //cube.materials = [material]
        //sphere.materials = [material]
        
        /// Node is a position in 3D space.
        //let node = SCNNode(geometry: cube)
        //let node = SCNNode()
        
        /// Postion of the object in 3D space. This is centered, low and further back a little.
        //node.position = SCNVector3(0, 0.1, -0.5)
        
        /// With a node in space we now assign the position to the cube.
        //node.geometry = cube
        //node.geometry = sphere
        
        /// put the node into the scene
        //sceneView.scene.rootNode.addChildNode(node)
        
        /// Add some depth as shadow to the object
        sceneView.autoenablesDefaultLighting = true
        
        // Create a new scene
        //        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        //        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
        //            diceNode.position = SCNVector3(0, 0, -0.1)
        //
        //            // Set the scene to the view
        //            sceneView.scene.rootNode.addChildNode(diceNode)
        //            //sceneView.scene = scene
        //        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        /// Enable plane detection. Ommitting vertical as the tutorial does not cover it. (didn't exist)
        //configuration.planeDetection = [.horizontal, .vertical]
        configuration.planeDetection = .horizontal
        //print("ARWorldTracking is supported: \(ARWorldTrackingConfiguration.isSupported)")
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    /// This method will convert touches on the screen to real world coordinates via SceneKit and AR
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /// Multitouch is not enabled (we don't want it) so we can assume there is only one touch and we
        /// will capture it.
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            /// This will convert the touch location on the screen into a 3D point in the real world.
            /// The hitTest will return an array of SCNHitTestResult objects.
            /// The .existingPlaneUsingExtent that is already in the scene becasue we put it on in the
            /// delegate method func renderer(...
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                //print("hitResult: \(hitResult)")
                
                /// Create a new scene
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3(
                        x: hitResult.worldTransform.columns.3.x,
                        y: hitResult.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResult.worldTransform.columns.3.z)
                    
                    // Set the scene to the view
                    sceneView.scene.rootNode.addChildNode(diceNode)
                    
                    /// Create a random result between 1 and 4 that represents the die face in the x
                    let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
                    /// Using the Y axis won't change the number.
                    /// TODO Make the die position look more random if the face could change
                    
                    diceNode.runAction(SCNAction.rotateBy(
                        x: 0,
                        y: CGFloat(randomX * 3),
                        z: CGFloat(randomZ * 3),
                        duration: 0.5))
                    

                            
                                   
                }
            }
        }
    }
    
    /// This will search for the Horizontal plane that can be used as an  Anchor of the object to the plane
    /// IRL of the scene.
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            /// When a plane is detected, cast it as an ARPlanAnchor to use it as a reference.
            let planeAnchor = anchor as! ARPlaneAnchor
            
            let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width),
                                 height: CGFloat(planeAnchor.planeExtent.height))
            
            let planeNode = SCNNode()
            /// This planeNode creates a 2D plane in the vertical orientation with no Z axis.
            planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
            
            /// We need the planeNode horizontal so we need to transform it and rotate it 90°. The
            /// method needs radians. 180° = 1π radians. 90° = π/2 radians and is measured CCW
            /// from the position. We want to go CW so we need to negate the value.
            planeNode.transform = SCNMatrix4MakeRotation((-Float.pi/2), 1, 0, 0)
            
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            //sceneView.scene.rootNode.addChildNode(planeNode)
            node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
}
