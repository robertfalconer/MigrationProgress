import Foundation

public class MigrationEventHandler {
    public var migrationState: MigrationEventData

    private var observers = [MigrationProgessObserver]()

    public init(state: MigrationEventData) {
        self.migrationState = state
    }

    public func handleEvent(event: MigrationEvent) {

        // TODO: Implement
        // Correct handling of specific events

        processBlockOnEventQueue {

            // This sleep just simulates a non-instant processing time
            let randomTime = UInt32(rand() % 200000)
            usleep(randomTime)

            switch event {
            case .ProcessingStarted():
                self.migrationState.recordMigrationStart()
                break
            case .ProcessingEnded():
                self.migrationState.recordMigrationEnd()
                break
            case .ItemProcessingStarted(let migrationItem):
                self.migrationState.recordMigrationItemStart(migrationItem)
                break
            case .ItemProcessingEnded(let migrationItem):
                self.migrationState.recordMigrationItemEnd(migrationItem)
                break
            case .RecordProcessed():
                self.migrationState.recordMigrationItemRecord()
                break
            }
            
            self.notifyDelegates()
        }
    }

    public func registerListener(observer: MigrationProgessObserver) {
        observers.append(observer)
    }

    private func notifyDelegates() {
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
