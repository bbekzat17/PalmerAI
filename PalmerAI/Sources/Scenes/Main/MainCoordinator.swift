//
//  MainCoordinator.swift
//  PalmerAI
//
//  Created by Bekzat Batyrkhanov on 11.03.2025.
//
import UIKit
class MainCoordinator: Coordinator {
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let mainViewController = MainViewController()
        mainViewController.coordinator = self
        navigationController.pushViewController(mainViewController, animated: true)
    }
    
    func showCameraScreen() {
        let cameraViewController = CameraViewController()
        navigationController.pushViewController(cameraViewController, animated: true)
    }
    
    func showVoiceScreen() {
        let voiceViewController = VoiceViewController()
        navigationController.pushViewController(voiceViewController, animated: true)
    }
}
