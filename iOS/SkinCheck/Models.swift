import Foundation

struct SpotEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var title: String
    var metric: Int          // Concern
    var tag: String          // Location
    var note: String = ""
}

enum SkinCheckTags {
    static let all: [String] = ["Arm", "Back", "Leg", "Face", "Other"]
}
