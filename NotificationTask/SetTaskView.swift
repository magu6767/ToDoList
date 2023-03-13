//
//  SetTaskView.swift
//  ConcentrateTask
//
//  Created by 間口秀人 on 2023/02/11.
//

import SwiftUI

struct SetTaskView: View {
    @ObservedObject var viewModel =  ViewModel()
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: false)]) var TaskData: FetchedResults<TaskData>
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) private var dismiss
    let days = ["なし","今日","明日","2日後","3日後"]
    // フォーカスが当たるTextFieldを判断するためのenumを作成
      enum Field: Hashable {
          case text
      }
    //現在フォーカスしているのが、どのテキストフィールドか（カスタムField型）を定義
    @FocusState private var focusedField: Field?
    @Binding var titleText: String
    @Binding var deleteIndex: Int
    @Binding var daySelection: String

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("タイトルを入力", text: $titleText, onCommit: {
                   taskStart()
                })
                    .padding()
                    .focused($focusedField, equals: .text)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard){
                            Button {
                                dismiss()
                            } label: {
                                Text("閉じる")
                            }
                            Spacer()
                            Button(action: {
                                taskStart()
                            }, label: {
                                Text("開始")
                                    .padding(5)
                                    .foregroundColor(.white)
                                    .background(Color("AccentColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color("AccentColor"), lineWidth: 2)
                                    )
                            })
                        }
                    }
                Text("いつまでに終わらせる？")
                    .padding(.horizontal, 10)
                    .opacity(0.7)
                Picker(selection: $daySelection, label: EmptyView()){
                    ForEach(days, id: \.self){ day in
                        Text(day)
                    }
                }
                .padding(.horizontal, 10)
                .pickerStyle(.segmented)
                Spacer()
            }
        }
        .onAppear() {
            // 画面を表示してから0.5秒後にキーボードを表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
                focusedField = .text
            }
        }
    }
    func taskStart() {
        //タスクを変更した場合
        if deleteIndex != Int.max {
            rowRemove(index: deleteIndex)
        }
        //データ保存処理
        viewModel.createdAt = Date()
        viewModel.titleText = titleText
        viewModel.daySelection = daySelection
        viewModel.saveData(context: moc)
        titleText = ""
        //通知設定
        update()
        dismiss()
    }
    //行の削除
    func rowRemove(index: Int) {
        let putRow = TaskData[index]
        moc.delete(putRow)
        do {
            try moc.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    //通知の更新
    func update() {
        viewModel.countTask(datas: TaskData)
        viewModel.notification()
    }

}

//struct SetTaskView_Previews: PreviewProvider {
//    static var previews: some View {
//        SetTaskView()
//    }
//}
