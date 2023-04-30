//
//  RowView.swift
//  ConcentrateTask
//
//  Created by 間口秀人 on 2023/02/16.
//

import SwiftUI
import CoreData

struct RowView: View {
    @Binding var data: FetchedResults<TaskData>.Element
    @State private var today = Calendar.current.dateComponents([.year,.month,.day], from: Date())
    
    var body: some View {
        VStack(alignment: .leading){
            Text(data.wrappedTitleText)

            HStack {
                if data.selectedDay != "なし"{
                    Image(systemName: "calendar")
                    if today == Calendar.current.dateComponents([.year,.month,.day], from: data.wrappedDeadline) {
                        Text("今日")
                    }else {
                        //期限が過ぎてたら赤字で表示
                        Text(formatDate(date: data.wrappedDeadline))
                            .foregroundColor(isOver(date: data.wrappedDeadline) ? .red : .black)
                    }
                }
            }
            .opacity(0.5)
        }
    }
    private func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "M月dd日(EEEEE)"
        return dateFormatter.string(from: date)
    }
    private func isOver(date: Date) -> Bool{
        //dateComponentsは等比較しかできないので、日付が違うのを確認してDate型でも比較
        if today != Calendar.current.dateComponents([.year,.month,.day], from: date) && Date() > date{
            return true
        }else {
            return false
        }
    }
}
