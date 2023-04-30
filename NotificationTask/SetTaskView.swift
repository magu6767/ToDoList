//
//  SetTaskView.swift
//  ConcentrateTask
//
//  Created by 間口秀人 on 2023/02/11.
//

import SwiftUI

struct SetTaskView: View {
    @ObservedObject private var viewModel =  ViewModel()
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TaskData.createdAt, ascending: false)]) private var taskData: FetchedResults<TaskData>
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.dismiss) private var dismiss
    private let days = ["なし","今日","明日","2日後","3日後"]
    @FocusState private var focus:Bool
    @Binding var titleText: String
    @Binding var indexToDelete: Int
    @Binding var selectedDay: String
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("タイトルを入力", text: $titleText)
                    .padding()
                    .focused($focus)
                    .onSubmit { startTask() }
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
                Spacer()
                
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("閉じる")
                    }
                    
                    Spacer()
                    
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
                .padding(.horizontal)
                .padding(.bottom)
                .background(Color(.systemBackground))
                
            }
        }
        .onAppear() {
            // 画面を表示してから0.5秒後にキーボードを表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                focus = true
            }
        }
    }
    private func startTask() {
        //タスクを変更した場合
        if indexToDelete != Int.max {
            removeRow(index: indexToDelete)
        }
        //データ保存処理
        viewModel.createdAt = Date()
        viewModel.titleText = titleText
        viewModel.selectedDay = selectedDay
        viewModel.saveTask(context: moc)
        titleText = ""
        //通知設定
        updateTask()
        dismiss()
    }
    //行の削除
    private func removeRow(index: Int) {
        let putRow = taskData[index]
        moc.delete(putRow)
        do {
            try moc.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    //通知の更新
    private func updateTask() {
        viewModel.countTask(datas: taskData)
        viewModel.notice()
    }
    
}

//struct SetTaskView_Previews: PreviewProvider {
//    static var previews: some View {
//        SetTaskView()
//    }
//}
