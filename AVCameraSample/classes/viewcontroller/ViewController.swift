//
//  ViewController.swift
//  AVCameraSample
//
//  Created by Kohei Tabata on 2016/02/14.
//  Copyright © 2016年 Kohei Tabata. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    let imageView: UIImageView = UIImageView(frame: UIScreen.mainScreen().bounds)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupImageView()
        setupCamera()
    }

    //MARK: - private

    private func setupImageView() {
        view.addSubview(imageView)
    }

    private func setupCamera() {
        Camera.sharedInstance.didCaptureSampleBufferClosure = {[weak self] sampleBuffer -> Void in
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self?.imageView.image = self?.convertSampleBufferToUIImage(sampleBuffer)
            })
        }
    }


    //MARK: - convert CMSampleBuffer to UIImage

    private func convertSampleBufferToUIImage(sampleBuffer: CMSampleBufferRef) -> UIImage {
        let pixelBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciImage: CIImage              = CIImage(CVPixelBuffer: pixelBuffer)
        let image                         = UIImage(CIImage: ciImage)
        return image
    }
}
