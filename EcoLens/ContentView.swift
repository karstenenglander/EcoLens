//
//  ContentView.swift
//  EcoLens
//
//  Created by Karsten Englander on 12/6/25.
//

import SwiftUI
import CoreML
import Vision
import PhotosUI

enum AppState {
    case idle
    case takingPhoto
}

struct ContentView: View {
    // Current Step
    @State private var appState: AppState = .idle
    
    // Data
    @State private var currentImage: UIImage? = nil
    @State private var tempImage: UIImage? = nil
    
    // Results
    @State private var classificationLabel: String = "Ready to Scan"
    @State private var disposalAdvice: String = ""
    @State private var statusColor: Color = .gray

    var body: some View {
        ZStack {
            switch appState {
            case .idle:
                mainMenuScreen
                
            case .takingPhoto:
                ImagePicker(image: $tempImage) { didTakePhoto in
                    if didTakePhoto, let img = tempImage {
                        
                        self.currentImage = img
                        
                        self.classifyImage(image: img)
                        
                        self.appState = .idle
                        
                    } else {
                        self.appState = .idle
                    }
                }
                .ignoresSafeArea()
                
            }
        }
    }
    
    // MARK: - Screen 1: Main Menu
    var mainMenuScreen: some View {
        VStack(spacing: 20) {
            Text("EcoLens")
                .font(.largeTitle)
                .bold()
                .foregroundColor(statusColor == .gray ? .green : statusColor)
            
            // Image Preview
            if let image = currentImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 300)
                    .overlay(Text("No Scan Yet").foregroundColor(.gray))
            }
            
            // Text Results
            VStack(spacing: 5) {
                Text(classificationLabel)
                    .font(.title2)
                    .bold()
                Text(disposalAdvice)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Spacer()
            
            // Start Button
            Button(action: {
                appState = .takingPhoto
            }) {
                Label("Take Picture", systemImage: "camera.fill")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - Classification Logic
    func classifyImage(image: UIImage) {
        // 1. Load Model
        guard let model = try? VNCoreMLModel(for: GarbageClassifier().model) else {
            print("Error: Model not found")
            return
        }
        
        // 2. Create Request
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation],
               let topResult = results.first {
                DispatchQueue.main.async {
                    let confidence = Int(topResult.confidence * 100)
                    let category = topResult.identifier
                    
                    self.classificationLabel = "\(category.uppercased()) (\(confidence)%)"
                    self.updateAdvice(for: category)
                }
            }
        }
        
        // 4. Run Handler
        guard let ciImage = CIImage(image: image) else { return }
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            try? handler.perform([request])
        }
    }
    
    func updateAdvice(for category: String) {
        let cat = category.lowercased()
        if cat.contains("bio") {
            disposalAdvice = "Compost this item."
            statusColor = .green
        } else if cat.contains("plastic") || cat.contains("metal") || cat.contains("glass") {
            disposalAdvice = "Recycle this item."
            statusColor = .blue
        } else {
            disposalAdvice = "Dispose in Trash."
            statusColor = .gray
        }
    }
}

// MARK: - Helper for Orientation
import ImageIO
extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
