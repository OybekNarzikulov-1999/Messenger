//
//  LocationPickerViewController.swift
//  Messenger
//
//  Created by Oybek Narzikulov on 23/01/23.
//

import UIKit
import CoreLocation
import MapKit

final class LocationPickerViewController: UIViewController {
    
    // MARK: - Properties
    
    public var completion: ((CLLocationCoordinate2D) -> Void)?
    
    private var coordinates: CLLocationCoordinate2D?
    
    private var isPickable = true
    
    private lazy var map: MKMapView = {
        let map = MKMapView()
        return map
    }()

    // MARK: - Lifecycle
    
    init(coordinates: CLLocationCoordinate2D?, isPickable: Bool){
        self.coordinates = coordinates
        self.isPickable = isPickable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        view.addSubview(map)
        
        if isPickable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendButtonTapped))
            map.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMap(_:)))
            gesture.numberOfTouchesRequired = 1
            gesture.numberOfTapsRequired = 1
            map.addGestureRecognizer(gesture)
        } else {
            // Just showing location
            guard let coordinates = coordinates else {
                return
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate =  coordinates
            map.addAnnotation(annotation)
        }
        
    }

    override func viewDidLayoutSubviews() {
        map.frame = view.bounds
    }
    
    // MARK: - Selectors
    
    @objc func sendButtonTapped(){
        
        guard let coordinates = coordinates else {
            return
        }
        navigationController?.popViewController(animated: true)
        completion?(coordinates)
        
    }
    
    @objc func didTapMap(_ gesture: UITapGestureRecognizer){
        
        let locationInView = gesture.location(in: map)
        let coordinates = map.convert(locationInView, toCoordinateFrom: map)
        self.coordinates = coordinates
        

        map.removeAnnotations(map.annotations)

        // drop a pin on this location
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        map.addAnnotation(annotation)

    }
    
}
