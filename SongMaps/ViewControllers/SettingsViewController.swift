//
//  SettingsViewController.swift
//  SongMaps
//
//  Created by Polecat on 1/9/20.
//  Copyright © 2020 Polecat. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController, Storyboarded {

    @IBOutlet weak var lastFMButton: RoundedButton!
    @IBOutlet weak var spotifyButton: RoundedButton!
    @IBOutlet var gradientBackground: FluidBackgroundView!
    
    var artists = [Artist]()
    
    let spotify = Spotify()
    let lastFM = LastFM()
    
    var customTabBar: TabBarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let tabBar = tabBarController else {
            return
        }
        
        guard let customTabBar = tabBar as? TabBarViewController else {
            return
        }
        
        self.customTabBar = customTabBar
        
        artists = customTabBar.artists
    }
    
    private func resetUI() {
        gradientBackground.resetToDefault()
        spotifyButton.alpha = 1
        spotifyButton.isEnabled = true
        spotifyButton.setTitle("Spotify", for: .normal)
        lastFMButton.alpha = 1
        lastFMButton.isEnabled = true
        lastFMButton.setTitle("Last.FM", for: .normal)
    }
    
    @IBAction func lastFMTap(_ sender: Any) {
        if hasArtists(from: "LastFM") {
            let alert = UIAlertController(title: "Artists Already Exist", message: "Would you like to re-add the artists or use the existing ones?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Delete Artists", style: .destructive, handler: { _ in
                for artist in self.artists where artist.source == "LastFM" {
                    self.customTabBar.container.viewContext.delete(artist)
                }
                
                self.customTabBar.saveContext()
                self.customTabBar.loadArtists()
                self.customTabBar.loadEvents()
                self.lastFMAlert()
            }))
            
            alert.addAction(UIAlertAction(title: "Use Existing", style: .default, handler: { _ in
                self.lastFMAlert()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            lastFMAlert()
        }
    }
    
    private func lastFMAlert() {
        gradientBackground.updateGradient(with: UIColor.red, followed: UIColor.white)
        
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
    
    private func getLastfmAritst(for username: String) {
        lastFMButton.isEnabled = false
        spotifyButton.isEnabled = false
        UIView.animate(withDuration: 2.0, animations: {
            self.spotifyButton.alpha = 0.0
        })
        
        lastFMButton.setTitle("Getting Artists", for: .normal)
        
        lastFM.getArtists(user: username, progress: { progress in
            
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
    
    private func showErrorAlert(error: String) {
        let alert = UIAlertController(title: "We Encountered An Error", message: error, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.resetUI()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func parseArtists(service: String, artists: [String]) {
        for artistName in artists {
            let artist = Artist(context: customTabBar.container.viewContext)
            artist.name = artistName
            artist.added = Date()
            artist.source = service
        }
        
        customTabBar.saveContext()
        customTabBar.loadArtists()
        customTabBar.loadEvents()
        self.artists = customTabBar.artists
        resetUI()
    }
    
    private func hasArtists(from source: String) -> Bool {
        for artist in artists {
            if artist.source == source {
                return true
            }
        }
        
        return false
    }
    
    
    @IBAction func spotifyTap(_ sender: Any) {
        if hasArtists(from: "Spotify") {
            let alert = UIAlertController(title: "Artists Already Exist", message: "Would you like to re-add the artists or use the existing ones?", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Delete Artists", style: .destructive, handler: { _ in
                for artist in self.artists where artist.source == "Spotify" {
                    self.customTabBar.container.viewContext.delete(artist)
                }
                
                self.customTabBar.saveContext()
                self.customTabBar.loadArtists()
                self.customTabBar.loadEvents()
                self.getSpotify()
            }))
            
            alert.addAction(UIAlertAction(title: "Use Existing", style: .default, handler: { _ in
                self.getSpotify()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            getSpotify()
        }
    }
    
    private func getSpotify() {
        gradientBackground.updateGradient(with: UIColor.green, followed: UIColor.black)
        
        spotifyButton.isEnabled = false
        lastFMButton.isEnabled = false
        UIView.animate(withDuration: 2.0, animations: {
            self.lastFMButton.alpha = 0.0
        })
        
        spotifyButton.setTitle("Getting Artists", for: .normal)
        
        spotify.authorize()
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

    // MARK: - EventHandler

}
