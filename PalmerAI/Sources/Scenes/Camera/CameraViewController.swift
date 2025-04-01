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
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
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
        previewLayer.videoGravity = .resizeAspectFill
        previewContainer.layer.addSublayer(previewLayer)
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue (label: "videoQueue"))
        captureSession?.addOutput(dataOutput)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update frames after view layout
        if let previewLayer = previewContainer.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = previewContainer.bounds
        }
        overlayView.frame = previewContainer.bounds
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentTime = Date()
        guard currentTime.timeIntervalSince(lastPredictionTime) > predictionInterval else {
            return // Skip this frame if not enough time has passed
        }
        lastPredictionTime = currentTime
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let orientation = CGImagePropertyOrientation.right
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        
        do {
            try handler.perform([handPoseRequest]) // Выполняем запрос на определение руки
            guard let observation = handPoseRequest.results?.first else {
                print("⚠️ No hand detected")
                return
            }
            
            drawHandLandmarks(observation)

            
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
            let orderedJoints: [VNHumanHandPoseObservation.JointName] = [
                .wrist, .thumbCMC, .thumbMP, .thumbIP, .thumbTip,
                .indexMCP, .indexPIP, .indexDIP, .indexTip,
                .middleMCP, .middlePIP, .middleDIP, .middleTip,
                .ringMCP, .ringPIP, .ringDIP, .ringTip,
                .littleMCP, .littlePIP, .littleDIP, .littleTip
            ]
            
            let allPoints = try observation.recognizedPoints(.all)
            
            // First, collect all x and y values to find min values for normalization
            var xValues: [CGFloat] = []
            var yValues: [CGFloat] = []
            
            for joint in orderedJoints {
                if let point = allPoints[joint], point.confidence > 0.3 {
                    xValues.append(point.location.x)
                    yValues.append(1 - point.location.y)
                }
            }
            
            // Find min values for normalization
            guard let minX = xValues.min(), let minY = yValues.min() else {
                return nil
            }
            
            // Build normalized features array
            var features = [Double]()
            
            for joint in orderedJoints {
                if let point = allPoints[joint], point.confidence > 0.3 {
                    // Normalize by subtracting min values
                    let x = point.location.x - minX
                    let y = 1 - point.location.y - minY
                    
                    features.append(Double(x))
                    features.append(Double(y))
                } else {
                    features.append(0.0)
                    features.append(0.0)
                }
            }
            
            return features.count == 42 ? features : nil
        } catch {
            print("Error extracting hand features: \(error)")
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
        previewContainer.addSubview(overlayView)
        overlayView.frame = previewContainer.bounds

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
    
    func drawHandLandmarks(_ observation: VNHumanHandPoseObservation) {
        
        let HandJointsConnections: [(VNHumanHandPoseObservation.JointName, VNHumanHandPoseObservation.JointName)] = [
            (.wrist, .thumbCMC), (.thumbCMC, .thumbMP), (.thumbMP, .thumbTip),
            (.wrist, .indexMCP), (.indexMCP, .indexPIP), (.indexPIP, .indexTip),
            (.wrist, .middleMCP), (.middleMCP, .middlePIP), (.middlePIP, .middleTip),
            (.wrist, .ringMCP), (.ringMCP, .ringPIP), (.ringPIP, .ringTip),
            (.wrist, .littleMCP), (.littleMCP, .littlePIP), (.littlePIP, .littleTip)
        ]
        
        DispatchQueue.main.async {
            self.overlayView.layer.sublayers?.removeAll()
            
            let width = self.overlayView.bounds.width
            let height = self.overlayView.bounds.height
            
            let convertPoint: (CGPoint) -> CGPoint = { point in
                let convertedX = (1 - point.x) * width  // Swap x and y
                let convertedY = (1 - point.y) * height
                return CGPoint(x: convertedX, y: convertedY)
            }
            
            let allPoints = try? observation.recognizedPoints(.all)
            
            guard let points = allPoints else { return }
            
            for jointPair in HandJointsConnections {
                if let firstPoint = points[jointPair.0],
                   let secondPoint = points[jointPair.1],
                   firstPoint.confidence > 0.3,
                   secondPoint.confidence > 0.3 {
                    
                    let p1 = convertPoint(firstPoint.location)
                    let p2 = convertPoint(secondPoint.location)
                    
                    let line = UIBezierPath()
                    line.move(to: p1)
                    line.addLine(to: p2)
                    
                    let shapeLayer = CAShapeLayer()
                    shapeLayer.path = line.cgPath
                    shapeLayer.strokeColor = UIColor.green.cgColor
                    shapeLayer.lineWidth = 2.0
                    self.overlayView.layer.addSublayer(shapeLayer)
                }
            }
            
            // Draw joint points
            for (_, point) in points where point.confidence > 0.3 {
                let convertedPoint = convertPoint(point.location)
                let dot = UIBezierPath(ovalIn: CGRect(x: convertedPoint.x - 3,
                                                      y: convertedPoint.y - 3,
                                                      width: 6,
                                                      height: 6))
                
                let dotLayer = CAShapeLayer()
                dotLayer.path = dot.cgPath
                dotLayer.fillColor = UIColor.red.cgColor
                self.overlayView.layer.addSublayer(dotLayer)
            }
        }
    }
}
