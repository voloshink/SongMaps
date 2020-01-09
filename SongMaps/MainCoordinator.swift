//
//  MainCoordinator.swift
//  SongMaps
//
//  Created by Polecat on 12/16/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        if settings.launchedBefore {
            normalLaunch()
        } else {
            initalLaunch()
        }
    }
    
    func askForLocation() {
        let vc = LocationRequestViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToMain() {
        let vc = TabBarViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func spotifyLogin(with url: URL, caller: SpotifyHandler) {
        let vc = SpotifyViewController.instantiate()
        vc.coordinator = self
        vc.handler = caller
        vc.spotifyURL = url
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goBack() {
        _ = navigationController.popViewController(animated: true)
    }
    
    private func normalLaunch() {
        let vc = TabBarViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    private func initalLaunch() {
        let vc = LoginViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}
