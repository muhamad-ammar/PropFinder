//
//  ImageLoader.swift
//  PropFinder
//
//  Created by Muhammad Ammar on 19/06/2026.
//


import UIKit
import MobileCoreServices

/// A high-performance, thread-safe memory image loader.
/// Senior Detail: Uses NSCache for automated eviction under memory pressure,
/// combined with downsampling techniques to prevent decoded image memory spikes.
final class ImageLoader {
    
    // MARK: - Singleton Instance
    static let shared = ImageLoader()
    
    // MARK: - In-Memory Cache Storage
    /// NSCache is automatically thread-safe and drops its contents when the OS broadcasts a Low Memory warning.
    /// Key: NSURL (standardized string hashing), Value: UIImage
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() {
        // Enforce basic constraints: limit memory usage to a maximum of ~40MB cached elements
        cache.totalCostLimit = 40 * 1024 * 1024
    }
    
    // MARK: - Download and Cache Execution Pipeline
    
    /// Loads an image from a URL, downsamples it to match the display box size, and stores it in the cache.
    /// - Parameters:
    ///   - urlString: The remote string destination.
    ///   - pointSize: The actual physical width/height dimensions of the target UIImageView.
    func loadImage(from urlString: String, targetSize pointSize: CGSize) async -> UIImage? {
        guard let url = URL(string: urlString), let nsURL = NSURL(string: urlString) else { return nil }
        
        // 1. Memory Cache Hit: check if we already processed and cached this image asset
        if let cachedImage = cache.object(forKey: nsURL) {
            return cachedImage
        }
        
        // 2. Cache Miss: Download raw data from network pipeline
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // 3. CRITICAL SENIOR OPTIMIZATION: Downsample the raw data down to display coordinates
            guard let downsampledImage = downsample(imageData: data, to: pointSize, scale: UIScreen.main.scale) else {
                return nil
            }
            
            // 4. Commit downsampled asset to the NSCache bucket
            cache.setObject(downsampledImage, forKey: nsURL)
            return downsampledImage
            
        } catch {
            print("ImageLoader Error: Failed to fetch data stream: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Core Downsampling Engine
    
    /// Downsamples raw image data into a precise thumbnail layout size before decoding occurs.
    /// This keeps the app's memory footprint incredibly small when handling high-res photos.
    private func downsample(imageData: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
            return nil
        }
        
        // Compute pixel layout metrics based on the screen density multiplier scale
        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale
        
        // Configure options to instruct CoreGraphics to decode exactly at our smaller display size bounds
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true, // Decode immediately upon thumbnail creation
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceTypeIdentifierHint: kUTTypeJPEG,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary
        
        guard let downsampledCFImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }
        
        return UIImage(cgImage: downsampledCFImage)
    }
}
