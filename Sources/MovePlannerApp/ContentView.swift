import SwiftUI

struct ContentView: View {
    @Bindable var store: ProjectStore
    @State private var selectedProjectID: UUID?
    @State private var draftFolderName = ""

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedProjectID) {
                Section("Projects (max 10)") {
                    ForEach(store.projects) { project in
                        NavigationLink(value: project.id) {
                            VStack(alignment: .leading) {
                                Text(project.name)
                                    .font(.headline)
                                Text(store.folderName(for: project.folderID))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contextMenu {
                            ProjectContextMenu(project: project, store: store)
                        }
                    }
                    .onDelete(perform: store.deleteProject)
                }

                Section("Folders") {
                    ForEach(store.folders) { folder in
                        Label(folder.name, systemImage: "folder")
                    }

                    HStack {
                        TextField("New folder", text: $draftFolderName)
                        Button("Add") {
                            store.addFolder(named: draftFolderName)
                            draftFolderName = ""
                        }
                    }
                }
            }
            .navigationTitle("Move Projects")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        store.addProject()
                    } label: {
                        Label("Add Project", systemImage: "plus")
                    }
                    .disabled(store.projects.count >= 10)

                    Button {
                        if let id = selectedProjectID,
                           let index = store.projects.firstIndex(where: { $0.id == id }) {
                            store.deleteProjects([store.projects[index].id])
                            selectedProjectID = nil
                        }
                    } label: {
                        Label("Remove Project", systemImage: "minus")
                    }
                    .disabled(selectedProjectID == nil)
                }

                ToolbarItem(placement: .automatic) {
                    Button("Load") {
                        store.loadFromDisk()
                    }
                }
            }
        } detail: {
            if let selectedProjectID,
               let project = store.projects.first(where: { $0.id == selectedProjectID }) {
                ProjectDetailView(project: project, store: store)
            } else {
                ContentUnavailableView("Select a project", systemImage: "shippingbox")
            }
        }
    }
}

private struct ProjectContextMenu: View {
    let project: MoveProject
    @Bindable var store: ProjectStore

    var body: some View {
        Button("Move to Main Screen") {
            store.moveProject(project.id, to: nil)
        }

        Menu("Move to Different Folder") {
            ForEach(store.folders) { folder in
                Button(folder.name) {
                    store.moveProject(project.id, to: folder.id)
                }
            }
        }

        Menu("Add to New Folder") {
            Button("Create \(project.name) Folder") {
                let folderName = "\(project.name) Folder"
                store.addFolder(named: folderName)
                if let folderID = store.folders.last?.id {
                    store.moveProject(project.id, to: folderID)
                }
            }
        }
    }
}
