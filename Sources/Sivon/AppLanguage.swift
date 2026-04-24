import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english
    case japanese

    static let storageKey = "appLanguage"

    static var current: AppLanguage {
        AppLanguage(storedValue: UserDefaults.standard.string(forKey: storageKey) ?? "")
    }

    var id: String { rawValue }

    var locale: Locale {
        switch self {
        case .system:
            return .autoupdatingCurrent
        case .english:
            return Locale(identifier: "en")
        case .japanese:
            return Locale(identifier: "ja")
        }
    }

    var localizedName: LocalizedStringKey {
        switch self {
        case .system:
            return "System"
        case .english:
            return "English"
        case .japanese:
            return "Japanese"
        }
    }

    init(storedValue: String) {
        self = AppLanguage(rawValue: storedValue) ?? .system
    }
}
