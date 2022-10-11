//
//  DoCatchTryThrow.swift
//  ModernConcurrency
//
//  Created by yeonBlue on 2022/10/11.
//

import SwiftUI

// do catch
// try, throws

class DoCatchTryThrowDataManager {
    
    var isActive: Bool = true
    
    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("Update Text", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }
    
    func getTitleWithResult() -> Result<String, Error> {
        if isActive {
            return .success("Update Text")
        } else {
            return .failure(URLError(.badURL))
        }
    }
    
    func getTitleThrowError() throws -> String {
        throw URLError(.badURL)
    }
    
    func getTitleFinal() throws -> String {
        if isActive {
            return "Final Text"
        } else {
            throw URLError(.appTransportSecurityRequiresSecureConnection)
        }
    }
}

class DoCatchTryThrowViewModel: ObservableObject {
    
    let manager = DoCatchTryThrowDataManager()
    
    @Published var text: String = "text"
    
    func fetchTitle() {
        
        // let returnValue = manager.getTitle()
        // if let newTitle = returnValue.title {
        //     self.text = newTitle
        // } else if let error = returnValue.error {
        //     self.text = error.localizedDescription
        // }
        
        //let returnValue = manager.getTitleWithResult()
        //switch returnValue {
        //case .success(let str):
        //    self.text = str
        //case .failure(let err):
        //    self.text = err.localizedDescription
        //}
        
        do {
            let newTitle = try? manager.getTitleThrowError()
            if let newTitle = newTitle {
                self.text = newTitle
            }
            
            let finalTitle = try manager.getTitleFinal()
            self.text = finalTitle
        } catch let error {
            self.text = error.localizedDescription
        }
    }
}

struct DoCatchTryThrow: View {
    
    @StateObject var viewModel = DoCatchTryThrowViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

struct DoCatchTryThrow_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrow()
    }
}
