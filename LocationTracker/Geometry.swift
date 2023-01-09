//
//  Coordinate.swift
//  LocationTracker
//
//  Created by Edgar on 05.01.23.
//

struct Geometry: Codable {
    let coordinates: [Coordinate]
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
}


