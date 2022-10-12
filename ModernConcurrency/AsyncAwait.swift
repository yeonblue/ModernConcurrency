//
//  AsyncAwait.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/12.
//

import SwiftUI

class AsyncAwaitViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    
    func addTitleMainAfterOneSecond() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.dataArray.append("row1 - \(Thread.current)")
        }
    }
    
    func addTitleBackgroundAfterTwoSecond() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            self.dataArray.append("row2 - \(Thread.current)")
        }
    }
    
    func addTitleWithAsync() async {
        
        let title = "row3 - \(Thread.current)"
        self.dataArray.append(title)
        try? await Task.sleep(nanoseconds: 500_000_000) // 백그라운드 thread 진입
        
        await MainActor.run {
            let title = "row4 - \(Thread.current)"
            self.dataArray.append(title)
        }
    }
    
    func doSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
}


struct AsyncAwait: View {
    
    @StateObject var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { data in
                Text(data)
            }
        }.onAppear {
            viewModel.addTitleMainAfterOneSecond()
            viewModel.addTitleBackgroundAfterTwoSecond()
            
            Task {
                await viewModel.addTitleWithAsync()
                // await 작업 전까지 suspend, 이후 작업 진행
                
                viewModel.dataArray.append("after async")
            }
        }
    }
}

struct AsyncAwait_Previews: PreviewProvider {
    static var previews: some View {
        AsyncAwait()
    }
}
