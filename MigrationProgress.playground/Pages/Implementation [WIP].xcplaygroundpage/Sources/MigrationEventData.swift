import Foundation

public struct MigrationItem {
    let name: String
    let description: String
    let recordCount: UInt

    public init(name: String, description: String, recordCount: UInt) {
        self.name = name
        self.recordCount = recordCount
        self.description = description
    }
}

public struct MigrationEventData {
    public private(set) var previousAppVersion: String?
    public private(set) var currentAppVersion: String?

    public private(set) var mineCartStartTime: NSDate?
    public private(set) var mineCartEndTime: NSDate?
    public private(set) var mineCartItemStartTime: NSDate?
    public private(set) var mineCartItemEndTime: NSDate?
    public private(set) var mineCartItemName: String?
    public private(set) var mineCartItemDescription: String?

    public private(set) var totalMineCartItems: UInt = 0
    public private(set) var completedMineCartItems: UInt = 0

    public private(set) var totalMineCartItemRecords: UInt = 0
    public private(set) var completedMineCartItemRecords: UInt = 0

    public var currentMineCartItem: UInt {
        if completedMineCartItems == totalMineCartItems {
            return completedMineCartItems
        }

        return completedMineCartItems + 1
    }

    public mutating func recordMigrationStart(fromVersion previousAppVersion: String, toVersion currentAppVersion: String, totalMineCartItems: UInt) {
        self.previousAppVersion = previousAppVersion
        self.currentAppVersion = currentAppVersion
        self.totalMineCartItems = totalMineCartItems

        completedMineCartItems = 0
        completedMineCartItemRecords = 0

        //  Overall migration process
        if mineCartStartTime == nil {
            mineCartStartTime = NSDate()
        }
        mineCartEndTime = nil

        //  Migration item process
        mineCartItemStartTime = nil
        mineCartItemEndTime = nil
    }

    public mutating func recordMigrationItemStart(migrationItem: MigrationItem) {
        //  Timings
        mineCartItemStartTime = NSDate()
        mineCartItemEndTime = nil

        //  Counts
        completedMineCartItemRecords = 0
        totalMineCartItemRecords = migrationItem.recordCount

        // Description
        mineCartItemName = migrationItem.name
        mineCartItemDescription = migrationItem.description
    }

    public mutating func recordMigrationItemRecordProcessed() {
        //  Counts
        completedMineCartItemRecords += 1
    }

    public mutating func recordMigrationItemEnd(migrationItem: MigrationItem) {
        assert(completedMineCartItemRecords == totalMineCartItemRecords,
            "Migration \(mineCartItemName) ended with unmigrated records: \(completedMineCartItemRecords) of \(totalMineCartItemRecords)")

        //  Timings
        mineCartItemEndTime = NSDate()

        //  Counts
        completedMineCartItems += 1
    }

    public mutating func recordMigrationEnd() {
        assert(completedMineCartItems == totalMineCartItems,
            "Migration ended without all migrations performed: \(completedMineCartItems) of \(totalMineCartItems)")

        mineCartEndTime = NSDate()
    }
}

//var migrationEventData = MigrationEventData(fromVersion: "2.7.0", toVersion: "2.7.8", totalMineCartItems: 3)
//
//let firstMigration = MigrationItem(name: "1st migration", description: "First migration", recordCount: 3)
//let secondMigration = MigrationItem(name: "2nd migration", description: "Second migration", recordCount: 2)
//let thirdMigration = MigrationItem(name: "3rd migration", description: "Third migration", recordCount: 1)
//
//
//migrationEventData.recordMigrationStart()
//
//migrationEventData.recordMigrationItemStart(firstMigration)
//migrationEventData.recordMigrationItemRecord()
//migrationEventData.recordMigrationItemRecord()
//migrationEventData.recordMigrationItemRecord()
//migrationEventData.recordMigrationItemEnd(firstMigration)
//
//migrationEventData.completedMineCartItems
//
//migrationEventData.recordMigrationItemStart(secondMigration)
//migrationEventData.recordMigrationItemRecord()
//migrationEventData.recordMigrationItemRecord()
//migrationEventData.recordMigrationItemEnd(secondMigration)
//
//migrationEventData.completedMineCartItems
//
//migrationEventData.recordMigrationItemStart(thirdMigration)
//migrationEventData.recordMigrationItemRecord()
//migrationEventData.recordMigrationItemEnd(thirdMigration)
//
//migrationEventData.recordMigrationEnd()
//migrationEventData.completedMineCartItems


