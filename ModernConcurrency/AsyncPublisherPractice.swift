//
//  AsyncPublisherPractice.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/23.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("One")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        myData.append("Two")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        myData.append("Three")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        myData.append("Four")
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        myData.append("Five")
    }
}

class AsyncPublisherPracticeViewModel: ObservableObject {
    
    @Published var dataArray: [String] = []
    let manager = AsyncPublisherDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscriber()
    }
    
    func addSubscriber() {
//        manager.$myData
//            .sink { _ in
//
//            } receiveValue: { arr in
//                self.dataArray = arr
//            }.store(in: &cancellables)
        
        Task { @MainActor in
            for await data in manager.$myData.values { // 응답을 계속 기다림, 끝이 나지 않음
                self.dataArray = data
            }
            
            print("End") // 실행될 일이 없음, 별도의 Task로 감싸야 함
        }
        
        Task { @MainActor in // dropFirst(), map() 등 여러 transform을 할 수 있음
            for await data in manager.$myData.values.dropFirst() {
                self.dataArray = data
            }
            
            print("End") // 실행될 일이 없음, 별도의 Task로 감싸야 함
        }
    }
    
    func start() async {
        await manager.addData()
    }
}

struct AsyncPublisherPractice: View {
    
    @StateObject var viewModel = AsyncPublisherPracticeViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) { data in
                    Text(data)
                        .font(.headline)
                }
            }
        }.task {
            await viewModel.start()
        }
    }
}

struct AsyncPublisherPractice_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherPractice()
    }
}
