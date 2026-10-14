import Foundation
import SwiftData

/// Protocol for practice data access.
/// Phase 1: LocalPracticeRepository (SwiftData)
/// Phase 2: RemotePracticeRepository (REST API sync with web backend)
protocol PracticeRepository {
    func savePracticeSession(_ session: PracticeSessionRecord) async throws
    func fetchSessions(forSongId songId: String) async throws -> [PracticeSessionRecord]
    func fetchAllSessions(limit: Int) async throws -> [PracticeSessionRecord]
    func fetchRecentSessions(days: Int) async throws -> [PracticeSessionRecord]
}

/// Local SwiftData implementation for Phase 1
final class LocalPracticeRepository: PracticeRepository {
    private let modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    @MainActor
    func savePracticeSession(_ session: PracticeSessionRecord) async throws {
        let context = ModelContext(modelContainer)
        let model = PracticeSessionModel.from(record: session)
        context.insert(model)
        try context.save()
    }
    
    @MainActor
    func fetchSessions(forSongId songId: String) async throws -> [PracticeSessionRecord] {
        let context = ModelContext(modelContainer)
        let predicate = #Predicate<PracticeSessionModel> { $0.songId == songId }
        let descriptor = FetchDescriptor<PracticeSessionModel>(predicate: predicate, sortBy: [SortDescriptor(\.startedAt, order: .reverse)])
        let models = try context.fetch(descriptor)
        return models.map { $0.toRecord() }
    }
    
    @MainActor
    func fetchAllSessions(limit: Int = 50) async throws -> [PracticeSessionRecord] {
        let context = ModelContext(modelContainer)
        var descriptor = FetchDescriptor<PracticeSessionModel>(sortBy: [SortDescriptor(\.startedAt, order: .reverse)])
        descriptor.fetchLimit = limit
        let models = try context.fetch(descriptor)
        return models.map { $0.toRecord() }
    }
    
    @MainActor
    func fetchRecentSessions(days: Int) async throws -> [PracticeSessionRecord] {
        let context = ModelContext(modelContainer)
        let since = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let predicate = #Predicate<PracticeSessionModel> { $0.startedAt >= since }
        let descriptor = FetchDescriptor<PracticeSessionModel>(predicate: predicate, sortBy: [SortDescriptor(\.startedAt, order: .reverse)])
        let models = try context.fetch(descriptor)
        return models.map { $0.toRecord() }
    }
}

/// Value type for passing practice session data between layers
struct PracticeSessionRecord {
    let id: UUID
    let songId: String
    let variant: ChartVariantId
    let mode: PracticeMode
    let score: Int
    let hitCount: Int
    let missCount: Int
    let wrongCount: Int
    let requiredNoteCount: Int
    let rightAccuracyPct: Int
    let leftAccuracyPct: Int
    let completionPct: Int
    let startedAt: Date
    let endedAt: Date?
}
