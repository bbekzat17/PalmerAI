//
//  LanguageButton.swift
//  PalmerAI
//
//  Created by Bekzat Batyrkhanov on 11.03.2025.
//

import UIKit

class LanguageButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemIndigo
        layer.cornerRadius = 10
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setActive(_ isActive: Bool) {
        alpha = isActive ? 1.0 : 0.5
    }
}
