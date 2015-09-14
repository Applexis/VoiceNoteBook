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

class MainViewController: UIViewController, AVAudioRecorderDelegate {


    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    var audioMeterView: AudioMeterView = AudioMeterView(frame: CGRectZero)
    
    var audioRecorder: AVAudioRecorder?

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

        initViews();
        
        // recorder
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        let soundFilePath = docsDir.stringByAppendingPathComponent("sound.caf")
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let recordSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0]
        
        var error: NSError?
        
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error)
        
        if let err = error {
            println("audioSession error: \(err.localizedDescription)")
        }
        
        audioRecorder = AVAudioRecorder(URL: soundFileURL,
            settings: recordSettings as [NSObject : AnyObject], error: &error)
        
        if let err = error {
            println("audioSession error: \(err.localizedDescription)")
        } else {
            audioRecorder?.prepareToRecord()
        }
        
        audioRecorder?.delegate = self
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
        if audioRecorder?.recording == false {
            audioRecorder?.record()
        }
        
        NSLog("begin")
    }
    
    func recordEnd(sender: AnyObject) {
        if audioRecorder?.recording == true {
            audioRecorder?.stop()
        }

        NSLog("end")
    }
    
    
    // Mark: - AudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        println("finish")
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println("Audio Record Encode Error")
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

