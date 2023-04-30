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
    private let persistenceController = PersistenceController.shared
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TaskData.createdAt, ascending: false)]) private var taskData: FetchedResults<TaskData>
    @Environment(\.managedObjectContext) var moc
    @ObservedObject private var viewModel = ViewModel()
    @State var isSetTaskShow = false
    @State private var selectedDay = "なし"
    @State private var titleText = ""
    @State private var indexToDelete = Int.max
    //レビュー依頼,フラグ
    @Environment(\.requestReview) private var requestReview
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
                ForEach(taskData.indices, id: \.self){ index in
                    HStack {
                        RowView(data: Binding.constant(taskData[index]))
                        Spacer()
                        Image(systemName: "arrowshape.left")
                            .foregroundColor(Color("MainColor"))
                    }
                    //行の削除
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            removeRow(index: index)
                            viewModel.updateNotice(tasks: taskData)
                        } label: {
                            Image(systemName: "checkmark.square")
                                .resizable()
                                .scaledToFit()
                        }.tint(Color("AccentColor"))
                    }
                    //タスクの内容変更
                    .contentShape(Rectangle())
                    .onTapGesture {
                        indexToDelete = index
                        titleText = taskData[index].wrappedTitleText
                        selectedDay = taskData[index].wrappedSelectedDay
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
            SetTaskView(titleText: $titleText, indexToDelete: $indexToDelete, selectedDay: $selectedDay)
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
    private func removeRow(index: Int) {
        moc.delete(taskData[index])
        do {
            try moc.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        indexToDelete = Int.max
        //レビューの依頼（一度のみ）
        if DidAppStoreReviewRequested == false {
            requestReview()
            DidAppStoreReviewRequested = true
        } else{
            return
        }
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
