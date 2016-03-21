import Foundation

class SKPAmazonMobileAnalytics {
    static func recordEventOfType(type: String, attributes: [String:String], metrics: [String:String]) {
        print("Recording event of type: \(type);\n\tAttributes: \(attributes)\n\tMetrics: \(metrics)")
    }
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
        let attributes: Dictionary<AWSEventAttributes, String> = [
            .StartTime: formatTime(progressState.mineCartStartTime),
            .ItemsToMigrate: String(progressState.totalMineCartItems)
        ]

        sendEventToAWS(eventType, progressState: progressState, attributes: attributes)
    }

    private func processingEndedEvent(progressState: MigrationProgressState) {
        let eventType: String
        if progressState.completedMineCartItems == progressState.totalMineCartItems {
            eventType = eventTypeBuilder([.RegisterMigration, .Success])
        } else {
            eventType = eventTypeBuilder([.RegisterMigration, .Fail])
        }

        let attributes: Dictionary<AWSEventAttributes, String> = [
            .EndTime: formatTime(progressState.mineCartEndTime),
            .ItemsToMigrate: String(progressState.totalMineCartItems),
            .ItemsMigrated: String(progressState.completedMineCartItems)
        ]

        sendEventToAWS(eventType, progressState: progressState, attributes: attributes)
    }

    private func itemProcessingStartedEvent(migrationItem: MigrationItem, progressState: MigrationProgressState) {
        let eventType = eventTypeBuilder([.RegisterMigration, .Item, .Start])
        let attributes: Dictionary<AWSEventAttributes, String> = [
            .StartTime: formatTime(progressState.mineCartItemStartTime),
            .RecordsToMigrate: String(progressState.totalMineCartItemRecords),
            .ItemRegisteredNumber: String(progressState.mineCareItemRegisteredNumber!),
            .ItemName: migrationItem.name
        ]

        sendEventToAWS(eventType, progressState: progressState, attributes: attributes)
    }

    private func itemProcessingEndedEvent(migrationItem: MigrationItem, progressState: MigrationProgressState) {
        let eventType: String
        if progressState.completedMineCartItemRecords == progressState.totalMineCartItemRecords {
            eventType = eventTypeBuilder([.RegisterMigration, .Item, .Success])
        } else {
            eventType = eventTypeBuilder([.RegisterMigration, .Item, .Fail])
        }

        let attributes: Dictionary<AWSEventAttributes, String> = [
            .EndTime: formatTime(progressState.mineCartItemEndTime),
            .RecordsToMigrate: String(progressState.totalMineCartItemRecords),
            .RecordsMigrated: String(progressState.completedMineCartItemRecords),
            .ItemRegisteredNumber: String(progressState.mineCareItemRegisteredNumber!),
            .ItemName: migrationItem.name
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

    func sendEventToAWS(eventType: String, progressState: MigrationProgressState, attributes: Dictionary<AWSEventAttributes, String>) {
        let commonAttributes = prepareCommonEventAttributes(progressState)
        var combinedAttributes: Dictionary<AWSEventAttributes, String> = attributes
        for (attribute, value) in commonAttributes {
            combinedAttributes[attribute] = value
        }

        SKPAmazonMobileAnalytics.recordEventOfType(eventType, attributes: finalizeAttributes(combinedAttributes), metrics: [:])
    }

    func prepareCommonEventAttributes(progressState: MigrationProgressState) -> Dictionary<AWSEventAttributes, String> {
        //  Record generic information for all events
        //    Store name
        //    iPad Model
        //    iOS Version
        let attributes: Dictionary<AWSEventAttributes, String> = [
            .OriginalAppVersion: progressState.previousAppVersion!,
            .NewAppVersion: progressState.currentAppVersion!,
            //    attributes[.StoreName] =

            .CorrelationID: progressState.correlationId
        ]

        return attributes
    }

    func finalizeAttributes(attributes: Dictionary<AWSEventAttributes, String>) -> Dictionary<String, String> {
        var finalizedAttributes: Dictionary<String, String> = [:]
        for (attribute, value) in attributes {
            let stringAttribute = attribute.rawValue
            finalizedAttributes[stringAttribute] = value
        }
        
        return finalizedAttributes
    }

    func eventTypeBuilder(nodes: [AWSEventBuilderNodes]) -> String {
        return nodes.map{$0.rawValue}.joinWithSeparator(".")
    }

    enum AWSEventBuilderNodes: String {
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

    enum AWSEventAttributes: String {
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
        case ItemRegisteredNumber = "item_registered_number"
        case ItemName = "item_name"
        case RecordsToMigrate = "records_to_migrate"
        case RecordsMigrated = "records_migrated"
        case ClassName = "class_name"
        case ClassesToIndex = "classes_to_index"
        case ClassesIndexed = "classes_indexed"
        
    }
}