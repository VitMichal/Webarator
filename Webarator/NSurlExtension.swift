//
//  NSurlExtension.swift
//  SpeakToMe
//
//  Created by Vít Míchal on 16.03.15.
//  Copyright (c) 2015 Vít Míchal. All rights reserved.
//

import Foundation


extension NSURL{
    /* An extension on the NSURL class that allows us to retrieve the current
    documents folder path */
    class func documentsFolder() -> NSURL{
        let fileManager = NSFileManager()
        return try! fileManager.URLForDirectory(.DocumentDirectory,
            inDomain: .UserDomainMask,
            appropriateForURL: nil,
            create: false)
    }
}
