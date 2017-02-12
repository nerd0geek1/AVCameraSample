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

    let imageView: UIImageView = UIImageView(frame: UIScreen.main.bounds)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupImageView()
        setupCamera()
    }

    // MARK: - private

    private func setupImageView() {
        view.addSubview(imageView)
    }

    private func setupCamera() {
        Camera.shared.didCaptureSampleBufferClosure = {[unowned self] sampleBuffer in
            DispatchQueue.main.sync {
                self.imageView.image = self.convertToUIImage(with: sampleBuffer)
            }
        }
    }


    // MARK: - convert CMSampleBuffer to UIImage

    private func convertToUIImage(with sampleBuffer: CMSampleBuffer) -> UIImage {
        let pixelBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciImage: CIImage           = CIImage(cvPixelBuffer: pixelBuffer)
        let image                      = UIImage(ciImage: ciImage)
        return image
    }
}
