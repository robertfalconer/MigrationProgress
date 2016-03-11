import Foundation
import UIKit
import XCPlayground

import Foundation

let migrationController = MigrationViewController()
XCPlaygroundPage.currentPage.liveView = migrationController.view

let eventHandler = MigrationEventHandler()
eventHandler.registerListener(migrationController)
let migrationSystem = MockMigrationSystem()

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
    migrationSystem.processMigrations(eventHandler)
}

// Simulates the migration process
class MockMigrationSystem {
    struct Migration {
        struct Record { }

        let name: String
        let records: [Record]

        init(name: String) {
            self.name = name
            self.records = Migration.generateRandomNumberOfRecords()
        }

        static func generateRandomNumberOfRecords() -> [Record] {
            var records = [Record]()
            let randomCount = Int(rand() % 51)
            for _ in 0..<randomCount {
                records.append(Record())
            }

            return records
        }
    }

    let migrations = [
        Migration(name: "Customers"),
        Migration(name: "Line Items"),
        Migration(name: "Checks"),
        Migration(name: "Register Settings"),
        Migration(name: "Line Items"),
        Migration(name: "Stock Items"),
        Migration(name: "Taxes"),
        Migration(name: "Core Data 74"),
        Migration(name: "Level Up"),
        Migration(name: "Tenders"),
        Migration(name: "Core Data 75"),
        Migration(name: "Customers"),
        Migration(name: "Modifiers"),
        Migration(name: "Matrix Stock Items"),
        Migration(name: "Matrix Variants"),
        Migration(name: "Core Data 76"),
        Migration(name: "Transactions")
    ]

    /*

    This is where we touch the migration system

    We pass in a reference to the handler, then call addEvent when we have any information to record. 
    All events will be added to an async background queue to be processed (in order) without hoilding up the migration process in anyway.

    */
    func processMigrations(handler: MigrationEventHandler) {
        for migration in migrations {
            for _ in migration.records {

                // This sleep just simulates a non-instant processing time
                let randomTime = UInt32(rand() % 500000)
                usleep(randomTime)

                // Just add any event for testing
                let event = MigrationEvent.Ended(time: NSDate())
                handler.addEvent(event)
            }
        }
    }
}

class MigrationViewController: UIViewController, MigrationProgessListenerDelegate {

    let countLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 600, height: 100))

    override func viewDidLoad() {
        super.viewDidLoad()

        countLabel.textColor = UIColor.whiteColor()
        view.addSubview(countLabel)
    }

    func onProgressUpdated() {

        // The MigrationProgessListenerDelegate will responsible for updating itself
        dispatch_async(dispatch_get_main_queue()) {
            self.countLabel.text = "\(eventHandler.migrationState.count)"
        }
    }
}
