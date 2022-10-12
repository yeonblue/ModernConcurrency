//
//  TaskPractice.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/12.
//

import SwiftUI

class TaskPracticeViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    @MainActor func fetchImage() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else {
                return
            }
            try await Task.sleep(nanoseconds: 3_000_000_000)
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data)
            self.image = image
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else {
                return
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            let image = UIImage(data: data)
            self.image2 = image
            
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskPractice: View {
    
    @StateObject var viewModel = TaskPracticeViewModel()
    
    // Task를 가지고 있다가 뒤로가기 등 상황 발생 시 해당 Task를 취소시킬 수 있음
    // self는 immutalble 오류 발생 - @State가 아닌 일반 변수는 불가
    @State private var task: Task<(), Never>? = nil
    
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 100, height: 100)
            }
        }.onAppear {
            self.task = Task(priority: .low) {
                print(Thread.current)
                print(Task.currentPriority)
                await viewModel.fetchImage()
            }
            
            Task(priority: .high) {
                print(Thread.current)
                print(Task.currentPriority)
                await viewModel.fetchImage2()
            }
            
            // Task Priority - 먼저 끝내야한다는 것을 의미하는 것은 아님, 단순한 우선도
            // low: 17, medium: 21, high: 25, userInitiated: 25
            // utility: 17, background: 9
            
            Task(priority: .high) {
                
                // 다른 task가 먼저 실행되도록 허용, Task.sleep으로 쉬어서 넘기는 것보다 효율
                // medium이 먼저 실행될 것임
                
                await Task.yield()
                print("high")
            }
            
            Task(priority: .userInitiated) {
                print("userInitiated")
            }
            
            Task(priority: .medium) {
                print("medium")
            }
            
            Task(priority: .low) {
                print("low")
            }
            
            Task(priority: .background) {
                print("background")
            }
            
            Task(priority: .medium) {
                Task {
                    // priority는 밖의 Task와 마찬가지로 medium임
                }
            }
            
            Task(priority: .low) {
                Task.detached {
                    
                    // priority는 밖의 low와 다르게 가질 수 있음
                    // 되도록 detached는 사용하지 않는 것이 좋음
                    // Don't use a detached task if it's possible라고 공식으로 제공
                    // TaskGroup을 사용 권장
                }
            }
        }.onDisappear {
            task?.cancel() // 작업 취소
            
            // task {} 안에서는 자동으로 끝나지 않은 task는 cancel() 시킴 - iOS 15 추가
            // long task일 경우는 체크 필요 - document 참고
            // Task.checkCancellation()을 적극 사용
        }
    }
}

struct TaskPracticeView2: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click") {
                    TaskPractice()
                }
            }
        }
    }
}

struct TaskPracticeView2_Previews: PreviewProvider {
    static var previews: some View {
        TaskPracticeView2()
    }
}
