//
//  ViewController.swift
//  AR_RULER_RR
//
//  Created by Ciro Angeleri on 28/07/2020.
//  Copyright © 2020 Ciro Angeleri. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

extension SCNNode {
    
    func distance(to destination: SCNNode) -> CGFloat {
        
        let dx = destination.position.x - position.x
        let dy = destination.position.y - position.y
        let dz = destination.position.z - position.z
         
        let meters = sqrt(dx*dx + dy*dy + dz*dz)
         
        return CGFloat(meters * 100)
    }

}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // Label to show measures
    var measurementLabel = UILabel()
    
    var spheres: [SCNNode] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        measurementLabel.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100)
        measurementLabel.backgroundColor = .gray
        
        measurementLabel.text = "0 centimetros"
        measurementLabel.textAlignment = .center
        view.addSubview(measurementLabel)
        
        // Creates a tap handler and then sets it to a constant
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        // Sets the amount of taps needed to trigger the handler
        tapRecognizer.numberOfTapsRequired = 1
        
        // Adds the handler to the scene view
        sceneView.addGestureRecognizer(tapRecognizer)
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        // Gets the location of the tap and assigns it to a constant
        let location = sender.location(in: sceneView)
         
        // Searches for real world objects such as surfaces and filters out flat surfaces
        let hitTest = sceneView.hitTest(location, types: [ARHitTestResult.ResultType.featurePoint])
         
        // Assigns the most accurate result to a constant if it is non-nil
        guard let result = hitTest.last else { return }
        
        // Converts the matrix_float4x4 to an SCNMatrix4 to be used with SceneKit
        let transform = SCNMatrix4.init(result.worldTransform)
         
        // Creates an SCNVector3 with certain indexes in the matrix
        let vector = SCNVector3Make(transform.m41, transform.m42, transform.m43)
         
        // Makes a new sphere with the created method
        let sphere = newSphere(at: vector)
        
        if let first = spheres.first {
            // Adds a second sphere to the array
            spheres.append(sphere)
            var distance = sphere.distance(to: first)
            
            measurementLabel.text = "\(distance) centimetros"
             
            // If more that two are present...
            if spheres.count > 2 {
                 
                // Iterate through spheres array
                for sphere in spheres {
                     
                    // Remove all spheres
                    sphere.removeFromParentNode()
                }
                 
                // Remove extraneous spheres
                spheres = [spheres[2]]
            }
        } else {
            // Add the sphere
            spheres.append(sphere)
        }
        
        // Iterate through spheres array
        for sphere in spheres {
             
            // Add all spheres in the array
            self.sceneView.scene.rootNode.addChildNode(sphere)
        }
    }
    
    func newSphere(at position: SCNVector3) -> SCNNode {
        // Creates an SCNSphere with a radius of 0.01 meters
        let sphere = SCNSphere(radius: 0.01)
         
        // Converts the sphere into an SCNNode
        let node = SCNNode(geometry: sphere)
         
        // Positions the node based on the passed in position
        node.position = position
        
        // Creates a material that is recognized by SceneKit
        let material = SCNMaterial()
        
        // Converts the contents of the PNG file into the material
        material.diffuse.contents = UIColor.orange
        
        // Creates realistic shadows around the sphere
        material.lightingModel = .blinn
         
        // Wraps the newly made material around the sphere
        sphere.firstMaterial = material
        
        return node
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
