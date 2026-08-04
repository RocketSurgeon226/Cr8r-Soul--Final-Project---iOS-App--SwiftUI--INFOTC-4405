//
//  Models.swift
//  Final_Cra8_Soul
//
//  Created by user287268 on 4/28/26.
//

import SwiftUI
import CoreData

// MARK: - Element

enum Element: String, CaseIterable, Codable, Identifiable {
    case water = "Water", earth = "Earth", fire = "Fire", air = "Air"
    var id: String { rawValue }

    var instrumentFamily: String {
        switch self {
        case .water: return "Strings"
        case .earth: return "Percussion"
        case .fire: return "Brass"
        case .air: return "Woodwinds"
        }
    }

    var symbol: String {
        switch self {
        case .water: return "💧"
        case .earth: return "🌍"
        case .fire: return "🔥"
        case .air: return "💨"
        }
    }

    var primaryColor: Color {
        switch self {
        case .water: return Color(red: 0.18, green: 0.55, blue: 0.78)
        case .earth: return Color(red: 0.45, green: 0.32, blue: 0.18)
        case .fire: return Color(red: 0.88, green: 0.28, blue: 0.10)
        case .air: return Color(red: 0.40, green: 0.70, blue: 0.90)
        }
    }

    var secondaryColor: Color {
        switch self {
        case .water: return Color(red: 0.08, green: 0.30, blue: 0.55)
        case .earth: return Color(red: 0.25, green: 0.18, blue: 0.08)
        case .fire: return Color(red: 0.95, green: 0.55, blue: 0.10)
        case .air: return Color(red: 0.80, green: 0.92, blue: 1.00)
        }
    }
}

// MARK: - Format

enum Format: String, CaseIterable, Codable, Identifiable {
    case vinyl = "Vinyl", cassette = "Cassette", cd = "CD"
    case miniDisc = "MiniDisc", eightTrack = "8-Track", shellac = "Shellac"
    case digital = "Digital"
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .vinyl: return "record.circle"
        case .cassette: return "recordingtape"
        case .cd: return "opticaldisc"
        case .miniDisc: return "square.stack"
        case .eightTrack: return "rectangle.portrait"
        case .shellac: return "clock.arrow.circlepath"
        case .digital: return "waveform"
        }
    }
}

// MARK: - Genre

struct GenreLibrary {
    static let genres: [String] = [
        "Hip-Hop", "R&B/Soul", "Jazz", "Funk", "EDM (Electronic Dance Music)",
        "Reggae/Dancehall", "Blues", "Rock", "Gospel", "Country",
        "Afrobeats/African", "Classical"
    ]

    static let subgenres: [String: [String]] = [
        "Hip-Hop": ["Boom Bap", "Lo-Fi Hip-Hop", "Trap", "Conscious", "Jazz Rap", "G-Funk", "Drill", "Cloud Rap", "Electro", "RnBass", "Crunk", "Hyphy", "NOLA Bounce", "Jersey Club", "Miami Bass", "Chopped N Screwed", "Phonk", "Alternative Hip-Hop"],
        "R&B/Soul": ["Neo-Soul", "Classic Soul", "Motown", "Country Soul", "New Jack Swing", "Quiet Storm", "Contemporary R&B", "Doo-Wop", "Gospel Soul", "Trap Soul", "RnBass"],
        "Jazz": ["Dixieland", "Bebop", "Hard Bop", "Modal", "Free Jazz", "Fusion", "Smooth Jazz", "Spiritual Jazz", "Swing", "Ragtime", "Third Stream", "Latin Jazz", "Cool Jazz", "Bossa Nova", "Western Swing", "Avant-Garde"],
        "Funk": ["P-Funk", "Boogie", "Psychedelic Funk", "Funk Rock", "Electro-Funk", "Go-Go"],
        "EDM (Electronic Dance Music)": ["House", "Techno", "Drum and Bass", "Ambient", "Footwork", "Jungle", "Dubstep", "Liquid DnB", "Chicago House", "Electro", "Disco", "Jersey Club", "Ghettotech", "Ghetto House", "Afro House", "Eurodance", "Drift Phonk", "Juke", "Chiptune", "Vaporwave", "IDM", "Industrial", "Chillout", "Synthwave", "Tropical House", "Folktronica"],
        "Reggae/Dancehall": ["Roots Reggae", "Dancehall", "Dub", "Ska", "Rocksteady", "Mento"],
        "Blues": ["Rockabilly Blues", "Delta Blues", "Chicago Blues", "Electric Blues", "Jump Blues", "Saint Louis Blues", "Blues Rock", "Emo", "Gothic Rock"],
        "Rock": ["Classic Rock", "Psychedelic Rock", "Rock n Roll", "Rockabilly", "Surf Rock", "Yacht Rock", "Soft Rock", "Glam Rock", "Metal", "Heavy Metal", "Hard Rock", "Arena Rock", "Funk Rock", "Afrorock", "Swamp Rock", "Roots Rock", "Country Rock", "Southern Rock", "Heartland Rock", "Blues Rock", "Pop Rock"],
        "Gospel": ["Traditional Gospel", "Southern Gospel", "Contemporary Gospel", "Choir", "Negro Spirituals", "Praise and Worship"],
        "Country": ["Country Western", "Rockabilly", "Country Rock", "Classic Country", "Outlaw Country", "Bluegrass", "Country Soul", "Country Blues", "Americana", "Folk Country", "Country Pop", "Honky Tonk", "Western Swing", "Neotraditional Country", "Alt-Country"],
        "Afrobeats/African": ["Afrobeat", "Afropop", "Highlife", "Juju", "Amapiano", "Makossa", "Afrofusion", "Emo-Afrobeats", "Alte", "Afro-Bashment", "Naija Beats", "Ghanaian Pop"],
        "Classical": ["Baroque", "Classical", "Romantic", "Modern", "Contemporary Classical", "Chamber", "Opera", "Choral", "Orchestral", "Concerto", "Ballet", "Third Stream"]
    ]
}
// MARK: - RecordEntity

@objc(RecordEntity)
public class RecordEntity: NSManagedObject {}

extension RecordEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordEntity> {
        NSFetchRequest<RecordEntity>(entityName: "RecordEntity")
    }
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var artist: String?
    @NSManaged public var year: Int32
    @NSManaged public var genre: String?
    @NSManaged public var subgenre: String?
    @NSManaged public var format: String?
    @NSManaged public var label: String?
    @NSManaged public var elements: [String]?
    @NSManaged public var isOwned: Bool
    @NSManaged public var isFavorite: Bool
    @NSManaged public var rating: Int16
    @NSManaged public var linerNotes: String?
    @NSManaged public var dateAdded: Date?

    var formatEnum: Format? { Format(rawValue: format ?? "") }
    var elementEnums: [Element] { (elements ?? []).compactMap { Element(rawValue: $0) } }
    var displayTitle: String { title ?? "Unknown Title" }
    var displayArtist: String { artist ?? "Unknown Artist" }
}

extension RecordEntity: Identifiable {}
