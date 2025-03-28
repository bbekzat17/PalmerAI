//
//  VoiceViewController.swift
//  PalmerAI
//
//  Created by Bekzat Batyrkhanov on 11.03.2025.
//

import UIKit

class VoiceViewController: UIViewController {
    
    private let firstButton = LanguageButton()
    private let secondButton = LanguageButton()
    private let swapButton = UIButton()

    private let outputView1 = CustomTextfield()
    private let outputView2 = CustomTextfield()
    
    private lazy var micButton: UIButton = {
        let micButton = UIButton()
        micButton.setImage(UIImage(systemName: "microphone.circle.fill"), for: .normal)
        micButton.imageView?.contentMode = .scaleAspectFit
        micButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 100, weight: .bold, scale: .large), forImageIn: .normal)

        micButton.tintColor = .black
        micButton.translatesAutoresizingMaskIntoConstraints = false
        return micButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Voice Recognition"
        setupButtons()
        setupConstraints()
    }
    
    func setupConstraints() {
        let buttonStack = UIStackView(arrangedSubviews: [firstButton, swapButton, secondButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        let outputStack = UIStackView(arrangedSubviews: [outputView1, outputView2])
        outputStack.axis = .vertical
        outputStack.spacing = 50
        outputStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonStack)
        view.addSubview(outputStack)
        view.addSubview(micButton)
        
        NSLayoutConstraint.activate([
            // Button Stack
            firstButton.widthAnchor.constraint(equalToConstant: 130),
            secondButton.widthAnchor.constraint(equalToConstant: 130),
            buttonStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStack.widthAnchor.constraint(equalToConstant: 300),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
            
            // Output Stack
            outputView1.heightAnchor.constraint(equalToConstant: 200),
            outputView2.heightAnchor.constraint(equalToConstant: 200),
            outputStack.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 20),
            outputStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            outputStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            outputStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            micButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            micButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            micButton.widthAnchor.constraint(equalToConstant: 200),
            micButton.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupButtons() {
        firstButton.setTitle("Kazakh", for: .normal)
        firstButton.layer.cornerRadius = 10
                
        secondButton.setTitle("Russian", for: .normal)
        secondButton.layer.cornerRadius = 10
                
        swapButton.setImage(UIImage(systemName: "arrow.2.circlepath"), for: .normal)
        swapButton.tintColor = .black
        swapButton.addTarget(self, action: #selector(swapLanguages), for: .touchUpInside)
    }
    
    @objc private func swapLanguages() {
        let temp = outputView1.getText()
        outputView1.setText(outputView2.getText() ?? "")
        outputView2.setText(temp ?? "")
    }
}
