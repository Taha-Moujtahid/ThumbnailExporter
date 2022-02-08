//
//  WaterPlane.swift
//  VereinsApp
//
//  Created by Taha Moujtahid on 31.10.21.
//

import Foundation
import SceneKit

struct WaterPlane {
    
    static let material = SCNMaterial()
    
    static func addShader(_ node : SCNNode){
        WaterPlane.material.diffuse.contents = NSColor(red: 0,green: 0,blue: 1, alpha: 0.45)
        WaterPlane.material.shaderModifiers = [
            SCNShaderModifierEntryPoint.geometry:
            "#pragma arguments \n" +
            "float deltaTime = 0.0; \n" +
            "float frequency = 1; \n" +
            "float amplitude = 0.1; \n" +
            "#pragma body \n" +
            "_geometry.position.z = sin(_geometry.position.x * _geometry.position.y * frequency * deltaTime) * amplitude; "
        ]
        
        setShaderValue(Float(0.1), forKey: "amplitude")
        setShaderValue(Float(1), forKey: "frequency")
        
        node.childNode(withName: "WaterPlane", recursively: true)?.geometry?.materials = [WaterPlane.material]
    }
    
    static func setShaderValue(_ value : Any, forKey : String){
        material.setValue(value, forKey: forKey)
    }
    
}
