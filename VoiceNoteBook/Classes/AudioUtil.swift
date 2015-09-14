//
//  AudioUtil.swift
//  VoiceNoteBook
//
//  Created by applex on 15/9/14.
//  Copyright (c) 2015年 cn.edu.sjtu. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol AudioUtilDelegate {
    optional func audioUtil(audioUtil: AudioUtil, didReceiveSoundLevelUpdate audioRecorder: AVAudioRecorder)
}

class AudioUtil: NSObject, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder?
    var delegate: AudioUtilDelegate?
    
    // Mark: - Actions
    
    func recordBegin() -> String {
        
        let newFileName = FileUtil.newFileName()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0] as! String
        let soundFilePath = docsDir.stringByAppendingPathComponent(newFileName)
        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
        let recordSettings =
        [
//            AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
//            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey: 16000.0,
            AVFormatIDKey: kAudioFormatMPEG4AAC
        ]
        
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
        audioRecorder?.meteringEnabled = true;

        audioRecorder?.record()
        beginUpdateMeters()
        
        return newFileName
    }
    
    func recordEnd() {
        if audioRecorder?.recording == true {
            audioRecorder?.stop()
        }
        
        audioRecorder = nil
    }
    
    
    // Mark: - AudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        // println("finish")
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
        println("Audio Record Encode Error")
    }
    
    private func beginUpdateMeters() {
        if audioRecorder == nil {
            return
        }
        
        let queue = NSOperationQueue()
        queue.addOperationWithBlock { () -> Void in
            do {
                
                dispatch_async(dispatch_get_main_queue()) {
                    () -> Void in
                    if let recorder = self.audioRecorder {
                        self.delegate?.audioUtil?(self, didReceiveSoundLevelUpdate: recorder)
                        
                    }
                }
                NSThread.sleepForTimeInterval(0.05)
            } while (self.audioRecorder?.recording == true);
        }
    }

}
