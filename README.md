# MovePlannerApp (iOS + macOS)

A SwiftUI multiplatform app scaffold for:
- macOS Ventura+ (macOS 13+)
- iPhone iOS 18+

## Implemented features

### Main Screen
- Project list with max 10 projects.
- Add (+) and remove (-) projects.
- Rename projects directly in project details.
- Folder support.
- iPhone-friendly context menu (press and hold) with:
  - Add to new folder
  - Move to different folder
  - Move to main screen

### Project Screen
- Add moving items by category (major bulk, medium, boxes, essentials).
- Generate timeline suggestions for move sequencing and transport recommendations.
- Timeline entries can be used as the base for a Gantt chart view.
- Optional Room Setup page toggle.

### Room Setup
- Create room plans with dimensions and floor level.
- Add furniture items with shape and dimensions.
- Automatic optimization action (sorts by footprint and updates suggestion quality).
- Save/load support using JSON persistence.

## Notes on "ChatGPT suggestions"
This scaffold includes a local heuristic timeline generator and layout optimizer. To use real ChatGPT-backed suggestions, wire `ProjectStore.generateTimeline` and `optimizeRoomLayout` to your OpenAI API flow.

## Open in Xcode
1. Open package folder in Xcode.
2. Select `MovePlannerApp` executable target.
3. Run on `My Mac` or iPhone simulator.

