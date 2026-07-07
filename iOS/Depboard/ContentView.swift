import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: DepboardEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()

                if store.entries.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundStyle(Theme.textSecondary)
                        Text("No flights yet")
                            .font(Theme.headlineFont)
                            .foregroundStyle(Theme.textSecondary)
                    }
                } else {
                    List {
                        ForEach(store.entries) { entry in
                            Button {
                                editingEntry = entry
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.field1)
                                        .font(Theme.headlineFont)
                                        .foregroundStyle(Theme.textPrimary)
                                    Text(entry.field2)
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.textSecondary)
                                    if !entry.field3.isEmpty {
                                        Text(entry.field3)
                                            .font(Theme.captionFont)
                                            .foregroundStyle(Theme.textSecondary)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .accessibilityIdentifier("entryRow_\(entry.field1)")
                            .listRowBackground(Theme.cardBackground)
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Departure Board")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryEditorView(entry: nil)
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditorView(entry: entry)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
    }
}

struct EntryEditorView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?

    enum Field { case f1, f2, f3 }

    let entry: DepboardEntry?
    @State private var field1: String = ""
    @State private var field2: String = ""
    @State private var field3: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Flight Number") {
                    TextField("Flight Number", text: $field1)
                        .accessibilityIdentifier("field1Input")
                        .focused($focusedField, equals: .f1)
                }
                Section("Scheduled Time") {
                    TextField("Scheduled Time", text: $field2)
                        .accessibilityIdentifier("field2Input")
                        .focused($focusedField, equals: .f2)
                }
                Section("Actual Time") {
                    TextField("Actual Time", text: $field3)
                        .accessibilityIdentifier("field3Input")
                        .focused($focusedField, equals: .f3)
                }

                if entry != nil {
                    Section {
                        Button("Delete Flight", role: .destructive) {
                            if let entry { store.delete(entry) }
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteEntryButton")
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(entry == nil ? "Add Flight" : "Edit Flight")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelEntryButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .accessibilityIdentifier("saveEntryButton")
                    .disabled(field1.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let entry {
                    field1 = entry.field1
                    field2 = entry.field2
                    field3 = entry.field3
                }
            }
        }
    }

    private func save() {
        if var entry {
            entry.field1 = field1
            entry.field2 = field2
            entry.field3 = field3
            store.update(entry)
        } else {
            store.add(field1: field1, field2: field2, field3: field3)
        }
        dismiss()
    }
}
