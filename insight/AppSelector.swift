//
//  Reader.swift
//  insight
//
//  Created by Lakr Aream on 2021/9/27.
//

import AVFAudio
import Colorful
import Kingfisher
import SwiftUI

public let ApiCountryCodeTable =
    [
        "CN", "DK", "NL", "AT", "CA",
        "US", "GB", "FI", "FR", "DE",
        "GR", "ID", "IT", "JP", "KR",
        "MY", "BR", "PT", "RU", "MX",
        "ES", "SE", "TH", "TR", "VN",
    ]
    .sorted()
public let ApiCountryCodeNotification = Notification
    .Name(rawValue: "ApiCountryCodeNotification")

struct InsightReaderView: View {
    let insightReport: NDPrivacySummary

    @State var appKeys: [String] = []
    @State var hideApple: Bool = true
    @State var selectedApplication: NDPrivacySummary.NDApplicationSummary?
    @State var highlightIndex: Int?
    @State var apiCountryCodeSelection = "CN"

    var body: some View {
        GeometryReader { reader in
            VStack(spacing: 0) {
                HStack(spacing: 5) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(generateHeader())
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .padding(.horizontal)
                    }
                    Toggle("Hide Apple", isOn: $hideApple)
                    Picker("  iTunes Api", selection: $apiCountryCodeSelection) {
                        ForEach(ApiCountryCodeTable, id: \.self) { selection in
                            Text(selection)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        }
                    }
                    .frame(width: 200)
                }
                .frame(width: reader.size.width, height: 30)
                Divider()
                GeometryReader { innerReader in
                    HStack(spacing: 0) {
                        ScrollView {
                            VStack {
                                ForEach(appKeys, id: \.self) { key in
                                    if let idx = appKeys.firstIndex(of: key),
                                       let app = insightReport.applicationSummary[key] {
                                        ApplicationView(app: app)
                                            .padding(4)
                                            .onHover { hover in
                                                highlightIndex = hover ? idx : nil
                                            }
                                            .scaleEffect(idx == highlightIndex ? 1.02 : 1)
                                            .background(
                                                Color
                                                    .yellow
                                                    .opacity(idx == highlightIndex ? 0.2 : 0)
                                                    .cornerRadius(8)
                                            )
                                            .animation(.interactiveSpring(), value: highlightIndex)
                                            .onTapGesture {
                                                debugPrint("[i] processing for \(app.bundleIdentifier)")
                                                selectedApplication = app
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                    NotificationCenter.default.post(name: SelectNotification, object: app)
                                                }
                                            }
                                            .padding(.horizontal, 8)
                                        Divider()
                                    }
                                }
                            }
                            .padding(.vertical, 20)
                        }
                        .frame(width: innerReader.size.width * 0.35)
                        Divider()
                        ScrollView {
                            if selectedApplication != nil {
                                AppDetailView()
                            } else {
                                ZStack {
                                    VStack(spacing: 8) {
                                        Image(systemName: "cursorarrow.rays")
                                            .font(.system(size: 60, weight: .semibold, design: .rounded))
                                            .foregroundColor(.pink)
                                        Text("Select an app to begin analyze ~")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    }
                                }
                                .frame(width: innerReader.size.width * 0.65, height: innerReader.size.height)
                            }
                        }
                        .frame(width: innerReader.size.width * 0.65)
                    }
                }
            }
            .frame(width: reader.size.width, height: reader.size.height)
        }
        .onChange(of: hideApple, perform: { _ in
            rebuildKeys()
        })
        .onAppear {
            rebuildKeys()
        }
        .onChange(of: apiCountryCodeSelection, perform: { code in
            NotificationCenter.default.post(name: ApiCountryCodeNotification, object: code)
        })
        .background(Color(NSColor.textBackgroundColor))
        .ignoresSafeArea()
    }

    func rebuildKeys() {
        let origKeys = insightReport
            .applicationSummary
            .keys
            .sorted()
        if hideApple {
            debugPrint("hide apple")
            appKeys = origKeys
                .filter { !$0.lowercased().hasPrefix("com.apple") }
        } else {
            debugPrint("unhide apple")
            appKeys = origKeys
        }
    }

    func generateHeader() -> String {
        "[Insight]" +
//        " - " +
//        "Privacy " + String(insightReport.privacyAccess.count) +
//        " " +
//        "Network " + String(insightReport.networkAccess.count) +
            " " +
            generateRecordRange()
    }

    func generateRecordRange() -> String {
        DateFormatter.localizedString(from: insightReport.beginDate,
                                      dateStyle: .medium,
                                      timeStyle: .none)
            + " -> " +
            DateFormatter.localizedString(from: insightReport.endingDate,
                                          dateStyle: .medium,
                                          timeStyle: .none)
    }
}

