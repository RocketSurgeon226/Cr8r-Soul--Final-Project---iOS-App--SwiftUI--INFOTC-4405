//
//  ViewModels.swift
//  Final_Cra8_Soul
//
//  Created by user287268 on 4/28/26.
//

import SwiftUI
import CoreData
import Combine

// MARK: - Cr8ViewModel

class Cr8ViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedElement: Element? = nil
    @Published var selectedFormat: Format? = nil
    @Published var showFavoritesOnly = false
    @Published var sortOption: SortOption = .dateAdded
    
    @Published private(set) var debouncedSearch = ""
    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .removeDuplicates()
            .assign(to: \.debouncedSearch, on: self)
            .store(in: &cancellables)
    }

    enum SortOption: String, CaseIterable {
        case dateAdded = "Date Added", title = "Title", artist = "Artist"
        case year = "Year", rating = "Rating"
    }

    func filtered(_ records: [RecordEntity]) -> [RecordEntity] {
        var result = records
        if let el = selectedElement {
            result = result.filter { $0.elementEnums.contains(el) }
        }
        if showFavoritesOnly {
            result = result.filter { $0.isFavorite }
        }
        if !debouncedSearch.isEmpty {
            result = result.filter {
                ($0.title  ?? "").localizedCaseInsensitiveContains(debouncedSearch) ||
                ($0.artist ?? "").localizedCaseInsensitiveContains(debouncedSearch)
            }
        }
        switch sortOption {
        case .dateAdded: result.sort { ($0.dateAdded ?? .distantPast) > ($1.dateAdded ?? .distantPast) }
        case .title: result.sort { ($0.title  ?? "") < ($1.title  ?? "") }
        case .artist: result.sort { ($0.artist ?? "") < ($1.artist ?? "") }
        case .year: result.sort { $0.year   > $1.year }
        case .rating: result.sort { $0.rating > $1.rating }
        }
        return result
    }

    func delete(_ record: RecordEntity, context: NSManagedObjectContext) {
        context.delete(record); try? context.save()
    }

    func toggleFavorite(_ record: RecordEntity, context: NSManagedObjectContext) {
        record.isFavorite.toggle(); try? context.save()
    }
}


// MARK: - AddEditViewModel

class AddEditViewModel: ObservableObject {
    @Published var title = ""
    @Published var artist = ""
    @Published var year = ""
    @Published var genre = ""
    @Published var subgenre = ""
    @Published var format: Format = .vinyl
    @Published var label = ""
    @Published var selectedElements: Set<Element> = []
    @Published var isOwned  = true
    @Published var isFavorite = false
    @Published var rating: Int16  = 0
    @Published var linerNotes = ""

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !artist.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func populate(from record: RecordEntity) {
        title = record.title    ?? ""
        artist = record.artist   ?? ""
        year = record.year > 0 ? String(record.year) : ""
        genre = record.genre    ?? ""
        subgenre = record.subgenre ?? ""
        format = record.formatEnum ?? .vinyl
        label = record.label    ?? ""
        selectedElements = Set(record.elementEnums)
        isOwned = record.isOwned
        isFavorite = record.isFavorite
        rating = record.rating
        linerNotes = record.linerNotes ?? ""
    }

    func save(record: RecordEntity? = nil, context: NSManagedObjectContext) {
        let target = record ?? RecordEntity(context: context)
        target.id = target.id ?? UUID()
        target.title = title.trimmingCharacters(in: .whitespaces)
        target.artist = artist.trimmingCharacters(in: .whitespaces)
        target.year = Int32(year) ?? 0
        target.genre = genre
        target.subgenre = subgenre
        target.format = format.rawValue
        target.label = label.trimmingCharacters(in: .whitespaces)
        target.elements = selectedElements.map(\.rawValue).sorted()
        target.isOwned = isOwned
        target.isFavorite = isFavorite
        target.rating = rating
        target.linerNotes = linerNotes
        target.dateAdded = target.dateAdded ?? Date()
        try? context.save()
    }
}


// MARK: - DigModeViewModel

class DigModeViewModel: ObservableObject {
    @Published var currentRecord: RecordEntity? = nil
    @Published var digSource: DigSource = .both
    @Published var filterElement: Element? = nil
    @Published var hasBeenUsed = false

    enum DigSource: String, CaseIterable {
        case collection = "Cr8 Only", cr8Shipment = "Shipment Only", both = "Both"
    }

    func dig(from allRecords: [RecordEntity]) {
        var pool = allRecords
        switch digSource {
        case .collection: pool = pool.filter {  $0.isOwned }
        case .cr8Shipment: pool = pool.filter { !$0.isOwned }
        case .both: break
        }
        if let el = filterElement {
            pool = pool.filter { $0.elementEnums.contains(el) }
        }
        guard !pool.isEmpty else { currentRecord = nil; hasBeenUsed = true; return }

        if pool.count == 1 {
            currentRecord = pool.first
        } else {
            var candidate = pool.randomElement()
            if let current = currentRecord {
                var attempts = 0
                while candidate?.objectID == current.objectID && attempts < 20 {
                    candidate = pool.randomElement()
                    attempts += 1
                }
            }
            currentRecord = candidate
        }
        hasBeenUsed = true
    }
}
