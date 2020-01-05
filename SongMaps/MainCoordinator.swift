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
    }

    func start() {
        let vc = TabBarViewController.instantiate()
        navigationController.pushViewController(vc, animated: false)
    }
    
    func firstLaunch() {
        let vc = LoginViewController.instantiate()
        navigationController.pushViewController(vc, animated: false)
    }
}
