import SwiftUI
import AVFoundation
import Vision
import CoreImage
import SwiftData

struct HomeView: View {
    @State private var recognizedPlate: String?
    @State private var showScanResult = false
    @State private var isShowingManualInput = false
    @State private var isCameraAuthorized = false
    @State private var showTutorial = false
    @State private var capturedImage: CVPixelBuffer?
    @State private var isPlateDetected = false
    @State private var isProcessing = false
    @State private var detectedPlateText = ""
    @State private var scanFrameRect = CGRect(x: 0, y: 0, width: 250, height: 150)
    @State private var showHistory = false
    @State private var activeJourney: BusInfo?
    @State private var showJourneyView = false
    @State private var selectedTab: Int = 0
    
    // Add deep link handling
    var deepLinkJourney: Bool
    var deepLinkPlateNumber: String?
    
    // Add SwiftData environment
    @Environment(\.modelContext) private var modelContext
    @Query private var busInfos: [BusInfo]
    @Query private var busRoutes: [BusRoute]
    
    init(deepLinkJourney: Bool = false, deepLinkPlateNumber: String? = nil) {
        self.deepLinkJourney = deepLinkJourney
        self.deepLinkPlateNumber = deepLinkPlateNumber
        print("HomeView initialized with deepLinkJourney: \(deepLinkJourney), plateNumber: \(deepLinkPlateNumber ?? "none")")
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera view
                CameraView(recognizedPlate: $recognizedPlate,
                           showScanResult: $showScanResult,
                           capturedImage: $capturedImage,
                           isPlateDetected: $isPlateDetected,
                           detectedPlateText: $detectedPlateText,
                           scanFrameRect: $scanFrameRect,
                           manualCapture: false)
                .edgesIgnoringSafeArea(.all)
                
                // Overlay UI
                VStack(spacing: 0) {
                    // Header area with fixed height
                    VStack(spacing: 0) {
                        // Tutorial button in top right
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                showTutorial = true
                            }) {
                                Image(systemName: "questionmark")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Circle().fill(Color(hex: "a068ff")))
                            }
                            .padding(.trailing)
                            .padding(.top, geometry.safeAreaInsets.top > 0 ? 0 : 8)
                        }
                        .padding(.top, geometry.safeAreaInsets.top)
                        
                        // Active journey card (if there's an active journey)
                        if let journey = activeJourney {
                            ActiveJourneyCard(busInfo: journey) {
                                showJourneyView = true
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                            .padding(.bottom, 8)
                            .transition(.move(edge: .top))
                        }
                    }
                    .background(Color.black.opacity(0.3))
                    
                    // Flexible space that adapts based on screen size
                    Spacer(minLength: 0)
                    
                    // Scanning frame area - centered in the remaining space
                    VStack {
                        Spacer()
                        
                        // Scanning frame - solid rectangle that turns green when plate detected
                        Rectangle()
                            .stroke(style: StrokeStyle(lineWidth: 3))
                            .frame(width: min(geometry.size.width - 40, 300), height: 150)
                            .foregroundColor(isPlateDetected ? .green : .white)
                            .overlay(
                                GeometryReader { frameGeometry in
                                    Color.clear
                                        .onAppear {
                                            // Store the frame's position for region of interest
                                            let frame = frameGeometry.frame(in: .global)
                                            scanFrameRect = frame
                                        }
                                }
                            )
                        
                        Spacer()
                    }
                    .frame(height: geometry.size.height * 0.4)
                    
                    // Plate detection card area with fixed height
                    ZStack {
                        // Plate detection overlay with purple gradient
                        if isPlateDetected {
                            VStack(spacing: 4) {
                                Text(detectedPlateText)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                Text("Is this the Correct Plate?")
                                    .font(.subheadline)
                                    .foregroundColor(.white)

                                Text("Click Shutter Button to Confirm!")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "a068ff").opacity(0.8), Color(hex: "8a4fd3").opacity(0.8)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .cornerRadius(16)
                        }
                    }
                    .frame(height: 80)
                    
                    // Capture button area with fixed height
                    VStack {
                        Button(action: {
                            captureAndAnalyze()
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .fill(isProcessing ? Color.gray : Color.white)
                                    .frame(width: 70, height: 70)
                                
                                if isProcessing {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.5)
                                }
                            }
                        }
                        .disabled(isProcessing)
                        .padding(.bottom, 20)
                    }
                    .frame(height: 100)
                    
                    // Bottom tab bar with fixed height
                    HStack {
                        Spacer()
                        
                        // History tab
                        Button(action: {
                            showHistory = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.title3)
                                Text("History")
                                    .font(.caption)
                            }
                            .foregroundColor(.gray)
                            .frame(width: 80)
                        }
                        
                        Spacer()
                        
                        // Manual input tab
                        Button(action: {
                            isShowingManualInput = true
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "123.rectangle")
                                    .font(.title3)
                                Text("Enter Plate")
                                    .font(.caption)
                            }
                            .foregroundColor(.gray)
                            .frame(width: 80)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                }
                .edgesIgnoringSafeArea(.bottom)
            }
            .background(Color.black)
        }
        .onAppear {
            checkCameraPermission()
            
            // Check for active journey from LiveActivityManager
            if LiveActivityManager.shared.hasActiveJourney() {
                print("Found active journey from LiveActivityManager")
                activeJourney = LiveActivityManager.shared.getCurrentJourneyInfo()
                
                // If we have an active journey and we're coming from a deep link, show the journey view
                if deepLinkJourney && activeJourney != nil {
                    print("Opening journey view from deep link")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showJourneyView = true
                    }
                }
            }
            
            // Handle deep link with plate number
            if let plateNumber = deepLinkPlateNumber, deepLinkJourney {
                print("Processing deep link with plate number: \(plateNumber)")
                
                // Find the bus info for this plate number
                if let busInfo = findBusInfo(for: plateNumber) {
                    print("Found matching bus info for plate: \(plateNumber)")
                    activeJourney = busInfo
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showJourneyView = true
                    }
                }
            }
            
            // Debug print
            print("Current bus infos: \(busInfos.count)")
            print("Available routes: \(busRoutes.count)")
        }
        .onChange(of: deepLinkJourney) { oldValue, newValue in
            if newValue && activeJourney != nil {
                print("Deep link journey flag changed, showing journey view")
                showJourneyView = true
            }
        }
        .sheet(isPresented: $showScanResult) {
            if let plate = recognizedPlate {
                ScanResultView(plateNumber: plate)
            }
        }
        .sheet(isPresented: $isShowingManualInput) {
            ManualPlateInputView(onSelectBus: { plateNumber in
                // Find the bus info for this plate number
                if findBusInfo(for: plateNumber) != nil {
                    recognizedPlate = plateNumber
                    showScanResult = true
                    isShowingManualInput = false
                }
            })
        }
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView(showTutorial: $showTutorial)
        }
        .sheet(isPresented: $showHistory) {
            HistoryView(onSelectBus: { plateNumber in
                recognizedPlate = plateNumber
                showScanResult = true
                showHistory = false
            })
        }
        .fullScreenCover(isPresented: $showJourneyView) {
            if let journey = activeJourney {
                JourneyView(
                    busInfo: journey,
                    initialState: .ongoing,
                    onJourneyComplete: {
                        // Clear the active journey
                        activeJourney = nil
                        
                        // Double-check that LiveActivityManager has cleared everything
                        if LiveActivityManager.shared.hasActiveJourney() {
                            print("Warning: LiveActivityManager still has an active journey, forcing cleanup")
                            Task {
                                await LiveActivityManager.shared.forceEndAllActivities()
                            }
                        }
                    }
                )
            }
        }
        .alert(isPresented: .constant(!isCameraAuthorized && AVCaptureDevice.authorizationStatus(for: .video) == .denied)) {
            Alert(
                title: Text("Camera Access Required"),
                message: Text("B-Link needs camera access to scan bus plates. Please enable it in Settings."),
                primaryButton: .default(Text("Settings"), action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
    }
    
    // Helper function to find bus info for a plate number
    private func findBusInfo(for plateNumber: String) -> BusInfo? {
        // Normalize the plate number for comparison
        let normalizedPlate = plateNumber.uppercased().filter { $0.isLetter || $0.isNumber }
        
        // Find the matching bus info
        return busInfos.first(where: {
            let normalizedBusPlate = $0.plateNumber.uppercased().filter { $0.isLetter || $0.isNumber }
            return normalizedPlate == normalizedBusPlate
        })
    }
    
    // Update captureAndAnalyze function to ensure proper timing
    private func captureAndAnalyze() {
        if isProcessing { return }
        
        isProcessing = true
        
        // Add a small delay to ensure everything is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.isPlateDetected && self.isValidIndonesianPlate(self.detectedPlateText) {
                // If plate is already detected and valid, use the detected text
                self.recognizedPlate = self.detectedPlateText
                self.showScanResult = true
                self.isProcessing = false
            } else if let pixelBuffer = self.capturedImage {
                // Otherwise try to analyze the current frame
                self.analyzeImage(pixelBuffer)
            } else {
                self.isProcessing = false
            }
        }
    }
    
    private func isValidIndonesianPlate(_ text: String) -> Bool {
        // Check if the text matches the Indonesian plate format
        // 1-2 letters (region) + 1-4 digits (number) + 1-3 letters (identifier)
        let platePattern = "^[A-Z]{1,2}\\s?\\d{1,4}\\s?[A-Z]{1,3}$"
        return text.range(of: platePattern, options: .regularExpression) != nil
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isCameraAuthorized = granted
                }
            }
        case .denied, .restricted:
            isCameraAuthorized = false
        @unknown default:
            isCameraAuthorized = false
        }
    }
    
    private func analyzeImage(_ pixelBuffer: CVPixelBuffer) {
        // Create a request to recognize text
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
                return
            }
            
            if let results = request.results as? [VNRecognizedTextObservation] {
                // Process text observations
                let recognizedStrings = results.compactMap { observation in
                    // Get multiple candidates to improve chances of finding the plate
                    observation.topCandidates(3).map { $0.string }
                }.flatMap { $0 }
                
                // Look for patterns that might be bus plate numbers
                var plateFound = false
                
                for string in recognizedStrings {
                    // Try to find a plate number in the recognized text
                    if let plateNumber = self.extractPlateNumber(from: string) {
                        DispatchQueue.main.async {
                            self.recognizedPlate = plateNumber
                            self.showScanResult = true
                            self.isProcessing = false
                        }
                        plateFound = true
                        return
                    }
                }
                
                // If no plate was found, just end processing without showing manual input
                if !plateFound {
                    DispatchQueue.main.async {
                        self.isProcessing = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isProcessing = false
                }
            }
        }
        
        // Configure the request for optimal text recognition
        request.recognitionLevel = .accurate // Use accurate for the final capture
        request.usesLanguageCorrection = false
        request.revision = 3 // Use the latest revision for better accuracy
        
        // Create a handler to perform the request
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform text recognition: \(error)")
            DispatchQueue.main.async {
                self.isProcessing = false
            }
        }
    }
    
    // Helper function to extract plate number from text
    private func extractPlateNumber(from text: String) -> String? {
        // Standard Indonesian license plate pattern:
        // 1-2 letters (region) + 1-4 digits (number) + 1-3 letters (identifier)
        // Examples: B 7366 JE, DK 1234 AB
        let platePattern = "\\b[A-Z]{1,2}\\s?\\d{1,4}\\s?[A-Z]{1,3}\\b"
        
        if let regex = try? NSRegularExpression(pattern: platePattern) {
            let range = NSRange(location: 0, length: text.utf16.count)
            if let match = regex.firstMatch(in: text, range: range) {
                let matchRange = match.range
                if let range = Range(matchRange, in: text) {
                    let plateNumber = String(text[range])
                    
                    // Additional validation - check if it has the right format
                    // Must have at least one letter, followed by numbers, followed by letters
                    let hasCorrectFormat = plateNumber.range(of: "^[A-Z]{1,2}.*\\d+.*[A-Z]{1,3}$", options: .regularExpression) != nil
                    
                    // Check if it's not a common bus text
                    let commonBusText = ["BSDCITY", "BSD", "CITY", "BUS", "BUSWAY", "TRANS"]
                    let isNotCommonText = !commonBusText.contains { plateNumber.uppercased().contains($0) }
                    
                    if hasCorrectFormat && isNotCommonText {
                        return plateNumber
                    }
                }
            }
        }
        
        return nil
    }
}

