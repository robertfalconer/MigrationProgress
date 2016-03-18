import Foundation

public class MigrationEventHandler {
    public var migrationProgressState = MigrationProgressState()

    private let observers: [MigrationProgressObserver]

    public init(observers: [MigrationProgressObserver]) {
        self.observers = observers
    }

    public func handleEvent(event: MigrationEvent) {

        // TODO: Implement
        // Correct handling of specific events

        processBlockOnEventQueue {

            // This sleep just simulates a non-instant processing time
            let randomTime = UInt32(rand() % 200000)
            usleep(randomTime)

            switch event {
            case .ProcessingStarted(let previousVersion, let currentVersion, let itemCount):
                self.migrationProgressState.recordMigrationStart(fromVersion: previousVersion, toVersion: currentVersion, totalMineCartItems: itemCount)
                break
            case .ProcessingEnded():
                self.migrationProgressState.recordMigrationEnd()
                break
            case .ItemProcessingStarted(let item):
                self.migrationProgressState.recordMigrationItemStart(item)
                break
            case .ItemProcessingEnded(let item):
                self.migrationProgressState.recordMigrationItemEnd(item)
                break
            case .RecordProcessed():
                self.migrationProgressState.recordMigrationItemRecordProcessed()
                break
            }

            self.notifyObservers(event, progressState: self.migrationProgressState)
        }
    }

    private func notifyObservers(event: MigrationEvent, progressState: MigrationProgressState) {
        for observer in observers {
            observer.onProgressUpdated(event, progressState: progressState)
        }
    }

    lazy var eventQueue: dispatch_queue_t = {
        let queue = dispatch_queue_create("com.shopkeep.migrationevents", DISPATCH_QUEUE_SERIAL)
        dispatch_set_target_queue(queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
        return queue
    }()

    private func processBlockOnEventQueue(block: () -> Void) {
        dispatch_async(eventQueue, block)
    }
}

public protocol MigrationProgressObserver {
    func onProgressUpdated(event: MigrationEvent, progressState: MigrationProgressState)
}
