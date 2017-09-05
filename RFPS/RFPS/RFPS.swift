//
//  RFPS.swift
//  RToast
//
//  Created by ray on 2017/9/5.
//  Copyright © 2017年 ray. All rights reserved.
//

import UIKit

let fpsLabelTag = 123453

class RFPS: NSObject {

    var fpsLabel:UILabel!
    var displayLink: CADisplayLink!
    var lastTime: TimeInterval = 0
    var count: Int = 0
    var fpsHandler: ((_ fps:Int)->())!
    
    static let shared: RFPS = {
        let shared = RFPS.init()
        return shared
    }()
    
    static public func trackFPS(){
        RFPS.shared.open()
    }
    
    static public func closeFPS(){
        RFPS.shared.close()
    }
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActiveNotification), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
//        使用DisplayLink检测FPS
        displayLink = CADisplayLink.init(target: self, selector: #selector(displayLinkTick(_:)))
        displayLink.isPaused = true
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
//        fspLabel
        fpsLabel = UILabel.init(frame: CGRect.init(x: (UIScreen.main.bounds.width-40)/2+50, y: 0, width: 50, height: 20))
        fpsLabel.font = UIFont.boldSystemFont(ofSize: 12)
        fpsLabel.textColor = UIColor.init(red: 0.33, green: 0.84, blue: 0.43, alpha: 1.0)
        fpsLabel.backgroundColor = UIColor.clear
        fpsLabel.textAlignment = NSTextAlignment.center
        fpsLabel.tag = fpsLabelTag
        
    }
    
    func displayLinkTick(_ link: CADisplayLink) {
        if lastTime == 0 {
            lastTime = link.timestamp
            return
        }
        count = count + 1
        let interval = link.timestamp - lastTime
        if interval < 1 {
            return
        }
        lastTime = link.timestamp
        let fps = Double(count)/interval
        count = 0
        let text = String.init(format: "%d FPS", Int(fps))
        fpsLabel.text = text
        if let tmpHandler = self.fpsHandler {
            tmpHandler(Int(fps))
        }
    }
    
    func open() {
        let rootVCViewSubViews = UIApplication.shared.delegate!.window!?.rootViewController?.view.subviews
        for label in rootVCViewSubViews! {
            if label.isKind(of: UILabel.self) && label.tag == fpsLabelTag {
                return
            }
        }
        displayLink.isPaused = false
        UIApplication.shared.delegate!.window!?.rootViewController?.view.addSubview(fpsLabel)
    }
    
    func open(_ handler: @escaping (_ fps:Int)->()) {
        RFPS.shared.open()
        self.fpsHandler = handler
    }
    
    func close() {
        displayLink.isPaused = true
        let rootVCViewSubViews = UIApplication.shared.delegate!.window!?.rootViewController?.view.subviews
        for label in rootVCViewSubViews! {
            if label.isKind(of: UILabel.self) && label.tag == fpsLabelTag {
                label.removeFromSuperview()
                return
            }
        }
        
    }
    
    func applicationDidBecomeActiveNotification() {
        displayLink.isPaused = false
    }
    
    func applicationWillResignActiveNotification() {
        displayLink.isPaused = true
    }
    
    
    
}
