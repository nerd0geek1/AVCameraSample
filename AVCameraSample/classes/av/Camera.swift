//
//  Camera.swift
//  AVCameraSample
//
//  Created by Kohei Tabata on 2016/02/14.
//  Copyright © 2016年 Kohei Tabata. All rights reserved.
//

import AVFoundation
import Foundation

class Camera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    static let shared: Camera = Camera()

    var didCaptureSampleBufferClosure: ((CMSampleBuffer) -> Void)?

    private let captureSession: AVCaptureSession = AVCaptureSession()
    private var device: AVCaptureDevice!

    override fileprivate init() {
        super.init()

        setup()
    }

    //MARK: - private

    private func setup() {
        guard let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] else {
            return
        }

        for device in devices {
            if !device.hasMediaType(AVMediaTypeVideo) {
                continue
            }

            if device.position == .back {
                self.device = device
                break
            }
        }

        captureSession.sessionPreset = AVCaptureSessionPresetHigh

        do {
            let deviceInput: AVCaptureInput = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }

            let videoOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)]

            let videoOutputQueue: DispatchQueue = DispatchQueue(label: "AVCameraSample.Camera.videoOutputQueue", attributes: [])
            videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }

            var videoConnection: AVCaptureConnection? = nil
            guard let connections: [AVCaptureConnection] = videoOutput.connections as? [AVCaptureConnection] else {
                return
            }

            captureSession.beginConfiguration()
            for connection in connections {
                guard let inputPorts: [AVCaptureInputPort] = connection.inputPorts as? [AVCaptureInputPort] else {
                    return
                }
                for port in inputPorts {
                    if port.mediaType == AVMediaTypeVideo {
                        videoConnection = connection
                        break
                    }
                }
            }

            videoConnection?.videoOrientation = .portrait

            captureSession.commitConfiguration()
            captureSession.startRunning()
        } catch let error as NSError {
            print("error:\(error)")
        }
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        didCaptureSampleBufferClosure?(sampleBuffer)
    }
}
