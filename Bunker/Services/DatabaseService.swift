import Foundation
import SQLite

final class DatabaseService: @unchecked Sendable {
    static let shared = DatabaseService()

    private var db: Connection?
    private let dbQueue = DispatchQueue(label: "com.bunker.database")

    // Tables
    private let decisions = Table("decisions")
    private let outcomes = Table("outcomes")

    // Decision columns
    private let id = SQLite.Expression<String>("id")
    private let title = SQLite.Expression<String>("title")
    private let descriptionCol = SQLite.Expression<String>("description")
    private let criteriaData = SQLite.Expression<Data>("criteria_data")
    private let optionsData = SQLite.Expression<Data>("options_data")
    private let createdAt = SQLite.Expression<Date>("created_at")
    private let updatedAt = SQLite.Expression<Date>("updated_at")

    // Outcome columns
    private let decisionId = SQLite.Expression<String>("decision_id")
    private let outcomeData = SQLite.Expression<Data>("outcome_data")

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let fileManager = FileManager.default
            let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let dbFolder = appSupport.appendingPathComponent("Bunker", isDirectory: true)

            if !fileManager.fileExists(atPath: dbFolder.path) {
                try fileManager.createDirectory(at: dbFolder, withIntermediateDirectories: true)
            }

            let dbPath = dbFolder.appendingPathComponent("bunker.sqlite3")
            db = try Connection(dbPath.path)

            try createTables()
        } catch {
            print("Database setup failed: \(error)")
        }
    }

    private func createTables() throws {
        try db?.run(decisions.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(descriptionCol)
            t.column(criteriaData)
            t.column(optionsData)
            t.column(createdAt)
            t.column(updatedAt)
        })

        try db?.run(outcomes.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(decisionId)
            t.column(outcomeData)
            t.column(createdAt)
        })
    }

    // MARK: - Decision CRUD

    func saveDecision(_ decision: Decision) throws {
        guard let db = db else { return }

        let criteriaEncoded = try JSONEncoder().encode(decision.criteria)
        let optionsEncoded = try JSONEncoder().encode(decision.options)

        let upsert = decisions.upsert(
            id <- decision.id.uuidString,
            title <- decision.title,
            descriptionCol <- decision.description,
            criteriaData <- criteriaEncoded,
            optionsData <- optionsEncoded,
            createdAt <- decision.createdAt,
            updatedAt <- Date(),
            onConflictOf: id
        )
        try db.run(upsert)
    }

    func fetchAllDecisions() throws -> [Decision] {
        guard let db = db else { return [] }

        var result: [Decision] = []
        for row in try db.prepare(decisions.order(updatedAt.desc)) {
            let criteria: [Criteria] = (try? JSONDecoder().decode([Criteria].self, from: row[criteriaData])) ?? []
            let options: [String] = (try? JSONDecoder().decode([String].self, from: row[optionsData])) ?? []

            let decision = Decision(
                id: UUID(uuidString: row[id]) ?? UUID(),
                title: row[title],
                description: row[descriptionCol],
                criteria: criteria,
                options: options,
                createdAt: row[createdAt],
                updatedAt: row[updatedAt]
            )
            result.append(decision)
        }
        return result
    }

    func fetchDecision(id decisionId: UUID) throws -> Decision? {
        guard let db = db else { return nil }

        let query = decisions.filter(id == decisionId.uuidString)
        guard let row = try db.pluck(query) else { return nil }

        let criteria: [Criteria] = (try? JSONDecoder().decode([Criteria].self, from: row[criteriaData])) ?? []
        let options: [String] = (try? JSONDecoder().decode([String].self, from: row[optionsData])) ?? []

        return Decision(
            id: UUID(uuidString: row[id]) ?? UUID(),
            title: row[title],
            description: row[descriptionCol],
            criteria: criteria,
            options: options,
            createdAt: row[createdAt],
            updatedAt: row[updatedAt]
        )
    }

    func deleteDecision(id decisionId: UUID) throws {
        guard let db = db else { return }

        let decision = decisions.filter(id == decisionId.uuidString)
        try db.run(decision.delete())

        // Also delete associated outcomes
        let relatedOutcomes = outcomes.filter(self.decisionId == decisionId.uuidString)
        try db.run(relatedOutcomes.delete())
    }

    // MARK: - Outcome CRUD

    func saveOutcome(_ outcome: Outcome) throws {
        guard let db = db else { return }

        let outcomeEncoded = try JSONEncoder().encode(outcome)

        let upsert = outcomes.upsert(
            id <- outcome.id.uuidString,
            decisionId <- outcome.decisionId.uuidString,
            outcomeData <- outcomeEncoded,
            createdAt <- outcome.generatedAt,
            onConflictOf: id
        )
        try db.run(upsert)
    }

    func fetchOutcomes(for decisionIdValue: UUID) throws -> [Outcome] {
        guard let db = db else { return [] }

        let query = outcomes.filter(decisionId == decisionIdValue.uuidString).order(createdAt.desc)
        var result: [Outcome] = []

        for row in try db.prepare(query) {
            if let outcome = try? JSONDecoder().decode(Outcome.self, from: row[outcomeData]) {
                result.append(outcome)
            }
        }
        return result
    }

    func deleteOutcomes(for decisionIdValue: UUID) throws {
        guard let db = db else { return }

        let relatedOutcomes = outcomes.filter(decisionId == decisionIdValue.uuidString)
        try db.run(relatedOutcomes.delete())
    }
}
