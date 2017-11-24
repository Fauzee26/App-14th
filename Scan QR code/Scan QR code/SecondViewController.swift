//
//  SecondViewController.swift
//  Scan QR code
//
//  Created by Hilmy OS on 17/9/17.
//  Copyright © 2017 Hilmy OS. All rights reserved.
//

import UIKit
//add library
import AVFoundation

class SecondViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    
    //declare widget
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var topBar: UIView!
    
    //declare variable
    var captureSession : AVCaptureSession?
    var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    var qrCodeFrameView : UIView?
    
    //declare supportCodeType
    let supportCodeTypes = [AVMetadataObjectTypeUPCECode,
                            AVMetadataObjectTypeCode39Code,
                            AVMetadataObjectTypeCode39Mod43Code,
                            AVMetadataObjectTypeCode93Code,
                            AVMetadataObjectTypeCode128Code,
                            AVMetadataObjectTypeEAN13Code,
                            AVMetadataObjectTypeEAN8Code,
                            AVMetadataObjectTypeAztecCode,
                            AVMetadataObjectTypePDF417Code,
                            AVMetadataObjectTypeQRCode]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Declare captureDevice and use video as media type
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // mengecek apakah bisa capture atau tidak
        do{
            let input = try AVCaptureDeviceInput(device: captureDevice)
            //menjaikan capture session sebagai object dari AVCaptureSession()
            captureSession = AVCaptureSession()
            //menambahkan input pada capture session
            captureSession?.addInput(input)
            
            //deklarasi captureMetaDataoutput sebagai object dari AVCaptureMetaDataOutput
            let captureMetadataOutput = AVCaptureMetadataOutput()
            //menambahkan output capture session
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportCodeTypes
            
            //deklarai video preview
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            //menjadikan layar fullScreen
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            //memulai capture video
            captureSession?.startRunning()
            
            //memindahkan message label dan top bar ke tampilan bagian depan
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: topBar)
            
            //deklarasi QRcode frame menjadi highlight QRCode
            qrCodeFrameView = UIView()
            
            //pengecekan apakah sama dengan qrCodeFrameview
            if let qrCodeFrameView = qrCodeFrameView {
                //memberikan warna border : hijau
                qrCodeFrameView.layer.borderWidth = 2
                //menambahkan subview
                view.addSubview(qrCodeFrameView)
                //menambahkan subview ke tampilan depan
                view.bringSubview(toFront: qrCodeFrameView)
                
            }
            
        }catch{
            print(error)
            return
        }
    }

    //implemen method
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
    
    //pengecekan apakah metadata objectnya nil
        if metadataObjects == nil || metadataObjects.count == 0 {
            //kondisi ketika data nil
            
            qrCodeFrameView?.frame = CGRect.zero
            //menampilkan teks ke label
            messageLabel.text = "NO QR / Barcode detect"
            return
        }
        
        //mengambil metadata object
        let metadataObj = metadataObjects[0] as!
            AVMetadataMachineReadableCodeObject
        
        //mengecek apakah type data yg di support termasuk di metadata object
        
        if supportCodeTypes.contains(metadataObj.type){
            //jika metadata yg ditemukan dengan QR code metadata maka status label text akan update dan di set menjadi full screen
            
            let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barcodeObject!.bounds
            if metadataObj.stringValue != nil{
                messageLabel.text = metadataObj.stringValue
                //memanggil method launchApp
                launchApp(decodeURL : metadataObj.stringValue)
            }
            
        }
        
    }
    
    
    
    //method launchApp
    func launchApp(decodeURL : String) {
        
        //mengecek apakah data view controller kosong /nil
        if presentedViewController != nil {
            return
    }
    
        // menampilkan alert dialoglet
        let alertPrompt = UIAlertController(title:"Open App", message: "You're going to open", preferredStyle: .actionSheet)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            (action) -> Void in
            
            if let url = URL(string: decodeURL){
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.open(url, options: [:],completionHandler: nil)
                }
            }
        })
    
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertPrompt.addAction(confirmAction)
        alertPrompt.addAction(cancelAction)
        present(alertPrompt, animated:  true, completion: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
