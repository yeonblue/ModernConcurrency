//
//  GlobalActorPractice.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/22.
//

import SwiftUI


@globalActor struct MyGlobalActor {
    static var shared = GlobalActorDataManager()
}

actor GlobalActorDataManager {
    
    func getDataFromDataBase() -> [String] {
        return ["1", "2", "3"]
    }
}

class GlobalActorViewModel: ObservableObject {
    
    @MainActor @Published var dataArray: [String] = []
    let manager = MyGlobalActor.shared
    
    @MyGlobalActor func getData() {
        
        // heavy 작업 존재 가정
        
        Task {
            let data = await manager.getDataFromDataBase()
            await MainActor.run {
                self.dataArray = data
            }
        }
    }
}

struct GlobalActorPractice: View {
    
    @StateObject var viewModel = GlobalActorViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) { data in
                    Text(data)
                        .font(.headline)
                }
            }
        }.task {
            // Call to global actor 'MyGlobalActor'-isolated instance method 'getData()' in a synchronous main actor-isolated context
            // viewModel.getData()
            
            await viewModel.getData()
        }
    }
}

struct GlobalActorPractice_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorPractice()
    }
}
