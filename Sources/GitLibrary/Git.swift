import Foundation
@_implementationOnly import TSCBasic
@_implementationOnly import TSCUtility

public struct Git: Hashable {
    private var tool: String = TSCUtility.Git.tool
    private var environment: [String: String] = TSCUtility.Git.environment

    public func run(_ args: [String], url: Foundation.URL) throws -> String {
        let path = AbsolutePath(url.path)
        return try execute(["-C", path.dirname] + args)
    }

    private func execute(_ arguments: [String]) throws -> String {
        let process = Process(arguments: [tool] + arguments, environment: environment)
        try process.launch()
        let result = try process.waitUntilExit()

        guard result.exitStatus == .terminated(code: .zero) else {
            throw GitError(result: result, arguments: arguments)
        }

        let content = try result.utf8Output().spm_chomp()
        return content
    }
}

struct GitError: Error {
    let result: ProcessResult
    let arguments: [String]
}
