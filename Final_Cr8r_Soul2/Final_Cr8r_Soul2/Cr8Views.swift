//
//  Cr8Views.swift
//  Final_Cra8r_Soul
//
//  Created by user287268 on 4/28/26.
//

import SwiftUI
import CoreData

// MARK: - Cr8 Filter Bar

struct Cr8FilterBar: View {
    @ObservedObject var vm: Cr8ViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "♥ Favorites", isActive: vm.showFavoritesOnly) {
                    vm.showFavoritesOnly.toggle()
                }
                Divider().frame(height: 20)
                ForEach(Element.allCases) { el in
                    FilterChip(
                        label: "\(el.symbol) \(el.rawValue)",
                        isActive: vm.selectedElement == el,
                        activeColor: el.primaryColor
                    ) {
                        vm.selectedElement = vm.selectedElement == el ? nil : el
                    }
                }
                Divider().frame(height: 20)
                ForEach(Format.allCases) { fmt in
                    FilterChip(label: fmt.rawValue, isActive: vm.selectedFormat == fmt) {
                        vm.selectedFormat = vm.selectedFormat == fmt ? nil : fmt
                    }
                }
            }
            .padding(.horizontal).padding(.vertical, 6)
        }
    }
}

// MARK: - Cr8 Card

struct Cr8CardView: View {
    let record: RecordEntity
    var onFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AlbumArtPlaceholderView(elements: record.elementEnums, genre: record.genre ?? "", size: 150)
                .overlay(alignment: .topTrailing) {
                    Button(action: onFavorite) {
                        Image(systemName: record.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(record.isFavorite ? .red : .white)
                            .padding(8)
                            .background(Color.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                    .padding(6)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(record.displayTitle).font(.caption).fontWeight(.semibold).lineLimit(1)
                Text(record.displayArtist).font(.caption2).foregroundColor(.secondary).lineLimit(1)
            }
            .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    if let fmt = record.formatEnum {
                        FormatBadgeView(format: fmt)
                    }
                    ForEach(record.elementEnums.prefix(2)) { el in ElementBadgeView(element: el, compact: true) }
                }
                .padding(.horizontal, 4)
            }
            Spacer(minLength: 0)
        }
        .frame(width: 150)
        .padding(.bottom, 8)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Cr8 View

struct Cr8View: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = Cr8ViewModel()
    @State private var showAdd = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RecordEntity.dateAdded, ascending: false)],
        predicate: NSPredicate(format: "isOwned == YES"),
        animation: .default
    ) private var records: FetchedResults<RecordEntity>

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $vm.searchText)
                    .padding(.horizontal).padding(.top, 8)

                Cr8FilterBar(vm: vm)

                HStack {
                    Text("\(filtered.count) record\(filtered.count == 1 ? "" : "s")")
                        .font(.caption).foregroundColor(.secondary)
                    Spacer()
                    Picker("Sort", selection: $vm.sortOption) {
                        ForEach(Cr8ViewModel.SortOption.allCases, id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.menu).font(.caption)
                }
                .padding(.horizontal).padding(.bottom, 4)

                if filtered.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "square.stack.3d.up.slash")
                            .font(.system(size: 48)).foregroundColor(.secondary)
                        Text(records.isEmpty ? "Your crate is empty" : "No matches found")
                            .font(.headline)
                        Text(records.isEmpty ? "Tap + to add your first record" : "Try adjusting your filters")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filtered) { record in
                                NavigationLink(destination: RecordDetailView(record: record)) {
                                    Cr8CardView(record: record) {
                                        vm.toggleFavorite(record, context: context)
                                    }
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        vm.delete(record, context: context)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Cr8")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddEditRecordView(isOwned: true)
                    .environment(\.managedObjectContext, context)
            }
        }
    }

    private var filtered: [RecordEntity] { vm.filtered(Array(records)) }
}

// MARK: - Want List Row

struct Cr8ShipmentRowView: View {
    let record: RecordEntity
    var body: some View {
        HStack(spacing: 12) {
            AlbumArtPlaceholderView(elements: record.elementEnums, genre: record.genre ?? "", size: 56)
            VStack(alignment: .leading, spacing: 3) {
                Text(record.displayTitle).font(.subheadline).fontWeight(.semibold).lineLimit(1)
                Text(record.displayArtist).font(.caption).foregroundColor(.secondary).lineLimit(1)
                HStack(spacing: 4) {
                    if let fmt = record.formatEnum {
                        FormatBadgeView(format: fmt)
                    }
                    if let el = record.elementEnums.first {
                        ElementBadgeView(element: el, compact: true)
                    }
                }
            }
            Spacer()
            if record.year > 0 {
                Text(String(record.year)).font(.caption2).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Want List View

struct Cr8ShipmentView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = Cr8ViewModel()
    @State private var showAdd = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \RecordEntity.dateAdded, ascending: false)],
        predicate: NSPredicate(format: "isOwned == NO"),
        animation: .default
    ) private var records: FetchedResults<RecordEntity>

    private var filtered: [RecordEntity] { vm.filtered(Array(records)) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBar(text: $vm.searchText)
                    .padding(.horizontal).padding(.top, 8)

                if records.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "shippingbox")
                            .font(.system(size: 48)).foregroundColor(.secondary)
                        Text("Cr8 Shipment is empty").font(.headline)
                        Text("Add records you're hunting for").font(.subheadline).foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filtered) { record in
                            NavigationLink(destination: RecordDetailView(record: record)) {
                                Cr8ShipmentRowView(record: record)
                            }
                            .swipeActions(edge: .leading) {
                                Button { markOwned(record) } label: {
                                    Label("Got It!", systemImage: "checkmark.circle")
                                }
                                .tint(.green)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    vm.delete(record, context: context)
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Cr8 Shipment")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAdd = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddEditRecordView(isOwned: false)
                    .environment(\.managedObjectContext, context)
            }
        }
    }

    private func markOwned(_ record: RecordEntity) {
        record.isOwned = true
        try? context.save()
    }
}
