import SwiftUI
import FamilyControls

struct BlockListView: View {
    @ObservedObject var blockList: BlockList
    @Environment(\.dismiss) var dismiss

    @State private var showAppPicker = false
    @State private var newDomain = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                List {
                    // MARK: App picker
                    Section {
                        Button {
                            showAppPicker = true
                        } label: {
                            HStack {
                                Label("Choose Apps", systemImage: "plus.app")
                                Spacer()
                                Text("\(blockList.selection.applicationTokens.count) selected")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } header: {
                        Text("Apps")
                    }

                    // MARK: Category presets
                    Section {
                        ForEach(BlockCategory.presets) { category in
                            Toggle(category.displayName, isOn: Binding(
                                get: { blockList.enabledCategoryIDs.contains(category.id) },
                                set: { _ in blockList.toggle(categoryID: category.id) }
                            ))
                        }
                    } header: {
                        Text("Categories")
                    } footer: {
                        Text("Category blocking uses Screen Time to shield entire app groups.")
                            .font(.caption)
                    }

                    // MARK: Website domains
                    Section {
                        HStack {
                            TextField("e.g. reddit.com", text: $newDomain)
                                .keyboardType(.URL)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                            Button("Add") {
                                blockList.addDomain(newDomain)
                                newDomain = ""
                            }
                            .disabled(newDomain.trimmingCharacters(in: .whitespaces).isEmpty)
                        }

                        ForEach(blockList.blockedDomains, id: \.self) { domain in
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundStyle(.secondary)
                                Text(domain)
                            }
                        }
                        .onDelete { indices in
                            indices.forEach { blockList.blockedDomains.remove(at: $0) }
                        }
                    } header: {
                        Text("Websites")
                    } footer: {
                        Text("Domain blocking requires the Content Filter extension — see docs/SETUP.md.")
                            .font(.caption)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Block List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .familyActivityPicker(
                isPresented: $showAppPicker,
                selection: $blockList.selection
            )
        }
    }
}
