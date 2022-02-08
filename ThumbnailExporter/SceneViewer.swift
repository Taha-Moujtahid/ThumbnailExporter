//
//  SceneViewer.swift
//  SceneViewer
//
//  Created by Taha Moujtahid on 07.09.21.
//

import Foundation
import SwiftUI
import SceneKit
import GameController

struct SceneViewer: NSViewRepresentable {
    
    static let scnView = SCNView()

    init(){
        SceneViewer.scnView.rendersContinuously = true
        SceneViewer.scnView.scene = SCNScene(named: "photobooth.scn")!
    }
    
    func makeNSView(context: NSViewRepresentableContext<SceneViewer>) -> SceneViewer.NSViewType {
        return SceneViewer.scnView
    }
    
    class Coordinator: NSObject {
        private let view: SCNView
        
        init(_ view: SCNView) {
            self.view = view
            super.init()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(SceneViewer.scnView)
    }

    func updateNSView(_ uiView: NSView, context: NSViewRepresentableContext<SceneViewer>) {
        // Update the view.
    }
}
