//
//  ActorPractice.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/22.
//

import SwiftUI

class MyDataManager {
    
    // race condition을 막기 위한 별도의 queue
    private let lock = DispatchQueue(label: "com.MyDataManager")
    
    static let instance = MyDataManager()
    private init() {}
    
    var data: [String] = []
    
    func getRandomData(completion: @escaping (_ title: String?) -> Void) {
        lock.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            
            completion(self.data.randomElement())
        }
    }
}

// 멀티스레드 환경에서 race condition 문제 해결에 적합
actor MyActorDataManager {
    
    // actor 안의 변수들은 isolated 되어있음
    
    static let instance = MyActorDataManager()
    private init() {}
    
    var data: [String] = []
    
    func getRandomData() -> String? {
        self.data.append(UUID().uuidString)
        print(Thread.current)
        
        return self.data.randomElement()
    }
    
    // 굳이 safe thread가 필요없을 경우 선언하면 await 안붙여도 사용 가능
    nonisolated func getStaticData() -> String {
        
        // nonisolated 함수 내에서는 아래와 같이 호출 불가
        // let data = getRandomData()
        
        return "static Data"
    }
}

struct HomeView: View {
    
    @State private var text: String = ""
    let manager = MyActorDataManager.instance
    
    let timer = Timer.publish(every: 0.1,
                              tolerance: nil,
                              on: .main,
                              in: .common,
                              options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.3).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }.onReceive(timer) { _ in
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    DispatchQueue.main.async {
//                        if let data = title {
//                            self.text = data
//                        }
//                    }
//                }
//            }
            
            Task {
                if let text = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = text
                    }
                }
            }
        }
        .onAppear {
            
            // Actor-isolated property 'data' can not be referenced from the main actor
            // print(manager.data)
            
            Task {
                // await print(manager.data) // 별도 처리가 없으면 await로 받아야 함
                print(manager.getStaticData())
            }
        }
    }
}

struct BrowseView: View {
    
    @State private var text: String = ""
    let manager = MyActorDataManager.instance
    
    let timer = Timer.publish(every: 0.1,
                              tolerance: nil,
                              on: .main,
                              in: .common,
                              options: nil).autoconnect()
    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.3).ignoresSafeArea()
            Text(text)
        }.onReceive(timer) { _ in
//            DispatchQueue.global(qos: .default).async {
//                manager.getRandomData { title in
//                    DispatchQueue.main.async {
//                        if let data = title {
//                            self.text = data
//                        }
//                    }
//                }
//            }
            
            // getRandomData()가 async 선언안해도, actor로 정의했기에 await로 받아야 함
            Task {
                if let text = await manager.getRandomData() {
                    await MainActor.run {
                        self.text = text
                    }
                }
            }
        }
    }
}

struct ActorPractice: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ActorPractice_Previews: PreviewProvider {
    static var previews: some View {
        ActorPractice()
    }
}
