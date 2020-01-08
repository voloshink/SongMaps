//
//  ViewController.swift
//  SongMaps
//
//  Created by Polecat on 11/11/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, Storyboarded {
    
    @IBOutlet var backgroundView: FluidBackgroundView!
    @IBOutlet weak var lastFMButton: RoundedButton!
    @IBOutlet weak var spotifyButton: RoundedButton!
    @IBOutlet weak var manualButton: RoundedButton!
    
    weak var coordinator: MainCoordinator?
    
    var container: NSPersistentContainer!
    
    let spotify = Spotify()
    let lastFM = LastFM()
    
    var artists = [Artist]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCoreData()
        loadArtists()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manualButton.isHidden = true
    }
    
    func spotifyAuthResponse(code: String, state: String, error: String?) {
        if let error = error {
            print(error)
            showErrorAlert(error: "Authentication Error")
            return
        }

        spotify.authorizationResponse(code: code, state: state, progress: { progress in
            var percentage = Int(progress * 100)
            if percentage > 100 {
                percentage = 100
            }
            self.spotifyButton.setTitle(String(percentage) + "%", for: .normal)
            
            }, completion: { artists in
                self.parseArtists(service: "Spotify", artists: artists)
        }, error: { err in
            self.showErrorAlert(error: err)
        })
    }
    
    private func getLastfmAritst(for username: String) {
        lastFMButton.isEnabled = false
        spotifyButton.isEnabled = false
        UIView.animate(withDuration: 2.0, animations: {
            self.spotifyButton.alpha = 0.0
            self.manualButton.isHidden = true
        })
        
        lastFMButton.setTitle("Getting Artists", for: .normal)
        
        lastFM.getArtists(user: username, progress: { progress in
            print(progress)
            
            var percentage = Int(progress * 100)
            if percentage > 100 {
                percentage = 100
            }
            self.lastFMButton.setTitle(String(percentage) + "%", for: .normal)
        }, completion: { artists in
            self.parseArtists(service: "LastFM", artists: artists)
        }, error: { error in
            print(error)
            self.showErrorAlert(error: error)
        })
    }
    
    private func existingArtistsAlert() {
        let alert = UIAlertController(title: String(artists.count) + " Artists Already On Disk", message: "Would you like to re-add the artists or use the existing ones?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Delete Artists", style: .destructive, handler: { _ in
            for artist in self.artists {
                self.container.viewContext.delete(artist)
            }
            
            self.saveContext()
        }))
        
        alert.addAction(UIAlertAction(title: "Use Existing", style: .default, handler: { _ in
            self.coordinator?.askForLocation()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showErrorAlert(error: String) {
        let alert = UIAlertController(title: "We Encountered An Error", message: error, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.resetUI()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func resetUI() {
        backgroundView.resetToDefault()
        spotifyButton.alpha = 1
        spotifyButton.isEnabled = true
        spotifyButton.setTitle("Spotify", for: .normal)
        lastFMButton.alpha = 1
        lastFMButton.isEnabled = true
        lastFMButton.setTitle("Last.FM", for: .normal)
    }
    
    private func parseArtists(service: String, artists: [String]) {
        for artistName in artists {
            let artist = Artist(context: container.viewContext)
            artist.name = artistName
            artist.added = Date()
            artist.source = service
        }
        
        saveContext()
        coordinator?.askForLocation()
    }
    
    private func loadArtists() {
        let request = Artist.createFetchRequest()
        guard let artists = try? container.viewContext.fetch(request) else {
            return
        }
        self.artists = artists
        existingArtistsAlert()
        print("Got \(artists.count) artists")
    }
    
    // MARK: - CoreData
    private func initializeCoreData() {
        container = NSPersistentContainer(name: "SongMaps")
        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
    }
    
    private func saveContext() {
        guard let container = container else {
            return
        }

        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func lastFMTap(_ sender: Any) {
        self.backgroundView.updateGradient(with: UIColor.red, followed: UIColor.white)
        
        let alert = UIAlertController(title: "LastFM", message: "Please Enter Your LastFM Username", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Username"
        }

        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            guard let text = textField.text else {
                self.resetUI()
                return
            }
            
            guard text != "" else {
                self.resetUI()
                return
            }
            self.getLastfmAritst(for: text)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.resetUI()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func spotifyTap(_ sender: Any) {
         self.backgroundView.updateGradient(with: UIColor.green, followed: UIColor.black)
        
        spotifyButton.isEnabled = false
        lastFMButton.isEnabled = false
        UIView.animate(withDuration: 2.0, animations: {
            self.lastFMButton.alpha = 0.0
            self.manualButton.isHidden = true
        })
        
        spotifyButton.setTitle("Getting Artists", for: .normal)
        
        spotify.authorize()
    }
    
    @IBAction func manualTap(_ sender: Any) {
        self.backgroundView.updateGradient(with: UIColor.white, followed: UIColor.blue)
    }
    
}



