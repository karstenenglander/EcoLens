# Developer Instructions and Operational Guide

This document outlines the technical procedures for setting up the EcoLens development environment, retraining the machine learning model, and deploying updates to the iOS application.

## 1. Machine Learning Environment Setup

The model training pipeline relies on Python and PyTorch. It is recommended to run these scripts in a virtual environment to manage dependencies effectively.

### 1.1 Prerequisites
*   Python 3.8 or higher
*   pip (Python Package Installer)
*   Virtualenv or Conda (Optional but recommended)

### 1.2 Configuration
1.  **Navigate to the training directory:**
    ```bash
    cd Model_Training
    ```

2.  **Create and activate a virtual environment:**
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```

3.  **Install dependencies:**
    ensure the `requirements.txt` file is present, then execute:
    ```bash
    pip install -r requirements.txt
    ```

### 1.3 Model Retraining
To modify or improve the classification model:

1.  Launch the Jupyter Notebook environment:
    ```bash
    jupyter notebook
    ```
2.  Open `EcoLens_Training.ipynb`.
3.  Execute the cells sequentially. The script handles:
    *   Dataset augmentation and normalization.
    *   Downloading the pre-trained MobileNetV2 weights.
    *   Fine-tuning the model on the garbage classification dataset.
    *   Exporting the model as `EcoLensClassifier.mlpackage`.

**Note:** The export step uses `coremltools` to convert the PyTorch model to CoreML format. Ensure the metadata (author, version, description) is updated in the export cell before running.

---

## 2. iOS Application Configuration

### 2.1 Project Dependencies
The iOS project utilizes standard Apple frameworks (SwiftUI, CoreML, Vision, AVFoundation) and does not require external CocoaPods or Swift Package Manager dependencies.

### 2.2 Integration of the ML Model
If the model has been retrained, the updated artifact must be imported into Xcode:

1.  Locate the generated `EcoLensClassifier.mlpackage` in the `Model_Training` directory.
2.  Drag and drop the file into the `Models` group within the Xcode Project Navigator.
3.  Ensure "Copy items if needed" is checked and the "EcoLens" target is selected.
4.  **Verification:** Click on the model file in Xcode. The "Model Class" section should show an automatically generated Swift class named `EcoLensClassifier`.

### 2.3 Info.plist Configuration
The application requires access to the camera hardware. The `Info.plist` file must contain the following key:
*   **Key:** `Privacy - Camera Usage Description`
*   **Value:** "EcoLens requires camera access to analyze waste items in real-time."

### 2.4 Code Signing
To deploy to a physical device (required for camera testing):

1.  Select the **EcoLens** project in the Project Navigator.
2.  Select the main **Target**.
3.  Navigate to the **Signing & Capabilities** tab.
4.  Ensure a valid **Team** is selected.
5.  Ensure the **Bundle Identifier** is unique to your development team.

---

## 3. Operational Usage

### 3.1 Device Deployment
1.  Connect the iOS device via USB.
2.  Unlock the device.
3.  In Xcode, select the device from the Scheme menu (top bar).
4.  Press **Cmd + R** to build and run.

### 3.2 Troubleshooting Common Issues

**Issue: "Signing for EcoLens requires a development team"**
*   **Resolution:** Navigate to project settings and select your personal Apple ID under the "Team" dropdown.

**Issue: Application crashes immediately upon launch**
*   **Resolution:** Verify that `Privacy - Camera Usage Description` is correctly set in `Info.plist`. iOS terminates apps that attempt to access hardware without declared permission strings.

**Issue: Model prediction is always "Unknown" or low confidence**
*   **Resolution:** Ensure the input image is handled correctly in `CameraViewController.swift`. The Vision request expects the image orientation to match the device orientation.

---

## 4. Maintenance

### Updating Class Labels
If the training dataset classes change:
1.  Update the `class_labels.json` in the training directory.
2.  Retrain the model.
3.  Update the `ClassificationService.swift` file in the iOS project to map the new model output indices to the correct UI strings.
