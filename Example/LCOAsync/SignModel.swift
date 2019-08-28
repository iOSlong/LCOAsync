//
//  SignModel.swift
//  LCAsyncExamples
//
//  Created by lxw on 2019/7/30.
//  Copyright © 2019 lxw. All rights reserved.
//

import Foundation
import HandyJSON

enum LCSignType:NSNumber {
    case SyncConcurrent             = 1
    case AsyncConcurrent            = 2
    case SyncSerial                 = 3
    case AsyncSerial                = 4
    case SyncMainQueue              = 5
    case AsyncMainQueue             = 6
    case NestAsynConcurrent         = 7
    
    case Communication              = 8
    case BarrierAsync               = 9
    case DispatchAfter              = 10
    case DispatchOnce               = 11
    case DispatchApply              = 12
    
    case GroupNotify                = 13
    case GroupWait                  = 14
    case GroupEnterLeave            = 15
    
    case SemaphoreSync              = 16
    case SemaphoreThreadSafe        = 17
    case ThreadAsyncNotSafe         = 18

    case DispatchWorkCancel         = 19
    
    case SyncMainQueueCrash         = 20

}


class LCSignModel :HandyJSON {
    var signType:NSNumber?      = nil
    var signName:String?        = nil
    var signDesc:String?        = nil
    required init() { }
}


