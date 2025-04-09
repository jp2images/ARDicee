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
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(0, 0, -0.1)
            
            // Set the scene to the view
            sceneView.scene.rootNode.addChildNode(diceNode)
            //sceneView.scene = scene
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        //print("ARWorldTracking is supported: \(ARWorldTrackingConfiguration.isSupported)")
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
}
