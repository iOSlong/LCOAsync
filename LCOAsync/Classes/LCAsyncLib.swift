//
//  LCAsyncLib.swift
//  LCAsync
//
//  Created by lxw on 2019/7/12.
//  Copyright © 2019 lxw. All rights reserved.
//


import Foundation

public enum LCDispatchType:Int {
    case Sync
    case Async
}

public enum LCQueueMode:Int {
    case MainQueue   = 1
    case Default     = 2
    case Globle      = 3
    case Concurrent  = 5
    case Serial      = 4
}

public class LCQueueManager {
    // MARK: - Properties
    private static var manager : LCQueueManager = {
       let manager = LCQueueManager()
        // Configuration
        // ...
        return manager
    }()
    
    
    // MARK: -
    let name: String
    var holdGroup:DispatchGroup
    var semaphore:DispatchSemaphore?
    private init(name:String = "lcqueue"){
        self.name = name
        self.holdGroup = DispatchGroup.init()
        // 注意。value = 1,标识为一次只允许一个线程任务进行访问。
        self.semaphore = DispatchSemaphore.init(value: 1);
    }
    
    
    // MARK: - Accessors

    public class func share() -> LCQueueManager {
        return manager
    }
    
    public func addQueue(queueModel:LCQueueMode) -> DispatchQueue  {
        switch queueModel {
        case .MainQueue:
            return DispatchQueue.main
        case .Concurrent:
            struct Holder {
                static var  queue = DispatchQueue.init(label: "queue.concurrent")
            }
            return Holder.queue
        case .Serial:
            struct Holder {
                static var queue = DispatchQueue.init(label: "queue.serial")
            }
            return Holder.queue
        case .Default:
            struct Holder {
                static var queue = DispatchQueue.global()
            }
            return Holder.queue
        case .Globle:
            struct Holder {
                static var queue = DispatchQueue.global()
            }
            return Holder.queue
        }
    }
    
    // create new DispatchQueue every time called.
    public func queue(queueModel:LCQueueMode) -> DispatchQueue {
        var queue:DispatchQueue? = nil
        switch queueModel {
        case .MainQueue:
            queue = DispatchQueue.main
            break
        case .Concurrent:
            queue = DispatchQueue.init(label: "queue.concurrent")
            break
        case .Serial:
            queue = DispatchQueue.init(label: "queue.serial")
            break
        case .Default:
            queue = DispatchQueue.global()
            break
        case .Globle:
            queue = DispatchQueue.global()
        }
        return queue!
    }
    
    public func atomic(taskQueue:()->Void) -> LCQueueManager {
        _ = self.semaphore?.wait(timeout: .distantFuture)
        taskQueue()
        self.semaphore?.signal()
        return self
    }
    
    public func dispatch(taskQueue : @escaping ()->Void, type : LCDispatchType,mode : LCQueueMode, atomic:Bool) -> DispatchQueue {
        let dispatchQueue = queue(queueModel: mode)
        switch type {
        case .Async: do {
            if atomic == true {
                _ = self.atomic(taskQueue: taskQueue);
            }else {
                dispatchQueue.async(execute: taskQueue)
            }
        }
            break
        case .Sync: do {
            if atomic == true {
                _ = self.atomic(taskQueue: taskQueue);
            }else {
                dispatchQueue.sync(execute: taskQueue)
            }
        }
            break
        }
        return dispatchQueue
    }
    
    public func dispatch(taskQueue : @escaping ()->Void, type : LCDispatchType,mode : LCQueueMode) -> DispatchQueue {
        let dispatchQueue = queue(queueModel: mode)
        switch type {
        case .Async:
            dispatchQueue.async(execute: taskQueue)
            break
        case .Sync:
            dispatchQueue.sync(execute: taskQueue)
            break
        }
        return dispatchQueue
    }
    
    public func addDispatch(taskQueue : @escaping ()->Void, type : LCDispatchType,mode : LCQueueMode) -> LCQueueManager {
        let dispatchQueue = addQueue(queueModel: mode)
        switch type {
        case .Async:
            dispatchQueue.async(execute: taskQueue)
            break
        case .Sync:
            dispatchQueue.sync(execute: taskQueue)
            break
        }
        return self
    }
    
