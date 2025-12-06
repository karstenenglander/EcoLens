//
//  ImagePicker.swift
//  EcoLens
//
//  Created by Karsten Englander on 12/6/25.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onFinish: (Bool) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        #if targetEnvironment(simulator)
        picker.sourceType = .photoLibrary
        #else
        picker.sourceType = .camera
        #endif
        
        // 1. ENABLE NATIVE CROPPING
        // This brings up the standard "Move and Scale" square box after taking a photo
        picker.allowsEditing = true
        
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // 2. RETRIEVE THE CROPPED IMAGE
            // We use .editedImage instead of .originalImage
            if let uiImage = info[.editedImage] as? UIImage {
                parent.image = uiImage
                parent.onFinish(true)
            } else if let uiImage = info[.originalImage] as? UIImage {
                // Fallback if editing failed for some reason
                parent.image = uiImage
                parent.onFinish(true)
            } else {
                parent.onFinish(false)
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onFinish(false)
        }
    }
}
