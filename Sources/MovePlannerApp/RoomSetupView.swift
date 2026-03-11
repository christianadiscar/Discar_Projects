import SwiftUI

struct RoomSetupView: View {
    @State var project: MoveProject
    @EnvironmentObject private var store: ProjectStore
    @State private var newRoomName = ""
    @State private var roomWidth = ""
    @State private var roomDepth = ""
    @State private var floorLevel = "1"

    var body: some View {
        List {
            Section("Add Room") {
                TextField("Room name", text: $newRoomName)
                TextField("Width (ft)", text: $roomWidth)
                TextField("Depth (ft)", text: $roomDepth)
                TextField("Floor level", text: $floorLevel)
                Button("Add Room") { addRoom() }
            }

            ForEach($project.rooms) { $room in
                Section(room.name) {
                    Text("Size: \(room.width, specifier: "%.1f") x \(room.depth, specifier: "%.1f")")
                    Text("Occupancy: \(room.occupancyRatio * 100, specifier: "%.0f")%")
                    Text("AI layout suggestion: \(store.optimizeRoomLayout(room))")
                        .foregroundStyle(.secondary)

                    FurnitureEditor(room: $room)
                }
            }

            Section("Actions") {
                Button("Automatic Optimization") {
                    autoOptimize()
                }

                Button("Save") {
                    persist()
                }

                Button("Load") {
                    store.loadFromDisk()
                    if let updated = store.projects.first(where: { $0.id == project.id }) {
                        project = updated
                    }
                }
            }
        }
        .navigationTitle("Room Setup")
        .onDisappear(perform: persist)
    }

    private func addRoom() {
        let width = Double(roomWidth) ?? 0
        let depth = Double(roomDepth) ?? 0
        let level = Int(floorLevel) ?? 1
        guard !newRoomName.isEmpty, width > 0, depth > 0 else { return }

        project.rooms.append(
            RoomPlan(name: newRoomName, width: width, depth: depth, floorLevel: level)
        )
        newRoomName = ""
        roomWidth = ""
        roomDepth = ""
        floorLevel = "1"
        persist()
    }

    private func autoOptimize() {
        for index in project.rooms.indices {
            project.rooms[index].furniture.sort { lhs, rhs in
                (lhs.width * lhs.depth) > (rhs.width * rhs.depth)
            }
        }
        persist()
    }

    private func persist() {
        store.updateProject(project)
    }
}

private struct FurnitureEditor: View {
    @Binding var room: RoomPlan
    @State private var name = ""
    @State private var width = ""
    @State private var depth = ""
    @State private var height = ""
    @State private var shape: FurnitureShape = .rectangle

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TextField("Furniture name", text: $name)
                Picker("Shape", selection: $shape) {
                    ForEach(FurnitureShape.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }
                TextField("W", text: $width)
                TextField("D", text: $depth)
                TextField("H", text: $height)
                Button("Add") { addFurniture() }
            }

            ForEach(room.furniture) { item in
                Text("• \(item.name) – \(item.shape.rawValue), \(item.width, specifier: "%.1f")x\(item.depth, specifier: "%.1f")x\(item.height, specifier: "%.1f")")
                    .font(.caption)
            }
        }
    }

    private func addFurniture() {
        let w = Double(width) ?? 0
        let d = Double(depth) ?? 0
        let h = Double(height) ?? 0
        guard !name.isEmpty, w > 0, d > 0, h > 0 else { return }

        room.furniture.append(FurnitureItem(name: name, shape: shape, width: w, depth: d, height: h))

        name = ""
        width = ""
        depth = ""
        height = ""
        shape = .rectangle
    }
}
