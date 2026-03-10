import Foundation
import Combine
import FamilyControls

// MARK: - Category preset
//
// ActivityCategoryToken is an opaque system token that only comes FROM a
// FamilyActivitySelection — we cannot construct one manually.
// BlockCategory is purely a UI label; actual category blocking is handled
// through the tokens the user picks in FamilyActivityPicker.

struct BlockCategory: Identifiable, Hashable {
    let id: String
    let displayName: String
}

extension BlockCategory {
    static let presets: [BlockCategory] = [
        BlockCategory(id: "social", displayName: "Social Media"),
        BlockCategory(id: "video",  displayName: "Video & Streaming"),
        BlockCategory(id: "games",  displayName: "Games"),
        BlockCategory(id: "adult",  displayName: "Adult Content"),
    ]
}

// MARK: - Persisted block list

final class BlockList: ObservableObject {
    // The FamilyActivitySelection chosen via FamilyActivityPicker.
    // FamilyActivitySelection conforms to Codable on iOS 16+.
    @Published var selection: FamilyActivitySelection {
        didSet { saveSelection() }
    }

    // Website domains the user typed manually.
    @Published var blockedDomains: [String] {
        didSet { saveDomainsAndCategories() }
    }

    // Category preset IDs toggled on.
    @Published var enabledCategoryIDs: Set<String> {
        didSet { saveDomainsAndCategories() }
    }

    // MARK: - Keys

    private let selectionKey  = "blockListSelection"
    private let domainsKey    = "blockedDomains"
    private let categoryKey   = "enabledCategories"

    // MARK: - Init

    init() {
        if let data = UserDefaults.standard.data(forKey: "blockListSelection"),
           let sel  = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) {
            selection = sel
        } else {
            selection = FamilyActivitySelection()
        }

        blockedDomains     = UserDefaults.standard.stringArray(forKey: "blockedDomains") ?? []
        let saved          = UserDefaults.standard.stringArray(forKey: "enabledCategories") ?? []
        enabledCategoryIDs = Set(saved)
    }

    // MARK: - Helpers

    var isEmpty: Bool {
        selection.applicationTokens.isEmpty &&
        selection.categoryTokens.isEmpty &&
        blockedDomains.isEmpty &&
        enabledCategoryIDs.isEmpty
    }

    func addDomain(_ domain: String) {
        let cleaned = domain.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty, !blockedDomains.contains(cleaned) else { return }
        blockedDomains.append(cleaned)
    }

    func removeDomain(_ domain: String) {
        blockedDomains.removeAll { $0 == domain }
    }

    func toggle(categoryID: String) {
        if enabledCategoryIDs.contains(categoryID) {
            enabledCategoryIDs.remove(categoryID)
        } else {
            enabledCategoryIDs.insert(categoryID)
        }
    }

    // MARK: - Persistence

    private func saveSelection() {
        if let data = try? JSONEncoder().encode(selection) {
            UserDefaults.standard.set(data, forKey: selectionKey)
        }
    }

    private func saveDomainsAndCategories() {
        UserDefaults.standard.set(blockedDomains, forKey: domainsKey)
        UserDefaults.standard.set(Array(enabledCategoryIDs), forKey: categoryKey)
    }
}
