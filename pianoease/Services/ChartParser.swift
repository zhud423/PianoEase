import Foundation

/// Parses chart.v0.json files from the app bundle.
/// Aligned with web version: lib/chart/validation.ts
final class ChartParser {
    private var cache: [String: SongChart] = [:]

    func findChart(bySongId songId: String) -> SongChart? {
        if let cached = cache[songId] {
            return cached
        }
        guard let chart = loadChart(songId: songId) else {
            return nil
        }
        cache[songId] = chart
        return chart
    }

    private func loadChart(songId: String) -> SongChart? {
        guard let url = Bundle.main.url(
            forResource: "\(songId)-chart.v0",
            withExtension: "json"
        ) else {
            print("[ChartParser] \(songId)-chart.v0.json not found in bundle")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let chart = try JSONDecoder().decode(SongChart.self, from: data)
            return validate(chart)
        } catch {
            print("[ChartParser] Failed to decode chart for \(songId): \(error)")
            return nil
        }
    }

    private func validate(_ chart: SongChart) -> SongChart? {
        guard !chart.songId.isEmpty,
              chart.bpm > 0,
              chart.ppq > 0,
              chart.timeSignature.count == 2,
              !chart.variants.isEmpty else {
            print("[ChartParser] Validation failed for chart: \(chart.songId)")
            return nil
        }
        return chart
    }
}
