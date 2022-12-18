//
//  DragDropImageView.swift
//  CoreDataRelationshipTest (macOS)
//
//  Created by Kenneth Lo on 12/26/21.
//

import SwiftUI

#if os(macOS)
struct DragDropImageView: View {
    
    //@Binding var image: NSImage?
    
    @Binding var image: NSImage?
    @Binding var filename: String
    
    @Binding var full_path: String
    var post_action: () -> Void
    
    var body: some View {
        ZStack {
            if (image != nil) {
                Image( nsImage: self.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                    .frame(width: 400)

            } else {
                Text("Drag and drop image file")
                    .frame(width: 400)
            }
        }
        .frame(minWidth: .zero, maxWidth: .infinity)
        .frame(minHeight: 350)
        .background(Color.black.opacity(0.5))
        .cornerRadius(8)
        
        .onDrop(of: ["public.url","public.file-url"], isTargeted: nil) { (items) -> Bool in
            if let item = items.first {
                if let identifier = item.registeredTypeIdentifiers.first {
                    print("onDrop with identifier = \(identifier)")
                    if identifier == "public.url" || identifier == "public.file-url" {
                        item.loadItem(forTypeIdentifier: identifier, options: nil) { (urlData, error) in
                            DispatchQueue.main.async {
                                if let urlData = urlData as? Data {
                                    let urll = NSURL(absoluteURLWithDataRepresentation: urlData, relativeTo: nil) as URL
                                    if let img = NSImage(contentsOf: urll) {
                                        self.image = img
                                        self.filename = urll.lastPathComponent ?? "<none>"
                                        self.full_path = urll.path
                                        debugPrint("self.full_path: \(self.full_path)")
                                        self.post_action()
                                    } else {
                                        print(">> not valid image")
                                    }
                                }
                            }
                        }
                    }
                }
                return true
            } else {
                print("item not here")
                return false
                
            }
        }
    }
}

#endif
