//
//  DashboardViews.swift
//  Final_Cra8r_Soul
//
//  Created by user287268 on 4/28/26.
//

import SwiftUI
import Charts
import CoreData
import Combine

// MARK: - Chart Data Structs

struct ElementStat: Identifiable {
    let element: Element
    let count: Int
    var id: String { element.id }
}

struct FormatStat: Identifiable {
    let format: String
    let count: Int
    var id: String { format }
}

struct EraStat: Identifiable {
    let era: String
    let count: Int
    var id: String { era }
}

struct GenreStat: Identifiable {
    let genre: String
    let count: Int
    var id: String { genre }
}

// MARK: - Dashboard View

class DashboardViewModel: ObservableObject {
    @Published var elementData: [ElementStat] = []
    @Published var formatData: [FormatStat] = []
    @Published var eraData: [EraStat] = []
    @Published var genreData: [GenreStat] = []
    @Published var favs: [RecordEntity] = []
    @Published var topRated: [RecordEntity] = []
    @Published var avgRating: Double = 0
    @Published var ownedCount: Int = 0
    @Published var shipCount: Int = 0

    func recompute(from records: [RecordEntity]) {
        ownedCount = records.filter { $0.isOwned }.count
        shipCount = records.filter { !$0.isOwned }.count
        elementData = Element.allCases.map { el in
            ElementStat(element: el, count: records.filter { $0.elementEnums.contains(el) }.count)
        }
        var fmtCounts: [String: Int] = [:]
        for r in records { fmtCounts[r.format ?? "Unknown", default: 0] += 1 }
        formatData = fmtCounts.map { FormatStat(format: $0.key, count: $0.value) }.sorted { $0.count > $1.count }

        var eraCounts: [String: Int] = [:]
        for r in records {
            let decade = r.year > 0 ? "\(r.year / 10 * 10)s" : "Unknown"
            eraCounts[decade, default: 0] += 1
        }
        eraData = eraCounts.map { EraStat(era: $0.key, count: $0.value) }.sorted { $0.era < $1.era }

        var genreCounts: [String: Int] = [:]
        for r in records.filter({ $0.isOwned }) { genreCounts[r.genre ?? "Unknown", default: 0] += 1 }
        genreData = genreCounts.map { GenreStat(genre: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }.prefix(6).map { $0 }

        favs = records.filter { $0.isFavorite }.sorted { $0.rating > $1.rating }
        topRated = records.filter { $0.isOwned && $0.rating >= 4 }.sorted { $0.rating > $1.rating }

        let rated = records.filter { $0.isOwned && $0.rating > 0 }
        avgRating = rated.isEmpty ? 0 : Double(rated.map { Int($0.rating) }.reduce(0, +)) / Double(rated.count)
    }
}




struct DashboardView: View {
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var allRecords: FetchedResults<RecordEntity>
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    HStack(spacing: 12) {
                        BlurbCard(value: vm.ownedCount, label: "In Cr8", icon: "square.stack.3d.up", color: .indigo)
                        BlurbCard(value: vm.shipCount, label: "Shipment", icon: "shippingbox", color: .orange)
                        BlurbCard(value: vm.favs.count, label: "Favorites", icon: "heart.fill", color: .red)
                    }
                    .padding(.horizontal)

