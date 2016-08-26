//
//  ViewController.swift
//  SampleRSBarCodeScanner
//
//  Created by Alvin George on 8/25/16.
//  Copyright © 2016 Alvin George. All rights reserved.
//

import UIKit
import AVFoundation


class ViewController: RSCodeReaderViewController  {

    var barcode: String = ""
    var barcodeTypeString:String = ""
    var dispatched: Bool = false
    var contents: String = "http://www.zai360.com/"
    var barcodeTypeImage: UIImage?

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var showBarCodeButton: UIButton!
    @IBOutlet weak var torchButton: UIButton!
    @IBOutlet weak var cameraOrientationButton: UIButton!
    @IBOutlet weak var imageDisplayed: UIImageView!
    @IBOutlet weak var barCodeLabel: UILabel!
    @IBOutlet weak var barCodeTypeLabel: UILabel!

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
        self.barCodeTypeLabel.hidden =  true

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
     
        //We can remove some bar types if needed:
        //types.removeObject(AVMetadataObjectTypeQRCode)

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
                    self.barcodeTypeString = barcode.type
                    dispatch_async(dispatch_get_main_queue(), {
                        // MARK: NOTE: Perform UI related actions here.
                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
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

        self.contents = self.barcode
        print ("generating image with barcode: " + self.contents)

        switch (barcodeTypeString) {

        case "org.ansi.Interleaved2of5":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeInterleaved2of5Code)!
            break;
        case "org.gs1.ITF14":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeITF14Code)!
            break;
        case "org.gs1.EAN-13":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeEAN13Code)!
            break;
        case "org.gs1.EAN-8":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeEAN8Code)
            break;

        case "org.gs1.UPC-A":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeUPCECode)
            break;

        case "org.gs1.UPC-E":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeUPCECode)
            break;

        case "org.iso.Code39":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeCode39Code)
            break;


        case "org.iso.Code128":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeCode128Code)
            break;
        case "org.iso.Code39Mod43":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeCode39Mod43Code)
            break;
        case "org.iso.DataMatrix":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeDataMatrixCode)
            break;
        case "org.iso.Aztec":
            print("self.contents : \(self.contents)")
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeFace)
            break;
        case "org.iso.PDF417":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypePDF417Code)
            break;
        case "org.iso.QRCode":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeQRCode)
            break;
        case "com.intermec.Code93":
            barcodeTypeImage = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeCode93Code)
            break;
        default:
            break
        }

        //let image: UIImage? = gen.generateCode(self.contents, machineReadableCodeObjectType: AVMetadataObjectTypeQRCode)

        if (barcodeTypeImage != nil) {
            self.imageDisplayed.layer.borderWidth = 1
            self.imageDisplayed.image = RSAbstractCodeGenerator.resizeImage(barcodeTypeImage!, targetSize: self.imageDisplayed.bounds.size, contentMode: UIViewContentMode.ScaleAspectFit)
        }
        print("barcode: \(barcode)")
        self.barCodeLabel.text = self.barcode
        self.barCodeTypeLabel.text = self.barcodeTypeString

        self.barCodeLabel.hidden =  false
        self.imageDisplayed.hidden =  false
        self.barCodeTypeLabel.hidden =  false
        self.viewWillAppear(true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

