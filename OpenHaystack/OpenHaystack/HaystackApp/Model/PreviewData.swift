//
//  OpenHaystack – Tracking personal Bluetooth devices via Apple's Find My network
//
//  Copyright © 2021 Secure Mobile Networking Lab (SEEMOO)
//  Copyright © 2021 The Open Wireless Link Project
//
//  SPDX-License-Identifier: AGPL-3.0-only
//

import CoreLocation
import Foundation
import SwiftUI

// swiftlint:disable force_try
struct PreviewData {
    static let accessories: [Accessory] = {
        return accessoryList()
    }()

    static let latitude: Double = 49.878046
    static let longitude: Double = 8.656993

    static func randomLocation(lat: Double = latitude, lng: Double = longitude, distance: Double = 0.005) -> CLLocation {
        return CLLocation(
            latitude: lat + Double.random(in: 0..<distance) * (Bool.random() ? -1 : 1),
            longitude: lng + Double.random(in: 0..<distance) * (Bool.random() ? -1 : 1)
        )
    }

    static func randomTimestamp() -> Date {
        return Date.init().addingTimeInterval(TimeInterval(-Double.random(in: 0..<24 * 60 * 60)))
    }

    static func previewAccessory(name: String, color: Color, number: String) -> Accessory {
        let accessory = try! Accessory(name: name, color: color, number: number)
        accessory.lastLocation = randomLocation()
        accessory.locationTimestamp = randomTimestamp()
        accessory.isDeployed = true
        accessory.isActive = true
        accessory.isNearby = Bool.random()
        //Generate recent locations
        let startDate = Date().addingTimeInterval(-60 * 60 * 24)
        var date = startDate
        var locations: [FindMyLocationReport] = []
        while date < Date() {
            let location = randomLocation(lat: accessory.lastLocation!.coordinate.latitude, lng: accessory.lastLocation!.coordinate.longitude, distance: 0.0005)
            locations.append(FindMyLocationReport(lat: location.coordinate.latitude, lng: location.coordinate.longitude, acc: 10, dP: date, t: date, c: 0))
            date += 30 * 60
        }
        accessory.locations = locations
        return accessory
    }

    static func accessoryList() -> [Accessory] {
        return [
            previewAccessory(name: "Backpack", color: Color.green, number: "1"),
            previewAccessory(name: "Bag", color: Color.blue, number: "2"),
            previewAccessory(name: "Car", color: Color.red, number: "3"),
            previewAccessory(name: "Keys", color: Color.orange, number: "4"),
            previewAccessory(name: "Items", color: Color.gray, number: "5"),
        ]
    }
}
