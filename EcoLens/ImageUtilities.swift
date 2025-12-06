//
//  ImageUtilities.swift
//  EcoLens
//
//  Created by Karsten Englander on 12/6/25.
//

import UIKit
import AVFoundation

func cropImage(_ original: UIImage, toRect highlightRect: CGRect, inView viewSize: CGSize) -> UIImage? {
    
    // 1. Calculate the scale and position of the image as displayed on screen (Aspect Fit)
    let imageRatio = original.size.width / original.size.height
    let viewRatio = viewSize.width / viewSize.height
    
    var scale: CGFloat = 1.0
    var offsetX: CGFloat = 0.0
    var offsetY: CGFloat = 0.0
    
    if imageRatio > viewRatio {
        scale = viewSize.width / original.size.width
        let displayedHeight = original.size.height * scale
        offsetX = 0
        offsetY = (viewSize.height - displayedHeight) / 2.0
    } else {
        scale = viewSize.height / original.size.height
        let displayedWidth = original.size.width * scale
        offsetX = (viewSize.width - displayedWidth) / 2.0
        offsetY = 0
    }
    
    // 2. Adjust the drawn Highlight Rect to remove the "Black Bars" (Offsets)
    let adjustedX = highlightRect.origin.x - offsetX
    let adjustedY = highlightRect.origin.y - offsetY
    
    // 3. Scale up to original Image Pixel Coordinates
    let cropX = adjustedX / scale
    let cropY = adjustedY / scale
    let cropW = highlightRect.width / scale
    let cropH = highlightRect.height / scale
    
    // 4. Create the pixel-based rect
    let finalRect = CGRect(
        x: max(0, cropX),
        y: max(0, cropY),
        width: min(original.size.width - max(0, cropX), cropW),
        height: min(original.size.height - max(0, cropY), cropH)
    )
    
    guard finalRect.width > 0 && finalRect.height > 0 else { return nil }
    
    // 5. Perform Crop
    guard let cgImage = original.cgImage?.cropping(to: finalRect) else { return nil }
    
    return UIImage(cgImage: cgImage, scale: original.scale, orientation: original.imageOrientation)
}
