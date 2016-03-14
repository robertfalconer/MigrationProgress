import Foundation

public enum MigrationEvent {
    case ProcessingStarted()
    case ProcessingEnded()
    case ItemProcessingStarted(migrationItem: MigrationItem)
    case ItemProcessingEnded(migrationItem: MigrationItem)
    case RecordProcessed()
}
