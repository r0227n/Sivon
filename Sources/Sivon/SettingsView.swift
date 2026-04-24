import SwiftUI

struct SettingsView: View {
    @Binding var selectedLanguageRawValue: String

    var body: some View {
        TabView {
            GeneralSettingsPane(selectedLanguageRawValue: $selectedLanguageRawValue)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            OSSLicensesSettingsPane()
                .tabItem {
                    Label("OSS Licenses", systemImage: "doc.text")
                }
        }
        .padding(20)
        .frame(width: 560, height: 420)
    }
}

private struct GeneralSettingsPane: View {
    @Binding var selectedLanguageRawValue: String

    var body: some View {
        Form {
            Picker("Language", selection: $selectedLanguageRawValue) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.localizedName)
                        .tag(language.rawValue)
                }
            }

            Text("Changing the language updates the app immediately.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
        .navigationTitle("General")
    }
}

private struct OSSLicensesSettingsPane: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OSS Licenses")
                .font(.system(size: 17, weight: .semibold))

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(OSSLicenseItem.all) { item in
                        OSSLicenseRow(item: item)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct OSSLicenseRow: View {
    let item: OSSLicenseItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 13, weight: .semibold))
                Text("\(item.version) - \(item.license)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Link(destination: item.repositoryURL) {
                Image(systemName: "arrow.up.right.square")
            }
            .accessibilityLabel("Open repository")
        }
        .padding(10)
        .background(Color.sivonBackground, in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.sivonBorder)
        )
    }
}

private struct OSSLicenseItem: Identifiable {
    let name: String
    let version: String
    let license: String
    let repositoryURL: URL

    var id: String { name }

    static let all: [OSSLicenseItem] = [
        .init(
            name: "combine-schedulers", version: "1.2.0", license: "MIT License",
            repositoryURL: URL(string: "https://github.com/pointfreeco/combine-schedulers")!),
        .init(
            name: "swift-case-paths", version: "1.7.3", license: "MIT License",
            repositoryURL: URL(string: "https://github.com/pointfreeco/swift-case-paths")!),
        .init(
            name: "swift-clocks", version: "1.0.6", license: "MIT License",
            repositoryURL: URL(string: "https://github.com/pointfreeco/swift-clocks")!),
        .init(
            name: "swift-collections", version: "1.4.1", license: "Apache License 2.0",
            repositoryURL: URL(string: "https://github.com/apple/swift-collections")!),
        .init(
            name: "swift-composable-architecture", version: "1.25.5", license: "MIT License",
            repositoryURL: URL(
                string: "https://github.com/pointfreeco/swift-composable-architecture")!),
        .init(
            name: "swift-concurrency-extras", version: "1.3.2", license: "MIT License",
            repositoryURL: URL(string: "https://github.com/pointfreeco/swift-concurrency-extras")!),
        .init(
            name: "swift-custom-dump", version: "1.5.0", license: "MIT License",
            repositoryURL: URL(string: "https://github.com/pointfreeco/swift-custom-dump")!),
        .init(
            name: "swift-dependencies", version: "1.12.0", license: "MIT License",
            repositoryURL: URL(string: "https://github.com/pointfreeco/swift-dependencies")!),
        .init(
            name: "swift-identified-collections", version: "1.1.1", license: "MIT License",
            repositoryURL: URL(
                string: "https://github.com/pointfreeco/swift-identified-collections")!),
        .init(
            name: "swift-navigation", version: "2.8.0", license: "MIT License",
            repositoryURL: URL(string: "https://github.com/pointfreeco/swift-navigation")!),
        .init(
            name: "swift-perception", version: "2.0.10", license: "MIT License",
            repositoryURL: URL(string: "https://github.com/pointfreeco/swift-perception")!),
        .init(
            name: "swift-sharing", version: "2.8.0", license: "MIT License",
            repositoryURL: URL(string: "https://github.com/pointfreeco/swift-sharing")!),
        .init(
            name: "swift-syntax", version: "603.0.1", license: "Apache License 2.0",
            repositoryURL: URL(string: "https://github.com/swiftlang/swift-syntax")!),
        .init(
            name: "xctest-dynamic-overlay", version: "1.9.0", license: "MIT License",
            repositoryURL: URL(string: "https://github.com/pointfreeco/xctest-dynamic-overlay")!),
    ]
}
