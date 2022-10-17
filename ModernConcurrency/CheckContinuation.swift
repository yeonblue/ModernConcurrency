//
//  CheckContinuation.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/17.
//

import SwiftUI

class CheckContinuationNetworkManager {
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { contiuation in
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    contiuation.resume(returning: data)
                } else if let error = error {
                    contiuation.resume(throwing: error)
                } else {
                    contiuation.resume(throwing: URLError(.badURL))
                }
            }.resume()
        }
    }
    
    func getHeartImageAfterFiveSeconds(completion: @escaping (UIImage) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completion(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageWithContinuation() async -> UIImage {
        return await withCheckedContinuation { continuation in
            getHeartImageAfterFiveSeconds { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class CheckContinuationViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    let networkManager = CheckContinuationNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/200") else {
            return
        }
        
        do {
            let data = try await networkManager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.image = image
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getHeartImage() {
        networkManager.getHeartImageAfterFiveSeconds { [weak self] image in
            self?.image = image
        }
    }
    
    func getHeartImageAsync() async {
        self.image = await networkManager.getHeartImageWithContinuation()
    }
}

struct CheckContinuation: View {
    
    @StateObject var viewModel = CheckContinuationViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 200, height: 200)
            }
        }.task {
            // await viewModel.getImage()
            await viewModel.getHeartImageAsync()
        }
    }
}

struct CheckContinuation_Previews: PreviewProvider {
    static var previews: some View {
        CheckContinuation()
    }
}
