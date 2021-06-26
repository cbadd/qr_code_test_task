//
//  ScannerViewController.swift
//  QRScanner
//
//  Created by Александр Строганов on 25.06.2021.
//

import UIKit
import AVFoundation

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
}

class ScannerViewController: UIViewController {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrcodeFrameView: UIView?
    var detectedURL: String?
    
    @IBOutlet var msgLabel: UILabel!
    @IBOutlet var stuffView: UIView!
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //если объекты не найдены, показываем стандартную надись
        if metadataObjects.count == 0 {
            qrcodeFrameView?.frame = CGRect.zero
            msgLabel.text = "Наведите камеру на QR-код"
            detectedURL = nil
            return
        }
        
        //если видим QR-код
        let metaDataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metaDataObj.type == AVMetadataObject.ObjectType.qr {
            //наводим на него желтый квадрат
            let qrObject = videoPreviewLayer?.transformedMetadataObject(for: metaDataObj)
            qrcodeFrameView?.frame = qrObject!.bounds
            
            //считываем данные QR-кода, если ссылка отличается от уже считанной, обновляем action sheet
            if metaDataObj.stringValue != nil {
                if detectedURL != metaDataObj.stringValue {
                    detectedURL = metaDataObj.stringValue
                    if let url = URL(string: metaDataObj.stringValue!) {
                        let actionSheet = UIAlertController(title: "Найдена ссылка", message: metaDataObj.stringValue, preferredStyle: .actionSheet)
                        actionSheet.addAction(UIAlertAction.init(title: "Перейти", style: .default, handler: { action in
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }))
                        actionSheet.addAction(UIAlertAction.init(title: "Отмена", style: .cancel, handler: { action in
                            
                        }))
                        present(actionSheet, animated: true, completion: nil)
                    } else {
                        msgLabel.text = "Неверная ссылка"
                    }
                    
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("ошибка доступа к камере")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.startRunning()
            
            //веведем наверх view с полупрозрачным темным фоном и кнопкой отмены
            view.bringSubviewToFront(stuffView)
            
            //добавим желтую рамку вокруг QR-кода. Здесь зададим ее размер 0, при распознавании QR-кода, будем менять размер рамки и она будет его обрамлять
            qrcodeFrameView = UIView()
            qrcodeFrameView?.layer.borderColor = UIColor.yellow.cgColor
            qrcodeFrameView?.layer.borderWidth = 2
            view.addSubview(qrcodeFrameView!)
            view.bringSubviewToFront(qrcodeFrameView!)
        } catch {
            print(error)
            return
        }
    }
    
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
