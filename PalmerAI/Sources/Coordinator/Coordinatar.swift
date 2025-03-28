//
//  Coordinatar.swift
//  PalmerAI
//
//  Created by Bekzat Batyrkhanov on 11.03.2025.
//

import UIKit
protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}
