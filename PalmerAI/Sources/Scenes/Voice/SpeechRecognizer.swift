////
////  SpeechRecognizer.swift
////  PalmerAI
////
////  Created by Bekzat Batyrkhanov on 06.04.2025.
////
//
////import Vosk
//import AVFoundation
//
//class SpeechRecognizer: NSObject {
//    private var recognizer: VoskRecognizer!
//    private var audioEngine = AVAudioEngine()
//
//    // languageCode: "kz" or "ru"
//    func startRecognition(languageCode: String) {
//        let modelFolder: String
//        switch languageCode {
//        case "kz":
//            modelFolder = "Models/kaz"
//        case "ru":
//            modelFolder = "Models/russian"
//        case "en":
//            modelFolder = "Models/eng"
//        default:
//            print("Unsupported language")
//            return
//        }
//
//        guard let modelPath = Bundle.main.path(forResource: modelFolder, ofType: nil) else {
//            print("Model path not found")
//            return
//        }
//
//        let model = Model(path: modelPath)
//        recognizer = VoskRecognizer(model: model, sampleRate: 16000.0)
//
//        let inputNode = audioEngine.inputNode
//        let recordingFormat = inputNode.outputFormat(forBus: 0)
//
//        inputNode.removeTap(onBus: 0)
//        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
//            let audioBuffer = buffer.audioBufferList.pointee.mBuffers
//            let data = Data(bytes: audioBuffer.mData!, count: Int(audioBuffer.mDataByteSize))
//
//            if self.recognizer.acceptWaveform(data) {
//                print("Result:", self.recognizer.result() ?? "")
//            } else {
//                print("Partial:", self.recognizer.partialResult() ?? "")
//            }
//        }
//
//        audioEngine.prepare()
//        try? audioEngine.start()
//        print("Started listening in \(languageCode.uppercased())")
//    }
//
//    func stopRecognition() {
//        audioEngine.stop()
//        audioEngine.inputNode.removeTap(onBus: 0)
//    }
//}
