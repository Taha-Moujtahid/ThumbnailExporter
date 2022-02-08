//
//  ContentView.swift
//  ThumbnailExporter
//
//  Created by Taha Moujtahid on 17.10.21.
//

import SwiftUI
import SceneKit


struct LabeledInput : View{
    let label : String
    let input : Binding<String>
    
    var body: some View{
        HStack{
            Text(label).font(.footnote)
            TextField(label, text: input)
        }
    }
}

struct ContentView: View {
    
    @State var directory = ""
    @State var write_directory = ""
    @State var width = 256
    @State var height = 256
    @State var modelScale = Float(1.0)
    @State var cameraPosition = SCNVector3(-1.5,1.5,1.5)
    @State var oneToOneRatio = true
    @State var fileCount = 0
    @State var previewNum = 0
    @State var previewFileName : String?
    @State var previewNode : SCNNode?
    let sceneView = SceneViewer()
    
    fileprivate func cameraTransform() -> some View{
        VStack{
            Text("Camera Transform")
            LabeledInput(label: "x", input: Binding(
                get: { String(Float(cameraPosition.x)) },
                set: {
                    if( Float($0) != nil && Float($0)! < 3){
                        cameraPosition.x = CGFloat(Float($0)!)
                        SceneViewer.scnView.pointOfView?.worldPosition = cameraPosition
                    }
                }
            ))
            LabeledInput(label: "y", input: Binding(
                get: { String(Float(cameraPosition.y)) },
                set: {
                    if( Float($0) != nil && Float($0)! < 3){
                        cameraPosition.y = CGFloat(Float($0)!)
                        SceneViewer.scnView.pointOfView?.worldPosition = cameraPosition
                    }
                }
            ))
            LabeledInput(label: "z", input: Binding(
                get: { String(Float(cameraPosition.z)) },
                set: {
                    if( Float($0) != nil && Float($0)! < 3){
                        cameraPosition.z = CGFloat(Float($0)!)
                        SceneViewer.scnView.pointOfView?.worldPosition = cameraPosition
                    }
                }
            ))
        }
    }
    
    fileprivate func previewPanel() -> some View{
        VStack{
            Text("Preview")
            HStack{
                Image(systemName: "chevron.backward.square.fill").onTapGesture {
                    if(previewNum == 0 && fileCount != 0){
                        previewNum = fileCount-1
                    }else if(fileCount != 0){
                        previewNum -= 1
                    }
                    if(directory != ""){
                        updatePreview()
                    }
                }
                Spacer()
                Text(previewFileName ?? "none")
                Spacer()
                Image(systemName: "chevron.forward.square.fill").onTapGesture {
                    if(fileCount != 0 && previewNum == fileCount){
                        previewNum = 0
                    }else if(fileCount != 0){
                        previewNum += 1
                    }
                    if(directory != ""){
                        updatePreview()
                    }
                }
            }
        }
    }
    
    fileprivate func imagePanel() -> some View{
        VStack{
            Text("Image Resoloution")
            LabeledInput(label: "width", input: Binding(
                get: { String(width) },
                set: {
                    if( Int($0) != nil && Int($0)! < 640){
                        width = Int($0)!
                        height = oneToOneRatio ? width : height
                    }
                }
            ))
            LabeledInput(label: "height", input: Binding(
                get: { String(height) },
                set: {
                    if( Int($0) != nil && Int($0)! < 640){
                        height = Int($0)!
                        width = oneToOneRatio ? height : width
                    }
                }
            ))
            HStack(alignment: .center){
                Image(systemName: oneToOneRatio ? "checkmark.square.fill" : "square")
                    .foregroundColor(oneToOneRatio ? Color(.systemBlue) : Color.secondary)
                    .onTapGesture {
                        oneToOneRatio.toggle()
                    }
                
                Text("1:1 Ratio").font(.footnote)
            }
        }
    }
    
    func removeAnimations(_ node: SCNNode){
        node.removeAllAnimations()
        if(!node.childNodes.isEmpty){
            node.childNodes.forEach({childNode in
                removeAnimations(childNode)
            })
        }
    }
    
    var body: some View {
        VStack{
            Text("SceneKit to Thumbnail exporter").font(.title).padding()
            VStack(alignment: .leading){
                Text("Assets Directory: \(directory)")
                Text("Destination Directory: \(write_directory)")
            }
            HStack{
                sceneView.frame(width: CGFloat(width), height: CGFloat(height))
                VStack(alignment: .leading){
                    previewPanel()
                    LabeledInput(label: "modelScale", input: Binding(
                        get: { String(modelScale)}, set: {
                            modelScale = Float($0) ?? 1
                            updatePreview()
                        }
                    ))
                    cameraTransform()
                    imagePanel()
                }.frame(width: 128)
            }
            HStack{
                Button(action: {
                    openAssets()
                }){
                    Text("Select Assets")
                }
                Button(action: {
                    openDestination()
                }){
                    Text("Select Destination")
                }
                
                if(directory != "" && write_directory != ""){
                    Button(action: {
                        generateThumbnails()
                    }, label: {
                        Text("Generate ALL Thumbnails")
                    })
                }
                
            }
            
        }.padding()
    }
        
