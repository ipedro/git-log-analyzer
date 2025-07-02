import Foundation

struct CountedSet<Element: Hashable>: CustomStringConvertible {
    private var store: [Element: Int] = [:]
    
    init() {}
    
    var isEmpty: Bool { store.isEmpty }
    
    var members: [Element] { Array(store.keys) }
    
    var totalCount: Int { store.values.reduce(.zero, +) }
    
    var maxCount: Int? { store.values.max() }
    
    subscript(_ member: Element) -> Int {
        store[member, default: .zero]
    }
    
    mutating func insert(_ member: Element) {
        store[member, default: .zero] += 1
    }
    
    mutating func remove(_ member: Element) -> Element? {
        guard var count = store[member], count > .zero else { return nil }
        count -= 1
        store[member] = count == .zero ? .none : count
        return member
    }
    
    func count(of member: Element) -> Int {
        store[member, default: .zero]
    }
    
    var description: String { store.description }
}
