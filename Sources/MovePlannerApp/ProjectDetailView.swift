import SwiftUI

struct ProjectDetailView: View {
    @State var project: MoveProject
    @Bindable var store: ProjectStore
    @State private var newItemName = ""
    @State private var selectedCategory: MoveCategory = .majorBulk
    @State private var itemRoom = ""
    @State private var itemFragile = false

    var body: some View {
        Form {
            Section("Project") {
                TextField("Project name", text: $project.name)
                DatePicker("Move date", selection: $project.moveDate, displayedComponents: .date)
                Toggle("Include Room Setup page", isOn: $project.includeRoomSetup)
                TextField("Notes", text: $project.notes, axis: .vertical)
            }

            Section("Items to Move") {
                HStack {
                    TextField("Item name", text: $newItemName)
                    TextField("Room", text: $itemRoom)
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(MoveCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    Toggle("Fragile", isOn: $itemFragile)
                    Button("Add") { addItem() }
                        .disabled(newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                ForEach(project.items) { item in
                    VStack(alignment: .leading) {
                        Text(item.name)
                        Text("\(item.room) • \(item.category.rawValue)\(item.isFragile ? " • Fragile" : "")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Timeline & Gantt Suggestions") {
                Button("Generate AI-Assisted Timeline") {
                    saveProjectAndGenerateTimeline()
                }

                if project.timeline.isEmpty {
                    Text("Generate a timeline to see recommended move-day sequencing.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(project.timeline) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Day \(entry.day): \(entry.title)")
                                .font(.headline)
                            Text(entry.details)
                            Text("Transport: \(entry.suggestedTransport)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if project.includeRoomSetup {
                Section("Room Setup") {
                    NavigationLink("Open Room Setup") {
                        RoomSetupView(project: project, store: store)
                    }
                }
            }
        }
        .navigationTitle(project.name)
        .onDisappear(perform: saveProject)
    }

    private func addItem() {
        project.items.append(
            MoveItem(
                name: newItemName,
                category: selectedCategory,
                room: itemRoom.isEmpty ? "Unassigned" : itemRoom,
                isFragile: itemFragile
            )
        )
        newItemName = ""
        itemRoom = ""
        itemFragile = false
        saveProject()
    }

    private func saveProject() {
        store.updateProject(project)
    }

    private func saveProjectAndGenerateTimeline() {
        saveProject()
        store.generateTimeline(for: project.id)
        if let updated = store.projects.first(where: { $0.id == project.id }) {
            project = updated
        }
    }
}
