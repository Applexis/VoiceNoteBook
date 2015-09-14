//
//  PlayUtil.swift
//  VoiceNoteBook
//
//  Created by applex on 15/9/14.
//  Copyright (c) 2015年 cn.edu.sjtu. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol PlayUtilDelegate {
    optional func playUtilDidFinishPlaying(playUtil: PlayUtil!, successfully flag: Bool)
}
class PlayUtil: NSObject, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer?
    var delegate: PlayUtilDelegate?

    func playWithFileName(fileName: String) {
        
        var soundUrl = NSURL(fileURLWithPath: FileUtil.getWholePathFromFileName(fileName))
        
        var error:NSError?

        audioPlayer = AVAudioPlayer(contentsOfURL: soundUrl, error: &error)
        audioPlayer?.delegate = self;
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
    
    func stop() {
        if audioPlayer != nil {
            audioPlayer?.stop()
        }
        audioPlayer = nil
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        delegate?.playUtilDidFinishPlaying?(self, successfully: flag)
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        NSLog("audioPlayerDecodeErrorDidOccur: %@", error)
    }

}
