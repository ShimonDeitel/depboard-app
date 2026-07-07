import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [DepboardEntry] = []
    @Published var isPro: Bool = false

    /// Free-tier cap. Always set safely above the seed count so a fresh
    /// install never hits the paywall immediately.
    static let freeLimit = 8

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("depboard_entries.json")
        load()
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    @discardableResult
    func add(field1: String, field2: String, field3: String) -> Bool {
        guard canAddMore else { return false }
        let entry = DepboardEntry(field1: field1, field2: field2, field3: field3)
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: DepboardEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: DepboardEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([DepboardEntry].self, from: data) {
            entries = decoded
        } else {
            entries = [
            DepboardEntry(field1: "Sample Flight Number 1", field2: "Sample Scheduled Time 1", field3: "Sample Actual Time 1"),
            DepboardEntry(field1: "Sample Flight Number 2", field2: "Sample Scheduled Time 2", field3: "Sample Actual Time 2"),
            DepboardEntry(field1: "Sample Flight Number 3", field2: "Sample Scheduled Time 3", field3: "Sample Actual Time 3")
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
