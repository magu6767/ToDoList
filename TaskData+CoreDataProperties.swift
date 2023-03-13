//
//  TaskData+CoreDataProperties.swift
//  NotificationTask
//
//  Created by 間口秀人 on 2023/02/22.
//
//

import Foundation
import CoreData


extension TaskData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskData> {
        return NSFetchRequest<TaskData>(entityName: "TaskData")
    }
    @NSManaged public var createdAt: Date?
    @NSManaged public var deadline: Date?
    @NSManaged public var daySelection: String?
    @NSManaged public var titleText: String?
    
    public var wrappedcreatedAt: Date {createdAt ?? Date()}
    public var wrappedDeadline: Date {deadline ?? Date()}
    public var wrappedDaySelection: String {daySelection ?? ""}
    public var wrappedTitleText: String {titleText ?? ""}


}

extension TaskData : Identifiable {

}