    func generateThumbnails(){
        
        if(previewNode != nil){
            previewNode?.removeFromParentNode()
        }
        
        do {
            let modelPathDirectoryFiles = try FileManager.default.contentsOfDirectory(atPath: directory)
            modelPathDirectoryFiles.forEach{ file in
                print("Generate img for \(file)")
                do{
                    let node = try SCNScene(url: URL(fileURLWithPath: "\(directory)/\(file)"), options: [.flattenScene:true]).rootNode
                    node.scale = SCNVector3(modelScale*0.5,modelScale*0.5,modelScale*0.5)
                    removeAnimations(node)
                    WaterPlane.addShader(node) // checks if object has waterPlane in it
                    SceneViewer.scnView.scene!.rootNode.addChildNode(node)
                    let groupName = directory.split(separator: "/").last!.split(separator: ".")[0]
                    let image = SceneViewer.scnView.snapshot()
                    if let png = image.png {
                        do {
                            if(FileManager.default.fileExists(atPath: "\(write_directory)/\(groupName)_\(file.split(separator: ".")[0]).png")){
                                try FileManager.default.removeItem(atPath: "\(write_directory)/\(groupName)_\(file.split(separator: ".")[0]).png")
                            }
                            try png.write(to: URL(fileURLWithPath: "\(write_directory)/\(groupName)_\(file.split(separator: ".")[0]).png"))
                            print("PNG image saved")
                        } catch {
                            print(error)
                        }
                    }
                    node.removeFromParentNode()
                }catch{
                    print("error getting list of files")
                }
                
            }
        } catch {
            print("error getting list of files")
        }
        
        if(previewNode != nil){
            SceneViewer.scnView.scene?.rootNode.addChildNode(previewNode!)
        }
        
    }
    
    func updatePreview(){
        print(fileCount)
        print(previewNum)
        if(previewNode != nil){
            previewNode!.removeFromParentNode()
        }
        var modelPathDirectoryFiles = getFiles(directory: directory)!
        modelPathDirectoryFiles.removeAll(where: {it in it.contains(".DS_Store")})
        do{
            previewNode = try SCNScene(url: URL(fileURLWithPath: "\(directory)/\(modelPathDirectoryFiles[previewNum])"), options: [.flattenScene:true]).rootNode
            previewNode?.scale = SCNVector3(modelScale*0.5,modelScale*0.5,modelScale*0.5)
            WaterPlane.addShader(previewNode!) // checks if object has waterPlane in it
            SceneViewer.scnView.scene!.rootNode.addChildNode(previewNode!)
            removeAnimations(previewNode!)
            previewFileName = modelPathDirectoryFiles[previewNum]
        }catch{
            print("error adding the model for preview")
        }
    }
    
    func openAssets() {
        let dialog = NSOpenPanel();

        dialog.title                    = "Choose a directory"
        dialog.showsResizeIndicator     = true
        dialog.showsHiddenFiles         = false
        dialog.allowsMultipleSelection  = false
        dialog.canChooseDirectories     = true
        dialog.canChooseFiles           = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            if let url = dialog.url {
                directory = url.path
                let modelPathDirectoryFiles = getFiles(directory: directory)!
                fileCount = modelPathDirectoryFiles.count-1
                previewNum = 1
                updatePreview()
            }
        } else {
            print("user cancelled")
            return
        }
    }
    
    func openDestination() {
        let dialog = NSOpenPanel();

        dialog.title                    = "Choose a directory"
        dialog.showsResizeIndicator     = true
        dialog.showsHiddenFiles         = false
        dialog.allowsMultipleSelection  = false
        dialog.canChooseDirectories     = true
        dialog.canChooseFiles           = false

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            if let url = dialog.url {
                write_directory = url.path
            }
        } else {
            print("user cancelled")
            return
        }
    }
    
    func getFiles(directory: String) -> [String]?{
        do{
            var modelPathDirectoryFiles = try FileManager.default.contentsOfDirectory(atPath: directory)
            modelPathDirectoryFiles.removeAll(where: {it in it.contains(".DS_Store")})
            return modelPathDirectoryFiles
        }catch{
            print("error")
        }
        return nil
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension NSBitmapImageRep {
    var png: Data? { representation(using: .png, properties: [:]) }
}
extension Data {
    var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}
extension NSImage {
    var png: Data? { tiffRepresentation?.bitmap?.png }
}
