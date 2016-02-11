//
//  ServerResponse.swift
//  SpeakToMe
//
//  Created by Vít Míchal on 21.03.15.
//  Copyright (c) 2015 Vít Míchal. All rights reserved.
//

import Foundation

enum ServerResponseError : ErrorType {
    case NoData
}

public class ServerResponse {
    private var status: [String:String]
    private var data: NSDictionary
    
    init(json: NSDictionary) throws {
        do {
            self.status = json.valueForKey("status") as! Dictionary
            self.data = NSDictionary()

            
            if let data = json.valueForKey("data") as? NSDictionary {
                self.data = data
            } else {
                throw ServerResponseError.NoData
            }
            
            
        }
    }
    
    func getArticle(errorHandler: (message: NSString) -> (), emptyHanlder: ( message: NSString)->() ) -> NSDictionary? {
        print("data \(data)")
        
        let code = status["code"]! as String
        print("code \(code)", terminator: "")
        let message = status["message"]! as String
        
        print("message \(message)", terminator: "")
        if code != "OK" {
            switch code {
            case "ERROR":
                errorHandler(message: message)
            case "EMPTY":
                emptyHanlder(message: message)
                
            default:
                errorHandler(message: message)
                
                
            }
        }
        
        return data
        
    }
    
}


