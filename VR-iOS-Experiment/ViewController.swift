//
//  ViewController.swift
//  VR-iOS-Experiment
//
//  Created by Steven Saunders on 30/09/2014.
//  Copyright (c) 2014 Steven Saunders. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion

func degreesToRadians(_ degrees: Float) -> Float {
    return degrees * .pi / 180
}

func radiansToDegrees(_ radians: Float) -> Float {
    return 180 / .pi * radians
}

class ViewController: UIViewController, SCNSceneRendererDelegate {
    
    @IBOutlet var leftSceneView : SCNView?
    @IBOutlet var rightSceneView : SCNView?
    
    var motionManager : CMMotionManager?
    var cameraRollNode : SCNNode?
    var cameraPitchNode : SCNNode?
    var cameraYawNode : SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftSceneView?.backgroundColor = UIColor.black
        rightSceneView?.backgroundColor = UIColor.black
        
        // Create Scene
        let scene = SCNScene()
        
        leftSceneView?.scene = scene
        rightSceneView?.scene = scene
        
        // Create cameras
        let leftCamera = SCNCamera()
        let rightCamera = SCNCamera()

        let leftCameraNode = SCNNode()
        leftCameraNode.camera = leftCamera
        leftCameraNode.position = SCNVector3(x: -0.5, y: 0, z: 0)
        
        let rightCameraNode = SCNNode()
        rightCameraNode.camera = rightCamera
        rightCameraNode.position = SCNVector3(x: 0.5, y: 0, z: 0)
        
        let camerasNode = SCNNode()
        camerasNode.position = SCNVector3(x: 0, y: 0, z: -3)
        camerasNode.addChildNode(leftCameraNode)
        camerasNode.addChildNode(rightCameraNode)
        
        // The user will be holding their device up (i.e. 90 degrees roll from a flat orientation)
        // so roll the cameras by -90 degrees to orient the view correctly.
        camerasNode.eulerAngles = SCNVector3Make(degreesToRadians(-90), 0, 0)
        
        cameraRollNode = SCNNode()
        cameraRollNode!.addChildNode(camerasNode)
        
        cameraPitchNode = SCNNode()
        cameraPitchNode!.addChildNode(cameraRollNode!)
        
        cameraYawNode = SCNNode()
        cameraYawNode!.addChildNode(cameraPitchNode!)
        
        scene.rootNode.addChildNode(cameraYawNode!)
        
        leftSceneView?.pointOfView = leftCameraNode
        rightSceneView?.pointOfView = rightCameraNode
        
        // Ambient Light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.1, alpha: 1)
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Omni Light
        let diffuseLight = SCNLight()
        diffuseLight.type = .omni
        diffuseLight.color = UIColor(white: 1, alpha: 1)
        let diffuseLightNode = SCNNode()
        diffuseLightNode.light = diffuseLight
        diffuseLightNode.position = SCNVector3(x: -30, y: 30, z: 50)
        scene.rootNode.addChildNode(diffuseLightNode)
        
        // Create Floor
        let floor = SCNFloor()
        floor.reflectivity = 0.15
        let mat = SCNMaterial()
        let darkBlue = UIColor(red: 0, green: 0, blue: 0.5, alpha: 1)
        mat.diffuse.contents = darkBlue
        mat.specular.contents = darkBlue
        floor.materials = [mat]
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(x: 0, y: -1, z: 0)
        scene.rootNode.addChildNode(floorNode)
        
        // Create boing ball
        let boingBall = SCNSphere(radius: 1)
        let boingBallNode = SCNNode(geometry: boingBall)
        boingBallNode.position = SCNVector3(x: 0, y: 3, z: -7)
        scene.rootNode.addChildNode(boingBallNode)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "checkerboard_pattern.png")
        material.specular.contents = UIColor.white
        material.shininess = 1.0
        boingBall.materials = [ material ]
        
        // Fire Particle System, attached to the boing ball
		if let fire = SCNParticleSystem(named: "FireParticles", inDirectory: nil) {
        	fire.emitterShape = boingBall
        	boingBallNode.addParticleSystem(fire)
		}
		
        // Make the ball bounce
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.byValue = -3.05
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        animation.duration = 0.5
        
        boingBallNode.addAnimation(animation, forKey: "bounce")
		
        // Make the camera move back and forth
        let camera_anim = CABasicAnimation(keyPath: "position.y")
        camera_anim.byValue = 12.0
        camera_anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        camera_anim.autoreverses = true
        camera_anim.repeatCount = Float.infinity
        camera_anim.duration = 2.0
        
        camerasNode.addAnimation(camera_anim, forKey: "camera_motion")
		
        // Respond to user head movement
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager?.startDeviceMotionUpdates(using: .xArbitraryZVertical)
		
        leftSceneView?.delegate = self
        
        leftSceneView?.isPlaying = true
        rightSceneView?.isPlaying = true
    }
    
    func renderer(_ aRenderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		let doCorrect = UIDevice.current.orientation == .landscapeLeft
		let rollPitchCorrect: Float = doCorrect ? -1 : 1
		let yawCorrect: Float = doCorrect ? .pi : 0
		
        if let mm = motionManager, let motion = mm.deviceMotion {
            let currentAttitude = motion.attitude
    
            cameraRollNode!.eulerAngles.x = Float(currentAttitude.roll) * rollPitchCorrect
            cameraPitchNode!.eulerAngles.z = Float(currentAttitude.pitch) * rollPitchCorrect
            cameraYawNode!.eulerAngles.y = Float(currentAttitude.yaw) - yawCorrect
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

