//
//  CameraViewController.swift
//  Slite
//
//  Created by Paul Marc on 10.04.2022.
//

import UIKit
import AVFoundation
import Lottie
import SwiftUI
import PhotosUI
import Mixpanel

let width = UIScreen.main.bounds.width
let height = UIScreen.main.bounds.height

class CameraViewController: UIViewController {
    // MARK: - Properties
    
    var useColorCallback: ((UIColor) -> Void)?
    
    var captureSession = AVCaptureSession()
    var currentDevice: AVCaptureDevice?
    
    let cameraPreviewLayer = CALayer()
    let colorPreview = UIView()
    let pickerView = UIImageView(image: UIImage(named: "picker"))
    let pickButton = UIButton()
    let useColorButton = UIButton()
    let revertButton = UIButton()
    let closeButton = UIButton()
    let settingsButton = UIButton()
    let galleryButton = UIButton()
    let cameraButton = UIButton()
    var emptyStateContentView = UIView()

    let queue = DispatchQueue(label: "com.camera.video.queue")
    
    var center: CGPoint = CGPoint(x: width/2, y: height/2)
    
    var colorWasLocked = false
    var galleryMode = false
    
    var imageView = UIImageView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:))))
        setupCameraPreviewLayer()
        cameraPreviewLayer.isHidden = true
        checkCameraPermission()
    }
    
    private func checkCameraPermission()  {
        let cameraMediaType = AVMediaType.video
        AVCaptureDevice.requestAccess(for: cameraMediaType) { [weak self] granted in
            if granted {
                DispatchQueue.main.async {
                    self?.emptyStateContentView.removeFromSuperview()
                    self?.setupUI()
                    self?.pickButton.isHidden = false
                    self?.setupCaptureSession()
                    self?.resetPickerPosition()
                }
            } else {
                DispatchQueue.main.async {
                    self?.setupMediaNotAvailableUI(isGallery: false)
                }
            }
        }
    }
    private func checkGalleryPermission() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            switch status {
            case .authorized, .limited:
                DispatchQueue.main.async {
                    self?.showGallery()
                }
            case .denied:
                DispatchQueue.main.async {
                    self?.captureSession.stopRunning()
                    self?.setupMediaNotAvailableUI(isGallery: true)
                    self?.galleryMode = true
                }
            default:
                return
            }
        }
    }
    
    @objc private func galleryAction() {
//        checkGalleryPermission()
        showGallery()
        
        Analytics.shared.trackEvent(.photoColorPicker)
    }
    
    @objc private func cameraAction() {
        guard galleryMode else { return }
        galleryMode = false
        colorWasLocked = false
        checkCameraPermission()
        cameraButton.removeFromSuperview()
        
        Analytics.shared.trackEvent(.cameraColorPicker)
    }
    
    private func resetPickerPosition() {
        pickerView.center = view.center
        colorPreview.center = .init(x: pickerView.center.x, y: pickerView.center.y - pickerView.frame.size.height / 2 - colorPreview.frame.size.height / 2 - 2)
    }
    
    private func setupMediaNotAvailableUI(isGallery: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .black
        
        emptyStateContentView.removeFromSuperview()
        cameraPreviewLayer.isHidden = true
        colorPreview.removeFromSuperview()
        pickerView.removeFromSuperview()
        revertButton.isHidden = true
        settingsButton.isHidden = false
        
        setupCloseButton()
        setupSettingsButton()
        setupUseColorButton()
        setupGalleryButton(cameraAvailable: false)
        setupCameraButton()
        setupImageView()
        
        emptyStateContentView = UIView()
        view.addSubview(emptyStateContentView)
        emptyStateContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emptyStateContentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        emptyStateContentView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateContentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        let imageView = UIImageView(image: UIImage(named: "no_device"))
        emptyStateContentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        imageView.topAnchor.constraint(equalTo: emptyStateContentView.topAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: emptyStateContentView.centerXAnchor).isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        emptyStateContentView.addSubview(label)
        
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        label.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.75).isActive = true
        label.bottomAnchor.constraint(equalTo: emptyStateContentView.bottomAnchor).isActive = true
        
        label.text = isGallery ? Texts.CameraView.galleryNotAvailable : Texts.CameraView.cameraNotAvailable
        label.numberOfLines = 0
        label.font = Font.Main.regular(size: 15).toUIFont()
        label.textColor = .sonicSilver
        label.textAlignment = .center
    }
    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .black
        
        cameraPreviewLayer.isHidden = false
        
        setupPickerView()
        setupPickColorButton()
        setupUseColorButton()
        setupRevertButton()
        setupGalleryButton(cameraAvailable: true)
