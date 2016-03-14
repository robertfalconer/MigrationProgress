import Foundation
import UIKit
import XCPlayground

import Foundation

let migrationController = MigrationViewController()
XCPlaygroundPage.currentPage.liveView = migrationController.view

let migrationSystem = MockMigrationSystem()
let eventHandler = MigrationEventHandler(observers: [migrationController])

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
    migrationSystem.processMigrations(eventHandler)
}

// Simulates the migration process
class MockMigrationSystem {
    struct Migration {
        struct Record { }

        let name: String
        let description: String
        let records: [Record]

        init(name: String, description: String) {
            self.name = name
            self.description = description
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
        Migration(name: "Customers", description: "Adding google plus field to customer collection"),
        Migration(name: "Line Items", description: "Changing modifier types"),
        Migration(name: "Checks", description: "Something to do with checks"),
        Migration(name: "Register Settings", description: "Extra card processor details"),
        Migration(name: "Line Items", description: "Kicthen not improvements"),
        Migration(name: "Stock Items", description: "Preliminary support for matrix"),
        Migration(name: "Taxes", description: "Never forget"),
        Migration(name: "Core Data 74", description: "Some things"),
        Migration(name: "Level Up", description: "Remove level up"),
        Migration(name: "Tenders", description: "Hmmm, chicken tenders"),
        Migration(name: "Core Data 75", description: "Remove another thing from core data"),
        Migration(name: "Customers", description: "Remove google plus field from customer collection"),
        Migration(name: "Modifiers", description: "Prep for matrix"),
        Migration(name: "Matrix Stock Items", description: "Add matrix stock items"),
        Migration(name: "Matrix Variants", description: "Add matrix variants"),
        Migration(name: "Core Data 76", description: "Remove stock items from core data"),
        Migration(name: "Transactions", description: "Something to do with transactions, or something")
    ]

    /*

    This is where we touch the migration system

    We pass in a reference to the handler, then call addEvent when we have any information to record. 
    All events will be added to an async background queue to be processed (in order) without hoilding up the migration process in anyway.

    */
    func processMigrations(handler: MigrationEventHandler) {

        let startEvent = MigrationEvent.ProcessingStarted(previousVerion: "2.7.2", currentVersion: "2.7.8", itemCount: UInt(migrations.count))
        handler.handleEvent(startEvent)

        for migration in migrations {

            let migrationItem = MigrationItem(name: migration.name, description: migration.description, recordCount: UInt(migration.records.count))

            let startItemEvent = MigrationEvent.ItemProcessingStarted(migrationItem: migrationItem)
            handler.handleEvent(startItemEvent)

            for _ in migration.records {

                // This sleep just simulates a non-instant processing time
                let randomTime = UInt32(rand() % 100000)
                usleep(randomTime)

                // Just add any event for testing
                let event = MigrationEvent.RecordProcessed()
                handler.handleEvent(event)
            }

            let endItemEvent = MigrationEvent.ItemProcessingEnded(migrationItem: migrationItem)
            handler.handleEvent(endItemEvent)
        }

        let endEvent = MigrationEvent.ProcessingEnded()
        handler.handleEvent(endEvent)
    }
}

class MigrationViewController: UIViewController, MigrationProgessObserver {

    let versionLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 600, height: 100))
    let itemLabel = UILabel(frame: CGRect(x: 100, y: 300, width: 600, height: 100))
    let countLabel = UILabel(frame: CGRect(x: 100, y: 500, width: 600, height: 100))

    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.textColor = UIColor.whiteColor()
        itemLabel.textColor = UIColor.whiteColor()
        countLabel.textColor = UIColor.whiteColor()

        view.addSubview(versionLabel)
        view.addSubview(itemLabel)
        view.addSubview(countLabel)
    }

    func onProgressUpdated() {

        // The MigrationProgessListenerDelegate will responsible for updating itself
        dispatch_async(dispatch_get_main_queue()) {
            if let name = eventHandler.migrationData.mineCartItemName,
                let previousVersion = eventHandler.migrationData.previousAppVersion,
                let currentVersion = eventHandler.migrationData.currentAppVersion {
                self.versionLabel.text = "Migrating from version \(previousVersion) to \(currentVersion)"
                self.itemLabel.text = "Running migration \(name) (\(eventHandler.migrationData.currentMineCartItem) of \(eventHandler.migrationData.totalMineCartItems))"
                self.countLabel.text = "Migrating records \(eventHandler.migrationData.completedMineCartItemRecords) to \(eventHandler.migrationData.totalMineCartItemRecords)"
            }
        }
    }
}
