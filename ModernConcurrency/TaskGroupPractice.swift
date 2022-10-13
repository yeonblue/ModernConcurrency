//
//  TaskGroupPractice.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/13.
//

import SwiftUI

class TaskGroupPracticeManager {
    func fetchImage(urlString: String = "https://picsum.photos/200") async throws -> UIImage {
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw URLError(.badURL)
        }
    }
    
    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = fetchImage()
        async let fetchImage2 = fetchImage()
        async let fetchImage3 = fetchImage()
        
        let (image1, image2, image3) = await (try fetchImage1,
                                              try fetchImage2,
                                              try fetchImage3)
        return [image1, image2, image3]
    }
    
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        
        // 에러를 던지지 않으면 withTaskGroup() 사용
        // 지금은 throws를 발생시키므로 withThrowingTaskGroup을 사용
        // 결과 값(Type)이 모두 동일해야 함, 지금은 [UIImage]를 return할 것이므로 UIImage.self 선언
        
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images = [UIImage]()
            
            let urlArr = [
                "https://picsum.photos/200",
                "https://picsum.photos/200",
                "https://picsum.photos/200",
                "https://picsum.photos/200",
                "https://picsum.photos/200",
                "https://picsum.photos/200",
                "https://picsum.photos/200",
                "https://picsum.photos/200"
            ]
            
            images.reserveCapacity(urlArr.count) // 메모리 관리가 좀 더 용이하도록 선언
            
            for url in urlArr {
                group.addTask {
                    
                    // 하나가 오류가 발생해도, 전체가 취소되지 않도록 optional 선언
                    try? await self.fetchImage(urlString: url)
                }
            }
            
            for try await image in group {
                if let image = image {
                    images.append(image)
                }
            }
            
            return images
        }
    }
}

class TaskGroupPracticeViewModel: ObservableObject {
    @Published var images = [UIImage]()
    let manager = TaskGroupPracticeManager()
    
    func getImage() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}

struct TaskGroupPractice: View {
    
    @StateObject private var viewModel = TaskGroupPracticeViewModel()
    
    let column = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: column) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                    }
                }
            }.navigationTitle("TaskGroupPractice")
                .task {
                    await viewModel.getImage()
                }
        }
    }
}

struct TaskGroupPractice_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupPractice()
    }
}
