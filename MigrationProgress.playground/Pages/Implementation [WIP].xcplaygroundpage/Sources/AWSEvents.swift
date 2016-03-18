import Foundation

class SKPAmazonMobileAnalytics {
    static func recordEventOfType(type: String, attributes: [String:String], metrics: [String:String]) {
        type
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

    SKPAmazonMobileAnalytics.recordEventOfType(eventType, attributes: finalizeAttributes(attributes), metrics: [:])
}

func prepareCommonEventAttributes(progressState: MigrationProgressState) -> Dictionary<RegisterMigrationEventAttribute, String> {
    //  Record generic information for all events
    //    Original app version
    //    New app version
    //    Store name
    //    iPad Model
    //    iOS Version
    //    Correlation ID
    var attributes: Dictionary<RegisterMigrationEventAttribute, String> = [:]
    attributes[.OriginalAppVersion] = progressState.previousAppVersion!
    attributes[.NewAppVersion] = progressState.currentAppVersion!
    //    attributes[.StoreName] =

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


class AWSEventMigrationProgressObserver: MigrationProgressObserver {
    func onProgressUpdated(event: MigrationEvent, progressState: MigrationProgressState) {
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

    func processingStartedEvent(progressState: MigrationProgressState) {
        let eventType = eventTypeBuilder([.RegisterMigration, .Start])
        let startTime: NSDate
        if progressState.mineCartStartTime != nil {
            startTime = progressState.mineCartStartTime!
        } else {
            startTime = NSDate()
        }

        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.FullStyle
        let startTimeString = formatter.stringFromDate(startTime)

        let attributes: Dictionary<RegisterMigrationEventAttribute, String> = [.StartTime: startTimeString]
        sendEventToAWS(eventType, progressState: progressState, attributes: attributes)
    }

    func processingEndedEvent(progressState: MigrationProgressState) {
        let eventType = eventTypeBuilder([.RegisterMigration, .Success])
        sendEventToAWS(eventType, progressState: progressState, attributes: [:])
    }

    func itemProcessingStartedEvent(migrationItem: MigrationItem, progressState: MigrationProgressState) {

    }

    func itemProcessingEndedEvent(migrationItem: MigrationItem, progressState: MigrationProgressState) {

    }
}