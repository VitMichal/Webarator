//
//  Article.swift
//  SpeakToMe
//
//  Created by Vít Míchal on 21.03.15.
//  Copyright (c) 2015 Vít Míchal. All rights reserved.
//

import Foundation

public class Article {
    private var title: String
    private var sentences: [String];
    private var lang: String
    
    private var activeSentence: Int
    private var sentencesCount: Int
    
    init(data: NSDictionary) {
        title = data.valueForKey("title") as! String
        sentences = data.valueForKey("sentences") as! [String]
        lang = data.valueForKey("lang") as! String
        activeSentence = 0
        sentencesCount = sentences.count;
    }
    
    func getCurrentSentence() -> String {
        return sentences[activeSentence]
        //return sentences.objectAtIndex(activeSentence) as! String
        //return sentences[activeSentence];
    }
    
    public func getNextSentence() -> String? {
        if activeSentence+1 >= sentencesCount {
            return nil
        } else {
            activeSentence++
            //return sentences.objectAtIndex(activeSentence) as? String
            return sentences[activeSentence];
        }
    }
    
    public func getPrevSentence() -> String? {
        if activeSentence == 0 {
            return nil
        } else {
            activeSentence--
            //return sentences.objectAtIndex(activeSentence) as? String
            return sentences[activeSentence];
        }
    }
    
    public func getPageText () -> String {
        return sentences.joinWithSeparator(" ")
    }
    
    public func getLang() -> String {
        return self.lang
    }
    
    public func getTitle() -> String {
        return self.title
    }
}