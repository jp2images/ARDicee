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
    
    var diceArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Show the debgug options such as feature points and world origin the SceneKit uses for
        /// locating a plane in the real world.
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints /*, ARSCNDebugOptions.showWorldOrigin*/]
        
        /// Set the view's delegate
        sceneView.delegate = self
        
        /// Add some depth as shadow to the object
        sceneView.autoenablesDefaultLighting = true
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
    
    //MARK: - Touch Methods
    
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
                addDice(atLocation: hitResult)
            }
        }
    }


    //MARK: - Dice Methods
    
    func addDice(atLocation location: ARHitTestResult) {
        //print("hitResult: \(hitResult)")
        
        /// Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.scale = SCNVector3(3.0, 3.0, 3.0)
            
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius * 3.0,
                z: location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            // Set the scene to the view
            sceneView.scene.rootNode.addChildNode(diceNode)
            roll(dice: diceNode)
        }
    }
    
    
    func roll(dice: SCNNode) {
        /// Create a random result between 1 and 4 that represents the die face in the x
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        /// Using the Y axis won't change the number.
        /// TODO Make the die position look more random if the face could change
        
        dice.runAction(SCNAction.rotateBy(
            x: 0,
            y: CGFloat(randomX * 3),
            z: CGFloat(randomZ * 3),
            duration: 0.5))
    }
    
    /// Role all of the dice
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }

    //MARK: - ARSCNViewDelegate Methods
    
    /// This will search for the Horizontal plane that can be used as an  Anchor of the object to the plane
    /// IRL of the scene.
    func renderer(_ renderer: any SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)

        node.addChildNode(planeNode)
    }
    
    //MARK: - Plane rederring methods
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        
        let plane = SCNPlane(width: CGFloat(planeAnchor.planeExtent.width),
                             height: CGFloat(planeAnchor.planeExtent.height))
        
        let planeNode = SCNNode()
        /// This planeNode creates a 2D plane in the vertical orientation with no Z axis.
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        /// We need the planeNode horizontal so we need to transform it and rotate it 90°. The
        /// method needs radians. 180° = 1π radians. 90° = π/2 radians and is measured CCW
        /// from the position. We want to go CW so we need to negate the value.
        planeNode.transform = SCNMatrix4MakeRotation((-Float.pi/2), 1, 0, 0)
        
        //let gridMaterial = SCNMaterial()
        //gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        //plane.materials = [gridMaterial]
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor.clear
        plane.materials = [transparentMaterial]
        
        planeNode.geometry = plane
        return planeNode
    }
        
}


