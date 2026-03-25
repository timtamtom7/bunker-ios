import Foundation

struct Decision: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String
    var criteria: [Criteria]
    var options: [String]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        criteria: [Criteria] = [],
        options: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.criteria = criteria
        self.options = options
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var isComplete: Bool {
        !criteria.isEmpty && !options.isEmpty
    }

    var allCriteriaScored: Bool {
        criteria.allSatisfy { $0.isScored }
    }
}

extension Decision {
    static let preview = Decision(
        title: "Choose a Tech Stack",
        description: "Evaluate options for the backend architecture of our new product.",
        criteria: [
            Criteria(name: "Performance", importance: 8),
            Criteria(name: "Developer Experience", importance: 7),
            Criteria(name: "Scalability", importance: 9),
            Criteria(name: "Cost", importance: 6)
        ],
        options: ["Node.js", "Go", "Rust"]
    )

    static let empty = Decision(
        title: "",
        description: "",
        criteria: [],
        options: []
    )
}
