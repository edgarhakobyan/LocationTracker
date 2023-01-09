//
//  ViewController.swift
//  LocationTracker
//
//  Created by Edgar on 04.01.23.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager: CLLocationManager = CLLocationManager()
    private let jsonHelper = JsonHelper()
    private let annotationTypeStart = "start"
    private let annotationTypeEnd = "end"
    
    private var routeCoordinates : [CLLocation] = []
    private var routeOverlay : MKOverlay?
    
    private var jsonFilePath: URL? {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)
        if let url = urls.first {
            let fileURL = url.appendingPathComponent("data").appendingPathExtension("json")
            return fileURL
        }
        return nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.distanceFilter = 50.0
        locationManager.startUpdatingLocation()
        
        locationManager.startMonitoringSignificantLocationChanges()
        
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        if let url = jsonFilePath,
           let jsonData = jsonHelper.getJsonData(filePath: url) {
            routeCoordinates = jsonHelper.getCoordinates(jsonData: jsonData)
        }
        
        addPins()
        drawRoute(routeData: routeCoordinates)
    }
    
    private func addPins() {
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        if routeCoordinates.count != 0 {
            let startPin = MKPointAnnotation()
            startPin.title = annotationTypeStart
            startPin.coordinate = CLLocationCoordinate2D(
                latitude: routeCoordinates[0].coordinate.latitude,
                longitude: routeCoordinates[0].coordinate.longitude
            )
            mapView.addAnnotation(startPin)
            
            let endPin = MKPointAnnotation()
            endPin.title = annotationTypeEnd
            endPin.coordinate = CLLocationCoordinate2D(
                latitude: routeCoordinates[routeCoordinates.count - 1].coordinate.latitude,
                longitude: routeCoordinates[routeCoordinates.count - 1].coordinate.longitude
            )
            mapView.addAnnotation(endPin)
        }
    }
    
    private func drawRoute(routeData: [CLLocation]) {
        if routeCoordinates.count == 0 {
            print("No Coordinates to draw")
            return
        }
        
        let coordinates = routeCoordinates.map { (location) -> CLLocationCoordinate2D in
            return location.coordinate
        }
        
        DispatchQueue.main.async {
            self.routeOverlay = MKPolyline(coordinates: coordinates, count: coordinates.count)
            self.mapView.addOverlay(self.routeOverlay!, level: .aboveRoads)
            let customEdgePadding: UIEdgeInsets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 20)
            self.mapView.setVisibleMapRect(self.routeOverlay!.boundingMapRect, edgePadding: customEdgePadding, animated: false)
        }
    }
    
    private func updateRouteCoordinates(location: CLLocation) {
        routeCoordinates.append(location)
        addPins()
        drawRoute(routeData: routeCoordinates)
        if let url = jsonFilePath {
            jsonHelper.writeIntoJson(filePath: url, routeCoordinates: routeCoordinates)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        guard let currentLocation = routeCoordinates.last else {
            updateRouteCoordinates(location: newLocation)
            return
        }
        
        let distance = currentLocation.distance(from: newLocation)
        if (distance >= 50) {
            updateRouteCoordinates(location: newLocation)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
        } else {
            annotationView?.annotation = annotation
        }
        
        if (annotation.title == annotationTypeStart || annotation.title == annotationTypeEnd) {
            annotationView?.image = UIImage(systemName: "mappin")
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKGradientPolylineRenderer(overlay: overlay)
        renderer.setColors([.black], locations: [])
        renderer.lineCap = .round
        renderer.lineWidth = 1.0
        return renderer
    }
}
