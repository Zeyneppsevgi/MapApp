//
//  ListViewController.swift
//  MapApp
//
//  Created by Zeynep Sevgi on 6.09.2022.
//

import UIKit
import CoreData
class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var isimDizisi = [String] ()
    var idDizisi = [UUID] ()
    
    var secilenYerIsmi = ""
    var secilenYerId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate=self
        tableView.dataSource=self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(artiButtonuTiklandi))
        
        veriAl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(veriAl), name: NSNotification.Name("yeniYerOlusturuldu"), object: nil)
    }
    
     @objc func veriAl() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
        request.returnsObjectsAsFaults = false
        
        do {
            let sonuclar = try context.fetch(request)
            if sonuclar.count > 0 {
                isimDizisi.removeAll(keepingCapacity: false)
                idDizisi.removeAll(keepingCapacity: false)
                
                for sonuc in sonuclar as! [NSManagedObject] {
                    if let isim =  sonuc.value(forKey: "isim") as? String{
                        isimDizisi.append(isim)
                    }
                    if let id = sonuc.value(forKey:"id") as? UUID{
                        idDizisi.append(id)
                    }
                }
                tableView.reloadData()
            }
        }catch{
            print("hata")
        }
        
    }
    
    @objc func artiButtonuTiklandi (){
        secilenYerIsmi = ""
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenYerIsmi = isimDizisi[indexPath.row]
        secilenYerId = idDizisi[indexPath.row]
        
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapsVC" {
            let destinationVC = segue.destination as! ViewController
            destinationVC.secilenIsim = secilenYerIsmi
            destinationVC.secilenId = secilenYerId
        }
    }


}
