//
//  WeatherCollectionVC.swift
//  SimpleWeather!
//
//  Created by Daniel Legler on 8/10/17.
//  Copyright © 2017 Daniel Legler. All rights reserved.
//

import UIKit
import RealmSwift

let SWPrimaryColor = UIColor(red: 71/255, green: 96/255, blue: 137/255, alpha: 1)
let SWSecondaryColor = UIColor(red: 0, green: 0.737, blue: 0.831, alpha: 1)
let navigationBarTitleAttributes = [NSFontAttributeName: UIFont(name: "Avenir", size: 20)!,
                                    NSForegroundColorAttributeName: SWPrimaryColor]

class WeatherCollectionVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var doneEditingButton: UIBarButtonItem!
    
    var locations: Results<Location> = {
        
            let realm = try! Realm()
            
            let sortProperties = [SortDescriptor(keyPath: "isCurrentLocation", ascending: false), SortDescriptor(keyPath: "city", ascending: true)]
            
            return realm.objects(Location.self).sorted(by: sortProperties)

    }()

    var token: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(noConnection), name: .SWNoNetworkConnection, object: nil)

        customizeNavigationController()
        
        doneEditingButton.target = self
        doneEditingButton.action = #selector(editButton)
        
        let refresher = UIRefreshControl()
        self.collectionView.alwaysBounceVertical = true
        refresher.tintColor = UIColor.white
        refresher.addTarget(self, action: #selector(refreshWeather), for: UIControlEvents.valueChanged)
        self.collectionView.refreshControl = refresher
        
        initializeRealm()
        refreshWeather()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fabMenuController?.fabMenu.isHidden = false

    }
    
    func addCityButtonPressed() {
        performSegue(withIdentifier: "CitySearch", sender: nil)
    }
    
    @IBAction func newCityAdded(segue: UIStoryboardSegue) {
        Loading.shared.show(view)
    }
    
    func refreshWeather() {
        
        Coordinator.shared.updateAllWeather { error in
            self.collectionView.refreshControl?.endRefreshing()
            guard error == nil else { return }
            
            switch error! {
            case .downloadError: self.alert(title: "Network Error", message: "Couldn't download weather")
            case .invalidCoordinates: self.alert(title: "Network Error", message: "Weather for city unavailable")
            case .jsonError: self.alert(title: "Network Error", message: "Weather Server Error")
            case .realmError: self.alert(title: "Error", message: "Couldn't Save Weather")
            }
        }
    }

    func initializeRealm() {
        
        token = locations.addNotificationBlock {[weak self] (changes: RealmCollectionChange) in
            
            guard let collectionView = self?.collectionView else { return }
            
            switch changes {
                
            case .initial:
                
                collectionView.reloadData()

                self?.updateUI()
                
                Loading.shared.hide()
                
                break
                
            case .update( _, let deletions, let insertions, let modifications):
                
                collectionView.performBatchUpdates({

                    collectionView.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                    collectionView.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                    collectionView.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                    
                }, completion: { _ in
                    collectionView.reloadData()
                    self?.updateUI()
                    Loading.shared.hide()
                    self?.collectionView.refreshControl?.endRefreshing()
                })
            case .error(let error):
                print(error)
                break
            }
        }
    }
    
    @objc func editButton() {
        setEditing(!isEditing, animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        doneEditingButton.tintColor = editing == true ? SWPrimaryColor : .clear
        doneEditingButton.isEnabled = editing
        fabMenuController?.fabMenu.isHidden = editing
        collectionView.reloadData()
        
    }
    
    func updateUI() {
        
        let locationsPresent = locations.count > 0
        
        if !locationsPresent {
            setEditing(false, animated: false)
        }
    
        collectionView.isHidden = !locationsPresent
        
    }
}

extension WeatherCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let weatherDetailVC = segue.destination as? WeatherDetailVC {
            guard let tappedCell = collectionView.indexPathsForSelectedItems?.first else { return }
            weatherDetailVC.location = locations[tappedCell.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
            performSegue(withIdentifier: "WeatherDetail", sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as? WeatherCell else {
            return UICollectionViewCell()
        }
        
        cell.configureWith(locations[indexPath.row])
        cell.motionIdentifier = cell.location.city
        cell.deleteButton.isHidden = (!isEditing) || (cell.location.isCurrentLocation)
        cell.deleteButton.addTarget(self, action: #selector(deleteCellButton(button:)), for: UIControlEvents.touchUpInside )
        
        return cell
    }
    
    func deleteCellButton(button: DeleteButton) {
        
        guard let city = button.cityToDelete else {
            print("No City Associated with that Button"); return
        }
        
        Coordinator.shared.deleteWeatherAt(city: city) { (_) in
            self.alert(title: "Error", message: "Couldn't Delete Weather For \(city)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let space: CGFloat = 3.0
        let dimension: CGFloat = (UIScreen.main.bounds.width - 20 - (2 * space)) / 2.0
        return CGSize(width: dimension, height: dimension + 10)
    }
}
