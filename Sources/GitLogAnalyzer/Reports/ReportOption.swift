import Foundation

enum ReportOption: String, Codable, CaseIterable, ExpressibleByStringLiteral {
    case json
    case full
    case oneline
    case squadOwnership = "squad-ownership"

    var type: Reportable.Type {
        switch self {
        case .json: return JSONReport.self
        case .full: return FullTextReport.self
        case .oneline: return OnelineTextReport.self
        case .squadOwnership: return SquadOwnershipReport.self
        }
    }

    init(stringLiteral value: String) {
        guard let option = ReportOption(rawValue: value) else {
            fatalError("'\(value)' is not a valid report option. Choose one: \(ReportOption.allCases.map(\.rawValue).joined(separator: ", "))")
        }
        self = option
    }
}
