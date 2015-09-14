//
//  FileUtil.swift
//  VoiceNoteBook
//
//  Created by applex on 15/9/14.
//  Copyright (c) 2015年 cn.edu.sjtu. All rights reserved.
//

import UIKit

class FileUtil: NSObject {
   
    private static var formatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        return formatter
    }()
    
    static var defaultPathExtention = "m4a"

    class func getAllFileNamesInDocumentDic(pathExtention: String = defaultPathExtention) -> [String] {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        if let directoryUrls =  NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions.SkipsSubdirectoryDescendants, error: nil) {
            let files = directoryUrls.map(){ $0.lastPathComponent }.filter(){ $0.pathExtension == pathExtention }.map() { $0! }
            return files
        }
        return []
    }
    
    class func newFileName() -> String {
        return formatter.stringFromDate(NSDate()) + "." + defaultPathExtention
    }
    
    class func getWholePathFromFileName(fileName: String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0] as! String

        return "\(documentsDirectory)/\(fileName)"
    }
}
