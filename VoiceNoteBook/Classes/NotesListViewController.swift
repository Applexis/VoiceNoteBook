//
//  NotesListViewController.swift
//  VoiceNoteBook
//
//  Created by applex on 15/9/14.
//  Copyright (c) 2015年 cn.edu.sjtu. All rights reserved.
//

import UIKit

class NotesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NoteTableViewCellDelegate {

    var tableView: UITableView!
    var identifier = "NoteIdentifier"
    var notes: [String] = []
    var playingFileName: String?
    
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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
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
    
    
    // Mark: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? NoteTableViewCell
        
        if cell == nil {
            cell = NoteTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: identifier)
            cell?.delegate = self
        }
        
        configureCell(cell!, atIndexPath: indexPath)
        
        return cell!
    }
    
    func configureCell(cell: NoteTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let fileName = noteObjAtIndexPath(indexPath)
        cell.fileName = fileName.stringByDeletingPathExtension
        cell.playing = self.playingFileName == fileName
        
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
            // should stop
            self.playingFileName = nil
            cell.playing = false
            
            // stop playing
        } else {
            if let oldFileName = self.playingFileName {
                if let indexPath = indexPathForNoteObj(oldFileName) {
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! NoteTableViewCell
                    let visibleCells = tableView.visibleCells() as! [NoteTableViewCell]
                    if find(visibleCells, cell) != nil {
                        cell.playing = false
                    }
                }
            }
            
            self.playingFileName = fileName
            cell.playing = true
            
            // stop playing and play this one
        }
    }
}
