//
//  mainThreadChecker.swift
//  Webarator
//
//  Created by Vít Míchal on 11.02.16.
//  Copyright © 2016 Vít Míchal. All rights reserved.
//

import Foundation

/*runThisInMainThread { () -> Void in
    runThisInMainThread { () -> Void in
        // No problem
    }
}*/

func runThisInMainThread(block: dispatch_block_t) {
    dispatch_async(dispatch_get_main_queue(), block)
}