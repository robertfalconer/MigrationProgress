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
    case OriginalAppVersion = "original_app_version"
    case NewAppVersion = "new_app_version"
    case StoreName = "store_name"
    case DeviceModel = "device_model"
    case OSVersion = "os_version"
    case CorrelationID = "correlation_id"
}

func sendEventToAWS(eventType: String, progressState: MigrationProgressState) {
    let attributes = prepareCommonEventAttributes(progressState)


    SKPAmazonMobileAnalytics.recordEventOfType(eventType, attributes: finalizeAttributes(attributes), metrics: [:])
}

func prepareCommonEventAttributes(progressState: MigrationProgressState) -> Dictionary<RegisterMigrationEventAttribute, String> {
    //  Record generic information for all events
    //    Original app version
    //    New app version
    //    Store name
    //    iPad Model
    //    iOS Version
    //    Correlation ID (to link related start and end events and potentially identify items that did not finish)
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
        sendEventToAWS(eventType, progressState: progressState)
    }

    func processingEndedEvent(progressState: MigrationProgressState) {
        let eventType = eventTypeBuilder([.RegisterMigration, .Success])
        sendEventToAWS(eventType, progressState: progressState)
    }

    func itemProcessingStartedEvent(migrationItem: MigrationItem, progressState: MigrationProgressState) {

    }

    func itemProcessingEndedEvent(migrationItem: MigrationItem, progressState: MigrationProgressState) {

    }
}