// Camera view using UIViewRepresentable
struct CameraView: UIViewRepresentable {
    @Binding var recognizedPlate: String?
    @Binding var showScanResult: Bool
    @Binding var capturedImage: CVPixelBuffer?
    @Binding var isPlateDetected: Bool
    @Binding var detectedPlateText: String
    @Binding var scanFrameRect: CGRect
    var manualCapture: Bool
    
    // Create the UIView
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        
        let cameraView = context.coordinator.setupCamera()
        view.addSubview(cameraView)
        cameraView.frame = view.bounds
        
        return view
    }
    
    // Update the view if needed
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.scanFrameRect = scanFrameRect
    }
    
    // Create the coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator class to handle camera setup and text recognition
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer?
        private var lastProcessingTime: Date = Date()
        private let processingInterval: TimeInterval = 0.2 // Process frames more frequently
        private var plateDetectionHistory: [String: Int] = [:]
        private let confidenceThreshold = 3
        var scanFrameRect: CGRect = .zero
        private var screenSize: CGSize = UIScreen.main.bounds.size
        
        init(_ parent: CameraView) {
            self.parent = parent
            super.init()
        }
        
        func setupCamera() -> UIView {
            let cameraView = UIView(frame: UIScreen.main.bounds)
            screenSize = cameraView.bounds.size
            
            // Initialize capture session
            let captureSession = AVCaptureSession()
            self.captureSession = captureSession
            
            // Set up camera input
            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("No camera available")
                return cameraView
            }
            
            do {
                // Configure camera for high resolution
                try camera.lockForConfiguration()
                if camera.isAutoFocusRangeRestrictionSupported {
                    camera.autoFocusRangeRestriction = .near
                }
                
                // Enable auto-focus
                if camera.isFocusModeSupported(.continuousAutoFocus) {
                    camera.focusMode = .continuousAutoFocus
                }
                
                // Enable auto-exposure
                if camera.isExposureModeSupported(.continuousAutoExposure) {
                    camera.exposureMode = .continuousAutoExposure
                }
                
                camera.unlockForConfiguration()
                
                // Add camera input to session
                let input = try AVCaptureDeviceInput(device: camera)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
                
                // Set up video output
                let videoOutput = AVCaptureVideoDataOutput()
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                videoOutput.alwaysDiscardsLateVideoFrames = true
                
                if captureSession.canAddOutput(videoOutput) {
                    captureSession.addOutput(videoOutput)
                }
                
                // Configure session for high resolution
                captureSession.sessionPreset = .high
                
                // Set up preview layer
                let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                self.previewLayer = previewLayer
                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.frame = cameraView.bounds
                cameraView.layer.addSublayer(previewLayer)
                
                // Start session in background
                DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                    self?.captureSession?.startRunning()
                }
                
            } catch {
                print("Camera setup error: \(error.localizedDescription)")
            }
            
            return cameraView
        }
        
        // Process video frames
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            // Store the current frame for manual capture
            DispatchQueue.main.async {
                self.parent.capturedImage = pixelBuffer
            }
            
            // Check if enough time has passed since last processing
            let currentTime = Date()
            if currentTime.timeIntervalSince(lastProcessingTime) < processingInterval {
                return
            }
            
            lastProcessingTime = currentTime
            
            // Perform real-time text detection
            detectPlateInFrame(pixelBuffer)
        }
        
        private func detectPlateInFrame(_ pixelBuffer: CVPixelBuffer) {
            // Skip if scan frame is not set yet
            if scanFrameRect == .zero {
                return
            }
            
            // Convert UI coordinates to normalized coordinates for Vision
            let normalizedRect = convertToNormalizedRect(scanFrameRect, pixelBuffer: pixelBuffer)
            
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let self = self, error == nil else { return }
                
                if let results = request.results as? [VNRecognizedTextObservation] {
                    // Process text observations
                    let recognizedStrings = results.compactMap { observation in
                        // Get more candidates to improve chances of finding the plate
                        observation.topCandidates(10).map { $0.string }
                    }.flatMap { $0 }
                    
                    var plateDetected = false
                    var plateText = ""
                    
                    // Look for Indonesian license plate pattern with more flexibility
                    // Format: B 7366 JE (1-2 letters + space + 1-4 digits + space + 1-3 letters)
                    let platePattern = "\\b[A-Z]{1,2}\\s*\\d{1,4}\\s*[A-Z]{1,3}\\b"
                    
                    // Also try a more lenient pattern that might catch partial plates
                    let lenientPattern = "[A-Z]{1,2}\\s*\\d{1,4}"
                    
                    for string in recognizedStrings {
                        // Clean up the string - remove unwanted characters and trim
                        let cleanedString = string
                            .replacingOccurrences(of: "BSDCITY", with: "")
                            .replacingOccurrences(of: "BSD", with: "")
                            .replacingOccurrences(of: "CITY", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .uppercased() // Ensure uppercase for consistent matching
                        
                        // Try the full plate pattern first
                        if let regex = try? NSRegularExpression(pattern: platePattern) {
                            let range = NSRange(location: 0, length: cleanedString.utf16.count)
                            if let match = regex.firstMatch(in: cleanedString, range: range) {
                                let matchRange = match.range
                                if let range = Range(matchRange, in: cleanedString) {
                                    let candidate = String(cleanedString[range])
                                    
                                    // Additional validation
                                    let hasCorrectFormat = candidate.range(of: "^[A-Z]{1,2}\\s*\\d{1,4}\\s*[A-Z]{1,3}$", options: .regularExpression) != nil
                                    
                                    // Check if it's not a common bus text
                                    let commonBusText = ["BSDCITY", "BSD", "CITY", "BUS", "BUSWAY", "TRANS"]
                                    let isNotCommonText = !commonBusText.contains { candidate.uppercased().contains($0) }
                                    
                                    if hasCorrectFormat && isNotCommonText {
                                        plateDetected = true
                                        plateText = candidate
                                        
                                        // Format the plate number consistently
                                        if let formattedPlate = self.formatPlateNumber(plateText) {
                                            plateText = formattedPlate
                                        }
                                        
                                        break
                                    }
                                }
                            }
                        }
                        
                        // If no full plate detected, try the lenient pattern
                        if !plateDetected {
                            if let regex = try? NSRegularExpression(pattern: lenientPattern) {
                                let range = NSRange(location: 0, length: cleanedString.utf16.count)
                                if let match = regex.firstMatch(in: cleanedString, range: range) {
                                    let matchRange = match.range
                                    if let range = Range(matchRange, in: cleanedString) {
                                        let candidate = String(cleanedString[range])
                                        
                                        // If we find a partial plate (like "B 7366")
                                        plateDetected = true
                                        plateText = candidate
                                        
                                        // Try to find the identifier part separately
                                        let letterPattern = "\\b[A-Z]{2,3}\\b"
                                        if let letterRegex = try? NSRegularExpression(pattern: letterPattern) {
                                            let letterRange = NSRange(location: 0, length: cleanedString.utf16.count)
                                            let letterMatches = letterRegex.matches(in: cleanedString, range: letterRange)
                                            
                                            for letterMatch in letterMatches {
                                                if let letterMatchRange = Range(letterMatch.range, in: cleanedString) {
                                                    let letters = String(cleanedString[letterMatchRange])
                                                    if letters != "BS" && letters != "SD" && !plateText.contains(letters) {
                                                        plateText += " " + letters
                                                        break
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Implement confidence-based detection with history tracking
                    if plateDetected {
                        // Update confidence for this plate
                        let currentConfidence = self.plateDetectionHistory[plateText] ?? 0
                        self.plateDetectionHistory[plateText] = currentConfidence + 1
                        
                        // Decay confidence for other plates
                        for (plate, confidence) in self.plateDetectionHistory where plate != plateText {
                            self.plateDetectionHistory[plate] = max(0, confidence - 1)
                        }
                        
                        // Find the plate with the highest confidence
                        if let (mostConfidentPlate, confidence) = self.plateDetectionHistory.max(by: { $0.value < $1.value }) {
                            // Lower the confidence threshold to 2 (was 3)
                            if confidence >= 2 {
                                plateDetected = true
                                plateText = mostConfidentPlate
                                print("Detected plate with confidence \(plateText)")
                            } else {
                                plateDetected = false
                            }
                        } else {
                            plateDetected = false
                        }
                    } else {
                        // Decay all confidences when no plate is detected
                        for plate in self.plateDetectionHistory.keys {
                            self.plateDetectionHistory[plate] = max(0, (self.plateDetectionHistory[plate] ?? 0) - 1)
                        }
                        
                        // Remove plates with zero confidence
                        self.plateDetectionHistory = self.plateDetectionHistory.filter { $0.value > 0 }
                    }
                    
                    // Store the detected plate text for capture button use
                    DispatchQueue.main.async {
                        if plateDetected {
                            self.parent.detectedPlateText = plateText
                            self.parent.isPlateDetected = true
                            print("✅ Plate detected: \(plateText)")
                        } else {
                            self.parent.isPlateDetected = false
                        }
                    }
                }
            }
            
            // Configure the request for optimal text recognition
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = false
            request.revision = 3
            
            // Use a slightly larger region of interest to catch more text
            let expandedRect = CGRect(
                x: max(0, normalizedRect.origin.x - 0.05),
                y: max(0, normalizedRect.origin.y - 0.05),
                width: min(1.0, normalizedRect.width + 0.1),
                height: min(1.0, normalizedRect.height + 0.1)
            )
            request.regionOfInterest = expandedRect
            
            // Create a handler to perform the request
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform text recognition: \(error)")
            }
        }
        
        // Helper function to format plate numbers consistently
        private func formatPlateNumber(_ plateText: String) -> String? {
            // Try to extract the components of the plate number
            let cleaned = plateText.uppercased().filter { !$0.isWhitespace }
            
            // Try to extract components
            var regionCode = ""
            var numbers = ""
            var identifier = ""
            
            var index = cleaned.startIndex
            
            // Extract region code (first 1-2 letters)
            while index < cleaned.endIndex && cleaned[index].isLetter {
                regionCode.append(cleaned[index])
                index = cleaned.index(after: index)
            }
            
            // Extract numbers
            while index < cleaned.endIndex && cleaned[index].isNumber {
                numbers.append(cleaned[index])
                index = cleaned.index(after: index)
            }
            
            // Extract identifier (remaining letters)
            while index < cleaned.endIndex && cleaned[index].isLetter {
                identifier.append(cleaned[index])
                index = cleaned.index(after: index)
            }
            
            // Format with proper spacing
            if !regionCode.isEmpty && !numbers.isEmpty {
                if !identifier.isEmpty {
                    return "\(regionCode) \(numbers) \(identifier)"
                } else {
                    return "\(regionCode) \(numbers)"
                }
            }
            
            return plateText
        }
        
        // Convert UI coordinates to normalized coordinates for Vision framework
        private func convertToNormalizedRect(_ rect: CGRect, pixelBuffer: CVPixelBuffer) -> CGRect {
            let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
            let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
            
            // Calculate the scale factors
            let scaleX = pixelBufferWidth / screenSize.width
            let scaleY = pixelBufferHeight / screenSize.height
            
            // Convert to pixel buffer coordinates
            let x = rect.origin.x * scaleX
            let y = rect.origin.y * scaleY
            let width = rect.size.width * scaleX
            let height = rect.size.height * scaleY
            
            // Normalize coordinates (Vision uses normalized coordinates)
            let normalizedX = x / pixelBufferWidth
            let normalizedY = 1.0 - ((y + height) / pixelBufferHeight) // Flip Y coordinate
            let normalizedWidth = width / pixelBufferWidth
            let normalizedHeight = height / pixelBufferHeight
            
            // Create normalized rect with minimal padding to focus on the frame
            let padding = 0.02 // 2% padding
            return CGRect(
                x: max(0, normalizedX - padding),
                y: max(0, normalizedY - padding),
                width: min(1.0, normalizedWidth + (padding * 2)),
                height: min(1.0, normalizedHeight + (padding * 2))
            )
        }
    }
}

// Active journey card component
struct ActiveJourneyCard: View {
    let busInfo: BusInfo
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Journey")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(limitTextLength(busInfo.routeName, maxLength: 30))
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                        
                        Text(busInfo.endPoint)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack {
                        Text("\(busInfo.estimatedTime) min")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Image(systemName: "clock.fill")
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    
                    HStack {
                        Text("\(String(format: "%.1f", busInfo.distance)) km")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Image(systemName: "figure.walk")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "6920e1"))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper function to limit text length for better display
    private func limitTextLength(_ text: String, maxLength: Int) -> String {
        if text.count <= maxLength {
            return text
        }
        let index = text.index(text.startIndex, offsetBy: maxLength - 3)
        return String(text[..<index]) + "..."
    }
}

#Preview {
    HomeView()
}
