# Missing Files to Add to Xcode Project

The following files exist on disk but are not added to the Xcode project:

## 1. Booking.swift
**Location:** `DarnaApp/Models/Booking.swift`
**Contains:** `PropertyWithBookings` struct
**Error:** Cannot find type 'PropertyWithBookings' in scope

## 2. FavoritesManager.swift  
**Location:** `DarnaApp/Services/FavoritesManager.swift`
**Contains:** `FavoritesManager` class
**Error:** Cannot find 'FavoritesManager' in scope

## 3. MapLocationPickerView.swift
**Location:** `DarnaApp/Views/Components/MapLocationPickerView.swift`
**Contains:** `InlineMapLocationPicker` component
**Error:** Cannot find 'InlineMapLocationPicker' in scope

## How to Fix in Xcode:

1. Open DarnaApp.xcodeproj in Xcode
2. For each missing file:
   - Right-click on the appropriate group (Models/Services/Views/Components)
   - Select "Add Files to DarnaApp..."
   - Navigate to and select the file
   - ✅ Ensure "Copy items if needed" is UNCHECKED
   - ✅ Ensure "DarnaApp" target is CHECKED
   - Click "Add"

3. Clean Build Folder (Cmd + Shift + K)
4. Build (Cmd + B)

## Quick Fix via File Drag:
- Drag each file from Finder into the correct group in Xcode's Project Navigator
- Make sure to uncheck "Copy items if needed"
- Make sure "DarnaApp" target is selected
