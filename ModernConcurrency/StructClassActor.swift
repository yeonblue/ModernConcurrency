//
//  StructClassActor.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/17.
//


/*
 Value Type:
 - struct, enum, string, int, etc..
 - store in the stack, heap을 통한 메모리 공유가 없음
 - therad 내 stack을 이용하므로 class나 actor보다 훨씬 빠름
 - thread safe, 데이터의 copy를 전달, arc는 reference type에서만 동작
 
 Reference Type:
 - class, actor, escaping closure... etc...
 - heap에 존재, value type보다 slow
 - not thread safe
 - 할당 시 새로운 reference가 할당
 
 Stack
 - store value types
 - variable은 stack에 할당, fast
 - each thread는 각자의 stack을 보유
 
 Heap
 - store reference type
 - thread간 공유됨
 
 Struct
 - based on value, stack에 저장
 
 Class
 - refernce type(instances)
 - heap에 저장, 상속이 가능
 
 Actor
 - class와 똑같으나, thread safe
 - actor 밖에서 property를 변경 불가
 
 Struct
 - 데이터 모델은 보통 struct - 데이터를 전달할 일이 많기 때문
 - SwiftUI View도 struct(viewmodel이 바뀔 때마다, view가 새로 생성되서 그려짐)
 
 Class
 - SwiftUI - Viewmodel(ObservableObject)
 
 Actor
 - shared Manager나 Data store가 될 때 적합
 
 */

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
    
    private func actorTest1() {
        Task {
            print("----- actorTest1 -----")
            let actorA = MyActor(title: "Start title")
            let actorB = actorA
            
            // actor의 property에 접근하려면 await로 접근해야 함
            await print("actorA: ", actorA.title)
            await print("actorB: ", actorB.title)
            
            print("actorB Change")
            // actorB.title = "Second title" // actor 밖에서 변경은 불가능
            await actorB.updateTitle(newTitle: "Second title")
            
            await print("actorA: ", actorA.title)
            await print("actorB: ", actorB.title)
        }
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

// class와 차이점은 thread safe, 둘 다 heap에 존재하는 reference type
// multi-thread에서 다른 thread가 특정 property접근 시 await 해야함
actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(newTitle: String) {
        self.title = newTitle
    }
}
