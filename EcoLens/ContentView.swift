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

struct ContentView: View {
    @State private var classificationLabel: String = "Select an image to start"
    @State private var disposalAdvice: String = ""
    @State private var confidenceLabel: String = ""
    @State private var currentImage: UIImage? = nil
    
    @State private var showCamera = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    @State private var statusColor: Color = .gray
    
    init(previewImage: UIImage? = nil) {
            _currentImage = State(initialValue: previewImage)
        }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("EcoLens")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(statusColor == .gray ? .green : statusColor)
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                
                if let image = currentImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(16)
                } else {
                    VStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            
            VStack(spacing: 10) {
                Text(classificationLabel)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                
                if !disposalAdvice.isEmpty {
                    Text(disposalAdvice)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                if !confidenceLabel.isEmpty {
                    Text(confidenceLabel)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Label("Upload", systemImage: "photo.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .onChange(of: selectedItem) { _, newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            
                            self.currentImage = image
                            classifyImage(image: image)
                        }
                    }
                }
                
                Button(action: {
                    self.showCamera = true
                }) {
                    Label("Camera", systemImage: "camera.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(statusColor == .gray ? .green : statusColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            
            .onAppear {
                        if let image = currentImage {
                            classifyImage(image: image)
                        }
                    }
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $currentImage, isPresented: $showCamera)
                .onDisappear {
                    if let image = currentImage {
                        classifyImage(image: image)
                    }
                }
        }
    }
    
    func classifyImage(image: UIImage) {
        guard let model = try? VNCoreMLModel(for: GarbageClassifier().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if let results = request.results as? [VNClassificationObservation],
               let topResult = results.first {
                
                DispatchQueue.main.async {
                    let confidence = Int(topResult.confidence * 100)
                    
                    if confidence < 60 {
                        self.classificationLabel = "NOT RECOGNIZED"
                        self.confidenceLabel = "Low Confidence: \(confidence)%"
                        self.disposalAdvice = "Could not identify object.\nTry moving closer."
                        self.statusColor = .gray
                    } else {
                        let category = topResult.identifier.lowercased()
                        self.classificationLabel = category.uppercased()
                        self.confidenceLabel = "AI Confidence: \(confidence)%"
                        self.updateAdvice(for: category)
                    }
                }
            }
        }
        
        guard let ciImage = CIImage(image: image) else { return }
        DispatchQueue.global(qos: .userInitiated).async {
            try? VNImageRequestHandler(ciImage: ciImage).perform([request])
        }
    }
    
    func updateAdvice(for category: String) {
        switch category {
        case "biological":
            self.disposalAdvice = "🌱 COMPOST\nOrganic waste."
            self.statusColor = .green
        case "cardboard", "paper", "glass", "metal", "plastic", "clothes":
            self.disposalAdvice = "♻️ RECYCLE\nEnsure it is clean."
            self.statusColor = .blue
        case "battery":
            self.disposalAdvice = "🔋 HAZARDOUS\nUse battery drop-off."
            self.statusColor = .orange
        case "trash", "shoes":
            self.disposalAdvice = "🗑️ LANDFILL\nRegular trash."
            self.statusColor = .gray
        default:
            self.disposalAdvice = "Unknown"
            self.statusColor = .gray
        }
    }
}

#Preview {
    ContentView(previewImage: UIImage(named: "test_garbage2"))
}
