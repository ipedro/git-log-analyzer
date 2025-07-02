import Foundation

public struct GitLogFormat: Hashable, ExpressibleByStringLiteral, CustomStringConvertible, Sendable {
    public let quoteSymbol: Character = "⍺"
    public let eofSymbol: Character = "☑️"
    public var sanitizePattern: String { "(?<=: \(quoteSymbol))[^\(quoteSymbol)]*" }
    public let description: String

    public init(stringLiteral: String) {
        description = stringLiteral
    }
}

extension GitLogFormat {
    public static let json: GitLogFormat = """
{
  ⍺subject⍺: {
      ⍺description⍺: ⍺%s⍺,
      ⍺sanitized⍺: ⍺%f⍺
  },
  ⍺created⍺: ⍺%aI⍺,
  ⍺published⍺: ⍺%cI⍺,
  ⍺body⍺: ⍺%b⍺,
  ⍺parent⍺: ⍺%P⍺,
  ⍺author⍺: {
    ⍺email⍺: ⍺%aE⍺,
    ⍺name⍺: ⍺%aN⍺
  },
  ⍺committer⍺: {
    ⍺email⍺: ⍺%cE⍺,
    ⍺name⍺: ⍺%cN⍺
  },
  ⍺notes⍺: ⍺%N⍺,
  ⍺hash⍺: {
      ⍺description⍺: ⍺%H⍺,
      ⍺abbreviated⍺: ⍺%h⍺
  }
}☑️
"""
}
