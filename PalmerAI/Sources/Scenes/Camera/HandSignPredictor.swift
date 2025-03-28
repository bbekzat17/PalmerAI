//
//  HandSignPredictor.swift
//  PalmerAI
//
//  Created by Bekzat Batyrkhanov on 20.02.2025.
//

import CoreML

class HandSignPredictor {
    private let model: RandomForestModel
    init?() {
        do {
            self.model = try RandomForestModel(configuration: .init())
        } catch {
            print("⚠️ Error loading CoreML model: \(error)")
            return nil
        }
    }

    func predict(features: [Double]) -> String? {
        guard features.count == 42 else {
            print("⚠️ Invalid number of features: expected 42, got \(features.count)")
            return nil
        }
        
        let modelInput = RandomForestModelInput(
            feature_0: features[0], feature_1: features[1], feature_2: features[2], feature_3: features[3],
            feature_4: features[4], feature_5: features[5], feature_6: features[6], feature_7: features[7],
            feature_8: features[8], feature_9: features[9], feature_10: features[10], feature_11: features[11],
            feature_12: features[12], feature_13: features[13], feature_14: features[14], feature_15: features[15],
            feature_16: features[16], feature_17: features[17], feature_18: features[18], feature_19: features[19],
            feature_20: features[20], feature_21: features[21], feature_22: features[22], feature_23: features[23],
            feature_24: features[24], feature_25: features[25], feature_26: features[26], feature_27: features[27],
            feature_28: features[28], feature_29: features[29], feature_30: features[30], feature_31: features[31],
            feature_32: features[32], feature_33: features[33], feature_34: features[34], feature_35: features[35],
            feature_36: features[36], feature_37: features[37], feature_38: features[38], feature_39: features[39],
            feature_40: features[40], feature_41: features[41]
        )
        
        do {
            let prediction = try model.prediction(input: modelInput)
            return prediction.classLabel
        } catch {
            print("⚠️ Prediction error: \(error)")
            return nil
        }
    }
}

