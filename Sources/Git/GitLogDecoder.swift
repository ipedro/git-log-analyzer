import Foundation

public struct GitLogDecoder: Sendable {
    let decoder: JSONDecoder

    public init(decoderConfigurationHandler: (JSONDecoder) -> Void) {
        decoder = JSONDecoder()
        decoderConfigurationHandler(decoder)
    }

    public func decode(_ rawEntries: [String]) throws -> [GitLogEntry] {
        var logs = [GitLogEntry]()

        for rawEntry in rawEntries {
            do {
                let logEntry = try decode(rawEntry)
                logs.append(logEntry)
            } catch {
                print(error, rawEntry, separator: "\n")
                throw error
            }
        }
        return logs
    }

    private func decode(_ string: String) throws -> GitLogEntry {
        guard let data = string.data(using: .utf8) else { throw DecodingError(input: string) }
        let logEntry = try decoder.decode(GitLogEntry.self, from: data)
        return logEntry
    }
}

// MARK: - Errors

extension GitLogDecoder {
    struct DecodingError: Error {
        var input: String
    }
}
