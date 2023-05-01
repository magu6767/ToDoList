//
//  ViewModel.swift
//
//  Created by 間口秀人 on 2023/02/15.
//

import SwiftUI
import CoreData

//coreData,通知に関する処理
final class DataControl: ObservableObject {
    @Published var createdAt =  Date()
    @Published var selectedDay = "なし"
    @Published var titleText = ""
    
    //データ保存処理
    func saveTask(context: NSManagedObjectContext) {
        let newData = TaskData(context: context)
        newData.titleText = titleText
        newData.deadline = Calendar.current.date(byAdding: .day, value: countDaysToDeadline(day: selectedDay), to: Date())
        newData.selectedDay = selectedDay
        newData.createdAt = createdAt
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    //設定した期限が今日よりどれくらい離れてるかカウント
    func countDaysToDeadline(day: String) -> Int{
        let byAdding : Int
        switch day {
        case "今日": byAdding = 0
        case "明日": byAdding = 1
        case "2日後": byAdding = 2
        case "3日後": byAdding = 3
        default: byAdding = 99999
        }
        return byAdding
    }
}

final class Notification {
    private let identifier = "固定通知"
    @AppStorage("munite") var munite = 0
    @AppStorage("hour") var hour = 7
    
    //通知
    func updateNotice(tasks: FetchedResults<TaskData>) {
        let center = UNUserNotificationCenter.current()
        
        if tasks.isEmpty {
            //通知を削除
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
        } else {
            var dateComponent = Calendar.current.dateComponents([.hour,.minute], from: Date())
            let taskTitles = tasks.compactMap{ $0.wrappedTitleText }
            let content = UNMutableNotificationContent()
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
            content.title = "未完了のやることが"+String(taskTitles.count)+"件あります"
            content.body = taskTitles.joined(separator: ",")
            dateComponent.hour = hour
            dateComponent.minute = munite
            center.add(UNNotificationRequest(identifier: identifier, content: content, trigger: trigger))
        }
    }
}