                    if vm.avgRating > 0 {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Avg Rating").font(.caption).foregroundColor(.secondary)
                                HStack(spacing: 4) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: Double(star) <= vm.avgRating ? "star.fill" :
                                              (Double(star) - 0.5 <= vm.avgRating ? "star.leadinghalf.filled" : "star"))
                                            .foregroundColor(.yellow).font(.system(size: 14))
                                    }
                                    Text(String(format: "%.1f", vm.avgRating))
                                        .font(.caption).foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                        }.padding(.horizontal)
                    }

                    ChartCard(title: "Your Soul by Element") {
                        Chart(vm.elementData) { item in
                            BarMark(x: .value("Element", item.element.rawValue), y: .value("Records", item.count))
                                .foregroundStyle(item.element.primaryColor)
                                .annotation(position: .top) {
                                    Text("\(item.count)").font(.caption2).foregroundColor(.secondary)
                                }
                        }
                        .frame(height: 160)
                        .chartXAxis {
                            AxisMarks { value in
                                AxisValueLabel {
                                    if let str = value.as(String.self), let el = Element(rawValue: str) {
                                        Text(el.symbol)
                                    }
                                }
                            }
                        }
                    }

                    ChartCard(title: "Format Breakdown") {
                        if vm.formatData.isEmpty {
                            Text("No data yet").font(.caption).foregroundColor(.secondary)
                        } else {
                            Chart(vm.formatData) { item in
                                BarMark(x: .value("Count", item.count), y: .value("Format", item.format))
                                    .foregroundStyle(Color.indigo.gradient)
                                    .annotation(position: .trailing) {
                                        Text("\(item.count)").font(.caption2).foregroundColor(.secondary)
                                    }
                            }
                            .frame(height: CGFloat(max(vm.formatData.count, 2)) * 36)
                            .chartXAxis(.hidden)
                        }
                    }

                    ChartCard(title: "Records by Era") {
                        if vm.eraData.isEmpty {
                            Text("No data yet").font(.caption).foregroundColor(.secondary)
                        } else {
                            Chart(vm.eraData) { item in
                                LineMark(x: .value("Era", item.era), y: .value("Count", item.count))
                                    .interpolationMethod(.catmullRom).foregroundStyle(Color.indigo)
                                PointMark(x: .value("Era", item.era), y: .value("Count", item.count))
                                    .foregroundStyle(Color.indigo)
                            }
                            .frame(height: 140)
                        }
                    }

                    ChartCard(title: "Top Genres") {
                        if vm.genreData.isEmpty {
                            Text("No data yet").font(.caption).foregroundColor(.secondary)
                        } else {
                            Chart(vm.genreData) { item in
                                BarMark(x: .value("Count", item.count), y: .value("Genre", item.genre))
                                    .foregroundStyle(Color.indigo.gradient)
                                    .annotation(position: .trailing) {
                                        Text("\(item.count)").font(.caption2).foregroundColor(.secondary)
                                    }
                            }
                            .frame(height: CGFloat(vm.genreData.count) * 32)
                            .chartXAxis(.hidden)
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Desert Island Shelf").font(.headline).padding(.horizontal)
                        if vm.favs.isEmpty {
                            Text("Heart a record to add it here")
                                .font(.caption).foregroundColor(.secondary).padding(.horizontal)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(vm.favs.prefix(10)) { record in
                                        NavigationLink(destination: RecordDetailView(record: record)) {
                                            VStack(spacing: 6) {
                                                AlbumArtPlaceholderView(elements: record.elementEnums, genre: record.genre ?? "", size: 90)
                                                Text(record.displayTitle).font(.system(size: 10)).lineLimit(1).frame(width: 90).foregroundColor(.primary)
                                            }
                                        }.buttonStyle(.plain)
                                    }
                                }.padding(.horizontal)
                            }
                        }
                    }

                    if !vm.topRated.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Highest Rated").font(.headline).padding(.horizontal)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(vm.topRated.prefix(10)) { record in
                                        NavigationLink(destination: RecordDetailView(record: record)) {
                                            VStack(spacing: 6) {
                                                AlbumArtPlaceholderView(elements: record.elementEnums, genre: record.genre ?? "", size: 90)
                                                Text(record.displayTitle).font(.system(size: 10)).lineLimit(1).frame(width: 90).foregroundColor(.primary)
                                                HStack(spacing: 1) {
                                                    ForEach(1...5, id: \.self) { s in
                                                        Image(systemName: Int(record.rating) >= s ? "star.fill" : "star")
                                                            .font(.system(size: 7))
                                                            .foregroundColor(Int(record.rating) >= s ? .yellow : .gray.opacity(0.3))
                                                    }
                                                }
                                            }
                                        }.buttonStyle(.plain)
                                    }
                                }.padding(.horizontal)
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .navigationTitle("Soul Stats")
        }
        .onAppear { vm.recompute(from: Array(allRecords)) }
        .onChange(of: allRecords.count) { _ in vm.recompute(from: Array(allRecords)) }
    }
}

// MARK: - Chart Card (reusable wrapper)

struct ChartCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.headline)
            content
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Summary Card

struct BlurbCard: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title2).foregroundColor(color)
            Text("\(value)").font(.title).fontWeight(.bold)
            Text(label).font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Dig Mode View

struct DigModeView: View {
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var allRecords: FetchedResults<RecordEntity>
    @StateObject private var vm = DigModeViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Picker("Source", selection: $vm.digSource) {
                        ForEach(DigModeViewModel.DigSource.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(label: "Any Element", isActive: vm.filterElement == nil) {
                                vm.filterElement = nil
                            }
                            ForEach(Element.allCases) { el in
                                FilterChip(
                                    label: "\(el.symbol) \(el.rawValue)",
                                    isActive: vm.filterElement == el,
                                    activeColor: el.primaryColor
                                ) {
                                    vm.filterElement = vm.filterElement == el ? nil : el
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                if let record = vm.currentRecord {
                    NavigationLink(destination: RecordDetailView(record: record)) {
                        DigCardView(record: record)
                    }
                    .buttonStyle(.plain)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .id(record.objectID)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "shuffle.circle")
                            .font(.system(size: 64)).foregroundColor(.secondary.opacity(0.40))
                        Text(vm.hasBeenUsed ? "Nothing matched your filters" : "Hit Dig to pull a record")
                            .font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity).padding(40)
                }

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        vm.dig(from: Array(allRecords))
                    }
                } label: {
                    Label("Dig", systemImage: "shuffle")
                        .font(.title3).fontWeight(.semibold)
                        .frame(maxWidth: .infinity).padding()
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal).padding(.bottom)
            }
            .navigationTitle("Dig Mode")
        }
    }
}

// MARK: - Dig Card View

struct DigCardView: View {
    let record: RecordEntity
    var body: some View {
        VStack(spacing: 16) {
            AlbumArtPlaceholderView(elements: record.elementEnums, genre: record.genre ?? "", size: 240)
                .shadow(radius: 14)
            VStack(spacing: 6) {
                Text(record.displayTitle).font(.title2).fontWeight(.bold).multilineTextAlignment(.center)
                Text(record.displayArtist).font(.title3).foregroundColor(.secondary)
                HStack(spacing: 8) {
                    if let fmt = record.formatEnum {
                        FormatBadgeView(format: fmt)
                    }
                    ForEach(record.elementEnums) { el in ElementBadgeView(element: el, compact: true) }
                }
                if record.year > 0 {
                    Text(String(record.year)).font(.caption2).foregroundColor(.secondary)
                }
            }
            Text("Tap to view full record →").font(.caption2).foregroundColor(.secondary)
        }
        .padding().frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
}
