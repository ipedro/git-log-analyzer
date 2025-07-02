import Foundation

public struct GitLogDecoder: Sendable {
    let decoder: JSONDecoder

    public init(decoderConfigurationHandler: (JSONDecoder) -> Void) {
        decoder = JSONDecoder()
        decoderConfigurationHandler(decoder)
    }

    public func decode(_ rawEntries: [String], stripEmptyProperties: Bool = false) throws -> [GitLogEntry] {
        var logs = [GitLogEntry]()

        for rawEntry in rawEntries {
            do {
                var logEntry = try decode(rawEntry)
                if stripEmptyProperties {
                    removeEmptyProperties(&logEntry)
                }
                logs.append(logEntry)
            } catch {
                print(error, rawEntry, separator: "\n")
                throw error
            }
        }
        return logs
    }
    
    private func removeEmptyProperties(_ logEntry: inout GitLogEntry) {
        if logEntry.body == "" {
            logEntry.body = .none
        }
        if logEntry.notes == "" {
            logEntry.notes = .none
        }
        if logEntry.signature?.issuer == "",
           logEntry.signature?.fingerprint == "",
           logEntry.signature?.key == "",
           logEntry.signature?.message == "",
           logEntry.signature?.trustLevel == "" || logEntry.signature?.trustLevel == "undefined"
        {
            logEntry.signature = .none
        }
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
