//
//  ApplicationState.swift
//  Webarator
//
//  Created by Vít Míchal on 03.01.16.
//  Copyright © 2016 Vít Míchal. All rights reserved.
//

import Foundation

enum ApplicationStates {
    case Stopped
    case Downloading
    case Playing
    case Paused
}


//private let _ApplicationStateSharedInstance = ApplicationState()

class ApplicationState {
    private var fsm: StateMachine <ApplicationStates>
    
    // STATES
    private let stopped = State(ApplicationStates.Stopped)
    private let downloading = State(ApplicationStates.Downloading)
    private let playing = State(ApplicationStates.Playing)
    private let paused = State(ApplicationStates.Paused)
    
    internal class Events {
        class var newUrl: String { return "newURL" }
        class var pageSuccDown: String { return "pageSuccDown" }
        class var resumePlaying: String { return "resumePlaying" }
        class var pausePlaying: String { return "pausePlaying" }
        class var stopPlaying: String { return "stopPlaying" }
    }
    
    /*class var sharedInstance: ApplicationState {
        return _ApplicationStateSharedInstance
    }*/
    
    init(stoppedClosure: () -> Void, downloadingClosure: () -> Void, playingClosure: () -> Void, pauseClosure: () -> Void) {
        
        // ENTRING CALLBACKS
        self.stopped.didEnterState = { _ in stoppedClosure() }
        self.downloading.didEnterState = { _ in downloadingClosure() }
        self.playing.didEnterState = { _ in playingClosure() }
        self.paused.didEnterState = { _ in pauseClosure() }

        // STATE MACHINE
        self.fsm = StateMachine(initialState: self.stopped, states: [self.stopped, self.downloading, self.playing, self.paused])
        
        // TRANSITIONS
        self.fsm.addEvents([
            Event(name: Events.newUrl , sourceValues: [ApplicationStates.Stopped], destinationValue: ApplicationStates.Downloading),
            //Event(name: Events.pageSuccDown, sourceValues: [ApplicationStates.Downloading], destinationValue: ApplicationStates.Playing),
            Event(name: Events.resumePlaying, sourceValues: [ApplicationStates.Paused, ApplicationStates.Downloading], destinationValue: ApplicationStates.Playing),
            Event(name: Events.pausePlaying, sourceValues: [ApplicationStates.Playing], destinationValue: ApplicationStates.Paused),
            Event(name: Events.stopPlaying, sourceValues: [ApplicationStates.Playing, ApplicationStates.Paused, ApplicationStates.Downloading], destinationValue: ApplicationStates.Stopped)
        ])

        
    }
    
    func setHandlers(stoppedClosure: () -> Void, downloadingClosure: () -> Void, playingClosure: () -> Void, pauseClosure: () -> Void ) {
        // ENTRING CALLBACKS
        self.stopped.didEnterState = { _ in stoppedClosure() }
        self.downloading.didEnterState = { _ in downloadingClosure() }
        self.playing.didEnterState = { _ in playingClosure() }
        self.paused.didEnterState = { _ in pauseClosure() }

    }
    
    
    func fireEvent(event: String) {
        print("fireEvent \(event) \(self.getState())")
        self.fsm.fireEvent(event)
    }
    
    func isInState(state: ApplicationStates) -> Bool {
        return self.fsm.isInState(state)
    }
    
    func getState() -> ApplicationStates {
        return fsm.currentState.value
    }
}
