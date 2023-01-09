//
//  JsonHelper.swift
//  LocationTracker
//
//  Created by Edgar on 05.01.23.
//

import Foundation
import MapKit

struct JsonHelper {
    
    func getJsonData(filePath: URL) -> Data? {
        do {
            let data = try Data(contentsOf: filePath)
            return data
        } catch {
            print("ERROR: Unable to read JSON file")
        }
        return nil
    }
    
    func getCoordinates(jsonData: Data) -> [CLLocation] {
        var routeCoordinates : [CLLocation] = []
        do {
            let geometry = try JSONDecoder().decode(Geometry.self, from: jsonData)
            
            for coordinates in geometry.coordinates {
                let loc = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                routeCoordinates.append(loc)
            }
        } catch {
            print("ERROR: Unable to parse JSON file")
            print(error)
        }
        return routeCoordinates
    }
    
    func writeIntoJson(filePath: URL, routeCoordinates: [CLLocation]) {
        do {
            print("fileUrl \(filePath)")
            var coordinates: [Coordinate] = []
            for routeCoordinate in routeCoordinates {
                let coordinate = Coordinate(latitude: routeCoordinate.coordinate.latitude, longitude: routeCoordinate.coordinate.longitude)
                coordinates.append(coordinate)
            }
            let geometry = Geometry(coordinates: coordinates)
            let jsonResultData = try JSONEncoder().encode(geometry)
            try jsonResultData.write(to: filePath)
        } catch {
            print("ERROR: Unable to write data into JSON file")
            print(error)
        }
    }
    
}
