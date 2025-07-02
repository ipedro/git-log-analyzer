import Foundation
import GitLibrary

protocol Reportable {
    init(directory: URL,
         items: [URL: [GitLogEntry]],
         includeRules: [String],
         maxCommitsPerFile: Int?)
    
    mutating func report() -> String
}

