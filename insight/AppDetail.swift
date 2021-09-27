//
//  Detail.swift
//  insight
//
//  Created by Lakr Aream on 2021/9/27.
//

import SwiftUI

public let SelectNotification = Notification.Name(rawValue: "SelectNotification")

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

private func localizedDateOfTime(from8601Date str: String) -> String {
    guard let date = formatter.date(from: str) else {
        return "Unknown Date"
    }
    return DateFormatter.localizedString(from: date,
                                         dateStyle: .none,
                                         timeStyle: .medium)
}

private func localizedDate(fromInt value: Int) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(value))
    return DateFormatter.localizedString(from: date,
                                         dateStyle: .full,
                                         timeStyle: .none)
}

struct AppDetailView: View {
    @State var report: NDPrivacySummary.NDApplicationSummary = .init(bundleIdentifier: "",
                                                                     reportPrivacyElement: [],
                                                                     reportNetworkElement: [])
    @State var loading: Bool = false
    @State var buildingToken: UUID = UUID()
    @State var privacyDataSource = [Int: [NDPrivacyAccess]]()
    @State var privacyDataAccessDateByDay = [Int]()

    var body: some View {
        Group {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "square.stack.3d.down.forward.fill")
                    Text(report.bundleIdentifier)
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                Divider()
                if loading {
                    Text("Loading...")
                        .font(.system(size: 14, weight: .semibold, design: .default))
                } else {
                    if report.reportPrivacyElement.count > 0 {
                        Text("Privacy Timeline")
                            .font(.system(size: 14, weight: .semibold, design: .default))
                        ForEach(privacyDataAccessDateByDay, id: \.self) { dayKey in
                            HStack {
                                Image(systemName: "arrowtriangle.right.circle.fill")
                                    .foregroundColor(Color.orange)
                                Text(localizedDate(fromInt: dayKey))
                            }
                            .font(.system(size: 10, weight: .regular, design: .monospaced))
                            .padding(.top, 8)
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: 200))], alignment: .leading, content: {
                                ForEach(privacyDataSource[dayKey] ?? [], id: \.self) { data in
                                    ZStack {
                                        HStack {
                                            imageTint(of: data)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.pink)
                                                .frame(width: 22, height: 22)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(data.category.uppercased())
                                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                                Divider()
                                                Text(localizedDateOfTime(from8601Date: data.timeStamp))
                                                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                                            }
                                        }
                                        .padding(12)
                                    }
                                    .background(Color.pink.opacity(0.1))
                                    .frame(height: 55)
                                    .cornerRadius(8)
                                }
                            })
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
            }
            .padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: SelectNotification, object: nil), perform: { notification in
            guard let app = notification.object as? NDPrivacySummary.NDApplicationSummary else {
                return
            }
            report = app
            let token = UUID()
            buildingToken = token
            generateDataSource(with: token)
        })
    }

    func imageTint(of privacyElement: NDPrivacyAccess) -> Image {
        if privacyElement.category.lowercased() == "location" {
            return Image(systemName: "location.circle.fill")
        } else if privacyElement.category.lowercased() == "photos" {
            return Image(systemName: "photo.fill.on.rectangle.fill")
        } else if privacyElement.category.lowercased() == "contacts" {
            return Image(systemName: "person.2.circle.fill")
        } else if privacyElement.category.lowercased() == "camera" {
            return Image(systemName: "camera.circle.fill")
        } else if privacyElement.category.lowercased() == "microphone" {
            return Image(systemName: "mic.circle.fill")
        }
        return Image(systemName: "questionmark.circle.fill")
    }

    func generateDataSource(with token: UUID) {
        loading = true
        debugPrint("constructing app data from \(report.bundleIdentifier)")
        DispatchQueue.global().async {
            var sourceBuilder: [Int: [NDPrivacyAccess]] = [:]
            for item in report.reportPrivacyElement {
                if token != buildingToken { return }
                guard let compile = formatter
                    .date(from: item.timeStamp)?
                    .get(.year, .month, .day),
                    let dateNew = Calendar.current.date(from: compile),
                    let basic = Int(exactly: dateNew.timeIntervalSince1970)
                else {
                    continue
                }
                var read = sourceBuilder[basic, default: []]
                read.append(item)
                sourceBuilder[basic] = read
            }
            for (key, value) in sourceBuilder {
                if token != buildingToken { return }
                sourceBuilder[key] = value.sorted(by: { a, b in
                    guard let dateA = formatter.date(from: a.timeStamp),
                          let dateB = formatter.date(from: b.timeStamp)
                    else {
                        return false
                    }
                    return dateA < dateB
                })
            }
            let keys = sourceBuilder.keys.sorted()
            DispatchQueue.main.async {
                if token != buildingToken { return }
                debugPrint("done app data from \(report.bundleIdentifier)")
                privacyDataSource = sourceBuilder
                privacyDataAccessDateByDay = keys
                loading = false
            }
        }
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
