//
//  DownloadImageAsync.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/11.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {
    let url = URL(string: "https://picsum.photos/200")!
    
    func handleResponse(data: Data?,
                        response: URLResponse?) -> Result<UIImage, Error> {
        guard let data = data,
              let image = UIImage(data: data),
              let response = response as? HTTPURLResponse,
              (200...300).contains(response.statusCode) else {
            return .failure(URLError(.badServerResponse))
        }
        
        return .success(image)
    }
    
    func downLoadWithEscape(completion: @escaping (Result<UIImage, Error>) -> ()) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, err in
            guard let self = self else { return }
            
            let result = self.handleResponse(data: data, response: response)
            completion(result)

        }.resume()
    }
    
    func downloadWithCombine() -> AnyPublisher<UIImage, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .tryMap { try $0.get() }
            .eraseToAnyPublisher()
    }
    
    func downloadWithAsync() async throws -> UIImage {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let imageResult = handleResponse(data: data, response: response)
            return try imageResult.get()
        } catch {
            throw error
        }
        
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncImageLoader()
    var cancelable = Set<AnyCancellable>()
    
    func fetchImage() async {
        // loader.downLoadWithEscape { result in
        //     switch result {
        //
        //     case .success(let image):
        //         DispatchQueue.main.async {
        //             self.image = image
        //         }
        //     case .failure(let err):
        //         print(err.localizedDescription)
        //     }
        // }
        
        // loader.downloadWithCombine()
        //     .receive(on: DispatchQueue.main)
        //     .sink { _ in

        //     } receiveValue: { [weak self] image in
        //         self?.image = image
        //     }.store(in: &cancelable)
        
        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageAsync: View {
    
    @StateObject var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .foregroundColor(Color.blue)
            }
        }.onAppear {
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
