import Foundation

struct Criteria: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var importance: Int // 1-10
    var scores: [UUID: Int] // optionId -> score 1-10

    init(
        id: UUID = UUID(),
        name: String,
        importance: Int = 5,
        scores: [UUID: Int] = [:]
    ) {
        self.id = id
        self.name = name
        self.importance = max(1, min(10, importance))
        self.scores = scores
    }

    var isScored: Bool {
        !scores.isEmpty && scores.values.allSatisfy { $0 > 0 }
    }

    func score(for optionId: UUID) -> Int {
        scores[optionId] ?? 0
    }

    mutating func setScore(_ score: Int, for optionId: UUID) {
        scores[optionId] = max(1, min(10, score))
    }
}

extension Criteria {
    static let preview = Criteria(
        name: "Performance",
        importance: 8,
        scores: [:]
    )
}