struct ApplicationView: View {
    let instructedHeight: CGFloat = 35

    let app: NDPrivacySummary.NDApplicationSummary
    @State var avatarImage: KFImage?
    @State var appName: String?

    var body: some View {
        GeometryReader { _ in
            HStack {
                ZStack {
                    if let avatarImage = avatarImage {
                        avatarImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: instructedHeight * 0.75, height: instructedHeight * 0.75)
                            .cornerRadius(8)
                    } else {
                        Image("AppStore")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: instructedHeight * 0.75, height: instructedHeight * 0.75)
                            .cornerRadius(8)
                            .foregroundColor(.pink)
                    }
                }
                .frame(width: instructedHeight, height: instructedHeight)
                VStack(alignment: .leading, spacing: 6) {
                    Text(appName ?? "[? Application]")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                    HStack(spacing: 0) {
                        Text(app.bundleIdentifier)
                            .minimumScaleFactor(0.5)
                        Spacer()
                        HStack(spacing: 2) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 8, weight: .regular, design: .rounded))
                            Text("\(app.reportPrivacyElement.count)")
                                .minimumScaleFactor(0.5)
                            Spacer()
                        }
                        .frame(width: 40)
                        .foregroundColor(.red)
                        HStack(spacing: 2) {
                            Image(systemName: "network")
                                .font(.system(size: 8, weight: .regular, design: .rounded))
                            Text("\(app.reportNetworkElement.count)")
                                .minimumScaleFactor(0.5)
                            Spacer()
                        }
                        .frame(width: 40)
                        .foregroundColor(.blue)
                    }
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                }
            }
        }
        .frame(height: instructedHeight)
        .onAppear {
            prepareApplicationInfo(countryCode: "CN")
        }
        .onReceive(NotificationCenter.default.publisher(for: ApiCountryCodeNotification, object: nil)) { notification in
            prepareApplicationInfo(countryCode: notification.object as? String ?? "CN")
        }
    }

    func prepareApplicationInfo(countryCode: String) {
        appName = nil
        avatarImage = nil
        requestApi(withBundle: app.bundleIdentifier, country: countryCode) { result in
            applyAppStoreApiResult(object: result)
        }
    }

    func applyAppStoreApiResult(object: ASResult) {
        DispatchQueue.main.async {
            appName = object.trackName
            avatarImage = KFImage(URL(string: object.artworkUrl60 ?? ""))
        }
    }
}

func requestApi(
    withBundle identifier: String,
    country code: String,
    completion: @escaping (ASResult) -> Void
) {
    DispatchQueue.global().async {
        guard let queryIdUrl = URL(string: "https://itunes.apple.com/lookup?bundleId=\(identifier)&country=\(code.lowercased())") else {
            return
        }
        if let cache = appStoreQueryCache[queryIdUrl],
           let apiResult = try? ASAPIResult(cache).results?.first {
            debugPrint("[i] Cached application \(identifier) => \(apiResult.trackName ?? "nope!")")
            completion(apiResult)
            return
        }
        URLSession
            .shared
            .dataTask(with: queryIdUrl) { data, _, _ in
                if let data = data,
                   let str = String(data: data, encoding: .utf8),
                   let apiResult = try? ASAPIResult(str).results?.first {
                    appStoreQueryCache[queryIdUrl] = str
                    completion(apiResult)
                }
            }
            .resume()
    }
}
