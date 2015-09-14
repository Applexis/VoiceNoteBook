//
//  NotesListViewController.swift
//  VoiceNoteBook
//
//  Created by applex on 15/9/14.
//  Copyright (c) 2015年 cn.edu.sjtu. All rights reserved.
//

import UIKit

class NotesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NoteTableViewCellDelegate, PlayUtilDelegate {

    var tableView: UITableView!
    var identifier = "NoteIdentifier"
    var notes: [String] = []
    var playingFileName: String?
    
    var playUtil: PlayUtil = PlayUtil()
    
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Plain)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("My Notes", comment: "")
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.registerNib(UINib(nibName: "NoteTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
        
        playUtil.delegate = self;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        playUtil.stop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Mark: - Actions
    
    func refreshUI() {
        notes = FileUtil.getAllFileNamesInDocumentDic()
        tableView.reloadData()
    }
    
    func playFile(fileName: String) {
        if let oldCell = visibleCellForFileName(self.playingFileName) {
            oldCell.playing = false
        }
        playUtil.stop()

        self.playingFileName = fileName
        
        if let cell = visibleCellForFileName(fileName) {
            cell.playing = true
        }
        playUtil.playWithFileName(fileName)
    }
    
    func stopPlay() {
        if let cell = visibleCellForFileName(self.playingFileName) {
            cell.playing = false
        }
        
        self.playingFileName = nil
        playUtil.stop()
    }
    
    // Mark: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? NoteTableViewCell
        
        if cell == nil {
            cell = NoteTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
        }
        
        configureCell(cell!, atIndexPath: indexPath)
        
        return cell!
    }
    
    func configureCell(cell: NoteTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let fileName = noteObjAtIndexPath(indexPath)
        cell.fileName = fileName
        cell.playing = self.playingFileName == fileName
        cell.delegate = self
    }
    
    func noteObjAtIndexPath(indexPath: NSIndexPath) -> String {
        return notes[indexPath.row]
    }
    
    func indexPathForNoteObj(noteObj: String) -> NSIndexPath? {
        if let row = find(notes, noteObj) {
            return NSIndexPath(forRow: row, inSection: 0)
        }
        return nil
    }
    
    
    // Mark: - NoteTableViewCellDelegate 
    
    func noteTableViewButtonPressed(cell: NoteTableViewCell, withFileName fileName: String) {
        if fileName == self.playingFileName {
            stopPlay()
        } else {
            playFile(fileName)
        }
    }
    
    
    // Mark: - PlayUtilDelegate
    
    func playUtilDidFinishPlaying(playUtil: PlayUtil!, successfully flag: Bool) {
        stopPlay()
    }
    
    
    // Mark: - Private Methods
    
    private func visibleCellForFileName(fileName: String?) -> NoteTableViewCell? {
        if let oldFileName = fileName {
            if let indexPath = indexPathForNoteObj(oldFileName) {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! NoteTableViewCell
                let visibleCells = tableView.visibleCells() as! [NoteTableViewCell]
                if find(visibleCells, cell) != nil {
                    return cell
                }
            }
        }
        return nil
    }
}
