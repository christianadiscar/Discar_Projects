import Foundation

struct ProjectFolder: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
}

enum MoveCategory: String, CaseIterable, Codable, Identifiable {
    case majorBulk = "Major Bulk"
    case medium = "Medium"
    case boxes = "Boxes"
    case essentials = "Essentials"

    var id: String { rawValue }
}

struct MoveItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var category: MoveCategory
    var room: String
    var isFragile: Bool
}

struct TimelineEntry: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var day: Int
    var title: String
    var details: String
    var suggestedTransport: String
}

enum FurnitureShape: String, CaseIterable, Codable, Identifiable {
    case rectangle
    case square
    case circle
    case lShape = "L-Shape"

    var id: String { rawValue }
}

struct FurnitureItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var shape: FurnitureShape = .rectangle
    var width: Double
    var depth: Double
    var height: Double
}

struct RoomPlan: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var width: Double
    var depth: Double
    var floorLevel: Int
    var furniture: [FurnitureItem] = []

    var area: Double { width * depth }
    var occupiedArea: Double {
        furniture.reduce(0) { partialResult, item in
            partialResult + (item.width * item.depth)
        }
    }

    var occupancyRatio: Double {
        guard area > 0 else { return 0 }
        return min(occupiedArea / area, 1)
    }
}

struct MoveProject: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var folderID: UUID?
    var moveDate: Date = .now
    var includeRoomSetup: Bool = true
    var items: [MoveItem] = []
    var timeline: [TimelineEntry] = []
    var rooms: [RoomPlan] = []
    var notes: String = ""
}

struct AppData: Codable {
    var projects: [MoveProject] = []
    var folders: [ProjectFolder] = []
}
