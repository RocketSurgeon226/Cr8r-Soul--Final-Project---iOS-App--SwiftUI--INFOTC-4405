# Cr8r Soul 🎵

A SwiftUI app for tracking a physical and digital music collection, with elemental tagging, a Dig Mode randomizer and a Swift Charts stats dashboard.

Final project for INFOTC 4405 (iOS App Development), May 2026.

| Cr8 | Dig Mode | Soul Stats |
|---|---|---|
| ![Cr8](docs/screenshots/cr8.png) | ![Dig Mode](docs/screenshots/dig.png) | ![Soul Stats](docs/screenshots/stats.png) |

## What it does

The app has four tabs.

- **Cr8.** Your collection, as a grid of cards. Search by artist or title, filter by favorites, element or format, and sort by date added, title, artist, year or rating.
- **Shipment.** Your Cr8 Shipment want list. Swipe right on a record to mark it "Got It!" and move it into your Cr8.
- **Dig.** Pulls a random "record of the moment" from your Cr8, your Shipment or both, optionally filtered by element, with a spring-animated card.
- **Soul Stats.** Swift Charts views of your collection by element, format, decade and top genres, plus your average rating, a Desert Island Shelf of favorites and a Highest Rated shelf.

Every record has a title, artist, year, label, format, genre and subgenre, a 1 to 5 star rating, liner notes, and one or more elements.

### Formats

Vinyl · Cassette · CD · MiniDisc · 8-Track · Shellac · Digital

### Elements

Tag each record by its dominant musical energy:

| Element | Instrument family |
|---|---|
| 💧 Water | Strings |
| 🌍 Earth | Percussion |
| 🔥 Fire | Brass |
| 💨 Air | Woodwinds |

### Generative cover art

There's no artwork to download. Each record gets a cover drawn in SwiftUI: a gradient from its element colors (or its genre if it has no elements) with a pattern for its element mix, such as waves for Water + Air or a diamond for Fire + Earth.

## Tech

- Swift and SwiftUI, MVVM with `ObservableObject` view models
- CoreData for local, offline storage (`RecordEntity`)
- Swift Charts for the Soul Stats dashboard
- Combine to debounce search

## Running it

1. Clone the repo.
2. Open `Final_Cr8r_Soul2/Final_Cr8r_Soul2.xcodeproj` in Xcode 26.4 or later.
3. Run on an iPhone simulator. The deployment target is iOS 26.4.

## Project structure

| File | What's in it |
|---|---|
| `Cr8rSoulApp.swift` | App entry point and the CoreData `PersistenceController` |
| `Models.swift` | `Element`, `Format`, the genre and subgenre library, `RecordEntity` |
| `ViewModels.swift` | `Cr8ViewModel` (search, filter, sort), `AddEditViewModel`, `DigModeViewModel` |
| `Cr8Views.swift` | Cr8 grid, filter bar and the Cr8 Shipment list |
| `DetailViews.swift` | Record detail, liner notes and the add/edit form |
| `DashboardViews.swift` | Soul Stats (`DashboardViewModel` and charts) and Dig Mode |
| `SharedViews.swift` | Generative album art, badges, star rating, search bar, filter chips, tab bar |

## Notable fix

The dashboard crashed with a stack overflow because its view model recomputed on every state change. `DashboardViewModel` now has a single `recompute(from:)` entry point that the view calls on appear and when the record count changes.

## From proposal to final app

- AI-generated or looked-up cover art became generative art drawn on the device, so the app stays offline.
- Filters by genre and mood became filters by element, format, favorites and keyword.

## License

MIT
