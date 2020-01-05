//
//  MapViewController.swift
//  SongMaps
//
//  Created by Polecat on 12/14/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, Storyboarded {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
//        mapView.delegate = self
        
        let initialLocation = CLLocation(latitude: 42.36008406, longitude: -71.05890512)
        centerMapOnLocation(location: initialLocation)
        
//        let event = Event(name: "Temples", venue: "The Sinclair Music Hall", date: Date(), coordinate: CLLocationCoordinate2D(latitude: 42.380199, longitude: -71.134697))
//         mapView.addAnnotation(event)
        mapView.isZoomEnabled = true
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension MapViewController: MKMapViewDelegate {
//
//  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//
//    guard let annotation = annotation as? Event else { return nil }
//    let identifier = "marker"
//    var view: MKMarkerAnnotationView
//    if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//      as? MKMarkerAnnotationView {
////      dequeuedView.annotation = annotation
//      view = dequeuedView
//    } else {
////      view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
////      view.canShowCallout = true
////      view.calloutOffset = CGPoint(x: -5, y: 5)
////      view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//    }
//    return view
//  }
//
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        print("tap tap!")
//        print(view.annotation as! Event)
//    }
//}
