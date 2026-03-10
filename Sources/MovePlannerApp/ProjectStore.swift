import Foundation
import Observation

@Observable
final class ProjectStore {
    private(set) var projects: [MoveProject]
    private(set) var folders: [ProjectFolder]
    private let saveURL: URL

    init() {
        let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.saveURL = baseURL.appendingPathComponent("move-planner-data.json")

        if let loaded = Self.load(from: saveURL) {
            self.projects = loaded.projects
            self.folders = loaded.folders
        } else {
            self.projects = []
            self.folders = []
        }
    }

    func addProject() {
        guard projects.count < 10 else { return }
        let index = projects.count + 1
        projects.append(MoveProject(name: "Project \(index)"))
        save()
    }

    func deleteProject(at offsets: IndexSet) {
        projects.remove(atOffsets: offsets)
        save()
    }

    func deleteProjects(_ ids: [UUID]) {
        projects.removeAll { ids.contains($0.id) }
        save()
    }

    func renameProject(_ projectID: UUID, to newName: String) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[index].name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        save()
    }

    func moveProject(_ projectID: UUID, to folderID: UUID?) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
        projects[index].folderID = folderID
        save()
    }

    func updateProject(_ project: MoveProject) {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else { return }
        projects[index] = project
        save()
    }

    func addFolder(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        folders.append(ProjectFolder(name: trimmed))
        save()
    }

    func folderName(for id: UUID?) -> String {
        guard let id, let folder = folders.first(where: { $0.id == id }) else {
            return "Main Screen"
        }
        return folder.name
    }

    func generateTimeline(for projectID: UUID) {
        guard let index = projects.firstIndex(where: { $0.id == projectID }) else { return }
        let project = projects[index]
        let heavyItems = project.items.filter { $0.category == .majorBulk }
        let fragileItems = project.items.filter(\.isFragile)

        var entries: [TimelineEntry] = [
            TimelineEntry(day: 1, title: "Packing kick-off", details: "Sort by room and label all boxes.", suggestedTransport: "Personal vehicle"),
            TimelineEntry(day: 2, title: "Reserve movers / U-Haul", details: "Finalize truck size and moving crew.", suggestedTransport: "Online booking")
        ]

        if !heavyItems.isEmpty {
            entries.append(
                TimelineEntry(
                    day: 3,
                    title: "Move major bulk items",
                    details: "Prioritize: \(heavyItems.map(\.name).joined(separator: ", ")).",
                    suggestedTransport: "U-Haul 20' / 26'"
                )
            )
        }

        if !fragileItems.isEmpty {
            entries.append(
                TimelineEntry(
                    day: 4,
                    title: "Fragile item transfer",
                    details: "Use padding for: \(fragileItems.map(\.name).joined(separator: ", ")).",
                    suggestedTransport: "Personal vehicle / padded bins"
                )
            )
        }

        entries.append(
            TimelineEntry(day: 5, title: "Final sweep + setup", details: "Deep clean old place and setup essentials in new home.", suggestedTransport: "Small utility run")
        )

        projects[index].timeline = entries
        save()
    }

    func optimizeRoomLayout(_ room: RoomPlan) -> String {
        let ratio = room.occupancyRatio
        switch ratio {
        case ..<0.35:
            return "Lots of open space. Add storage near wall edges and keep a 3ft central walkway."
        case 0.35..<0.65:
            return "Balanced room. Anchor largest furniture first, then align medium pieces to maintain traffic flow."
        case 0.65..<0.85:
            return "Dense layout. Rotate rectangular pieces 90° and move low-use furniture to corners."
        default:
            return "Overcrowded. Remove or relocate at least one large item before move day."
        }
    }

    func save() {
        let data = AppData(projects: projects, folders: folders)
        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: saveURL, options: .atomic)
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }

    func loadFromDisk() {
        guard let loaded = Self.load(from: saveURL) else { return }
        projects = loaded.projects
        folders = loaded.folders
    }

    private static func load(from url: URL) -> AppData? {
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(AppData.self, from: data)
        } catch {
            return nil
        }
    }
}
