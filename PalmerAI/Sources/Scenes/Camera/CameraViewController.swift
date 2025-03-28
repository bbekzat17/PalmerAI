import UIKit
import AVKit
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var captureSession: AVCaptureSession?
    private var handSignPredictor: HandSignPredictor?
    private let handPoseRequest = VNDetectHumanHandPoseRequest() // Запрос на распознавание руки
    private let predictionLabel: UILabel = {
        let label = UILabel()
        label.text = "Waiting for prediction..."
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()
    
    private let previewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let kazakhButton = LanguageButton()
    private let russianButton = LanguageButton()
    private let englishButton = LanguageButton()
    
    private let signLabels = [
        0: "Hello", 1: "Okay", 2: "My name is", 3: "Where",
        4: "Eat", 5: "Drink", 6: "Pain", 7: "Yes", 8: "No", 9: "Thank you"
    ]
    
    private var lastPredictionTime = Date()  // Stores the last time a prediction was made
    private let predictionInterval: TimeInterval = 0.5 // Only predict every 0.5 second
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "PalmerAI"
        view.backgroundColor = .white
        setupModel()
        setupCamera()
        setupPredictionLabel()
        
        setupButton(englishButton, title: "English", tag: 3)
        setupButton(kazakhButton, title: "Қазақша", tag: 1)
        setupButton(russianButton, title: "Русский", tag: 2)
        
        setupConstraints()
    }
    
    private func setupPredictionLabel() {
        view.addSubview(predictionLabel)
        predictionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            predictionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            predictionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            predictionLabel.widthAnchor.constraint(equalToConstant: 250),
            predictionLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupModel() {
        handSignPredictor = HandSignPredictor() // Инициализация предсказателя
        
        if handSignPredictor == nil {
            print("⚠️ Error: Model failed to load")
        } else {
            print("✅ Model loaded successfully")
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession?.addInput(input)
        DispatchQueue.global(qos: .background).async {
            self.captureSession?.startRunning()
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue (label: "videoQueue"))
        captureSession?.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentTime = Date()
        guard currentTime.timeIntervalSince(lastPredictionTime) > predictionInterval else {
            return // Skip this frame if not enough time has passed
        }
        lastPredictionTime = currentTime
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([handPoseRequest]) // Выполняем запрос на определение руки
            guard let observation = handPoseRequest.results?.first else {
                print("⚠️ No hand detected")
                return
            }
            
            guard let features = extractFeatures(from: observation) else {
                print("⚠️ Failed to extract features")
                return
            }
            
            guard let predictionIndex = handSignPredictor?.predict(features: features) else {
                print("⚠️ Prediction failed")
                return
            }
            
            let prediction = signLabels[Int(predictionIndex)!] ?? "Unknown"
            DispatchQueue.main.async {
                self.predictionLabel.text = "Prediction: \(prediction)"
            }
            print("🖐 Predicted sign: \(prediction)")
        }
        catch {
            print("⚠️ Error processing frame: \(error.localizedDescription)")
            
        }
    }
    
    func extractFeatures(from observation: VNHumanHandPoseObservation) -> [Double]? {
        do {
            let allPoints = try observation.recognizedPoints(.all)
            var features = [Double]()
            
            // Заполняем массив координатами x и y всех 21 ключевых точек
            for landmark in allPoints.values {
                features.append(Double(landmark.location.x))
                features.append(Double(landmark.location.y))
            }
            
            if features.count != 42 { return nil } // Должно быть 21 * 2 = 42 координаты
            
            return features
        } catch {
            print("⚠️ Error extracting hand features: \(error)")
            return nil
        }
    }
    
    func setupButton(_ button: LanguageButton, title: String, tag: Int) {
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.addTarget(self, action: #selector(languageButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc func languageButtonTapped(_ sender: LanguageButton) {
        let buttons = [kazakhButton, russianButton, englishButton]
        buttons.forEach { button in
            let isActive = (button == sender)
            button.setActive(isActive)
            
        }
    }
    
    func setupConstraints() {
        
        view.addSubview(previewContainer)

        let stackView = UIStackView(arrangedSubviews: [kazakhButton, russianButton, englishButton])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            
            previewContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            previewContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: previewContainer.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                ])
            }
}
