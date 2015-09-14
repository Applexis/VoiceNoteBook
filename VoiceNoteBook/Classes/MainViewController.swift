//
//  ViewController.swift
//  VoiceNoteBook
//
//  Created by applex on 15/9/14.
//  Copyright (c) 2015年 cn.edu.sjtu. All rights reserved.
//

import UIKit
import AVFoundation

var kMeterViewSideLength: CGFloat = 160.0;

class MainViewController: UIViewController, AudioUtilDelegate {


    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    var audioMeterView: AudioMeterView = AudioMeterView(frame: CGRectZero)
    var audioUtil: AudioUtil = AudioUtil()

    override func loadView() {
        super.loadView()
//        self.view.addSubview(audioMeterView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Voice Notebook", comment: "")
        self.rightBarButtonItem.title = NSLocalizedString("My Notes", comment: "");
        
        recordButton.addTarget(self, action: Selector("recordBegin:"), forControlEvents: UIControlEvents.TouchDown);
        recordButton.addTarget(self, action: Selector("recordEnd:"), forControlEvents: UIControlEvents.TouchUpInside);
        recordButton.addTarget(self, action: Selector("recordEnd:"), forControlEvents: UIControlEvents.TouchUpOutside);

        audioUtil.delegate = self
        initViews();
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkAVPermission()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Mark: - Actions
    
    func recordBegin(sender: AnyObject) {
        let fileName = audioUtil.recordBegin()
        NSLog("begin record, fileName: %@", fileName)
    }
    
    func recordEnd(sender: AnyObject) {
        audioUtil.recordEnd()
        NSLog("end recording")
    }
    

    // Mark: - AudioRecorderDelegate
    
    func audioUtil(audioUtil: AudioUtil, didReceiveSoundLevelUpdate audioRecorder: AVAudioRecorder) {
        audioRecorder.updateMeters()
        let averagePower: CGFloat = CGFloat(audioRecorder.averagePowerForChannel(0))
        let peakPower: CGFloat = CGFloat(audioRecorder.peakPowerForChannel(0))
        
        self.audioMeterView.updateViewWithPeakPower(peakPower, averagePower: averagePower)
    }
    
    // Mark: - Private Method
    
    func initViews() {
        recordButton.setTitle(NSLocalizedString("Touch to begin recording", comment: ""), forState: UIControlState.Normal)
        audioMeterView.frame = CGRectMake((self.view.frame.width - kMeterViewSideLength) / 2, 120, kMeterViewSideLength, kMeterViewSideLength)
    }
    
    
    func checkAVPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { (granted) -> Void in
            if !granted {
                let alertView = UIAlertView(title: "Error", message: "You cannot access microphone until you set it in your settings.", delegate: nil, cancelButtonTitle: "OK")
                alertView.show();
            }
        }
    }

}

