//
//  MapViewController.swift
//  SongMaps
//
//  Created by Polecat on 12/14/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import UIKit
import MapKit
import Kingfisher

class MapViewController: UIViewController, Storyboarded, EventHandler {

    var events = [Event]()
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        let initialLocation = CLLocation(latitude: settings.lat, longitude: settings.long)
        centerMapOnLocation(location: initialLocation)

        mapView.isZoomEnabled = true
        
        addEvents(events: events)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = metersFrom(miles: 100)
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
      mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func metersFrom(miles: Int) -> Double {
        return Double(miles)/0.00062137
    }
    
    // MARK: - EventHandler
    
    func newEvents(events: [Event]) {
        self.events = events

        addEvents(events: events)
    }
    
    func addEvents(events: [Event]) {
        guard mapView != nil else {
            return
        }
        mapView.removeAnnotations(self.mapView.annotations)
        for event in events {
            mapView.addAnnotation(event)
        }
    }

}

extension MapViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    guard let annotation = annotation as? Event else { return nil }
    let identifier = "marker"
    var view: MKMarkerAnnotationView
    if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
        dequeuedView.annotation = annotation
        view = dequeuedView
    } else {
        view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    return view
  }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let event = view.annotation as? Event else {
            return
        }

        if let url = URL(string: event.url) {
            UIApplication.shared.open(url)
        }
    }
}

extension Event: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(lat), longitude: Double(long))
    }
    
    public var title: String? {
        return name
    }
    
    public var subtitle: String? {
        return venue
    }
}
