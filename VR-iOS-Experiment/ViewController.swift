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

func degreesToRadians(degrees: Float) -> Float {
    return (degrees * Float(M_PI)) / 180.0
}

func radiansToDegrees(radians: Float) -> Float {
    return (180.0/Float(M_PI)) * radians
}

class ViewController: UIViewController {
    
    @IBOutlet var leftSceneView : SCNView?
    @IBOutlet var rightSceneView : SCNView?
    
    var motionManager : CMMotionManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftSceneView?.backgroundColor = UIColor.blackColor()
        rightSceneView?.backgroundColor = UIColor.blackColor()
        
        // Create Scene
        var scene = SCNScene()
        leftSceneView?.scene = scene
        rightSceneView?.scene = scene
        
        // Create cameras
        let leftCamera = SCNCamera()
        leftCamera.xFov = 45
        leftCamera.yFov = 45
        
        let rightCamera = SCNCamera()
        rightCamera.xFov = 45
        rightCamera.yFov = 45
        
        let leftCameraNode = SCNNode()
        leftCameraNode.camera = leftCamera
        leftCameraNode.position = SCNVector3(x: -0.5, y: 0, z: 0)
        
        let rightCameraNode = SCNNode()
        rightCameraNode.camera = rightCamera
        rightCameraNode.position = SCNVector3(x: 0.5, y: 0, z: 0)
        
        let camerasNode = SCNNode()
        camerasNode.addChildNode(leftCameraNode)
        camerasNode.addChildNode(rightCameraNode)
        
        // The user will be holding their device up (i.e. 90 degrees roll from a flat orientation)
        // so roll the cameras by -90 degrees to orient the view correctly.
        camerasNode.eulerAngles = SCNVector3Make(degreesToRadians(-90.0), 0, 0)
        
        let cameraRollNode = SCNNode()
        cameraRollNode.addChildNode(camerasNode)
        
        let cameraPitchNode = SCNNode()
        cameraPitchNode.addChildNode(cameraRollNode)
        
        let cameraYawNode = SCNNode()
        cameraYawNode.addChildNode(cameraPitchNode)
        
        scene.rootNode.addChildNode(cameraYawNode)
        
        leftSceneView?.pointOfView = leftCameraNode
        rightSceneView?.pointOfView = rightCameraNode
        
        // Ambient Light
        let ambientLight = SCNLight()
        ambientLight.type = SCNLightTypeAmbient
        ambientLight.color = UIColor(white: 0.1, alpha: 1.0)
        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Omni Light
        let diffuseLight = SCNLight()
        diffuseLight.type = SCNLightTypeOmni
        diffuseLight.color = UIColor(white: 1.0, alpha: 1.0)
        let diffuseLightNode = SCNNode()
        diffuseLightNode.light = diffuseLight
        diffuseLightNode.position = SCNVector3(x: -30, y: 30, z: 50)
        scene.rootNode.addChildNode(diffuseLightNode)
        
        // Create Floor
        let floor = SCNFloor()
        floor.reflectivity = 0.15
        let mat = SCNMaterial()
        let darkBlue = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
        mat.diffuse.contents = darkBlue
        mat.specular.contents = darkBlue
        floor.materials = [mat]
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(x: 0, y: -1, z: 0)
        scene.rootNode.addChildNode(floorNode)
        
        // Create boing ball
        let boingBall = SCNSphere(radius: 1.0)
        let boingBallNode = SCNNode(geometry: boingBall)
        boingBallNode.position = SCNVector3(x: 0, y: 3, z: -10)
        scene.rootNode.addChildNode(boingBallNode)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "checkerboard_pattern.png")
        material.specular.contents = UIColor.whiteColor()
        material.shininess = 1.0
        boingBall.materials = [ material ]
        
        // Make it bounce
        let animation = CABasicAnimation(keyPath: "position")
        animation.byValue = NSValue(SCNVector3: SCNVector3(x: 0, y: -3.05, z: 0))
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        animation.duration = 0.5
        
        boingBallNode.addAnimation(animation, forKey: "bounce")
        
        // Fire Particle System, attached to the boing ball
        let fire = SCNParticleSystem(named: "FireParticles", inDirectory: nil)
        fire.emitterShape = boingBall
        boingBallNode.addParticleSystem(fire)
        
        // Respond to user head movement
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager?.startDeviceMotionUpdatesUsingReferenceFrame(
            CMAttitudeReferenceFrameXArbitraryZVertical,
            toQueue: NSOperationQueue.mainQueue(),
            withHandler: { (motion: CMDeviceMotion!, error: NSError!) -> Void in
                
                let currentAttitude = motion.attitude
                let roll = Float(currentAttitude.roll)
                let pitch = Float(currentAttitude.pitch)
                let yaw = Float(currentAttitude.yaw)
                
                cameraRollNode.eulerAngles = SCNVector3Make(roll, 0.0, 0.0)
                cameraPitchNode.eulerAngles = SCNVector3Make(0.0, 0.0, pitch)
                cameraYawNode.eulerAngles = SCNVector3Make(0.0, yaw, 0.0)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

