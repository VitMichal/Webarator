//
//  Vocalizer.swift
//  SpeakToMe
//
//  Created by Vít Míchal on 15.03.15.
//  Copyright (c) 2015 Vít Míchal. All rights reserved.
//

import Foundation
import AVFoundation;

private let _VocalizerSharedInstance = Vocalizer()

class Vocalizer: NSObject, AVSpeechSynthesizerDelegate {
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")

    var readingFinishedCallBack: () -> () = { }
    var state = "stopped";
    var article: Article? = nil;
    var lang: String  = "en";
    
    class var sharedInstance: Vocalizer {
        return _VocalizerSharedInstance
    }
    
    override init() {
        super.init()
        synth.delegate = self
    }
    
    
    func setVocalizerLang(newLang: String) {
        self.lang = "";

        switch newLang {
            
            case "czech":   //         Czech (Czech Republic) - cs-CZ
                self.lang = "cs-CZ";
            case "english":
                self.lang = "en-US";
            case "arabic": //       Arabic (Saudi Arabia) - ar-SA
                self.lang = "ar-SA";
                /*case "english": //         Chinese (China) - zh-CN
                iosLang = "zh-CN";
                case "english": //         Chinese (Hong Kong SAR China) - zh-HK
                iosLang = "zh-HK";
                case "english": //        Chinese (Taiwan) - zh-TW
                iosLang = "zh-TW";*/
            case "danish": //         Danish (Denmark) - da-DK
                self.lang = "da-DK";
                /*case "english": //         Dutch (Belgium) - nl-BE
                iosLang = "nl-BE";*/
            case "dutch": //         Dutch (Netherlands) - nl-NL
                self.lang = "nl-NL";
                /*case "english": //         English (Australia) - en-AU
                iosLang = "en-AU";
                case "english": //         English (Ireland) - en-IE
                iosLang = "en-IE";
                case "english": //         English (South Africa) - en-ZA
                iosLang = "en-ZA";
                case "english": //        English (United Kingdom) - en-GB
                iosLang = "en-GB";
                case "english": //         English (United States) - en-US
                iosLang = "en-US";*/
            case "finnish": //         Finnish (Finland) - fi-FI
                self.lang = "fi-FI";
                /*case "english": //         French (Canada) - fr-CA
                iosLang = "fr-CA";*/
            case "french": //          French (France) - fr-FR
                self.lang = "fr-FR";
            case "german": //        German (Germany) - de-DE
                self.lang = "de-DE";
                /*case "english": //          Greek (Greece) - el-GR
                iosLang = "el-GR";*/
            case "hebrew": //        Hebrew (Israel) - he-IL
                self.lang = "he-IL";
                /*case "english": //         Hindi (India) - hi-IN
                iosLang = "hi-IN";
                case "english": //         Hungarian (Hungary) - hu-HU
                iosLang = "hu-HU";
                case "english": //         Indonesian (Indonesia) - id-ID
                iosLang = "id-ID";
                case "english": //         Italian (Italy) - it-IT
                iosLang = "it-IT";
                case "english": //         Japanese (Japan) - ja-JP
                iosLang = "ja-JP";
                case "english": //         Korean (South Korea) - ko-KR
                iosLang = "ko-KR";*/
            case "norwegian": //         Norwegian (Norway) - no-NO
                self.lang = "no-NO";
                /*case "english": //         Polish (Poland) - pl-PL
                iosLang = "pl-PL";
                case "english": //         Portuguese (Brazil) - pt-BR
                iosLang = "pt-BR";*/
            case "portuguese": //         Portuguese (Portugal) - pt-PT
                self.lang = "pt-PT";
            case "romanian": //         Romanian (Romania) - ro-RO
                self.lang = "ro-RO";
                /*case "english": //         Russian (Russia) - ru-RU
                iosLang = "ru-RU";
                case "english": //         Slovak (Slovakia) - sk-SK
                iosLang = "sk-SK";*/
            case "spanish": //         Spanish (Spain) - es-ES
                self.lang = "es-ES";
            case "swedish": //         Swedish (Sweden) - sv-SE
                self.lang = "sv-SE";
                /*case "english": //         Thai (Thailand) - th-TH
                iosLang = "th-TH";
                case "english": //         Turkish (Turkey) - tr-TR
                iosLang = "tr-TR";
                */
                
            default:
                self.lang = "en-US";
        }
    }

    func getVocalizerLang() -> String {
        return self.lang
    }


    

    func readText(text:String) {
        myUtterance = AVSpeechUtterance(string: text)
        myUtterance.rate = 0.5
        myUtterance.voice = AVSpeechSynthesisVoice(language: lang)

        synth.speakUtterance(myUtterance)
    }
    
    func pauseReading() {
        state = "paused"
        synth.pauseSpeakingAtBoundary( AVSpeechBoundary.Immediate )
    }
    
    func resumeReading() {
        if state=="paused" || state=="stopped" {
            synth.continueSpeaking()
        }
    }
    
    func speechSynthesizer(s: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        let sentence = article!.getNextSentence()
        if sentence != nil {
            if state != "stopped" {
                self.readText(article!.getCurrentSentence())
            }
        } else {
            state = "stopped"
            print("reading finnished")
            self.readingFinishedCallBack()
            
        }
        
    }
    
    
    func readArtice(newArticle: Article, callBack: () -> () ) {
        synth.stopSpeakingAtBoundary( AVSpeechBoundary.Immediate)
        synth.continueSpeaking()
        state = "reading"
        readingFinishedCallBack = callBack

        article = newArticle;
        
        setVocalizerLang(article!.getLang());
        self.readText(article!.getTitle())
        self.readText(article!.getCurrentSentence())

    }
    
    func backwards() {
        synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        article!.getPrevSentence()
        self.readText(article!.getCurrentSentence())
    }

    func forward() {
        synth.stopSpeakingAtBoundary(AVSpeechBoundary.Immediate)
        if article!.getNextSentence() != nil {
            self.readText(article!.getCurrentSentence())
        }
    }
}


