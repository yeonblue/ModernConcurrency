//
//  AsyncLet.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/13.
//

import SwiftUI

struct AsyncLet: View {
    
    @State private var images: [UIImage] = []
    
    let column = [GridItem(.flexible()), GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/200")!
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: column) {
                    ForEach(images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                    }
                }
            }.navigationTitle("AsyncLet")
                .task {
                    do {
                        
                        /// async let에서는 await를 붙이지 않아도 됨, 나중에 한번에 실행 가능
                        /// 응답도 return값이 다른 여러 개를 한 번에 받을 수 있음
                        async let fetchImage1 = fetchImage()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
                        
                        // 하나라도 실패하면 catch로 던져질 것임
                        // try?로 하면 UIImage?로 받을 수는 있음
                        let (img1, img2, img3, img4) = await (try fetchImage1,
                                                              try fetchImage2,
                                                              try fetchImage3,
                                                              try fetchImage4)
                        
                        self.images.append(contentsOf: [img1, img2, img3, img4])
                        
                        async let fetchImage5 = fetchImage()
                        async let newTitle = fetchTitle()
                        
                        let (img, title) = await (try fetchImage5, newTitle)
                        self.images.append(img)
                        print(title)
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
        }
    }
    
    func fetchImage() async throws -> UIImage {
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
    
    func fetchTitle() async -> String {
        return "new Title"
    }
}

struct AsyncLet_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLet()
    }
}
