//
//  ViewController.swift
//  MapApp

//haritalarla çalışma
//  Created by Zeynep Sevgi on 18.08.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class ViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate {
    
    
    
    
    @IBOutlet weak var IsimTextField: UITextField!
    
    @IBOutlet weak var NotTextField: UITextField!
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    var secilenIsim = ""
    var secilenId : UUID?
    
    
   var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate=self
        locationManager.delegate=self
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization() //konumun ne zaman kullanılacığı
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer:))) //kullanıcının tıkladığı yere ulaşmasını sağlayan konum //fonksiyonu
        gestureRecognizer.minimumPressDuration=3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if secilenIsim != "" {
            //core datadan verileri çek
            if let uuidString = secilenId?.uuidString {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetcRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetcRequest.predicate = NSPredicate(format: "id =%@", uuidString)
                fetcRequest.returnsObjectsAsFaults=false
                
                do{
                    let sonuclar = try context.fetch(fetcRequest)
                    if (sonuclar.count > 0) {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let isim = sonuc.value(forKey: "isim") as? String{
                                annotationTitle=isim
                                if let not = sonuc.value(forKey: "not") as? String {
                                    annotationSubtitle=not
                                    if let latitude = sonuc.value(forKey: "latitude") as? Double{
                                        annotationLatitude=latitude
                                        if let longitude = sonuc.value(forKey: "longitude") as? Double{
                                            annotationLongitude=longitude
                                            
                                            let annotation = MKPointAnnotation()
                                            annotation.title = annotationTitle
                                            annotation.subtitle=annotationSubtitle
                                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                            annotation.coordinate=coordinate
                                            mapView.addAnnotation(annotation)
                                            IsimTextField.text=annotationTitle
                                            NotTextField.text=annotationSubtitle
                                            locationManager.stopUpdatingLocation()
                                            
                                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                            let region = MKCoordinateRegion(center: coordinate, span: span)
                                            mapView.setRegion(region, animated:true)
                                        }
                                    }
                                }
                            }
                           
                          
                        }
                    }
                }catch{
                    print("hata")
                }
            }
        }else {
            //yeni veri eklemeye geldi
        }
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "benimAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .purple
            
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView=button
        }else{
            pinView?.annotation=annotation
        }
        return pinView
        
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if secilenIsim != ""{
            
            var requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarkDizisi,hata)  in
                if let placemarks = placemarkDizisi {
                    if ( placemarks.count > 0) {
                        let yeniPlacemark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: yeniPlacemark)
                        item.name = self.annotationTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey :MKLaunchOptionsDirectionsModeDriving ]
                        item.openInMaps(launchOptions: launchOptions)
                        
                        
                }
                
            }
        }
    }
        func konumSec(gestureRecognizer : UILongPressGestureRecognizer){
        //dokunulan yeri koordinata çevirebiliyoruz
        if gestureRecognizer.state == .began{
            let dokunulanNokta = gestureRecognizer.location(in: mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta,toCoordinateFrom: mapView)
            
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            let annotation = MKPointAnnotation() // işaretleme
            annotation.coordinate=dokunulanKoordinat
            annotation.title = IsimTextField.text
            annotation.subtitle = NotTextField.text
            mapView.addAnnotation(annotation)
        }
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       // print(locations[0].coordinate.latitude)
      //  print(locations[0].coordinate.longitude)
        if secilenIsim == ""{
            
       
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
             mapView.setRegion(region, animated: true)
        }
    }

    
    
    @IBAction func kaydetTiklandi(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        
        yeniYer.setValue(IsimTextField.text, forKey:"isim")
        yeniYer.setValue(NotTextField.text, forKey: "not")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("kayıt edildi")
        }catch{
            print("hata")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("yeniYerOlusturuldu")
    , object: nil)
        navigationController?.popViewController(animated: true)
        
    }
    
}

