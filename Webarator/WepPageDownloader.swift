//
//  WepPageDownloader.swift
//  SpeakToMe
//
//  Created by Vít Míchal on 15.03.15.
//  Copyright (c) 2015 Vít Míchal. All rights reserved.
//

import Foundation


private let _WebPageDownloaderSharedInstance = WebPageDownloader()

class WebPageDownloader {
    class var sharedInstance: WebPageDownloader {
        return _WebPageDownloaderSharedInstance
    }

    func getPageContent(urlAsString: String, callBack: (String) -> () ) {
        
        /* Construct the URL and the request to send to the connection */
        let url = NSURL(string: urlAsString)
        let urlRequest = NSURLRequest(URL: url!)
        
        /* We will do the asynchronous request on our own queue */
        let queue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest,
            queue: queue,
            completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) in
                
                /* Now we may have access to the data but check if an error came back
                first or not */
                print("response length: \(data!.length), error:\(error)");

                if data!.length > 0 && error == nil {
                    let dataStr: String = NSString(data:data!, encoding:NSUTF8StringEncoding)! as String;                    callBack( dataStr );
                    
                } else if data!.length == 0 && error == nil{
                    print("Nothing was downloaded")
                } else if error != nil {
                    print("Error happened = \(error);")
                }
                
        })
    }
}