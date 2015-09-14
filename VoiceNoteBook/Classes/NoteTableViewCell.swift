
//
//  NoteTableViewCell.swift
//  VoiceNoteBook
//
//  Created by applex on 15/9/14.
//  Copyright (c) 2015年 cn.edu.sjtu. All rights reserved.
//

import UIKit

@objc protocol NoteTableViewCellDelegate {
    optional func noteTableViewButtonPressed(cell: NoteTableViewCell, withFileName fileName: String)
}

class NoteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    weak var delegate: NoteTableViewCellDelegate?
    
    var fileName: String? {
        didSet {
            titleLabel.text = fileName
        }
    }
    
    var playing: Bool = false {
        didSet {
            if (playing) {
                playButton.setTitle(NSLocalizedString("Stop", comment: ""), forState: .Normal)
            } else {
                playButton.setTitle(NSLocalizedString("Play", comment: ""), forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playButton.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: UIControlEvents.TouchUpInside)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func buttonPressed(sender: AnyObject) {
        self.playing = !self.playing
        if delegate != nil {
            if let fname = self.fileName {
                delegate?.noteTableViewButtonPressed?(self, withFileName: fname)
            }
        }
    }
}
