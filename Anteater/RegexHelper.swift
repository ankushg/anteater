//
//  RegexHelpers.swift
//  Anteater
//
//  Created by Ankush Gupta on 3/1/16.
//  Copyright © 2016 Sam Madden. All rights reserved.
//

import Foundation

class RegexHelper {
    /**
     Returns new `NSRegularExpression` object.
     
     :param: pattern A regexp pattern.
     :returns: `NSRegularExpression` object or nil if it cannot be created.
     */
    private class func regexp(pattern: String) -> NSRegularExpression? {
        do {
            return try NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.CaseInsensitive)
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    /**
     Method that substring string with passed range.
     
     :param: str A string that is source of substraction.
     :param: range A range that tells which part of `str` will be substracted.
     :returns: A string contained in `range`.
     */
    private class func substring(str: String, range: NSRange) -> String {
        let startRange = str.startIndex.advancedBy(range.location)
        let endRange = startRange.advancedBy(range.length)
        
        return str.substringWithRange(startRange..<endRange)
    }
    
    /**
     Return all matches in a string.
     
     :param: pattern A regexp pattern.
     :param: inString A string that will be matched.
     :returns: Array of `Strings`s. If nothing found empty array is returned.
     */
    class func listMatches(pattern: String, inString: String) -> [String] {
        var matches = [String]()
        if let results = regexp(pattern)?.matchesInString(inString, options: .ReportCompletion, range: NSMakeRange(0, inString.startIndex.distanceTo(inString.endIndex))) {
            for result in results {
                matches.append(substring(inString, range: result.range))
            }
        }
        
        return matches
    }
    
    
    /**
     Replace all matches in a string with the given replacement
     
     :param: pattern A regexp pattern.
     :param: inString A string that will be matched.
     :param: withString A string that will be matched.
     :returns: a `String?` containing the original string with all matches replaced
     */
    class func replaceMatches(pattern: String, inString : String , withString replacementString: String) -> String? {
        
        return regexp(pattern)?.stringByReplacingMatchesInString(inString, options: .ReportCompletion, range: NSMakeRange(0, inString.startIndex.distanceTo(inString.endIndex)), withTemplate: replacementString)
    }
}