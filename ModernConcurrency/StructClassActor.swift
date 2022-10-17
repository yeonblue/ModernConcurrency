//
//  StructClassActor.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/17.
//

import SwiftUI

struct StructClassActor: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                runTest()
            }
    }
}

struct StructClassActor_Previews: PreviewProvider {
    static var previews: some View {
        StructClassActor()
    }
}

extension StructClassActor {
    private func runTest() {
        print("Test Start")
        
        structTest1()
        classTest1()
        
        structTest2()
        classTest2()
    }
    
    private func structTest1() {
        print("----- structTest1 -----")
        let structA = MyStruct(title: "Start title")
        print("structA: ", structA.title)
        
        var structB = structA // value이기 때문에 title을 바꾸려면 structB는 var 여야함
        print("structB: ", structB.title)
        
        print("structB Change")
        structB.title = "Second title" // 새로 만들어서 할당
        
        print("structA: ", structA.title)
        print("structB: ", structB.title) // structA를 바꾸지 않음, value를 전달
    }
    
    private func classTest1() {
        print("----- classTest1 -----")
        let classA = MyClass(title: "Start title")
        
        // classB는 let이어도 reference Type이므로 title만 var면 됨
        // classB를 바꾸는 것이 아니라 classB가 가리키고 있는 값을 바꾸는 것이므로
        let classB = classA
        
        print("classA: ", classA.title)
        print("classB: ", classB.title)
        
        print("classB Change")
        classB.title = "Second title" // reference므로 classA, classB 모두 변경
        
        print("classA: ", classA.title)
        print("classB: ", classB.title) // structA를 바꾸지 않음, value를 전달
    }
    
    private func structTest2() {
        print("----- structTest2 -----")
        
        var struct1 = MyStruct(title: "Title1")
        print("struct1: ", struct1.title)
        
        struct1.title = "Title2"
        print("struct1: ", struct1.title)
        
        var struct2 = CustomStruct(title: "Title1")
        print("struct2: ", struct2.title)
        struct2 = CustomStruct(title: "Title2")
        print("struct2: ", struct2.title)
        
        var struct3 = CustomStruct(title: "Title1")
        print("struct3: ", struct3.title)
        struct3 = struct3.updateTitle(newTitle: "Title2")
        print("struct3: ", struct3.title)
        
        var struct4 = MutateStruct(title: "Title1")
        print("struct4: ", struct4.title)
        struct4.updateTitle(newTitle: "Title2")
        print("struct4: ", struct4.title)
    }
    
    private func classTest2() {
        print("----- classTest2 -----")
        
        let class1 = MyClass(title: "Title1")
        print("class1: ", class1.title)
        
        class1.title = "Title2"
        print("class1: ", class1.title)
        
        let class2 = MyClass(title: "Title1") // object는 변함이 없음
        print("class2: ", class2.title)
        class2.updateTitle(newTitle: "Title2")
        print("class2: ", class2.title)
    }
}

// immutable struct
// 작거나, copy가 많이 일어날 경우 struct가 적합, memory leak, race condition 걱정이 덜함
// thread는 별도의 stack을 가지고 있고 heap에 있는 data는 공유되므로, syncronize가 struct는
// 필요없으므로 struct가 class보다 빠름
struct MyStruct {
    var title: String // implicit init 생성
}

struct CustomStruct {
    private(set) var title: String
    
    init(title: String) {
        self.title = title
    }
    
    // object를 change시키고 있음(새로 생성)
    func updateTitle(newTitle: String) -> CustomStruct {
        CustomStruct(title: newTitle)
    }
}

struct MutateStruct {
    var title: String
    
    mutating func updateTitle(newTitle: String) {
        // self is immutalble 에러 발생, mutating 추가
        // 새로운 object 생성
        self.title = newTitle
    }
}

class MyClass { // heap에 저장, escaping closure도 heap에 존재
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        self.title = newTitle
    }
}
