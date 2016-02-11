//
//  PlayPauseButtonStateManager.swift
//  Webarator
//
//  Created by Vít Míchal on 28.12.15.
//  Copyright © 2015 Vít Míchal. All rights reserved.
//

import Foundation

class PlayPauseButtonStateManager {
    var playing: Bool
    
    init() {
        self.playing = false
    }
    
    func isPlaying() -> Bool {
        return self.playing
    }
    
    func getImage() -> String {
        if self.isPlaying() {
            print("set PauseButton")
            return "PauseButton";
        } else {
            print("set PlayButton")            
            return "PlayButton";
        }
        
    }
    func setPlaying(playing: Bool) {
        print("setPlaying \(playing)")
        self.playing = playing
    }
}