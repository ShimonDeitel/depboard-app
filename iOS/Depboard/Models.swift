import Foundation

struct DepboardEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var field1: String
    var field2: String
    var field3: String
    var dateAdded: Date = Date()
}
