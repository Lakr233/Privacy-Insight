//
//  ContentView.swift
//  insight
//
//  Created by Lakr Aream on 2021/9/27.
//

import Colorful
import SwiftUI

private let kDefaultBackgroundColors = [#colorLiteral(red: 0.9586862922, green: 0.660125792, blue: 0.8447988033, alpha: 1), #colorLiteral(red: 0.8714533448, green: 0.723166883, blue: 0.9342088699, alpha: 1), #colorLiteral(red: 0.7458761334, green: 0.7851135731, blue: 0.9899476171, alpha: 1)]
    .map { Color($0) }

struct ContentView: View {
    @State var loading: Bool = false
    @State var progress: Progress = Progress()
    @State var insightReader: InsightReaderView?
    @State var dragOver = false

    var body: some View {
        GeometryReader { reader in
            if loading {
                ZStack {
                    VStack(spacing: 8) {
                        ProgressView()
                        ProgressView(progress)
                            .progressViewStyle(LinearProgressViewStyle())
                            .animation(.interactiveSpring(), value: progress)
                            .padding()
                        Text("Building your summary, please wait... ☕️")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .frame(width: 300)
                }
                .frame(width: reader.size.width, height: reader.size.height)
            } else if let insightReader = insightReader {
                insightReader
            } else {
                ZStack {
                    ColorfulView(colors: kDefaultBackgroundColors, colorCount: 16)
                    VStack {
                        Image("RoundedIcon")
                            .resizable()
                            .frame(width: 80, height: 80)
                        Text("Drag your file here to analyze ~")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
                .frame(width: reader.size.width, height: reader.size.height)
                .overlay(
                    ZStack {
                        Button {
                            let panel = NSOpenPanel()
                            panel.allowsMultipleSelection = false
                            panel.canChooseDirectories = false
                            if panel.runModal() == .OK, let url = panel.url {
                                loading = true
                                DispatchQueue.global().async {
                                    prepareInsightData(with: url)
                                    DispatchQueue.main.async {
                                        loading = false
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down.fill")
                                .padding(2)
                        }
                        .offset(x: 35 - reader.size.width / 2, y: reader.size.height / 2 - 25)
                    }
                    .frame(width: reader.size.width, height: reader.size.height)
                )
            }
        }
        .onDrop(of: ["public.file-url"], isTargeted: $dragOver, perform: { providers in
            providers
                .first?
                .loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { data, _ in
                    if let data = data,
                       let path = NSString(data: data, encoding: 4),
                       let url = URL(string: path as String) {
                        loading = true
                        DispatchQueue.global().async {
                            prepareInsightData(with: url)
                            DispatchQueue.main.async {
                                loading = false
                            }
                        }
                    }
                })
            return true
        })
        .animation(.interactiveSpring(), value: loading)
        .background(Color(NSColor.textBackgroundColor))
        .ignoresSafeArea()
    }

    func prepareInsightData(with url: URL) {
        debugPrint("[i] loading insight data \(url.path)")
        guard url.pathExtension.lowercased() == "ndjson" else {
            errorProcessingInsight(with: "Wrong format, requires .ndjson file.")
            return
        }
        var read: Data?
        do {
            read = try Data(contentsOf: url)
        } catch {
            errorProcessingInsight(with: error.localizedDescription)
        }
        guard let read = read,
              let text = String(data: read, encoding: .utf8)
        else {
            errorProcessingInsight(with: "Failed to decode record file.")
            return
        }
        debugPrint("[i] loaded ndjson with length: \(read.count)")
        var privacyAccessBuilder: [NDPrivacyAccess] = []
        var networkAccessBuilder: [NDNetworkAccess] = []
        analyzer: for line in text.components(separatedBy: "\n") {
            let cleanedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanedLine.count < 1 { continue analyzer }
            // try for each decoder
            if let privacyAccess = try? NDPrivacyAccess(cleanedLine) {
                privacyAccessBuilder.append(privacyAccess)
                continue analyzer
            }
            if let networkAccess = try? NDNetworkAccess(cleanedLine) {
                networkAccessBuilder.append(networkAccess)
                continue analyzer
            }
            debugPrint("[E] ignoring unknown line")
        }
        let summary = NDPrivacySummary(privacyAccess: privacyAccessBuilder,
                                       networkAccess: networkAccessBuilder) { pass in
            updateProgress(total: pass.0, current: pass.1)
        }
        print(
            """
            Loaded privacy summary with \(summary.applicationSummary.count) applications
            ===> Privacy Record \(summary.privacyAccess.count)
            ===> Network Record \(summary.networkAccess.count)
            """
        )
        if summary.privacyAccess.count < 1 && summary.networkAccess.count < 1 {
            errorProcessingInsight(with: "Nothing to load.")
            return
        }
        DispatchQueue.main.async {
            insightReader = InsightReaderView(insightReport: summary)
        }
    }

    func errorProcessingInsight(with reason: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = reason
            alert.runModal()
        }
    }
    
    func updateProgress(total: Int, current: Int) {
        DispatchQueue.main.async {
            let builder = Progress(totalUnitCount: Int64(exactly: total) ?? 0)
            builder.completedUnitCount = Int64(exactly: current) ?? 0
            progress = builder
        }
    }
}
