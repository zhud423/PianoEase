import Foundation

/// Loads and provides access to the bundled song catalog.
@Observable
final class SongCatalog {
    private(set) var songs: [Song] = []

    init() {
        loadManifest()
    }

    func findSong(byId id: String) -> Song? {
        songs.first { $0.id == id }
    }

    func search(query: String) -> [Song] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return songs
        }
        let q = query.lowercased()
        return songs.filter { song in
            song.title.lowercased().contains(q) ||
            song.subtitle.lowercased().contains(q) ||
            song.id.lowercased().contains(q)
        }
    }

    private func loadManifest() {
        guard let url = Bundle.main.url(forResource: "manifest", withExtension: "json") else {
            print("[SongCatalog] manifest.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let manifest = try JSONDecoder().decode(SongManifest.self, from: data)
            songs = manifest.songs
        } catch {
            print("[SongCatalog] Failed to decode manifest: \(error)")
        }
    }
}
