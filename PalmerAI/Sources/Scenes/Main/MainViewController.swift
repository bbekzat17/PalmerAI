//
//  MainViewController.swift
//  PalmerAI
//
//  Created by Bekzat Batyrkhanov on 11.03.2025.
//

import UIKit

class MainViewController: UIViewController {
    weak var coordinator: MainCoordinator?

    private let cameraButton = UIButton(type: .system)
    private let voiceButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "Main"
        view.backgroundColor = .white
        
        // Camera button setup
        cameraButton.setTitle("Open Camera", for: .normal)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Voice button setup
        voiceButton.setTitle("Open Voice", for: .normal)
        voiceButton.addTarget(self, action: #selector(voiceButtonTapped), for: .touchUpInside)
        voiceButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add buttons to view
        view.addSubview(cameraButton)
        view.addSubview(voiceButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            voiceButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            voiceButton.topAnchor.constraint(equalTo: cameraButton.bottomAnchor, constant: 40)
        ])
    }
        
    @objc private func cameraButtonTapped() {
        coordinator?.showCameraScreen()
    }
        
    @objc private func voiceButtonTapped() {
        coordinator?.showVoiceScreen()
    }
}

