// TODO: Implement
// Pending completion of https://www.pivotaltracker.com/story/show/115253329

public struct MigrationProgressState {

    public private(set) var count = 0

    mutating func update() {
        count = count + 1
    }
}
