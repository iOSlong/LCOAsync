//
//  SignViewController.swift
//  LCAsyncExamples
//
//  Created by lxw on 2019/7/30.
//  Copyright © 2019 lxw. All rights reserved.
//

import UIKit
import LCOAsync

class SignViewController: UIViewController {

    var signModel: LCSignModel? = nil
    var selfDispatchModel:Bool? = false
    var queueMode:UISegmentedControl!
    var dispatchType:UISegmentedControl!
    var task1:UIButton!
    var task2:UIButton!
    var task3:UIButton!
    var taskQueueMode:LCQueueMode = .Globle         //default config
    var taskDispatchType:LCDispatchType = .Async    //default config
    
    var ticketSurplusCount = 100;//车票剩余数量。
    var ticketSemaphore:DispatchSemaphore? //售票同步信号。
    
    func loadSegmentsAndIndicatorView() {
        let labelIndicator = UILabel.init(frame: CGRect.init(x: 10, y: 100, width: 150, height: 30));
        labelIndicator.text = "指示旋转标识器："
        self.view.addSubview(labelIndicator)
        let actIV = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        actIV.backgroundColor = .red
        actIV.frame = CGRect.init(x: 60, y: labelIndicator.frame.origin.y + labelIndicator.frame.size.height + 10, width: 100, height: 100)
        self.view.addSubview(actIV)
        actIV.startAnimating()
        
        let labelQueueMode = UILabel.init(frame: CGRect.init(x: 10, y: actIV.frame.origin.y + actIV.frame.size.height + 10, width: 150, height: 20));
        labelQueueMode.text = "选择任务模式："
        self.view.addSubview(labelQueueMode)
    
        queueMode = UISegmentedControl.init(items: ["MainQueue","Default","Globle","Concurrent","Serial"])
        queueMode.frame = CGRect.init(x: 0, y: labelQueueMode.frame.origin.y + labelQueueMode.frame.size.height + 10, width: self.view.frame.size.width, height: 30)
        queueMode.addTarget(self, action: #selector(queueSegmentSelected(seg:)), for: .valueChanged)
        self.view.addSubview(queueMode)
        
        
        let labelDispatchType = UILabel.init(frame: CGRect.init(x: 10, y: queueMode.frame.origin.y + queueMode.frame.size.height + 30, width: 150, height: 20));
        labelDispatchType.text = "选择分派类型："
        self.view.addSubview(labelDispatchType)
        
        dispatchType = UISegmentedControl.init(items: ["sync-同步执行","async - 异步执行"])
        dispatchType.frame = CGRect.init(x: 0, y: labelDispatchType.frame.origin.y + labelDispatchType.frame.size.height + 10, width: self.view.frame.size.width, height: 30)
        dispatchType.addTarget(self, action: #selector(dispatchTypeSegmentSelected(seg:)), for: .valueChanged)
        self.view.addSubview(dispatchType)

        let labelTask = UILabel.init(frame: CGRect.init(x: 10, y: dispatchType.frame.origin.y + dispatchType.frame.size.height + 30, width: 150, height: 20));
        labelTask.text = "点击执行任务："
        self.view.addSubview(labelDispatchType)
        let segBottom = labelTask.frame.origin.y + labelTask.frame.size.height + 20
        let tasks = ["task1","task2","task3"]
        for i in 1...3 {
            let btn = UIButton.init(type: UIButton.ButtonType.roundedRect)
            btn.frame = CGRect.init(x: 10 + (i - 1) * 120, y:Int(segBottom), width: 100, height: 30)
            btn.tag = i;
            btn.setTitle(tasks[i - 1], for: .normal)
            btn.addTarget(self, action: #selector(taskButtonClick(btn:)), for: .touchUpInside)
            self.view.addSubview(btn)
        }
    }
    
    @objc func taskButtonClick(btn:UIButton){
        if btn.tag == 1 {
            print("task 1")
            _ = LCQueueManager.share().dispatch(taskQueue: {
                LCSignTask().excuteTask(task: 1)
            }, type: self.taskDispatchType, mode: self.taskQueueMode)
        }else if btn.tag == 2 {
            print("task 2")
            
        }else if btn.tag == 3 {
            print("task 3")
        }
    }
    
    @objc func queueSegmentSelected(seg:UISegmentedControl) -> Void {
        print(seg.selectedSegmentIndex)
        if seg.selectedSegmentIndex == 0 {
            self.taskQueueMode = .MainQueue
        }else if seg.selectedSegmentIndex == 1 {
            self.taskQueueMode = .Default
        }else if seg.selectedSegmentIndex == 2 {
            self.taskQueueMode = .Globle
        }else if seg.selectedSegmentIndex == 3 {
            self.taskQueueMode = .Concurrent
        }else if seg.selectedSegmentIndex == 4 {
            self.taskQueueMode = .Serial
        }
    }
    
    @objc func dispatchTypeSegmentSelected(seg:UISegmentedControl) -> Void {
        print(seg.selectedSegmentIndex)
        if seg.selectedSegmentIndex == 0 {
            self.taskDispatchType = .Sync
        }else if seg.selectedSegmentIndex == 2 {
            self.taskDispatchType = .Async
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.loadSegmentsAndIndicatorView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let sign:LCSignType = LCSignType(rawValue: signModel!.signType!) ?? LCSignType(rawValue: 1)!
        switch sign {
        case .SyncConcurrent:
            dispatch_sync_concurrent()
        case .AsyncConcurrent:
            dispatch_async_concurrent()
        case .SyncSerial:
            dispatch_sync_serial()
        case .AsyncSerial:
            dispatch_async_serial()
        case .SyncMainQueue:
            dispatch_sync_main()
        case .AsyncMainQueue:
            dispatch_async_main()
        
        case .NestAsynConcurrent:
            dispatch_nest_asyncconcurrent()
        case .Communication:
            dispatch_communication()
        case .BarrierAsync:
            dispatch_barrier_async()
        case .DispatchAfter:
            dispatch_after()
        case .DispatchOnce:
            dispatch_once()
        case .DispatchApply:
            dispatchApply()
            
        case .GroupNotify:
            dispatch_groupNotify()
        case .GroupWait:
            dispatch_groupWait()
        case .GroupEnterLeave:
            dispatch_groupEnterLeave()

        case .SemaphoreSync:
            dispatch_semaphore_sync()
        case .SemaphoreThreadSafe:
            dispatch_semaphore_threadSafe(isSafe: true)
        case .ThreadAsyncNotSafe:
            dispatch_semaphore_threadSafe(isSafe: false)
            
        case .DispatchWorkCancel:
            dispatch_cancel_block()
        case .SyncMainQueueCrash:
            dispatch_sync_main_crash()
        }
    }
    
    func appendExcute(taskQueue: ()->Void) {
        print("func begin:\n")
        taskQueue()
        print("func end\n")
    }
    
    //MARK:- sync-concurrent
    /**
     * sync 同步执行 + 串行队列
     * 特点：不会开启新线程，在当前线程执行任务。任务是串行的，执行完一个任务，再执行下一个任务。
     * 补充：【同步执行(不具备开启新线程能力) + 串行队列(每次只有一个任务被执行，任务一个接一个按顺序执行)】
     * 对于给的2个queue任务，sync方法会将任务同步到主线程顺序执行。
     *
     * 任务按顺序执行的。按顺序执行的原因：虽然并发队列可以开启多个线程，并且同时执行多个任务。但是因为本身不能创建新线程，只有当前线程这一个线程（同步任务不具备开启新线程的能力），所以也就不存在并发。而且当前线程只有等待当前队列中正在执行的任务执行完毕之后，才能继续接着执行下面的操作（同步任务需要等待队列的任务执行结束）。所以任务只能一个接一个按顺序执行，不能同时被执行。
     */
    func dispatch_sync_concurrent() {
        appendExcute(taskQueue: {
            if selfDispatchModel == false {
                for i in 1...2{
                    DispatchQueue(label: "my.testQueue", qos: .userInitiated, attributes: .concurrent).sync {
                        LCSignTask().excuteTask(task:i)
                    }
                }
            }else{
                for i in 1...2{
                    _ = LCQueueManager.share().addDispatch(taskQueue: {
                        LCSignTask().excuteTask(task:i)
                    }, type: .Sync, mode: .Concurrent)
                }
            }
        })
    }
    
    //MARK:- async-concurrent
    /**
     * async 异步执行 + 并发队列
     * 特点：可以开启多个线程，任务交替（同时）执行。
     * 补充：每追加一次任务DispatchQueue.async，都会开辟一个新线程，所以不宜多此追加任务，减少创建线程开销。
     *【异步执行(具备开启新线程能力，不做等待，可以继续执行任务) + 并发队列(可开启多个线程，同时执行多个任务)】
     *
     * async 会根据DispatchQueue属性，如果不存在对应任务队列线程，则开屏新线程执行该任务。
     * 对于给的3个任务，第一个会在主线程执行，使用async不会异步任务不会卡死线程，
     * 它会等待主线程其他优先任务<UI>完成)，
     * 另外两个分别开辟新线程执行。
     */
    func dispatch_async_concurrent() {
        appendExcute(taskQueue: {
            if selfDispatchModel == false {
                DispatchQueue.main.async {
                    LCSignTask().excuteTask(task: 1)
                }
                DispatchQueue.global().async {
                    LCSignTask().excuteTask(task: 2)
                }
                DispatchQueue(label: "my.testQueue", qos: .userInitiated, attributes: .concurrent).async {
                    LCSignTask().excuteTask(task: 3)
                }
            }else{
                _ = LCQueueManager.share().dispatch(taskQueue: {
                    LCSignTask().excuteTask(task: 1)
                }, type: .Async, mode: .MainQueue)
                _ = LCQueueManager.share().dispatch(taskQueue: {
                    LCSignTask().excuteTask(task: 2)
                }, type: .Async, mode: .Globle)
                _ = LCQueueManager.share().dispatch(taskQueue: {
                    LCSignTask().excuteTask(task: 3)
                }, type: .Async, mode: .Concurrent)
            }
        })
    }
    
    //MARK:- sync_serial
    /**
     * 同步执行 + 串行队列
     * 特点：不会开启新线程，在当前线程执行任务。任务是串行的，执行完一个任务，再执行下一个任务。
     * 补充：【同步执行(不具备开启新线程能力) + 串行队列(每次只有一个任务被执行，任务一个接一个按顺序执行)】
     */
    func dispatch_sync_serial() {
        appendExcute(taskQueue: {
            if selfDispatchModel == false {
                for i in 1...2{
                    DispatchQueue(label: "my.testQueue").sync {
                        LCSignTask().excuteTask(task:i)
                    }
                }
            }else{
                for i in 1...2{
                    _ = LCQueueManager.share().addDispatch(taskQueue: {
                        LCSignTask().excuteTask(task:i)
                    }, type: .Sync, mode: .Serial)
                }
            }
        })
    }
    
    //MARK:- async_serial
    /**
     * 异步执行 + 串行队列
     * 特点：会开启新线程，但是因为任务是串行的，执行完一个任务，再执行下一个任务。
     *
     * 补充：只开启一个新线程，后续添加任务都在此新线程所在串型队列中顺序执行【异步执行(具备开启新线程能力) + 串行队列(只开启一个线程)】。
     */
    func dispatch_async_serial() {
        appendExcute(taskQueue: {
            if selfDispatchModel == false {
                let holdDispatch = DispatchQueue(label: "my.testQueue")
                for i in 1...2{
                    holdDispatch.async {
                        LCSignTask().excuteTask(task:i)
                    }
                }
            }else{
                for i in 1...2{
                    _ = LCQueueManager.share().addDispatch(taskQueue: {
                        LCSignTask().excuteTask(task:i)
                    }, type: .Async, mode: .Serial)
                }
            }
        })
    }
    
    
    //MARK:- sync_main
    /**
     * 同步执行 + 主队列
     * 特点(主线程调用)：互等卡主不执行。
     * 特点(其他线程调用)：不会开启新线程，执行完一个任务，再执行下一个任务。
     * [主队列是串行队列，每次只有一个任务被执行，任务一个接一个按顺序执行]
     */
    func dispatch_sync_main() {
        appendExcute(taskQueue: {
            if #available(iOS 10.0, *) {
                Thread.detachNewThread({
                    let currentThread:NSString = Thread.current.description as NSString
                    print("detachNewThread:\(currentThread.substring(from: "<NSThread:".count))") // 打印当前线程
                    if self.selfDispatchModel == false {
                        for i in 1...2{
                            DispatchQueue.main.sync {
                                LCSignTask().excuteTask(task:i)
                            }
                        }
                    }else{
                        for i in 1...2{
                            _ = LCQueueManager.share().addDispatch(taskQueue: {
                                LCSignTask().excuteTask(task:i)
                            }, type: .Sync, mode: .MainQueue)
                        }
                    }
                })
            } else {
                // Fallback on earlier versions
            }
        })
    }
    
    //MARK:- async_main
    /**
     * 异步执行 + 主队列
     * 特点：只在主线程中执行任务，执行完一个任务，再执行下一个任务
     */
    func dispatch_async_main() {
        appendExcute(taskQueue: {
            if selfDispatchModel == false {
                for i in 1...2{
                    DispatchQueue.main.async {
                        LCSignTask().excuteTask(task:i)
                    }
                }
            }else{
                for i in 1...2{
                    _ = LCQueueManager.share().addDispatch(taskQueue: {
                        LCSignTask().excuteTask(task:i)
                    }, type: .Async, mode: .MainQueue)
                }
            }
        })
    }

    
    //MARK:- dispatch_nest_asyncconcurrent
    /**
     * nest_asyncconcurrent 看打印消息可知，只创建了1个新线程。
     */
    func dispatch_nest_asyncconcurrent() {
        appendExcute(taskQueue: {
            if selfDispatchModel == false {
                DispatchQueue.global().async {
                    LCSignTask().excuteTask(task: 2)
                    DispatchQueue(label: "my.testQueue", qos: .userInitiated, attributes: .concurrent).async {
                        LCSignTask().excuteTask(task: 3)
                        DispatchQueue.main.async {
                            LCSignTask().excuteTask(task: 1)
                        }
                    }
                }
            }else{
                _ = LCQueueManager.share().dispatch(taskQueue: {
                    LCSignTask().excuteTask(task: 2)
                    _ = LCQueueManager.share().dispatch(taskQueue: {
                        LCSignTask().excuteTask(task: 3)
                        _ = LCQueueManager.share().dispatch(taskQueue: {
                            LCSignTask().excuteTask(task: 1)
                        }, type: .Async, mode: .MainQueue)
                    }, type: .Async, mode: .Concurrent)
                }, type: .Async, mode: .Globle)
            }
        })
    }
    
    
    
    //MARK:- communication
    /**
     * 线程间通信
     * 可以看到在其他线程中先执行任务，执行完了之后回到主线程执行主线程的相应操作。
     */
    func dispatch_communication() {
        appendExcute(taskQueue: {
            var threadMark:String = "main"
            if selfDispatchModel == false {
                DispatchQueue.global().async {
                    threadMark = "global"
                    print("threadMark:\(threadMark)")
                    LCSignTask().excuteTask(task: 2)
                    DispatchQueue.main.async {
                        threadMark = "main"
                        print("threadMark:\(threadMark)")
                        LCSignTask().excuteTask(task: 1)
                    }
                }
            }else{
                _ = LCQueueManager.share().dispatch(taskQueue: {
                    threadMark = "global"
                    print("threadMark:\(threadMark)")
                    LCSignTask().excuteTask(task: 2)
                    _ = LCQueueManager.share().dispatch(taskQueue: {
                        threadMark = "main"
                        print("threadMark:\(threadMark)")
                        LCSignTask().excuteTask(task: 1)
                    }, type: .Async, mode: .MainQueue)
                }, type: .Async, mode: .Globle)
            }
        })
    }
    
    //MARK:- barrier_async
    /**
     * 栅栏方法 dispatch_barrier_async
     * 在执行完栅栏前面的操作之后，才执行栅栏操作，最后再执行栅栏后边的操作。
     */
    func dispatch_barrier_async(){
        appendExcute(taskQueue: {
            let ocM:LCQueueOCManager = LCQueueOCManager.init()
            ocM.dispatch_barrier_async({
                LCSignTask().excuteTask(task: 1)
            }, barrierTask: {
                LCSignTask().excuteTask(task: 2)
            }, tailTask: {
                LCSignTask().excuteTask(task: 3)
            })
        })
    }
    
    
    //MARK:- dispatch_after
    /**
     * 延时执行方法 dispatch_after
     */
    func dispatch_after(){
        appendExcute(taskQueue: {
            if selfDispatchModel == false {
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 2.0) {
                    LCSignTask().excuteTask(task: 1)
                }
            } else {
                _ = LCQueueManager.share().dispatchAfter(taskQueue: {
                    LCSignTask().excuteTask(task: 2)
                }, mode: .Globle, delayTime: 2.0)
            }
        })
    }
    
    //MARK:- dispatch_once
    /**
     * 一次性代码（只执行一次）dispatch_once,
     * Swift3之后就取消了dispatch_once， 以下once实现，用了static处理。
     */
    func dispatch_once() {
        appendExcute(taskQueue: {
            if self.selfDispatchModel == false {
                for _ in 0...10{
                    struct Holder {
                        static var holder:Holder = Holder()
                        init() {
                            //只执行i==0的一次
                            print("excuteTimes.holder")
                            LCSignTask().excuteTaskMark(task:1)//执行标记
                        }
                    }
                    _ = Holder.holder
                    
                    DispatchQueue.once(token: "extentionOnce", block: {
                        print("excuteTimes.extentionOnce")
                        LCSignTask().excuteTaskMark(task:1)//执行标记
                    })
                }
            } else {
                for times in 0...3{
                    print("cycleindex:\(times)")
                    DispatchQueue.once(token: "extentionOnce", block: {
                        print("extentionOnce: \(times)")
                        let ocM:LCQueueOCManager = LCQueueOCManager.init()
                        for i in 0...10{
                            print("excuteTimes:\(i)")
                            ocM.dispatch_onceTask({
                                //只执行i==0的一次
                                LCSignTask().excuteTaskMark(task: 80)//执行标记
                            })
                        }
                        _ = LCQueueManager.share().dispatch(taskQueue: {
                            LCSignTask().excuteTaskMark(task: 90)//执行标记
                            ocM.dispatch_onceTask({
                                //不会再执行
                                print("excuteTime in LCQueue")
                                LCSignTask().excuteTaskMark(task: 80)//执行标记
                            })
                        }, type: .Async, mode: .Globle)
                    })
                }
            }
        })
    }
    
    //MARK:- dispatch_aplly
    /**
     * 快速迭代方法 dispatch_apply
     * 通常我们会用 for 循环遍历，但是 GCD 给我们提供了快速迭代的函数dispatch_apply。dispatch_apply按照指定的次数将指定的任务追加到指定的队列中，并等待全部队列执行结束。
     *  补充：新建多个线程异步并发执行，线程开销大。
     *
     * dispatch_apply函数是用来循环来执行队列中的任务的。在Swift 3.0里面对这个做了一些优化，使用以下方法：concurrentPerform(iterations:execute:)
     *
     * 特点:1. 如果想要在主线程操作，可以使用同一个队列等待的方式，DISPATCH_QUEUE_SERIAL
     * 补充:2. 如果过使用apply，那么不利用异步线程就显得多余了，所以最好还是利用开辟新线程时候使用。
     */
    func dispatchApply(){
        appendExcute(taskQueue: {
            if self.selfDispatchModel == false {
                DispatchQueue.global().async {
                    DispatchQueue.concurrentPerform(iterations: 3, execute: { (index) in
                        LCSignTask().excuteTask(task: index)
                    })
                }
                DispatchQueue.global().sync {
                    DispatchQueue.concurrentPerform(iterations: 3, execute: { (index) in
                        LCSignTask().excuteTask(task: index + 5)
                    })
                }
                //DispatchQueue.main.async 使用它，会看到有一个任务是在主线程执行,譬如：。
                
            } else {
                _ = LCQueueManager.share().dispatchApply(taskQueue: { (index) in
                    LCSignTask().excuteTask(task: index)
                }, type: .Async, mode: .MainQueue, iterations: 3)
                
                // 会优先执行下面的同步任务Sync，再执行上面👆的异步任务Async。
                _ = LCQueueManager.share().dispatchApply(taskQueue: { (index) in
                    LCSignTask().excuteTask(task: index+5)
                }, type: .Sync, mode: .Globle, iterations: 3)
            }
        })
    }
    
    
    //MARK:- dispatch_group_notify
    /**
     * 队列组 dispatch_group_notify
     *
     */
    func dispatch_groupNotify(){
        appendExcute(taskQueue: {
            if self.selfDispatchModel == false {
                let group = DispatchGroup.init()
                DispatchQueue.global().async(group: group, execute: DispatchWorkItem.init(block: {
                    for i in 1...3 {
                        LCSignTask().excuteTask(task: i)
                    }
                }))
                
                DispatchQueue.main.async(group: group, execute: DispatchWorkItem(block: {
                    for i in 4...5 {
                        LCSignTask().excuteTask(task: i)
                    }
                }))
                
                //上面的👆两个任务执行完之后，执行下面👇的任务：
                group.notify(queue: DispatchQueue.global(), execute: {
                    LCSignTask().excuteTask(task: 80)
                    print("global - group- notiEnd!")
                })
                
                //对比wait， 不会阻塞当前线程：
                LCSignTask().excuteTask(task: 100)
                
                //可以同时存在多个group通知任务。
                group.notify(queue: DispatchQueue.main, execute: {
                    LCSignTask().excuteTask(task: 90)
                    print("main - group- notieEnd!")
                })
            } else {
                _ = LCQueueManager.share().dispatchGroup(groupWorkItem: {
                    for i in 1...3 {
                        LCSignTask().excuteTask(task: i)
                    }
                }, groupMode: .Globle, notiMode: .Globle, notifyHandle: {
                    LCSignTask().excuteTask(task: 90)
                    print("group- notiEnd1 !")
                })
                
                _ = LCQueueManager.share().dispatchGroup(notifyHandle: {
                    LCSignTask().excuteTask(task: 100)
                    print("group- notiEnd2 !")
                },notiMode: .MainQueue)

                // 不同于Wait，与代码书写时序无关，notifyHandle内容始终在group完成后执行。
                _ = LCQueueManager.share().dispatchGroup(groupWorkItem: {
                    for i in 4...6 {
                        LCSignTask().excuteTask(task: i)
                    }
                }, groupMode: .Globle)
            }
        })
    }
    
    //MARK:- dispatch_groupWait
    /**
     * 队列组 dispatch_groupWait
     * wait : 计时等待结束后，返回结果值会告诉是否group所有任务执行性完毕，
     */
    func dispatch_groupWait() {
        appendExcute(taskQueue: {
            if self.selfDispatchModel == false {
                let group = DispatchGroup.init()
                DispatchQueue.global().async(group: group, execute: DispatchWorkItem(block: {
                    for i in 1...3 {
                        LCSignTask().excuteTask(task: i)
                    }
                }))
                let result:DispatchTimeoutResult = group.wait(timeout: DispatchTime.now() + 5.0)
                
                if result == .success {
                    print("wait等待结束，所有任务执行完毕")
                } else {
                    print("wait等待结束，不是所有任务执行完了，group任务会继续执行")
                }
                LCSignTask().excuteTaskMark(task: 100)
            } else {
                _ = LCQueueManager.share().dispatchWaitGroup(groupMode: .Globle, waitTime: 5.0, groupWorkItem: {
                    for i in 1...3 {
                        LCSignTask().excuteTask(task: i)
                    }
                }, waitResult: { (result) in
                    if result == .success {
                        print("wait等待结束，所有任务执行完毕")
                    } else {
                        print("wait等待结束，不是所有任务执行完了，group任务会继续执行")
                    }
                    LCSignTask().excuteTaskMark(task: 90)
                })
                // 下面👇的代码回在wait期间被等待。
                LCSignTask().excuteTaskMark(task: 100)
            }
        })
    }
    
    //MARK:- dispatch_group_enter|leave
    /**
     * 队列组 dispatch_group_enter、dispatch_group_leave
     * 这里的dispatch_group_enter、dispatch_group_leave组合，
     * 其实等同于dispatch_group_async。
     */
    func dispatch_groupEnterLeave(){
        appendExcute(taskQueue: {
            if self.selfDispatchModel == false {
                let group = DispatchGroup.init()
                DispatchQueue.global().async(group: group, execute: DispatchWorkItem(block: {
                    for i in 1...3 {
                        LCSignTask().excuteTask(task: i)
                    }
                }))
                
                //可以同时存在多个group通知任务。
                group.notify(queue: DispatchQueue.main, execute: {
                    LCSignTask().excuteTask(task: 90)
                    print("main - group- notieEnd!")
                })
                
                //Explicitly indicates that a block has entered the group.
                group.enter()
                DispatchQueue.global().sync {
                    LCSignTask().excuteTask(task: 10)
                    //Explicitly indicates that a block in the group has completed.
                    group.leave()
                }
                
                // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
                let result:DispatchTimeoutResult = group.wait(timeout: DispatchTime.distantFuture)
                if result == .success {
                    print("wait等待结束，所有任务执行完毕")
                } else {
                    print("wait等待结束，不是所有任务执行完了，group任务会继续执行")
                }
                LCSignTask().excuteTaskMark(task: 100)
                
                group.notify(queue: DispatchQueue.global(), execute: {
                    LCSignTask().excuteTask(task: 200)
                    print("globle - group- notieEnd!")
                })

            }else {
                //这里使用链式编程，可以方便书写调用。
                _ = LCQueueManager.share().dispatchGroup(groupWorkItem: {
                    for i in 1...3 {
                        LCSignTask().excuteTask(task: i)
                    }
                }, groupMode: .Globle, notiMode: .MainQueue, notifyHandle: {
                    LCSignTask().excuteTask(task: 90)
                    print("main - group- notieEnd!")
                }).dispatchGroupEnter(groupWorkItem: {
                    LCSignTask().excuteTask(task: 10)
                }, groupMode: .Globle, type: .Sync).dispatchWait(waitTime: 100, waitResult: { (result) in
                    if result == .success {
                        print("wait等待结束，所有任务执行完毕")
                    } else {
                        print("wait等待结束，不是所有任务执行完了，group任务会继续执行")
                    }
                    LCSignTask().excuteTaskMark(task: 100)
                }).dispatchGroup(notifyHandle: {
                    LCSignTask().excuteTask(task: 200)
                    print("globle - group- notieEnd!")
                }, notiMode: .Globle)
            }
        })
    }
    
    //MARK: -  dispatch_semaphore_sync
    /**
     * semaphore 线程同步
     */
    func dispatch_semaphore_sync() {
        appendExcute(taskQueue: {
            if self.selfDispatchModel == false {
                DispatchQueue.global().sync {
                    LCSignTask().excuteTaskMark(task: 1)
                    let semaphore = DispatchSemaphore.init(value: 0)
                    var number = 0
                    DispatchQueue.global().async {
                        for i in 2...4 {
                            LCSignTask().excuteTask(task: i)
                        }
                        number = 100
                        semaphore.signal()
                    }
                    //下面👇代码回阻塞当前线程（sync-main），直到semaphore信号传达任务完成。
                    let res = semaphore.wait(timeout: DispatchTime.distantFuture)
                    print("semaphore end, number = \(number)| res=\(res)")
                }

            } else {
                
            }
        })
    }
    
    //MARK: -  dispatch_semaphore_threadSafe
    /**
     * 非线程安全：不使用 semaphore
     * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
     */
    func dispatch_semaphore_threadSafe(isSafe:Bool)  {
        appendExcute(taskQueue: {
            func saleTicket(location:String) {
                while true {
                    if self.ticketSurplusCount > 0 {
                        self.ticketSurplusCount -= 1;
                        LCSignTask().excuteTaskMark(task: "\(location)正卖票，剩余票数：\(self.ticketSurplusCount)")//执行标记
                    }
                    print("\(location)完成一次售票流程)")
                    if  self.ticketSurplusCount == 0 {
                        print("\(location)所有火车票均已售完")
                        break;
                    }
                }
            }
            func saleTicketSafe(location:String)  {
                while true {
                    // begin:相当于加锁等待
                    let res = self.ticketSemaphore?.wait(timeout: .distantFuture);

                    if self.ticketSurplusCount > 0 {
                        self.ticketSurplusCount -= 1;
                        LCSignTask().excuteTaskMark(task: "\(location)正卖票，剩余票数：\(self.ticketSurplusCount)")//执行标记
                    }
                    // end:相当于解锁
                    self.ticketSemaphore?.signal()
                    print("\(location)完成一次售票流程 res\(String(describing: res))")
                    if  self.ticketSurplusCount == 0 {
                        print("\(location)所有火车票均已售完")
                        break;
                    }
                }
            }
            
            func LCQueuSaleTicketSafe(location:String) {
                while true {
                    _ = LCQueueManager.share().atomic(taskQueue: {
                        if self.ticketSurplusCount > 0 {
                            self.ticketSurplusCount -= 1;
                            LCSignTask().excuteTaskMark(task: "\(location)正卖票，剩余票数：\(self.ticketSurplusCount)")//执行标记
                        }
                    })
                    if  self.ticketSurplusCount == 0 {
                        print("\(location)所有火车票均已售完")
                        break;
                    }
                }
            }
            
            if self.selfDispatchModel == false {
                // 注意。value = 1,标识为一次只允许一个线程任务进行访问。
                self.ticketSemaphore = DispatchSemaphore.init(value: 1)
                let queueTW1 = DispatchQueue.main
                let queueTW2 = DispatchQueue.global()
                let queueTW3 = DispatchQueue.init(label: "queue.ticket")
                queueTW1.async {
                    if isSafe == true {
                        saleTicketSafe(location: "北京站");
                    } else {
                        saleTicket(location: "北京站")
                    }
                }
                queueTW2.async {
                    if isSafe == true {
                        saleTicketSafe(location: "毕节站");
                    } else {
                        saleTicket(location: "毕节站")
                    }
                }
                queueTW3.async {
                    if isSafe == true {
                        saleTicketSafe(location: "贵阳站");
                    } else {
                        saleTicket(location: "贵阳站")
                    }
                }
            } else {
                func excuteShorType() {
                    _ = LCQueueManager.share().dispatch(taskQueue: {
                        saleTicket(location: "北京站")
                    }, type: .Async, mode: .MainQueue, atomic: isSafe)
                    
                    _ = LCQueueManager.share().dispatch(taskQueue: {
                        saleTicket(location: "贵阳站")
                    }, type: .Async, mode: .Globle, atomic: isSafe)
                    
                    _ = LCQueueManager.share().dispatch(taskQueue: {
                        saleTicket(location: "毕节站")
                    }, type: .Async, mode: .Concurrent, atomic: isSafe)
                }
                
                func excuteDescType() {
                    _ = LCQueueManager.share().dispatch(taskQueue: {
                        if isSafe == true {
                            LCQueuSaleTicketSafe(location:"北京站")
                        } else {
                            saleTicket(location: "北京站")
                        }
                    }, type: .Async, mode: .MainQueue)
                    
                    _ = LCQueueManager.share().dispatch(taskQueue: {
                        if isSafe == true {
                            LCQueuSaleTicketSafe(location:"贵阳站")
                        } else {
                            saleTicket(location: "贵阳站")
                        }
                    }, type: .Async, mode: .Globle)
                    
                    _ = LCQueueManager.share().dispatch(taskQueue: {
                        if isSafe == true {
                            LCQueuSaleTicketSafe(location:"毕节站")
                        } else {
                            saleTicket(location: "毕节站")
                        }
                    }, type: .Async, mode: .Concurrent)
                }
                
                // 两个函数的执行效果一样的。
                if arc4random()%2 == 2 {
                    excuteShorType();
                }else {
                    excuteDescType();
                }
            }
        })
    }
    
    
    
    
    
    //MARK: -  dispatch_cancel_block
    /**
     * 取消操作使将来执行 dispatch block
     * 对已经在执行的 dispatch block 没有任何影响。
     */
    func dispatch_cancel_block() {
        appendExcute(taskQueue: {
            if self.selfDispatchModel == false {
                let workItem1 = DispatchWorkItem.init {
                    LCSignTask().excuteTask(task: "1")
                }
                let workItem2 = DispatchWorkItem.init {
                    LCSignTask().excuteTask(task: "2")
                }
                let workItem3 = DispatchWorkItem.init {
                    for i in 1...10 {
                        for j in 1...10 {
                            LCSignTask().excuteTask(task: "i(\(i))j(\(j))")
                        }
                    }
                }
                DispatchQueue.global().async(execute: workItem1);
                DispatchQueue.global().async(execute: workItem2);
                workItem2.cancel()//workItem2 如果没有正在执行，调用cancel后它将不再执行。
                
                //workItem3.cancel()//!生效因为workItem3尚未开始执行
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: workItem3);
                let cancelWork = DispatchWorkItem.init(block: {
                    workItem3.cancel()////!不生效， 因为longexcuteblock已经在执行
                })
                // 对已经在执行的 dispatch block 没有任何影响。
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 3.0, execute: cancelWork)
                
            } else {
                
            }
        })
        

    }

    
    
    
    
    
    //MARK: - 主线程 同步任务 互等崩溃
    /**
     * 奔溃信息: Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
     * 这是因为我们在主线程中执行syncMain方法，相当于把syncMain任务放到了主线程的队列中。而同步执行会等待当前队列中的任务执行完毕，才会接着执行。那么当我们把任务1追加到主队列中，任务1就在等待主线程处理完syncMain任务。而syncMain任务需要等待任务1执行完毕，才能接着执行。
     *
     *   解决线程等待问题方法：参考 dispatch_sync_main(),利用detachNewThread将任务异步到主线程。
     */
    func dispatch_sync_main_crash() {
        appendExcute(taskQueue: {
            if self.selfDispatchModel == false {
                DispatchQueue.main.sync {
                    LCSignTask().excuteTask(task:1)
                }
                
                DispatchQueue.main.sync {
                    DispatchQueue.concurrentPerform(iterations: 5, execute: { (index) in
                        LCSignTask().excuteTask(task: index)
                    })
                }
                
            }else{
                _ = LCQueueManager.share().addDispatch(taskQueue: {
                    LCSignTask().excuteTask(task:1)
                }, type: .Sync, mode: .MainQueue)
                
                _ = LCQueueManager.share().dispatchApply(taskQueue: { (index) in
                    LCSignTask().excuteTask(task: index)
                }, type: .Sync, mode: .MainQueue, iterations: 5)
            }
        })
    }
}

