//
//  ShareData.swift
//  ConcentrateTask
//
//  Created by 間口秀人 on 2023/02/15.
//

import SwiftUI
import CoreData

//coreData,通知に関する処理
class ViewModel: ObservableObject {
    @Published var shareTaskData: TaskData!
    @Published var createdAt =  Date()
    @Published var selectedDay = "なし"
    @Published var titleText = ""
    @Published var today = Calendar.current.dateComponents([.year,.month,.day], from: Date())
    //全てのタスク
    @Published var taskStr = [String]()
    @AppStorage("munite") var munite = 0
    @AppStorage("hour") var hour = 7
    @Published var count = 0
    
    //データ保存処理
    func saveData(context: NSManagedObjectContext) {
        let newData = TaskData(context: context)
        newData.titleText = titleText
        newData.deadline = Calendar.current.date(byAdding: .day, value: selectByAdding(day: selectedDay), to: Date())
        newData.selectedDay = selectedDay
        newData.createdAt = createdAt
        try? context.save()
    }
    //設定した期限が今日よりどれくらい離れてるかカウント
    func selectByAdding(day: String) -> Int{
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
    //タスクを配列に格納
    func countTask(datas: FetchedResults<TaskData>) {
        count = 0
        taskStr = [String]()
        for data in datas{
            count += 1
            taskStr.append(data.wrappedTitleText)
        }
    }
    //通知のメソッド
    func sendNotificationRequest(notificationHuor:Int, notificationMunite:Int, title:String, body:String, identifier:String){
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        var  dateComponent = Calendar.current.dateComponents([.hour,.minute], from: Date())
        dateComponent.hour = notificationHuor
        dateComponent.minute = notificationMunite
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    //通知
    func notification() {
        let center = UNUserNotificationCenter.current()
        if taskStr != [String]() {
            sendNotificationRequest(notificationHuor: hour, notificationMunite: munite, title: "未完了のやることが"+String(count)+"件あります", body: taskStr.joined(separator: ","), identifier: "固定通知")
        } else {
            //通知するタスクがない時は通知を削除
            center.removePendingNotificationRequests(withIdentifiers: ["固定通知"])
        }
    }
}

struct TaskDataModel: Identifiable {
    var id =  UUID()
    @State var createdAt: Date
    @State var selectedDay: String
    @State var titleText: String
    @State var deadline: Date
}