//        setupCameraButton()
        setupCloseButton()
        
        setupImageView()
    }
    
    private func setupPickerView() {
        if pickerView.superview == nil {
            view.addSubview(pickerView)
            pickerView.center = view.center
            pickerView.frame.size = .init(width: 30, height: 30)
            pickerView.layoutIfNeeded()
            pickerView.isUserInteractionEnabled = true
            pickerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragGesture(_:))))
        }
        if colorPreview.superview == nil {
            view.addSubview(colorPreview)
            colorPreview.frame.size = CGSize(width: 32, height: 32)
            colorPreview.center = .init(x: pickerView.center.x, y: pickerView.center.y - pickerView.frame.size.height / 2 - colorPreview.frame.size.height / 2 - 2)
            
            colorPreview.layer.cornerRadius = 16
            colorPreview.layer.borderColor = UIColor.white.cgColor
            colorPreview.layer.borderWidth = 1
        }
    }
    
    private func setupCameraPreviewLayer() {
        cameraPreviewLayer.bounds = CGRect(x: 0, y: 0, width: width, height: height)
        cameraPreviewLayer.frame = view.frame
        cameraPreviewLayer.position = view.center
        cameraPreviewLayer.contentsGravity = CALayerContentsGravity.resizeAspectFill
        cameraPreviewLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)))
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.frame
        imageView.center = view.center
        view.addSubview(imageView)
        view.sendSubviewToBack(imageView)
        
        imageView.isHidden = true
    }
    
    private func setupSettingsButton() {
        view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        settingsButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2).isActive = true
        settingsButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        settingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        settingsButton.backgroundColor = .tartRed
        settingsButton.setTitle(Texts.CameraView.settingsButtonTitle, for: .normal)
        settingsButton.setTitleColor(.white, for: .normal)
        settingsButton.titleLabel?.font = Font.Main.medium(size: 15).toUIFont()
        settingsButton.layer.cornerRadius = 5
        
        settingsButton.addTarget(self, action: #selector(goToSettings), for: .touchUpInside)
    }
    
    private func setupRevertButton() {
        view.addSubview(revertButton)
        revertButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        revertButton.leadingAnchor.constraint(equalTo: pickButton.trailingAnchor, constant: 24).isActive = true
        revertButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        revertButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        revertButton.centerYAnchor.constraint(equalTo: pickButton.centerYAnchor).isActive = true
        
        revertButton.backgroundColor = .white
        revertButton.setImage(UIImage(named: "revert"), for: .normal)
        revertButton.layer.cornerRadius = 16
        revertButton.isHidden = true
        revertButton.addTarget(self, action: #selector(revert), for: .touchUpInside)
    }
    
    private func setupGalleryButton(cameraAvailable: Bool) {
        view.addSubview(galleryButton)
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        
        galleryButton.trailingAnchor.constraint(equalTo: (cameraAvailable ? pickButton : settingsButton).leadingAnchor, constant: -24).isActive = true
        galleryButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        galleryButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        galleryButton.centerYAnchor.constraint(equalTo: (cameraAvailable ? pickButton : settingsButton).centerYAnchor).isActive = true
        
        galleryButton.backgroundColor = .white
        galleryButton.setImage(UIImage(named: "gallery"), for: .normal)
        galleryButton.layer.cornerRadius = 16
        
        galleryButton.addTarget(self, action: #selector(galleryAction), for: .touchUpInside)
    }
    
    private func setupCameraButton() {
        view.addSubview(cameraButton)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        
        cameraButton.centerXAnchor.constraint(equalTo: galleryButton.centerXAnchor).isActive = true
        cameraButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        cameraButton.bottomAnchor.constraint(equalTo: galleryButton.topAnchor, constant: -15).isActive = true
        
        cameraButton.backgroundColor = .white
        
        let image = UIImage(named: "lights_camera")
        
        cameraButton.setImage(image, for: .normal)
        cameraButton.imageView?.tintColor = .black
        
        cameraButton.layer.cornerRadius = 16
        
        cameraButton.addTarget(self, action: #selector(cameraAction), for: .touchUpInside)
    }
    
    private func setupUseColorButton() {
        view.addSubview(useColorButton)
        useColorButton.translatesAutoresizingMaskIntoConstraints = false
        
        useColorButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        useColorButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2).isActive = true
        useColorButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        useColorButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        useColorButton.backgroundColor = .tartRed
        useColorButton.setTitle(Texts.CameraView.useColorButonTitle, for: .normal)
        useColorButton.setTitleColor(.white, for: .normal)
        useColorButton.titleLabel?.font = Font.Main.medium(size: 15).toUIFont()
        useColorButton.layer.cornerRadius = 5
        useColorButton.isHidden = true
        useColorButton.addTarget(self, action: #selector(useColor), for: .touchUpInside)
    }
    
    private func setupPickColorButton() {
        view.addSubview(pickButton)
        pickButton.translatesAutoresizingMaskIntoConstraints = false
        
        pickButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        pickButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2).isActive = true
        pickButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        pickButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        pickButton.backgroundColor = .white
        pickButton.setTitle(Texts.CameraView.pickButtonTitle, for: .normal)
        pickButton.setTitleColor(.black, for: .normal)
        pickButton.titleLabel?.font = Font.Main.medium(size: 15).toUIFont()
        pickButton.layer.cornerRadius = 5
        
        pickButton.addTarget(self, action: #selector(pickColor), for: .touchUpInside)
    }
    
    private func setupCloseButton() {
        view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.backgroundColor = .white
        closeButton.layer.cornerRadius = 16
        
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    
    @objc private func pickColor() {
        colorWasLocked = true
        pickButton.isHidden = true
        useColorButton.isHidden = false
        revertButton.isHidden = false
    }
    
    @objc private func useColor() {
        guard let color = colorPreview.backgroundColor else { return }
        useColorCallback?(color)
        close()
        
        let saturation = Int(RGB(hexadecimal: color.hexValue).hsv.s * 100)
        let hue = Int(RGB(hexadecimal: color.hexValue).hsv.h)
        let properties: [String: MixpanelType] = ["saturation": saturation,
                                                  "hue": hue]
        Analytics.shared.trackEvent(galleryMode ? .photoColorPicker : .cameraColorPicker, properties: properties)
    }
    
    @objc private func revert() {
        colorWasLocked = false
        useColorButton.isHidden = true
        pickButton.isHidden = false
        revertButton.isHidden = true
    }
    
    @objc private func close() {
        DispatchQueue.main.async {
            self.cameraPreviewLayer.isHidden = true
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func goToSettings() {
        guard let url = NSURL(string:UIApplication.openSettingsURLString) as URL? else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    @objc private func dragGesture(_ gesture: UIPanGestureRecognizer) {
        guard galleryMode else { return }
        let location = gesture.location(in: self.view)
        let draggedView = gesture.view
        draggedView?.center = location
        colorPreview.center = CGPoint(x: location.x, y: CGFloat(location.y - pickerView.frame.size.height / 2 - colorPreview.frame.size.height / 2 - 2))
        updatePreviewFrom(imageView.layer)
        
        if gesture.state == .began {
            colorPreview.transform = CGAffineTransform(scaleX: 2, y: 2)
        } else if gesture.state == .ended {
            colorPreview.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    @objc private func tapGesture(_ gesture: UITapGestureRecognizer) {
        guard galleryMode else { return }
        let location = gesture.location(in: view)
        pickerView.center = location
        colorPreview.center = CGPoint(x: location.x, y: CGFloat(location.y - pickerView.frame.size.height / 2 - colorPreview.frame.size.height / 2 - 2))
        updatePreviewFrom(imageView.layer)
    }
    
    private func showGallery() {
        let viewController = ImagePickerViewController()
        viewController.imageCallback = { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.didPickedImageFromGallery(image)
            } 
        }
        self.present(viewController, animated: true)
    }
    
    private func didPickedImageFromGallery(_ image: UIImage) {
        captureSession.stopRunning()
        galleryMode = true
        
        emptyStateContentView.removeFromSuperview()
        useColorButton.isHidden = false
        settingsButton.isHidden = true
        pickButton.isHidden = true
        revertButton.isHidden = true
        cameraPreviewLayer.isHidden = true
        imageView.image = image
        imageView.isHidden = false
        setupCameraButton()
        
        setupPickerView()
        
        updatePreviewFrom(imageView.layer)
    }
    
    private func updatePreviewFrom(_ layer: CALayer) {
        
        let squareWidth: CGFloat = 11
        let centerOffset: CGFloat = squareWidth / 2
        
        layer.pickColor(at: CGPoint(x: pickerView.center.x - centerOffset, y: pickerView.center.y - centerOffset), squareWidth: squareWidth) { color in
            guard let color = color else {
                return
            }

            let hsv = RGB(hexadecimal: color.hexValue).hsv.fullBrightness
            self.colorPreview.backgroundColor = hsv.rgb.color.toUIColor()
        }
    }

    private func setupCaptureSession(){
        self.captureSession = AVCaptureSession()
        
        if captureSession.canSetSessionPreset(.hd4K3840x2160) {
            self.captureSession.sessionPreset = AVCaptureSession.Preset.hd4K3840x2160
        } else {
            self.captureSession.sessionPreset = AVCaptureSession.Preset.high
        }
         
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [ .builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                self.currentDevice = device
            }
        }
  
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable: NSNumber(value: kCMPixelFormat_32BGRA)] as? [String : Any]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.setSampleBufferDelegate(self, queue: queue)
            
            if self.captureSession.canAddOutput(videoOutput) {
                self.captureSession.addOutput(videoOutput)
            }
            self.captureSession.addInput(captureDeviceInput)
        } catch {
            print(error)
            return
        }
        DispatchQueue.global().async { [weak self] in
            self?.captureSession.startRunning()
        }
        
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        guard let baseAddr = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0) else {
            return
        }
        let width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bimapInfo: CGBitmapInfo = [
            .byteOrder32Little,
            CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)]
        
        guard let content = CGContext(data: baseAddr, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bimapInfo.rawValue) else {
            return
        }
        
        guard let cgImage = content.makeImage() else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard !self.galleryMode else { return }
            
            self.cameraPreviewLayer.contents = cgImage
            guard !self.colorWasLocked else { return }
            self.updatePreviewFrom(self.cameraPreviewLayer)
        }
    }
}

// MARK: - CALayer

extension CALayer {
    func pickColor(at position: CGPoint, squareWidth: CGFloat, callback: @escaping (UIColor?) -> Void) {
        
        DispatchQueue.global().async {
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
            
            let componentCount = squareWidth * squareWidth * 4
            var pixel = [UInt8](repeatElement(0, count: Int(componentCount)))
            
            // square width multiplied by 4 (r, g, b, alpha)
            let bytesPerRow = 4 * Int(squareWidth)
            
            guard let context = CGContext(data: &pixel, width: Int(squareWidth), height: Int(squareWidth), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
                callback(nil)
                return
            }
            context.translateBy(x: -position.x, y: -position.y);
            self.render(in: context)
            
            var index = 0
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            while index < Int(componentCount) {
                // The colors are distributed inside pixel array as it follows:
                // pixel[0] = red, pixel[1] = green, pixel[2] = blue, pixel[3] = alpha
                // so we have 4 elements for one pixel on the screen
                
                
                // To compute the average color we add up all red, green, and blue and divive the number
                // to the total number of pixels, which is 25 in our case of 5x5 square
                red += CGFloat(pixel[index]) / 255.0
                green += CGFloat(pixel[index + 1]) / 255.0
                blue += CGFloat(pixel[index + 2]) / 255.0
                alpha += CGFloat(pixel[index + 3]) / 255.0
                
                index += 4
            }
            
            let numberOfPixels = squareWidth * squareWidth
            
            let color = UIColor(red: red / numberOfPixels,
                                green: green / numberOfPixels,
                                blue: blue / numberOfPixels,
                                alpha: alpha / numberOfPixels)
            
            DispatchQueue.main.async {
                callback(color)
            }
        }
    }
}

/// For testing the actual pixels that we take the color from
//class Helper {
//    static func imageFromARGB32Bitmap(pixels: [UInt8], width: Int, height: Int) -> UIImage? {
//        guard width > 0 && height > 0 else { return nil }
////        guard pixels.count == width * height else { return nil }
//
//        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
//        let bitsPerComponent = 8
//        let bitsPerPixel = 32
//
//        var data = pixels // Copy to mutable []
//        guard let providerRef = CGDataProvider(data: NSData(bytes: &data,
//                                length: data.count * MemoryLayout<[UInt8]>.size)
//            )
//            else { return nil }
//
//        guard let cgim = CGImage(
//            width: width,
//            height: height,
//            bitsPerComponent: bitsPerComponent,
//            bitsPerPixel: bitsPerPixel,
//            bytesPerRow: 200,
//            space: rgbColorSpace,
//            bitmapInfo: bitmapInfo,
//            provider: providerRef,
//            decode: nil,
//            shouldInterpolate: true,
//            intent: .defaultIntent
//            )
//            else { return nil }
//
//        return UIImage(cgImage: cgim)
//    }
//}
