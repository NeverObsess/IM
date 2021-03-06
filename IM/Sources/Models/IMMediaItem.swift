//
//  IMMediaItem.swift
//  IMMessagesViewController
//
//  Created by Meniny on 19/08/2015.
//  Copyright (c) 2015 Meniny. All rights reserved.
//

import UIKit

open class IMMediaItem: NSObject, IMMessageMediaData, NSCoding, NSCopying {

    var cachedPlaceholderView: UIView?
    
    open var appliesMediaViewMaskAsOutgoing: Bool = true {
        
        didSet {
            
            self.cachedPlaceholderView = nil
        }
    }
    
    public override required init() {
        
        super.init()
        
        self.appliesMediaViewMaskAsOutgoing = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(IMMediaItem.didReceiveMemoryWarningNotification(_:)), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    public required init(maskAsOutgoing: Bool) {
    
        super.init()
        
        self.appliesMediaViewMaskAsOutgoing = maskAsOutgoing

        NotificationCenter.default.addObserver(self, selector: #selector(IMMediaItem.didReceiveMemoryWarningNotification(_:)), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)

        self.cachedPlaceholderView = nil
    }
    
    func clearCachedMediaViews() {
        
        self.cachedPlaceholderView = nil
    }
    
    // MARK: - Notifications
    
    func didReceiveMemoryWarningNotification(_ notification: Notification) {
        
        self.clearCachedMediaViews()
    }
    
    // MARK: - IMMessageMediaData protocol
    
    open var mediaView: UIView? {
        
        get {
            print("Error! required method not implemented in subclass. Need to implement \(#function)")
            abort()
        }
    }
    
    open var mediaViewDisplaySize: CGSize {
        
        get {
            
            if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                
                return CGSize(width: 315, height: 225)
            }
            return CGSize(width: 210, height: 150)
        }
    }
    
    open var mediaPlaceholderView: UIView {
        
        get {
    
            if let cachedPlaceholderView = self.cachedPlaceholderView {
                
                return cachedPlaceholderView
            }
            
            let size = self.mediaViewDisplaySize
            let view = IMMessagesMediaPlaceholderView.viewWithActivityIndicator()
            view.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            IMMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(view, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            
            self.cachedPlaceholderView = view
            
            return view
        }
    }
    
    open var mediaHash: Int {
    
        get {
        
            return self.hash
        }
    }
    
    // MARK: - NSObject
    
    open override func isEqual(_ object: Any?) -> Bool {
        
        if !(object! as AnyObject).isKind(of: type(of: self)) {
            
            return false
        }
        
        if let item = object as? IMMediaItem {
            
            return self.appliesMediaViewMaskAsOutgoing == item.appliesMediaViewMaskAsOutgoing
        }
        
        return false
    }
    
    open override var hash:Int {

        get {

            return NSNumber(value: self.appliesMediaViewMaskAsOutgoing as Bool).hash
        }
    }
    
    open override var description: String {
        
        get {
            
            return "<\(type(of: self)): appliesMediaViewMaskAsOutgoing=\(self.appliesMediaViewMaskAsOutgoing)>"
        }
    }
    
    func debugQuickLookObject() -> AnyObject? {
        
        return self.mediaPlaceholderView
    }
    
    // MARK: - NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        
        super.init()
        
        self.appliesMediaViewMaskAsOutgoing = aDecoder.decodeBool(forKey: "appliesMediaViewMaskAsOutgoing")
    }
    
    open func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.appliesMediaViewMaskAsOutgoing, forKey: "appliesMediaViewMaskAsOutgoing")
    }
    
    // MARK: - NSCopying
    
    open func copy(with zone: NSZone?) -> Any {
        
        return type(of: self).init(maskAsOutgoing: self.appliesMediaViewMaskAsOutgoing)
    }
}
