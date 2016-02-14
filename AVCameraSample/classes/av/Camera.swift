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

    static let sharedInstance: Camera = Camera()

    var didCaptureSampleBufferClosure: ((CMSampleBuffer) -> Void)?

    private let captureSession: AVCaptureSession = AVCaptureSession()
    private var device: AVCaptureDevice!

    override private init() {
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

            if device.position == .Front {
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
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey : Int(kCVPixelFormatType_32BGRA)]

            let videoOutputQueue: dispatch_queue_t = dispatch_queue_create("AVCameraSample.Camera.videoOutputQueue", nil)
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

            videoConnection?.videoOrientation = .Portrait

            captureSession.commitConfiguration()
            captureSession.startRunning()
        } catch let error as NSError {
            print("error:\(error)")
        }
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        didCaptureSampleBufferClosure?(sampleBuffer)
    }
}
