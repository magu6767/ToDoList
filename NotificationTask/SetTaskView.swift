//
//  SetTaskView.swift
//  ConcentrateTask
//
//  Created by 間口秀人 on 2023/02/11.
//

import SwiftUI

struct SetTaskView: View {
    @ObservedObject private var dataControl =  DataControl()
    private var notification = Notification()
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TaskData.createdAt, ascending: false)]) private var taskData: FetchedResults<TaskData>
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss
    private let days = ["なし","今日","明日","2日後","3日後"]
    @FocusState private var focus:Bool
    @Binding var titleText: String
    @Binding var indexToDelete: Int
    @Binding var selectedDay: String
    init(titleText: Binding<String>, indexToDelete: Binding<Int>, selectedDay: Binding<String>) {
        _titleText = titleText
        _indexToDelete = indexToDelete
        _selectedDay = selectedDay
    }
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("タイトルを入力", text: $titleText)
                    .padding()
                    .focused($focus)
                    .onSubmit { startTask() }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                                Button(action: {
                                    dismiss()
                                }) {
                                    Text("閉じる")
                                }
                                
                                
                                Button(action: {
                                    startTask()
                                }) {
                                    Text("開始")
                                        .padding(5)
                                        .foregroundColor(.white)
                                        .background(Color("AccentColor"))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 5)
                                                .stroke(Color("AccentColor"), lineWidth: 2)
                                        )
                                }
                                
                            
                        }
                    }
                Text("いつまでに終わらせる？")
                    .padding(.horizontal, 10)
                    .opacity(0.7)
                Picker(selection: $selectedDay, label: EmptyView()){
                    ForEach(days, id: \.self){ day in
                        Text(day)
                    }
                }
                .padding(.horizontal)
                .pickerStyle(.segmented)
            }
        }
        .onAppear() { focus = true }
    }
    private func startTask() {
        //タスクを変更した場合は元データを削除
        if indexToDelete != Int.max {
            moc.delete(taskData[indexToDelete])
            do {
                try moc.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        //データ追加
        dataControl.createdAt = Date()
        dataControl.titleText = titleText
        dataControl.selectedDay = selectedDay
        dataControl.saveTask(context: moc)
        titleText = ""
        //通知設定
        notification.updateNotification(tasks: taskData)
        dismiss()
    }
}
