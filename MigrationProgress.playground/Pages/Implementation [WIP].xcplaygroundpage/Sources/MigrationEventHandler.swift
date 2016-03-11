import Foundation

public class MigrationEventHandler {
    private var listenerDelegates = [MigrationProgessListenerDelegate]()
    private let queue = MigrationEventOperationQueue()
    public var migrationState = MigrationProgressState()

    public init() {

    }

    public func addEvent(event: MigrationEvent) {
        let operation = MigrationEventOperation(migrationEvent: event, eventHandler: self)
        queue.addOperation(operation)
    }

    public func registerListener(listener: MigrationProgessListenerDelegate) {
        listenerDelegates.append(listener)
    }

    private func notifyDelegates() {
        for listener in listenerDelegates {
            listener.onProgressUpdated()
        }
    }

    // MARK: Private Structures

    private class MigrationEventOperationQueue : NSOperationQueue {
        override init() {
            super.init()
            self.name = "JobWorkerQueue"
            self.qualityOfService = .Background
            self.maxConcurrentOperationCount = 1
        }
    }

    private class MigrationEventOperation : NSOperation {
        let migrationEvent: MigrationEvent
        let eventHandler: MigrationEventHandler

        override var asynchronous: Bool {
            return true
        }

        init(migrationEvent: MigrationEvent, eventHandler: MigrationEventHandler) {
            self.migrationEvent = migrationEvent
            self.eventHandler = eventHandler
        }

        override func main() {

            // TODO: Implement
            // Correct handling of specific events

            switch migrationEvent {
            case .Started(_, _):
                eventHandler.migrationState.update()
                break
            case .Ended(_):
                eventHandler.migrationState.update()
                break
            case .ItemStarted(_, _, _):
                eventHandler.migrationState.update()
                break
            case .ItemEnded(_):
                eventHandler.migrationState.update()
                break
            }

            eventHandler.notifyDelegates()
        }
    }
}
