//
//  IMLocationMediaItem.swift
//  IMMessagesViewController
//
//  Created by Meniny on 20/08/2015.
//  Copyright (c) 2015 Meniny. All rights reserved.
//

import Foundation
import MapKit

public typealias IMLocationMediaItemCompletionBlock = (() -> Void)

open class IMLocationMediaItem: IMMediaItem, MKAnnotation {

    open var location: CLLocation? {
        
        didSet {
            
            self.set(self.location, completion: nil)
            self.cachedMapImageView = nil
        }
    }
    
    fileprivate var cachedMapSnapshotImage: UIImage?
    fileprivate var cachedMapImageView: UIImageView?
    
    // MARK: - Initialization
    
    public required init() {
        
        super.init()
    }
    
    public required init(location: CLLocation?) {
        
        self.location = location
        self.cachedMapImageView = nil
        
        super.init()
    }
    
    public required init(maskAsOutgoing: Bool) {
        
        super.init(maskAsOutgoing: maskAsOutgoing)
    }
    
    open override var appliesMediaViewMaskAsOutgoing: Bool {
        
        didSet {
            
            self.cachedMapSnapshotImage = nil
            self.cachedMapImageView = nil
        }
    }
    
    override func clearCachedMediaViews() {
        
        super.clearCachedMediaViews()
        
        self.cachedMapImageView = nil
    }
    
    // MARK: - Map snapshot
    
    open func set(_ location: CLLocation?, completion: IMLocationMediaItemCompletionBlock?) {
        
        self.set(location, region: location != nil ? MKCoordinateRegionMakeWithDistance(location!.coordinate, 500, 500) : nil, completion: completion)
    }
    
    func set(_ location: CLLocation?, region: MKCoordinateRegion?, completion: IMLocationMediaItemCompletionBlock?) {
        
        if location != self.location {

            self.location = location?.copy() as? CLLocation
        }

        self.cachedMapSnapshotImage = nil
        self.cachedMapImageView = nil
        
        if let location = location,
            let region = region {

            self.createMapViewSnapshot(location, coordinateRegion: region, completion: completion)
        }
    }
    
    func createMapViewSnapshot(_ location: CLLocation, coordinateRegion region: MKCoordinateRegion, completion: IMLocationMediaItemCompletionBlock?) {
        
        let options = MKMapSnapshotOptions()
        options.region = region
        options.size = self.mediaViewDisplaySize
        options.scale = UIScreen.main.scale
        
        let snapShotter = MKMapSnapshotter(options: options)
        
        snapShotter.start(with: DispatchQueue.global(qos: .default), completionHandler: { (snapshot, error) -> Void in
            
            if error != nil {
                
//                print("\(#function) Error creating map snapshot: \(error)")
                return
            }
            
            let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            var coordinatePoint = snapshot!.point(for: location.coordinate)
            let image: UIImage = snapshot!.image
            
            coordinatePoint.x += pin.centerOffset.x - (pin.bounds.width / 2)
            coordinatePoint.y += pin.centerOffset.y - (pin.bounds.height / 2)
            
            UIGraphicsBeginImageContextWithOptions(image.size, true, image.scale)
            image.draw(at: CGPoint.zero)
            pin.image?.draw(at: coordinatePoint)
            self.cachedMapSnapshotImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            if let completion = completion {
            
                DispatchQueue.main.async(execute: completion)
            }
        })
    }
    
    // MARK: - MKAnnotation
    
    open var coordinate: CLLocationCoordinate2D {
        
        get {
            
            return self.location!.coordinate
        }
    }
    
    // MARK: - IMMessageMediaData protocol
    
    open override var mediaView: UIView? {
        
        get {
            
            if let _ = self.location,
                let cachedMapSnapshotImage = self.cachedMapSnapshotImage {
                    
                if let cachedMapImageView = self.cachedMapImageView {
                 
                    return cachedMapImageView
                }
                    
                let imageView = UIImageView(image: cachedMapSnapshotImage)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                
                IMMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(imageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
                self.cachedMapImageView = imageView
                
                return self.cachedMapImageView
            }
            
            return nil
        }
    }
    
    open override var mediaHash: Int {
        
        get {
            
            return self.hash
        }
    }
    
    // MARK: - NSObject
    
    open override func isEqual(_ object: Any?) -> Bool {
        
        if !super.isEqual(object) {
            
            return false
        }
        
        if let locationItem = object as? IMLocationMediaItem {
            
            if self.location == nil && locationItem.location == nil {
                
                return true
            }
            
            if let location = locationItem.location {
            
                return self.location?.distance(from: location) == 0
            }
        }
        
        return false
    }
    
    open override var hash:Int {
        
        get {
            
            return super.hash^(self.location?.hash ?? 0)
        }
    }
    
    open override var description: String {
        
        get {
            
            let l = self.location != nil ? "\(self.location!)" : "nil"
            return "<\(type(of: self)): location=\(l), appliesMediaViewMaskAsOutgoing=\(self.appliesMediaViewMaskAsOutgoing)>"
        }
    }
    
    // MARK: - NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        self.location = aDecoder.decodeObject(forKey: "location") as? CLLocation
    }
    
    open override func encode(with aCoder: NSCoder) {
        
        super.encode(with: aCoder)
        
        aCoder.encode(self.location, forKey: "location")
    }
    
    // MARK: - NSCopying
    
    open override func copy(with zone: NSZone?) -> Any {
        
        let copy = type(of: self).init(location: self.location)
        copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing
        return copy
    }
}
