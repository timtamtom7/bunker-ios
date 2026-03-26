import Foundation
import SQLite
import os.log

private let logger = Logger(subsystem: "com.bunker.database", category: "DatabaseService")

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
    // Extended columns (optional for backward compat)
    private let deadlineDate = SQLite.Expression<Date?>("deadline_date")
    private let reminderDate = SQLite.Expression<Date?>("reminder_date")
    private let resolvedAt = SQLite.Expression<Date?>("resolved_at")
    private let isGoodOutcome = SQLite.Expression<Bool?>("is_good_outcome")
    private let resolvedOption = SQLite.Expression<String?>("resolved_option")
    private let outcomeReflection = SQLite.Expression<String?>("outcome_reflection")
    private let journalEntriesData = SQLite.Expression<Data?>("journal_entries_data")
    private let stakeCol = SQLite.Expression<String?>("stake")
    private let reversibilityCol = SQLite.Expression<String?>("reversibility")
    private let timeHorizonCol = SQLite.Expression<String?>("time_horizon")
    private let aiAdvice = SQLite.Expression<String?>("ai_advice")
    private let decisionHistoryData = SQLite.Expression<Data?>("decision_history_data")

    // Outcome columns
    private let decisionId = SQLite.Expression<String>("decision_id")
    private let outcomeData = SQLite.Expression<Data>("outcome_data")

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let fileManager = FileManager.default
            guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                print("Database setup error: application support directory not available")
                return
            }
            let dbFolder = appSupport.appendingPathComponent("Bunker", isDirectory: true)

            if !fileManager.fileExists(atPath: dbFolder.path) {
                try fileManager.createDirectory(at: dbFolder, withIntermediateDirectories: true)
            }

            let dbPath = dbFolder.appendingPathComponent("bunker.sqlite3")
            db = try Connection(dbPath.path)

            try createTables()
            try runMigrations()
        } catch {
            logger.error("Database setup failed: \(error.localizedDescription)")
        }
    }

    private func createTables() throws {
        // Base decisions table (all columns nullable/optional for flexibility)
        try db?.run(decisions.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(title)
            t.column(descriptionCol)
            t.column(criteriaData)
            t.column(optionsData)
            t.column(createdAt)
            t.column(updatedAt)
            // Extended columns (all optional for backward compat)
            t.column(deadlineDate)
            t.column(reminderDate)
            t.column(resolvedAt)
            t.column(isGoodOutcome)
            t.column(resolvedOption)
            t.column(outcomeReflection)
            t.column(journalEntriesData)
            t.column(stakeCol)
            t.column(reversibilityCol)
            t.column(timeHorizonCol)
            t.column(aiAdvice)
            t.column(decisionHistoryData)
        })

        try db?.run(outcomes.create(ifNotExists: true) { t in
            t.column(id, primaryKey: true)
            t.column(decisionId)
            t.column(outcomeData)
            t.column(createdAt)
        })
    }

    private func runMigrations() throws {
        // Future migrations can be added here
        // e.g., check schema version and apply incremental changes
    }

    // MARK: - Decision CRUD

    func saveDecision(_ decision: Decision) throws {
        guard let db = db else { return }

        let criteriaEncoded = try JSONEncoder().encode(decision.criteria)
        let optionsEncoded = try JSONEncoder().encode(decision.options)
        let journalEncoded = try JSONEncoder().encode(decision.journalEntries)
        let historyEncoded = try JSONEncoder().encode(decision.decisionHistory)

        let upsert = decisions.upsert(
            id <- decision.id.uuidString,
            title <- decision.title,
            descriptionCol <- decision.description,
            criteriaData <- criteriaEncoded,
            optionsData <- optionsEncoded,
            createdAt <- decision.createdAt,
            updatedAt <- Date(),
            deadlineDate <- decision.deadlineDate,
            reminderDate <- decision.reminderDate,
            resolvedAt <- decision.resolvedAt,
            isGoodOutcome <- decision.isGoodOutcome,
            resolvedOption <- decision.resolvedOption,
            outcomeReflection <- decision.outcomeReflection,
            journalEntriesData <- journalEncoded,
            stakeCol <- decision.stake.rawValue,
            reversibilityCol <- decision.reversibility.rawValue,
            timeHorizonCol <- decision.timeHorizon.rawValue,
            aiAdvice <- decision.aiAdvice,
            decisionHistoryData <- historyEncoded,
            onConflictOf: id
        )
        try db.run(upsert)
    }

    func fetchAllDecisions() throws -> [Decision] {
        guard let db = db else { return [] }

        var result: [Decision] = []
        for row in try db.prepare(decisions.order(updatedAt.desc)) {
            if let decision = decodeDecision(from: row) {
                result.append(decision)
            }
        }
        return result
    }

    func fetchDecision(id decisionId: UUID) throws -> Decision? {
        guard let db = db else { return nil }

        let query = decisions.filter(id == decisionId.uuidString)
        guard let row = try db.pluck(query) else { return nil }

        return decodeDecision(from: row)
    }

    private func decodeDecision(from row: Row) -> Decision? {
        do {
            let criteria: [Criteria] = (try? JSONDecoder().decode([Criteria].self, from: row[criteriaData])) ?? []
            let options: [String] = (try? JSONDecoder().decode([String].self, from: row[optionsData])) ?? []
            let journalEntries: [JournalEntry] = (try? JSONDecoder().decode([JournalEntry].self, from: row[journalEntriesData] ?? Data())) ?? []
            let history: [DecisionHistoryEntry] = (try? JSONDecoder().decode([DecisionHistoryEntry].self, from: row[decisionHistoryData] ?? Data())) ?? []

            let stake = row[stakeCol].flatMap { StakeLevel(rawValue: $0) } ?? .medium
            let reversibility = row[reversibilityCol].flatMap { Reversibility(rawValue: $0) } ?? .moderate
            let timeHorizon = row[timeHorizonCol].flatMap { TimeHorizon(rawValue: $0) } ?? .mediumTerm

            return Decision(
                id: UUID(uuidString: row[id]) ?? UUID(),
                title: row[title],
                description: row[descriptionCol],
                criteria: criteria,
                options: options,
                createdAt: row[createdAt],
                updatedAt: row[updatedAt],
                deadlineDate: row[deadlineDate],
                reminderDate: row[reminderDate],
                resolvedAt: row[resolvedAt],
                isGoodOutcome: row[isGoodOutcome],
                resolvedOption: row[resolvedOption],
                outcomeReflection: row[outcomeReflection],
                journalEntries: journalEntries,
                stake: stake,
                reversibility: reversibility,
                timeHorizon: timeHorizon,
                aiAdvice: row[aiAdvice],
                decisionHistory: history
            )
        } catch {
            logger.error("Failed to decode decision: \(error.localizedDescription)")
            return nil
        }
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
