//
//  ViewController.swift
//  SampleRSBarCodeScanner
//
//  Created by Alvin George on 8/25/16.
//  Copyright © 2016 Alvin George. All rights reserved.
//

import UIKit
import AVFoundation
import RSBarcodes


class ViewController: RSCodeReaderViewController  {

    var barcode: String = ""
    var dispatched: Bool = false
    var contents: String = "http://www.zai360.com/"

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var showBarCodeButton: UIButton!
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var cameraOrientationButton: UIButton!
    @IBOutlet weak var imageDisplayed: UIImageView!
    @IBOutlet weak var barCodeLabel: UILabel!

    @IBAction func switchCamera(sender: AnyObject?) {
        let position = self.switchCamera()
        print("camera position :\(position)")
    }

    @IBAction func close(sender: AnyObject?) {
        print("close called.")
    }

    @IBAction func toggle(sender: AnyObject?) {
        let isTorchOn = self.toggleTorch()
        print(isTorchOn)
    }
    @IBAction func generateBarCode(sender: AnyObject) {

        self.showBarCodeAndCorrespondingImage()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.barCodeLabel.hidden =  true
        self.imageDisplayed.hidden =  true

    }

    override func viewWillAppear(animated: Bool) {
        self.dispatched = false // reset the flag so user can do another scan

        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        self.startScanningBarCode()
    }
    func startScanningBarCode()
    {
        self.focusMarkLayer.strokeColor = UIColor.redColor().CGColor
        self.cornersLayer.strokeColor = UIColor.yellowColor().CGColor
        self.tapHandler = { point in
            print(point)
        }

        let types = NSMutableArray(array: self.output.availableMetadataObjectTypes)
        types.removeObject(AVMetadataObjectTypeQRCode)
        self.output.metadataObjectTypes = NSArray(array: types) as [AnyObject]

        // MARK: NOTE: If you layout views in storyboard, you should add these 3 lines
        for subview in self.view.subviews {
            self.view.bringSubviewToFront(subview)
        }

        if !self.hasTorch() {
            self.torchButton.enabled = false
        }

        self.barcodesHandler = { barcodes in
            if !self.dispatched { // triggers for only once
                self.dispatched = true
                for barcode in barcodes {
                    self.barcode = barcode.stringValue
                    print("Barcode found: type=" + barcode.type + " value=" + barcode.stringValue)
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    dispatch_async(dispatch_get_main_queue(), {
                        // MARK: NOTE: Perform UI related actions here.
                        self.showBarCodeAndCorrespondingImage()

                    })
                }
            }
        }
    }
    func showBarCodeAndCorrespondingImage()
    {
        let gen = RSUnifiedCodeGenerator.shared
        gen.fillColor = UIColor.whiteColor()
        gen.strokeColor = UIColor.blackColor()
        print ("generating image with barcode: " + self.contents)

        let image: UIImage? = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeQRCode)

        if (image != nil) {
            self.imageDisplayed.layer.borderWidth = 1
            self.imageDisplayed.image = RSAbstractCodeGenerator.resizeImage(image!, targetSize: self.imageDisplayed.bounds.size, contentMode: UIViewContentMode.BottomRight)
        }
        print("barcode: \(barcode)")
        self.barCodeLabel.text = self.barcode

        self.barCodeLabel.hidden =  false
        self.imageDisplayed.hidden =  false
        self.viewWillAppear(true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

