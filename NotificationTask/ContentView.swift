//
//  ContentView.swift
//  ConcentrateTask
//
//  Created by 間口秀人 on 2023/02/10.
//

import SwiftUI
import CoreData
import StoreKit

struct ContentView: View {
    let persistenceController = PersistenceController.shared
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: false)]) var TaskData: FetchedResults<TaskData>
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var viewModel = ViewModel()
    @State var isSetTaskShow = false
    @State var today = Calendar.current.dateComponents([.year,.month,.day], from: Date())
    @State var titleText = ""
    @State var deleteIndex = Int.max
    @State var selectedDay = "なし"
    @State var checkFlag = false
    //レビュー依頼,フラグ
    @Environment(\.requestReview) var requestReview
    @AppStorage("DidAppStoreReviewRequested") var DidAppStoreReviewRequested = false
    @FocusState private var focusedField: Bool
    init(){
        //初めに通知許可をとる
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: .alert) { granted, error in
            if granted {
                print("許可されました！")
            }else{
                print("拒否されました...")
            }
        }
        //NavigaitonBarのカラー変更
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(Color("MainColor"))
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
    }
    
    var body: some View {
        //追加ボタンは重ねて表示
        ZStack {
            List{
                ForEach(TaskData.indices, id: \.self){ index in
                    HStack {
                        RowView(data: Binding.constant(TaskData[index]))
                        Spacer()
                        Image(systemName: "arrowshape.left")
                            .foregroundColor(Color("MainColor"))
                    }
                    //行の削除
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            rowRemove(index: index)
                            update()
                        } label: {
                                Image(systemName: "checkmark.square")
                                .resizable()
                                .scaledToFit()
                        }.tint(Color("AccentColor"))
                    }
                    //タスクの内容変更
                    .contentShape(Rectangle())
                    .onTapGesture {
                        deleteIndex = index
                        titleText = TaskData[index].wrappedTitleText
                        selectedDay = TaskData[index].wrappedDaySelection
                        self.isSetTaskShow.toggle()
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        //新規作成
                        selectedDay = "なし"
                        titleText = ""
                        self.isSetTaskShow.toggle()
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .foregroundColor(Color("MainColor"))
                            .frame(width: 60, height: 60)
                    })
                    .padding(.trailing, 50)
                    .padding(.bottom, 30)
                }
            }
        }
        .sheet(isPresented: $isSetTaskShow){
            SetTaskView(titleText: $titleText, deleteIndex: $deleteIndex, selectedDay: $selectedDay)
                //モーダルをどこまで表示させるか指定
                .presentationDetents([.fraction(0.20)])
        }
        .navigationTitle("やることリスト")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: SetTimeView()            .environment(\.managedObjectContext, persistenceController.container.viewContext)
                               , label: {
                    Image(systemName: "bell.fill")
                        .foregroundColor(Color("AccentColor"))
                })
            }
        }
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
        deleteIndex = Int.max
        //レビューの依頼（一度のみ）
        if DidAppStoreReviewRequested == false {
            requestReview()
            DidAppStoreReviewRequested = true
        } else{
            return
        }
    }
    //通知の更新
    func update() {
        viewModel.countTask(datas: TaskData)
        viewModel.notification()
    }
}

//チェックボタンのスタイル
struct CheckBoxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                Spacer()
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "checkmark.circle.fill")
                    .foregroundColor(configuration.isOn ? .gray : .green)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
