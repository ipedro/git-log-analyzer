import Foundation

/// A directory indexer that can be used to perform a deep enumeration of files in a directory, with regex-based filtering.
public struct FileIndexer {
    /// The location of the directory for which you want an enumeration. This URL must not be a symbolic link that points to the desired directory. You can use the resolvingSymlinksInPath method to resolve any symlinks in the URL.
    public var directory: URL
    /// Array of regex patterns to match against file paths. If empty, all files are included.
    public var includeRules: [String]
    /// Whether to print verbose logging during enumeration.
    public var verbose: Bool
    /// The file manager to use for file system operations.
    public var fileManager: FileManager
    /// An optional error handler block for the file manager to call when an error occurs. The handler block should return true if you want the enumeration to continue or false if you want the enumeration to stop.
    public var errorHandler: ((URL, Error) -> Bool)?

    public init(
        directory: URL,
        includeRules: [String],
        verbose: Bool = false,
        fileManager: FileManager = FileManager.default,
        errorHandler: ((URL, Error) -> Bool)? = nil
    ) {
        self.directory = directory
        self.verbose = verbose
        self.includeRules = includeRules
        self.fileManager = fileManager
        self.errorHandler = errorHandler
    }

    public func run() throws -> [URL] {
        let regExes = try includeRules.map { try NSRegularExpression(pattern: $0) }
        
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory) else {
            print("Directory not found: '\(directory.path)'")
            return []
        }

        let urls = isDirectory.boolValue ? enumerateDirectory() : [directory]
        return validate(urls: urls, regExes: regExes)
    }

    private func validate(urls: [URL], regExes: [NSRegularExpression]) -> [URL] {
        var validURLs = [URL]()

        for fileURL in urls where isIncluded(fileURL, regExes: regExes) {
            do {
                let properties = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                if properties.isRegularFile == true {
                    validURLs.append(fileURL)
                }
            } catch {
                guard let errorHandler = errorHandler else { continue }
                if errorHandler(fileURL, error) { continue }
                else { return validURLs }
            }
        }
        return validURLs
    }

    private func enumerateDirectory() -> [URL] {
        fileManager
            .enumerator(
                at: directory,
                includingPropertiesForKeys: [
                    .isRegularFileKey,
                ],
                options: [
                    .skipsHiddenFiles,
                    .skipsPackageDescendants,
                    .producesRelativePathURLs,
                ],
                errorHandler: errorHandler
            )?
            .compactMap { $0 as? URL }
            ?? []
    }

    private func isIncluded(_ url: URL, regExes: [NSRegularExpression]) -> Bool {
        if regExes.isEmpty { return true }
        
        for regex in regExes {
            if regex.matches(in: url.relativePath, range: NSRange(url.relativePath.startIndex..., in: url.relativePath)).isEmpty == false {
                if verbose { print("✅ Indexing", url.relativePath) }
                return true
            }
        }
        if verbose { print("➖ Skipping", url.relativePath) }
        return false
    }
}
