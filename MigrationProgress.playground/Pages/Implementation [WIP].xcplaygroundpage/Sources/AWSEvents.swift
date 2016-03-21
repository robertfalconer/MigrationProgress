import Foundation

class SKPAmazonMobileAnalytics {
    static func recordEventOfType(type: String, attributes: [String:String], metrics: [String:String]) {
        print("Recording event of type: \(type);\n\tAttributes: \(attributes)\n\tMetrics: \(metrics)")
    }
}

func eventTypeBuilder(nodes: [RegisterMigrationEventBuilderNodes]) -> String {
    return nodes.map{$0.rawValue}.joinWithSeparator(".")
}

enum RegisterMigrationEventBuilderNodes: String {
    case RegisterMigration = "register_migration"
    case Database = "database"
    case Item = "item"
    case Setup = "setup"
    case SecondaryIndexing = "secondary_indexing"
    case Start = "start"
    case Success = "success"
    case Fail = "fail"
    case Class = "class"
}

enum RegisterMigrationEventAttribute: String {
    //  Common attributes
    case OriginalAppVersion = "original_app_version"
    case NewAppVersion = "new_app_version"
    case StoreName = "store_name"
    case DeviceModel = "device_model"
    case OSVersion = "os_version"
    case CorrelationID = "correlation_id"
    //  Event-specific attributes
    case StartTime = "start_time"
    case EndTime = "end_time"
    case ItemsToMigrate = "items_to_migrate"
    case ItemsMigrated = "items_migrated"
    case ItemVersionNumber = "item_version_number"
    case RecordsToMigrate = "records_to_migrate"
    case RecordsMigrated = "records_migrated"
    case ClassName = "class_name"
    case ClassesToIndex = "classes_to_index"
    case ClassesIndexed = "classes_indexed"

}

func sendEventToAWS(eventType: String, progressState: MigrationProgressState, attributes: Dictionary<RegisterMigrationEventAttribute, String>) {
    let commonAttributes = prepareCommonEventAttributes(progressState)
    var combinedAttributes: Dictionary<RegisterMigrationEventAttribute, String> = attributes
    for (attribute, value) in commonAttributes {
        combinedAttributes[attribute] = value
    }

    SKPAmazonMobileAnalytics.recordEventOfType(eventType, attributes: finalizeAttributes(combinedAttributes), metrics: [:])
}

func prepareCommonEventAttributes(progressState: MigrationProgressState) -> Dictionary<RegisterMigrationEventAttribute, String> {
    //  Record generic information for all events
    //    Original app version
    //    New app version
    //    Store name
    //    iPad Model
    //    iOS Version
    //    Correlation ID
    let attributes: Dictionary<RegisterMigrationEventAttribute, String> = [
        .OriginalAppVersion: progressState.previousAppVersion!,
        .NewAppVersion: progressState.currentAppVersion!,
        //    attributes[.StoreName] =

        .CorrelationID: progressState.correlationId
    ]

    return attributes
}

func finalizeAttributes(attributes: Dictionary<RegisterMigrationEventAttribute, String>) -> Dictionary<String, String> {
    var finalizedAttributes: Dictionary<String, String> = [:]
    for (attribute, value) in attributes {
        let stringAttribute = attribute.rawValue
        finalizedAttributes[stringAttribute] = value
    }

    return finalizedAttributes
}


public class AWSEventMigrationProgressObserver: MigrationProgressObserver {
    public init() { }

    public func onProgressUpdated(event: MigrationEvent, progressState: MigrationProgressState) {
        switch event {
        case .ProcessingStarted(_, _, _):
            processingStartedEvent(progressState)
        case .ProcessingEnded():
            processingEndedEvent(progressState)
        case .ItemProcessingStarted(let migrationItem):
            itemProcessingStartedEvent(migrationItem, progressState: progressState)
        case .ItemProcessingEnded(let migrationItem):
            itemProcessingEndedEvent(migrationItem, progressState: progressState)
        case .RecordProcessed():
            break
        }
    }

    private func processingStartedEvent(progressState: MigrationProgressState) {
        let eventType = eventTypeBuilder([.RegisterMigration, .Start])
        let attributes: Dictionary<RegisterMigrationEventAttribute, String> = [
            .StartTime: formatTime(progressState.mineCartStartTime),
            .ItemsToMigrate: String(progressState.totalMineCartItems)
        ]

        sendEventToAWS(eventType, progressState: progressState, attributes: attributes)
    }

    private func processingEndedEvent(progressState: MigrationProgressState) {
        //  TODO: determine success/failure
        let eventType = eventTypeBuilder([.RegisterMigration, .Success])
        let attributes: Dictionary<RegisterMigrationEventAttribute, String> = [
            .EndTime: formatTime(progressState.mineCartEndTime),
            .ItemsMigrated: String(progressState.completedMineCartItems)
        ]

        sendEventToAWS(eventType, progressState: progressState, attributes: attributes)
    }

    private func itemProcessingStartedEvent(migrationItem: MigrationItem, progressState: MigrationProgressState) {
        let eventType = eventTypeBuilder([.RegisterMigration, .Item, .Start])
        let attributes: Dictionary<RegisterMigrationEventAttribute, String> = [
            .StartTime: formatTime(progressState.mineCartItemStartTime),
            .RecordsToMigrate: String(progressState.totalMineCartItemRecords),
            .ItemVersionNumber: String(progressState.mineCareItemRegisteredNumber!),
            .ClassName: migrationItem.name
        ]

        sendEventToAWS(eventType, progressState: progressState, attributes: attributes)
    }

    private func itemProcessingEndedEvent(migrationItem: MigrationItem, progressState: MigrationProgressState) {
        let eventType = eventTypeBuilder([.RegisterMigration, .Item, .Success])
        let attributes: Dictionary<RegisterMigrationEventAttribute, String> = [
            .EndTime: formatTime(progressState.mineCartItemEndTime),
            .RecordsMigrated: String(progressState.completedMineCartItemRecords),
            .ItemVersionNumber: String(progressState.mineCareItemRegisteredNumber!),
            .ClassName: migrationItem.name
        ]

        sendEventToAWS(eventType, progressState: progressState, attributes: attributes)
    }



    //  MARK: helper methods
    private func formatTime(maybeTime: NSDate?) -> String {
        let time = (maybeTime != nil) ? maybeTime! : NSDate()
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.FullStyle
        return formatter.stringFromDate(time)
    }
}