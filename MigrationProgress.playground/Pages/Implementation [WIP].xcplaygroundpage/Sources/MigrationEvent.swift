import Foundation

public enum MigrationEvent {
    case Started(itemCount: Int, time: NSDate)
    case Ended(time: NSDate)
    case ItemStarted(name: String, recordCount: Int, time: NSDate)
    case ItemEnded(time: NSDate)
}
