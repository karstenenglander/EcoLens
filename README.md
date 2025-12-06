# EcoLens: Waste Classification via Computer Vision

![Swift Version](https://img.shields.io/badge/Swift-5.0-orange)
![Platform](https://img.shields.io/badge/Platform-iOS_16.0+-lightgrey)
![License](https://img.shields.io/badge/License-MIT-blue)

## Overview
EcoLens is an iOS application utilizing machine learning to facilitate sustainable waste management. By leveraging the Apple Neural Engine and the Vision framework, the application performs real-time classification of waste items into three distinct categories: Recycling, Compost, and Landfill. The system is designed with a privacy-centric architecture, performing all inference on-device without external network dependencies for image processing.

## Key Features
*   **Real-Time Inference:** Utilizes a custom CameraController to analyze video frames instantaneously using CoreML.
*   **On-Device Processing:** Ensures user privacy and offline functionality by processing all data locally on the iOS device.
*   **Material Classification:** Identifies 12 distinct material classes (including glass, biological, paper, and metal) and maps them to appropriate disposal streams.
*   **Photo Library Integration:** Allows users to analyze static images imported from the native iOS photo gallery.

## Technical Architecture

### iOS Application
*   **Language:** Swift 5
*   **UI Framework:** SwiftUI
*   **Inference Engine:** CoreML
*   **Camera Handling:** AVFoundation (Custom implementation)
*   **Concurrency:** Grand Central Dispatch (GCD) for non-blocking UI updates

### Machine Learning Pipeline
*   **Architecture:** MobileNetV2 (Transfer Learning)
*   **Framework:** PyTorch
*   **Optimization:** Stochastic Gradient Descent (SGD)
*   **Model Conversion:** `coremltools` (PyTorch to CoreML conversion with localized probability mapping)
*   **Dataset:** Standardized Garbage Classification Dataset (15,000+ labeled images)

## Repository Structure
This repository follows a monorepo structure containing both the iOS source code and the machine learning development environment.
