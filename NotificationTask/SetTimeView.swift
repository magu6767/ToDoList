//
//  SetTimeView.swift
//  ConcentrateTask
//
//  Created by 間口秀人 on 2023/02/20.
//

import SwiftUI

struct SetTimeView: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TaskData.createdAt, ascending: false)]) private var taskData: FetchedResults<TaskData>
    @ObservedObject private var viewModel =  ViewModel()
    @State private var hour = 7
    @State private var munite = 0

    var body: some View {
        VStack {
            Text("通知する時間")
                .padding()
            Text(String(viewModel.hour) + " 時 " + String(viewModel.munite) + " 分")
            HStack {
                Picker(selection: $hour, label: Text("")) {
                    ForEach(0..<24) { hour in
                        Text(String(hour))
                    }
                }
                .pickerStyle(.wheel)
                Text("時")
                Picker(selection: $munite, label: Text("")) {
                    ForEach(0..<60) { munite in
                        Text(String(munite))
                    }
                }
                .pickerStyle(.wheel)
                Text("分")
                    .padding(.trailing, 10)
            }
            Button {
                updateNotificationTime()
            } label: {
                Text("決定")
                    .fontWeight(.bold)
                    .frame(width: 80)
            }
            .buttonStyle(AnimationButtonStyle())
        }
        .navigationTitle("通知設定")
        .onAppear{
            //初期表示の設定
            hour = viewModel.hour
            munite = viewModel.munite
        }
    }
    private func updateNotificationTime() {
        viewModel.hour = hour
        viewModel.munite = munite
        viewModel.updateNotification(tasks: taskData)
    }
}
//Buttonのアニメーション
struct AnimationButtonStyle : ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(5)
            .foregroundColor(.white)
            .background(Color("MainColor"))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color("MainColor"), lineWidth: 4)
            )
            .compositingGroup()
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.linear, value: configuration.isPressed)
    }
}

struct SetTimeView_Previews: PreviewProvider {
    static var previews: some View {
        SetTimeView()
    }
}
