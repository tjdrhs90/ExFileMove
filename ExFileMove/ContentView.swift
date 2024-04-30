//
//  ContentView.swift
//  ExFileMove
//
//  Created by 심성곤 on 4/30/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var sourcePath: URL?
    @State private var destinationPath: URL?
    @State private var message: String?
    
    var body: some View {
        VStack {
            Button("출발지 폴더 선택") {
                selectFolder { url in
                    sourcePath = url
                }
            }
            Text(sourcePath?.absoluteString ?? "")
            
            Button("목적지 폴더 선택") {
                selectFolder { url in
                    destinationPath = url
                }
            }
            Text(destinationPath?.absoluteString ?? "")
            
            Button("파일 이동") {
                moveFiles()
            }
            Text(message ?? "")
        }
    }
    
    /// 폴더 선택
    func selectFolder(completion: @escaping (URL) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.begin { response in
            if response == .OK, let url = openPanel.urls.first {
                completion(url)
            }
        }
    }
    
    /// 파일 이동
    func moveFiles() {
        guard let sourcePath,
              let destinationPath else {
            message = "Source or destination folder not selected."
            return
        }
        
        let fileName = "img.png"
        let sourceURL = sourcePath.appendingPathComponent("A").appendingPathComponent(fileName)
        let destinationFolderURL = destinationPath.appendingPathComponent("B").appendingPathComponent("C")
        let destinationFileURL = destinationFolderURL.appendingPathComponent(fileName)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: destinationFolderURL.path) { // 목적지 폴더가 있을 경우
            if fileManager.fileExists(atPath: destinationFileURL.path) { // img.png 파일이 있다면 삭제
                do {
                    try fileManager.removeItem(at: destinationFileURL)
                } catch {
                    message = "파일 삭제 실패: \(error.localizedDescription)"
                }
            }
        } else { // 목적지 폴더가 없을 경우
            do { // 폴더 생성
                try fileManager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true)
            } catch {
                message = "폴더 생성 실패: \(error.localizedDescription)"
            }
        }
        
        do { // 복사 시작
            try fileManager.copyItem(at: sourceURL, to: destinationFileURL)
            message = "복사 성공"
        } catch {
            message = "복사 실패: \(error.localizedDescription)"
        }
    }
}

#Preview {
    ContentView()
}
