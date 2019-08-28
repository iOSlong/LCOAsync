//
//  ViewController.swift
//  LCOAsync
//
//  Created by xuewu1011@163.com on 08/27/2019.
//  Copyright (c) 2019 xuewu1011@163.com. All rights reserved.
//

import UIKit
import LCOAsync

class ViewController: UIViewController {
    
    var isBlinking = false
    let blinkingLabel = LCLabel(frame: CGRect(x: 10, y: 20, width: 200, height: 30))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.testLCLabel()
        
        self.dispatch_sync_concurrent()
        
    }
    func testLCLabel() {
        // Setup the BlinkingLabel
        blinkingLabel.text = "I blink!"
        blinkingLabel.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(blinkingLabel)
        blinkingLabel.startBlinking()
        isBlinking = true
        
        // Create a UIButton to toggle the blinking
        let toggleButton:UIButton = UIButton(frame: CGRect(x: 10, y: 60, width: 125, height: 30))
        toggleButton.setTitle("Toggle Blinking", for: .normal)
        toggleButton.setTitleColor(.red, for: .normal)
        toggleButton.addTarget(self, action: #selector(toggleBlinking), for: .touchUpInside)
        view.addSubview(toggleButton)
    }
    @objc func toggleBlinking()  {
        print("");
        if (isBlinking) {
            blinkingLabel.stopBlinking()
        } else {
            blinkingLabel.startBlinking()
        }
        isBlinking = !isBlinking
    }
    func appendExcute(taskQueue: ()->Void) {
        print("func begin:\n")
        taskQueue()
        print("func end\n")
    }
    
    func dispatch_sync_concurrent() {
        appendExcute(taskQueue: {
            _ = LCQueueManager.share().dispatch(taskQueue: {
                LCSignTask().excuteTask(task: 1)
            }, type: .Async, mode: .Default)
            _ = LCQueueManager.share().dispatch(taskQueue: {
                LCSignTask().excuteTask(task: 2)
            }, type: .Async, mode: .Globle)
            _ = LCQueueManager.share().dispatch(taskQueue: {
                LCSignTask().excuteTask(task: 3)
            }, type: .Async, mode: .Concurrent)
            let LCQM:LCQueueManager = LCQueueManager.share()
            LCQM.dispatch(taskQueue: {
                LCSignTask().excuteTask(task: 3)
            }, type: .Async, mode: .Globle)
        })
    }
    
}

