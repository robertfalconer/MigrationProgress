import Foundation

public class MigrationEventHandler {
    public var migrationData = MigrationEventData()

    private let observers: [MigrationProgessObserver]

    public init(observers: [MigrationProgessObserver]) {
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
                self.migrationData.recordMigrationStart(fromVersion: previousVersion, toVersion: currentVersion, totalMineCartItems: itemCount)
                break
            case .ProcessingEnded():
                self.migrationData.recordMigrationEnd()
                break
            case .ItemProcessingStarted(let item):
                self.migrationData.recordMigrationItemStart(item)
                break
            case .ItemProcessingEnded(let item):
                self.migrationData.recordMigrationItemEnd(item)
                break
            case .RecordProcessed():
                self.migrationData.recordMigrationItemRecordProcessed()
                break
            }

            self.notifyObservers()
        }
    }

    private func notifyObservers() {
        for observer in observers {
            observer.onProgressUpdated()
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

public protocol MigrationProgessObserver {
    func onProgressUpdated()
}
