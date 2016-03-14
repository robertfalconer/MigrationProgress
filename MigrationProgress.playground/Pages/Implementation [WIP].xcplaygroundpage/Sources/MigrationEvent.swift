import Foundation

public enum MigrationEvent {
    case ProcessingStarted(previousVerion: String, currentVersion: String, itemCount: UInt)
    case ProcessingEnded()
    case ItemProcessingStarted(migrationItem: MigrationItem)
    case ItemProcessingEnded(migrationItem: MigrationItem)
    case RecordProcessed()
}
