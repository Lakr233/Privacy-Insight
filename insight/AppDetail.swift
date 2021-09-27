//
//  Detail.swift
//  insight
//
//  Created by Lakr Aream on 2021/9/27.
//

import SwiftUI

private let formatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

private func localizedDate(from8601Date str: String) -> String {
    guard let date = formatter.date(from: str) else {
        return "Unknown Date"
    }
    return DateFormatter.localizedString(from: date,
                                         dateStyle: .long,
                                         timeStyle: .long)
}

struct AppDetailView: View {
    @Binding var report: NDPrivacySummary.NDApplicationSummary?

    var body: some View {
        if let report = report {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.pink)
                    Text(report.bundleIdentifier)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                    Spacer()
                }
                Divider()
                if report.reportPrivacyElement.count > 0 {
                    Text("Privacy Timeline")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                    ForEach(report.reportPrivacyElement, id: \.self) { privacyElement in
                        HStack(spacing: 8) {
                            Circle()
                                .foregroundColor(.red)
                                .frame(width: 6, height: 6)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Group {
                                        if privacyElement.category.lowercased() == "location" {
                                            Image(systemName: "location.circle.fill")
                                        } else if privacyElement.category.lowercased() == "photos" {
                                            Image(systemName: "photo.fill.on.rectangle.fill")
                                        } else if privacyElement.category.lowercased() == "contacts" {
                                            Image(systemName: "person.2.circle.fill")
                                        } else if privacyElement.category.lowercased() == "camera" {
                                            Image(systemName: "camera.circle.fill")
                                        } else if privacyElement.category.lowercased() == "microphone" {
                                            Image(systemName: "mic.circle.fill")
                                        }
                                    }
                                    .foregroundColor(.pink)
                                    .frame(width: 10)
                                    .font(.system(size: 12, weight: .semibold, design: .default))
                                    Text(privacyElement.category.uppercased())
                                        .font(.system(size: 12, weight: .semibold, design: .default))
                                }
                                Text(localizedDate(from8601Date: privacyElement.timeStamp))
                                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                if report.reportNetworkElement.count > 0 {
                    Text("Network Timeline")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                    ForEach(report.reportNetworkElement, id: \.self) { networkElement in
                        HStack(spacing: 8) {
                            Circle()
                                .foregroundColor(.red)
                                .frame(width: 6, height: 6)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(networkElement.domain)
                                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                }
                                Text(localizedDate(from8601Date: networkElement.timeStamp))
                                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
        } else {
            ZStack {}
        }
    }
}
