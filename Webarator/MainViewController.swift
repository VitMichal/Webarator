//
//  ViewController.swift
//  Webarator
//
//  Created by Vít Míchal on 26.12.15.
//  Copyright © 2015 Vít Míchal. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var pageContentTV: UITextView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!

    
    var playedURL = ""
    var playPauseState: PlayPauseButtonStateManager = PlayPauseButtonStateManager()
    var fsm: ApplicationState!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.urlTextField.delegate = self;
        fsm = ApplicationState(stoppedClosure: stoppedState, downloadingClosure: downloadingState, playingClosure: playingState, pauseClosure: pausedState)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(urlText: UITextField) -> Bool {
        self.view.endEditing(true)
        playPause()
        return false
    }

    @IBAction func actionPrev(sender: AnyObject) {
        Vocalizer.sharedInstance.backwards()
    }

    @IBAction func actionPlayPause(sender: AnyObject) {
        playPause()
        
    }
    
    @IBAction func actioNext(sender: AnyObject) {
        Vocalizer.sharedInstance.forward()
    }
    
    func playPause() {
        
        print("playPause tapped \(fsm.getState())")
        
        if fsm.isInState(ApplicationStates.Stopped) {
            fsm.fireEvent(ApplicationState.Events.newUrl)
            
        } else if fsm.isInState(ApplicationStates.Playing) {
            fsm.fireEvent(ApplicationState.Events.pausePlaying)
        
        } else if fsm.isInState(ApplicationStates.Paused) {
            fsm.fireEvent(ApplicationState.Events.resumePlaying)
        
        } /*else {
            print("no known state")
        }*/

    }
    
    
    //// todo: move it to its own class
    
    func getArticleAndStartReading(url: String) {
        print("getArticleAndStartReading \(url)")
        OnlinePageParser.sharedInstance.getPageContent(url, callBack: self.articleArrivedHandler, newErrorCallBack: errorResponse, newEmptyCallBack:  emptyResponse)
        
    }
    
    func setPlayingAndChangeButton(state: Bool) {
        print("setPlayingAndChangeButton1 \(state)")
        runThisInMainThread({
            print("setPlayingAndChangeButton2 \(state)")
            self.playPauseState.setPlaying(state);
            self.playPauseButton.setImage(UIImage(imageLiteral: self.playPauseState.getImage()), forState: UIControlState.Normal)
        })
    }
    
    func articleArrivedHandler( articleDict: NSDictionary ) {
        let article = Article(data: articleDict)
        print("onlineparser \(article)")
        
        runThisInMainThread({
 
            self.pageContentTV.text = article.getPageText()
            self.languageLabel.text = article.getLang()
        })
        
        Vocalizer.sharedInstance.readArtice(article, callBack: {

            print("xxx finished")
            self.fsm.fireEvent(ApplicationState.Events.pausePlaying)

            //self.setPlayingAndChangeButton(false)
            self.playedURL = ""
            self.languageLabel.text = ""
            self.pageContentTV.text = ""
            
        })
        
        fsm.fireEvent(ApplicationState.Events.resumePlaying)
        
    }
    
    
    func emptyResponse(message:NSString) {

        
    }
    
    func errorResponse(message:NSString) {
        print("error \(message)", terminator: "")
        runThisInMainThread({
            self.errorResponseInner(message)
        
        })
        
        self.triggerStopPlaying()
        

    }
    
    func errorResponseInner(message:NSString) {
        let alert = UIAlertController(title: "Problem", message: message as String, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: {  _ in
            print("error alert click")
        }))
        
        self.presentViewController(alert, animated: true, completion: {
            print("error alert shown")
        })
        
    }
    
    func triggerStopPlaying() {
        self.fsm.fireEvent(ApplicationState.Events.stopPlaying)
    }

    func useURL( newURL: NSString) {
        print("useURL \(newURL)")
        urlTextField.text = newURL as String
        playPause()
        UIApplication.sharedApplication().openURL(NSURL(fileURLWithPath: "http://"));
        //UIApplication.sharedApplication.openURL(".");
    }
    
    // states handlers
    func stoppedState() {
        print("stoppedState");
        setPlayingAndChangeButton(false)
    }
    
    func downloadingState() {
        print("downloadingState");
        playedURL = urlTextField.text!
        getArticleAndStartReading(playedURL)
        
    }
    
    func playingState() {
        print("playingState");
        setPlayingAndChangeButton(true)

    }
    
    func pausedState() {
        print("pausedState");

        setPlayingAndChangeButton(false)
    }

}
