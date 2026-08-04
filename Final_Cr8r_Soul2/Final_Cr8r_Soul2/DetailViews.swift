//
//  DetailViews.swift
//  Final_Cra8_Soul
//
//  Created by user287268 on 4/28/26.
//

import SwiftUI

// MARK: - Record Detail View

struct RecordDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var record: RecordEntity
    @State private var showEdit = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AlbumArtPlaceholderView(elements: record.elementEnums, genre: record.genre ?? "", size: 260)
                    .shadow(radius: 10).padding(.top)

                VStack(spacing: 4) {
                    Text(record.displayTitle).font(.title2).fontWeight(.bold).multilineTextAlignment(.center)
                    Text(record.displayArtist).font(.title3).foregroundColor(.secondary)
                }

                HStack(spacing: 10) {
                    if record.year > 0 {
                        metaTag(String(record.year), icon: "calendar")
                    }
                    if let label = record.label, !label.isEmpty {
                        metaTag(label, icon: "building.2")
                    }
                    metaTag(record.isOwned ? "In Cr8" : "Shipment", icon: record.isOwned ? "checkmark.circle" : "shippingbox")
                }

                if let fmt = record.formatEnum {
                    FormatBadgeView(format: fmt)
                }

                if !record.elementEnums.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Elements").font(.caption).foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 8) {
                            ForEach(record.elementEnums) { el in ElementBadgeView(element: el) }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                }

                if let genre = record.genre, !genre.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Genre").font(.caption).foregroundColor(.secondary)
                        let display = (record.subgenre?.isEmpty == false) ? record.subgenre! : genre
                        Text(display).font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Rating").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: Int(record.rating) >= star ? "star.fill" : "star")
                                .foregroundColor(Int(record.rating) >= star ? .yellow : .gray.opacity(0.40))
                                .font(.system(size: 18))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)

                if let notes = record.linerNotes, !notes.isEmpty {
                    LinerNotesView(notes: notes).padding(.horizontal)
                }

                Spacer(minLength: 40)
            }
        }
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { Button("Edit") { showEdit = true } }
        }
        .sheet(isPresented: $showEdit) { AddEditRecordView(record: record) }
    }

    private func metaTag(_ text: String, icon: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2)
            Text(text).font(.caption)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
    }
}

// MARK: - Liner Notes View

struct LinerNotesView: View {
    let notes: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Liner Notes", systemImage: "note.text").font(.caption).foregroundColor(.secondary)
            Text(notes).font(.body).padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// MARK: - Add/Edit Record View

struct AddEditRecordView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = AddEditViewModel()

    var record: RecordEntity? = nil
    var isOwned: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Record Info") {
                    TextField("Title *", text: $vm.title)
                    TextField("Artist *", text: $vm.artist)
                    TextField("Year", text: $vm.year).keyboardType(.numberPad)
                    TextField("Label", text: $vm.label)
                }

                Section("Format") {
                    Picker("Format", selection: $vm.format) {
                        ForEach(Format.allCases) { fmt in
                            HStack {
                                Image(systemName: fmt.icon)
                                Text(fmt.rawValue)
                            }.tag(fmt)
                        }
                    }
                    .pickerStyle(.wheel).frame(height: 120).clipped()
                }

                Section("Genre") {
                    Picker("Genre", selection: $vm.genre) {
                        Text("Select Genre").tag("")
                        ForEach(GenreLibrary.genres, id: \.self) { Text($0).tag($0) }
                    }
                    if !vm.genre.isEmpty, let subs = GenreLibrary.subgenres[vm.genre], !subs.isEmpty {
                        Picker("Subgenre", selection: $vm.subgenre) {
                            Text("Select Subgenre").tag("")
                            ForEach(subs, id: \.self) { Text($0).tag($0) }
                        }
                    }
                }
                .onChange(of: vm.genre) { _ in vm.subgenre = "" }

                Section("Elements (select all that apply)") {
                    ForEach(Element.allCases) { el in
                        Button {
                            if vm.selectedElements.contains(el) {
                                vm.selectedElements.remove(el)
                            }
                            else {
                                vm.selectedElements.insert(el)
                            }
                        } label: {
                            HStack {
                                Text("\(el.symbol)  \(el.rawValue)").foregroundColor(.primary)
                                Text("· \(el.instrumentFamily)").font(.caption).foregroundColor(.secondary)
                                Spacer()
                                if vm.selectedElements.contains(el) {
                                    Image(systemName: "checkmark").foregroundColor(el.primaryColor).fontWeight(.semibold)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                Section("Status") {
                    Toggle("In My Cr8 (owned)", isOn: $vm.isOwned)
                    Toggle("Favorite", isOn: $vm.isFavorite)
                }

                Section("Rating") {
                    StarRatingView(rating: $vm.rating)
                }

                Section("Liner Notes") {
                    TextEditor(text: $vm.linerNotes).frame(minHeight: 100)
                }
            }
            .navigationTitle(record == nil ? "Add Record" : "Edit Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { vm.save(record: record, context: context); dismiss() }
                        .disabled(!vm.isValid).fontWeight(.semibold)
                }
            }
            .onAppear {
                if let record {
                    vm.populate(from: record)
                } else {
                    vm.isOwned = isOwned
                }
            }
        }
    }
}
