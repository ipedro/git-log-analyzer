import Foundation

/// A directory enumerator object that can be used to perform a deep enumeration of the directory at the specified URL.
public struct FileEnumerator {
    /// The location of the directory for which you want an enumeration. This URL must not be a symbolic link that points to the desired directory. You can use the resolvingSymlinksInPath method to resolve any symlinks in the URL.
    public var directory: URL

    public var fileManager: FileManager

    /// A handler block for the file collector to call and decide if a file should be indexed.
    public var matchHandler: (URL) -> Bool
    /// An optional error handler block for the file manager to call when an error occurs. The handler block should return true if you want the enumeration to continue or false if you want the enumeration to stop. The block takes the following parameters:
    ///
    /// - An URL identifies the item for which the error occurred.
    ///
    /// - An NSError object that contains information about the error.
    ///
    ///   If you specify nil for this parameter, the enumerator object continues to enumerate items as if you had specified a block that returned true.
    public var errorHandler: ((URL, Error) -> Bool)?

    public init(
        directory: URL,
        fileManager: FileManager = FileManager.default,
        matching matchHandler: @escaping (URL) -> Bool,
        errorHandler: ((URL, Error) -> Bool)? = nil
    ) {
        self.directory = directory
        self.fileManager = fileManager
        self.matchHandler = matchHandler
        self.errorHandler = errorHandler
    }

    public func run() -> [URL] {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: directory.path, isDirectory: &isDirectory) else {
            print("Directory not found: '\(directory.path)'")
            return []
        }

        let urls = isDirectory.boolValue ? enumerateDirectory() : [directory]
        return validate(urls: urls)
    }

    private func validate(urls: [URL]) -> [URL] {
        var validURLs = [URL]()

        for fileURL in urls where matchHandler(fileURL) {
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
}
