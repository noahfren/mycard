//
//  ImageManager.swift
//  mycard
//
//  Created by Noah Frenkel on 7/18/16.
//  Copyright © 2016 Noah Frenkel. All rights reserved.
//

import Foundation
import UIKit


// String extension to get stringByAddingPathComponent from NSString
extension String {
    func stringByAppendingPathComponent(pathComponent: String) -> String {
        return (self as NSString).stringByAppendingPathComponent(pathComponent)
    }
}

// UIImage Extension to make circular images and square images
extension UIImage {
    var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .ScaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.renderInContext(context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    var square: UIImage? {
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = size.width
        var cgheight: CGFloat = size.height
        
        // See what size is longer and create the center off of that
        if size.width > size.height {
            posX = ((size.width - size.height) / 2)
            posY = 0
            cgwidth = size.height
            cgheight = size.height
        } else {
            posX = 0
            posY = ((size.height - size.width) / 2)
            cgwidth = size.width
            cgheight = size.width
        }
        
        let rect = CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef = CGImageCreateWithImageInRect(CGImage, rect)
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let result = UIImage(CGImage: imageRef!, scale: scale, orientation: imageOrientation)
        
        return result
    }
    
    var resizeForPreview: UIImage? {
        
        let previewSize = CGSize(width: 200, height: 200)
        return ImageHelper.resizeImage(self.square!, targetSize: previewSize)
    }
}

class ImageHelper {
    
    // Function that returns path to filesystem for saving images
    static func getImageDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let imageDirectory = paths[0]
        return imageDirectory
    }
    
    static func getImageDirectory(withFileName nameWithExtension: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let imageDirectory = paths[0]
        return imageDirectory.stringByAppendingPathComponent(nameWithExtension)
    }
    
    // Function takes name and image data and saves image as jpeg to application sandbox
    static func saveImageAsJPEG(nameWithExtension: String, image: UIImage) {
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            let filename = getImageDirectory().stringByAppendingPathComponent(nameWithExtension)
            data.writeToFile(filename, atomically: true)
        }
    }
    
    static func imageToNSData(imageDirectory: String) -> NSData {
        if let image = UIImage(contentsOfFile: imageDirectory) {
            return NSKeyedArchiver.archivedDataWithRootObject(image)
        }
        else {
            return NSKeyedArchiver.archivedDataWithRootObject(UIImage(named: "defaultUser")!.circle!)
        }
    }
    
    static func dataToImage(data: NSData) -> UIImage {
        let dictionary = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Dictionary<String, AnyObject>
        let imageData = dictionary["imageData"] as! NSData
        return NSKeyedUnarchiver.unarchiveObjectWithData(imageData) as! UIImage
    }

    static func randomImageFileName() -> String {
        
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.characters.count)
        var randomString = ""
        
        for _ in (0..<32) {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
            randomString += String(newCharacter)
        }
        randomString += ".jpeg"
        
        return randomString
    }
    
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}