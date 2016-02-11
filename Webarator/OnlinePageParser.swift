//
//  OnlinePageParser.swift
//  SpeakToMe
//
//  Created by Vít Míchal on 16.03.15.
//  Copyright (c) 2015 Vít Míchal. All rights reserved.
//
import Foundation

private let _OnlinePageParserSharedInstance = OnlinePageParser()



public class OnlinePageParser {
    
    var succCallBack: ((NSDictionary) -> ())? = nil
    var errorCallBack: ((NSString) ->())? = nil
    var emptyCallBack: ((NSString)->())? = nil
    
    class var sharedInstance: OnlinePageParser {
        return _OnlinePageParserSharedInstance
    }
    
    
    func getPageContent( urlAsString: String, callBack: (NSDictionary) -> (), newErrorCallBack:(NSString) ->(), newEmptyCallBack: (NSString)->() ) {
        print("getPageContent")
        succCallBack = callBack;
        errorCallBack = newErrorCallBack
        emptyCallBack = newEmptyCallBack
        
        /* Construct the URL and the request to send to the connection */
        let url = NSURL(string: "https://decisive-coder-88617.appspot.com")
        let urlRequest = NSMutableURLRequest(URL: url!)
        
        let bodyData = "url=\(urlAsString)"
        urlRequest.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        urlRequest.HTTPMethod = "POST"
        
        /* We will do the asynchronous request on our own queue */
        let queue = NSOperationQueue()
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: queue, completionHandler: completitionHandler)
        
        
    }
    
    func completitionHandler(response: NSURLResponse?, data: NSData?, error: NSError?) {
        /* Now we may have access to the data but check if an error came back first or not */
        print("data \(data)", terminator: "")
        
        if data != nil && data!.length > 0 && error == nil { // server returned some data
            
            // is it JSON ??
            do {
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                print("xxxdata \(jsonDict)")
                let sr = try ServerResponse(json: jsonDict)

                let responseData = sr.getArticle(errorCallBack!, emptyHanlder: emptyCallBack!)
                print("data \(jsonDict)", terminator: "")
                print("responseData \(responseData)", terminator: "")

                if responseData != nil {
                    succCallBack!( responseData! );
                    
                }
                
            } catch let jsonError as NSError {
                print("error by NSError")
                errorCallBack!(jsonError.localizedDescription)
            
            } catch _ as ServerResponseError {
                print("error by exception")
                emptyCallBack!("no_response")
            }
        
        
        } else if data == nil && error == nil { // no data arrived
            print("error by data nil")
            errorCallBack!("no_response")
        } else if error != nil { // some other error occured
            print("error by another NSError")
            let message = error!.localizedDescription
            errorCallBack!(message as NSString)
        }
        
    }
}