    public func dispatchAfter(taskQueue : @escaping ()->Void, mode : LCQueueMode, delayTime:Double) -> LCQueueManager {
        let dispatchQueue = queue(queueModel: mode)
        let dispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(delayTime * 1000.0))
            dispatchQueue.asyncAfter(deadline: dispatchTime, execute: taskQueue)
        return self
    }
    
    public func dispatchApply(taskQueue :@escaping (_ index:Int)->Void,type : LCDispatchType,mode : LCQueueMode, iterations:Int) -> LCQueueManager {
        let dispatchQueue = queue(queueModel: mode)
        switch type {
        case .Async:
            dispatchQueue.async {
                DispatchQueue.concurrentPerform(iterations: iterations, execute: taskQueue)
            }
            break
        case .Sync:
            dispatchQueue.sync {
                DispatchQueue.concurrentPerform(iterations: iterations, execute: taskQueue)
            }
            break
        }
        return self
    }
    
    public func dispatchGroup(groupWorkItem:@escaping ()->Void, groupMode : LCQueueMode,notiMode : LCQueueMode, notifyHandle:@escaping ()->Void) -> LCQueueManager  {
        let dispatchQueue = queue(queueModel: groupMode)
        let notifyQueue = queue(queueModel: notiMode)
        dispatchQueue.async(group: holdGroup, execute: DispatchWorkItem(block:groupWorkItem))
        holdGroup.notify(queue: notifyQueue, execute: notifyHandle)
        return self
    }
    
    public func dispatchGroup(groupWorkItem:@escaping ()->Void, groupMode : LCQueueMode) -> LCQueueManager {
        let dispatchQueue = queue(queueModel: groupMode)
        dispatchQueue.async(group: holdGroup, execute: DispatchWorkItem(block:groupWorkItem))
        return self
    }
    
    public func dispatchGroupEnter(groupWorkItem:@escaping ()->Void,groupMode : LCQueueMode, type: LCDispatchType) -> LCQueueManager {
        holdGroup.enter()
        let dispatchQueue = queue(queueModel: groupMode)
        switch type {
        case .Async:
            dispatchQueue.async {
                groupWorkItem()
                self.holdGroup.leave()
            }
        case .Sync:
            dispatchQueue.sync {
                groupWorkItem()
                holdGroup.leave()
            }
        }
        return self
    }
    
    public func dispatchGroup(notifyHandle:@escaping ()->Void,notiMode : LCQueueMode) -> LCQueueManager {
        let notifyQueue = queue(queueModel: notiMode)
        holdGroup.notify(queue: notifyQueue, execute: notifyHandle)
        return self
    }
    
    public func dispatchWait(waitTime:Double, waitResult:(_ result:DispatchTimeoutResult)->Void) -> LCQueueManager {
        let timeout = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(waitTime * 1000.0))
        let result:DispatchTimeoutResult = holdGroup.wait(timeout:timeout)
        waitResult(result)
        return self
    }
    
    public func dispatchWaitGroup(groupMode:LCQueueMode, waitTime:Double, groupWorkItem: @escaping ()->Void, waitResult:(_ result:DispatchTimeoutResult)->Void) -> LCQueueManager {
        let dispatchQueue = queue(queueModel: groupMode)
        let timeout = DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(waitTime * 1000.0))
        dispatchQueue.async(group: holdGroup, execute: DispatchWorkItem(block: groupWorkItem))
        let result:DispatchTimeoutResult = holdGroup.wait(timeout:timeout)
        waitResult(result)
        return self
    }
}




public class LCSignTask: NSObject {
    public func excuteTask(task : Any)  {
        for _  in 0...1 {
            self.excuteTaskMark(task: task)
            print("sleep 2.0f\n")
            Thread.sleep(forTimeInterval: 2.0)              // 模拟耗时操作
        }
    }
    public func excuteTaskMark(task:Any)  {
        let currentThread:NSString = Thread.current.description as NSString
        print("task:\(task) in thread:\(currentThread.substring(from: "<NSThread:".count))") // 打印当前线程
    }
    
    func queueTasks(_ taskNumberBegin:Int, _ taskNumberEnd:Int, queue : DispatchQueue, type : LCDispatchType) -> Void {
        for task in taskNumberBegin...taskNumberEnd {
            switch type{
            case .Sync:
                queue.sync {
                    excuteTask(task: task)
                }
            case .Async:
                queue.async {
                    self.excuteTask(task: task)
                }
            }
        }
    }
    
    func syncQueueTasks(_ taskNumberEnd:Int, queue : DispatchQueue) -> Void {
        queueTasks(1, taskNumberEnd, queue: queue, type:.Sync)
    }
    
    func asyncQueueTasks(_ taskNumberEnd:Int, queue : DispatchQueue) -> Void {
        queueTasks(1, taskNumberEnd, queue: queue, type:.Async)
    }
}


public extension DispatchQueue {
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    class func once(token: String, block:()->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
}



public final class SwiftyLib {
    
    let name = "SwiftyLib"
    
    public func add(a: Int, b: Int) -> Int {
        return a + b
    }
    
    public func sub(a: Int, b: Int) -> Int {
        return a - b
    }
    
}
