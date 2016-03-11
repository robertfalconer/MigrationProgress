import Foundation
import UIKit
import XCPlayground

struct MigrationProgress {
    let previousAppVersion: String
    let currentAppVersion: String
    var startTime: NSDate?
    var endTime: NSDate?
    var migrationCount: Int?
    var currentMigrationItem: MigrationItem?
    var completedMigrationItems = [MigrationItem]()

    init(previousAppVersion: String, currentAppVersion: String) {
        self.previousAppVersion = previousAppVersion
        self.currentAppVersion = currentAppVersion
    }

    mutating func newMigrationItem(migratonItem: MigrationItem) {
        if let current = currentMigrationItem {
            completedMigrationItems.append(current)
        }

        currentMigrationItem = migratonItem
    }

    mutating func completeMigrations() {
        if let current = currentMigrationItem {
            completedMigrationItems.append(current)
        }

        currentMigrationItem = nil
    }
}

struct MigrationItem {
    let name: String
    let recordCount: Int
    var startTime: NSDate
    var endTime: NSDate?
    var recordsProcessed: Int = 0

    init(name: String, recordCount: Int, startTime: NSDate) {
        self.name = name
        self.recordCount = recordCount
        self.startTime = startTime
    }

    mutating func updateRecordsProcessed() {
        recordsProcessed = recordsProcessed + 1
    }
}

enum MigrationProgressEvent {
    case Started(number: Int, time: NSDate)
    case Ended(time: NSDate)
    case ItemStarted(name: String, recordCount: Int, time: NSDate)
    case ItemEnded(time: NSDate)
    case RecordProcessed()
}

class MigrationEventHandler {
    let displayDelegate: MigrationProgressDisplayDelegate
    var migrationProgress = MigrationProgress(previousAppVersion: "2.7.2", currentAppVersion: "2.8.0")

    init(displayDelegate: MigrationProgressDisplayDelegate) {
        self.displayDelegate = displayDelegate
    }

    func fire(event: MigrationProgressEvent) {
        switch event {
        case .Started(let number, let time):
            migrationProgress.migrationCount = number
            migrationProgress.startTime = time
            break
        case .Ended(let time):
            migrationProgress.endTime = time
            break
        case .ItemStarted(let name, let recordCount, let time):
            let migrationItem = MigrationItem(name: name, recordCount: recordCount, startTime: time)
            migrationProgress.newMigrationItem(migrationItem)
            break
        case .ItemEnded(let time):
            migrationProgress.currentMigrationItem?.endTime = time
            break
        case .RecordProcessed():
            migrationProgress.currentMigrationItem?.updateRecordsProcessed()
            break
        }

        displayDelegate.displayProgress(migrationProgress)
    }
}

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

    func processMigrations(displayDelegate: MigrationProgressDisplayDelegate) {
        let migrationEventHandler = MigrationEventHandler(displayDelegate: displayDelegate)
        migrationEventHandler.fire(.Started(number: migrations.count, time: NSDate()))

        for migration in migrations {
            migrationEventHandler.fire(.ItemStarted(name: migration.name, recordCount: migration.records.count, time: NSDate()))

            for _ in migration.records {
                usleep(500)
                migrationEventHandler.fire(.RecordProcessed())
            }

            migrationEventHandler.fire(.ItemEnded(time: NSDate()))
        }
    }
}

protocol MigrationProgressDisplayDelegate {
    func displayProgress(progress: MigrationProgress)
}

class MigrationViewController: UIViewController, MigrationProgressDisplayDelegate {

    let blurbLabel = UILabel(frame: CGRect(x: 100, y: 100, width: 600, height: 100))
    let migrationLabel = UILabel(frame: CGRect(x: 100, y: 200, width: 600, height: 100))
    let recordLabel = UILabel(frame: CGRect(x: 100, y: 300, width: 600, height: 100))

    override func viewDidLoad() {
        super.viewDidLoad()

        blurbLabel.textColor = UIColor.whiteColor()
        view.addSubview(blurbLabel)

        migrationLabel.textColor = UIColor.whiteColor()
        view.addSubview(migrationLabel)

        recordLabel.textColor = UIColor.whiteColor()
        view.addSubview(recordLabel)
    }

    func displayProgress(progress: MigrationProgress) {

        NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate())

        self.blurbLabel.text = "Migrating from \(progress.previousAppVersion) to \(progress.currentAppVersion)"

        if let current = progress.currentMigrationItem, count = progress.migrationCount {
            self.migrationLabel.text = "\(current.name) (\(progress.completedMigrationItems.count + 1) of \(count))"
            self.recordLabel.text = "\(current.recordsProcessed) of \(current.recordCount)"
        }
    }
}

let migrationController = MigrationViewController()
XCPlaygroundPage.currentPage.liveView = migrationController.view

let migrationSystem = MockMigrationSystem()
migrationSystem.processMigrations(migrationController)
