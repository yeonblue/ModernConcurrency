//
//  SendablePractice.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/23.
//

import SwiftUI

actor CurrentUserManager {
    func updateDatabase(userInfo: ClassUserInfo) {
        
    }
}

class SendablePractiveViewModel: ObservableObject {
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        let info = ClassUserInfo(name: "Info")
        await manager.updateDatabase(userInfo: info)
    }
}

struct UserInfo: Sendable { // concurrency 에서 문제 없음을 보장
    let name: String
}

// unchecked는 단순히 컴파일러가 체크하지 않겠다는 의미, 개발자가 별도 예외처리 필요
final class ClassUserInfo: @unchecked Sendable {
    private var name: String // let이 아닐 경우 선언해야 함, 권장하지는 않음
    let queue = DispatchQueue(label: "com.ClassUserInfo")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
}

struct SendablePractice: View {
    
    @StateObject var viewModel = SendablePractiveViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                
            }
    }
}

struct SendablePractice_Previews: PreviewProvider {
    static var previews: some View {
        SendablePractice()
    }
}
