import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [SpotEntry] = []
    @Published var isPro: Bool = false

    // Free-tier cap. Kept comfortably above seed-data count so a fresh
    // install never trips the paywall immediately.
    static let freeLimit = 30

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("skincheck_entries.json")
        load()
    }

    func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([SpotEntry].self, from: data) {
            entries = decoded
        } else {
            entries = [
            SpotEntry(date: Date().addingTimeInterval(-0), title: "Mole, left forearm", metric: 2, tag: "Arm"),
            SpotEntry(date: Date().addingTimeInterval(-86400), title: "New freckle, upper back", metric: 1, tag: "Back")
            ]
            save()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    @discardableResult
    func add(title: String, metric: Int, tag: String, note: String = "") -> Bool {
        guard canAddMore else { return false }
        entries.insert(SpotEntry(title: title, metric: metric, tag: tag, note: note), at: 0)
        save()
        Haptics.success()
        return true
    }

    func update(_ entry: SpotEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: SpotEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
}
