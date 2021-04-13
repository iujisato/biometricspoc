//
//  CombateAFraude.swift
//  BiometricsPOC
//
//  Created by Iuji Ujisato on 13/04/21.
//  Copyright © 2021 Facebook. All rights reserved.
//

import UIKit
import Foundation
import PassiveFaceLivenessNoSentryStatic

@objc(CombateAFraude)
class CombateAFraude: RCTEventEmitter, PassiveFaceLivenessControllerDelegate {

    @objc
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

  // PassiveFaceLiveness

    @objc(passiveFaceLiveness:)
    func passiveFaceLiveness(mobileToken: String) {
        let passiveFaceLiveness = PassiveFaceLivenessNoSentryStatic.Builder(mobileToken: mobileToken)
            .build()

        DispatchQueue.main.async {
            let currentViewController = UIApplication.shared.keyWindow!.rootViewController

            let sdkViewController = PassiveFaceLivenessController(passiveFaceLiveness: passiveFaceLiveness)
            sdkViewController.passiveFaceLivenessDelegate = self

            currentViewController?.present(sdkViewController, animated: true, completion: nil)
        }
    }

    func passiveFaceLivenessController(_ passiveFacelivenessController: PassiveFaceLivenessController, didFinishWithResults results: PassiveFaceLivenessResult) {
        let response : NSMutableDictionary! = [:]

        let imagePath = saveImageToDocumentsDirectory(image: results.image, withName: "selfie.jpg")
        response["imagePath"] = imagePath
        response["imageUrl"] = results.imageUrl
        response["signedResponse"] = results.signedResponse
        response["trackingId"] = results.trackingId

    sendEvent(withName: "PassiveFaceLiveness_Success", body: response)
    }

    func passiveFaceLivenessControllerDidCancel(_ passiveFacelivenessController: PassiveFaceLivenessController) {
    sendEvent(withName: "PassiveFaceLiveness_Cancel", body: nil)
    }

    func passiveFaceLivenessController(_ passiveFacelivenessController: PassiveFaceLivenessController, didFailWithError error: PassiveFaceLivenessFailure) {
       let response : NSMutableDictionary! = [:]

        response["message"] = error.message
        response["type"] = String(describing: type(of: error))

    sendEvent(withName: "PassiveFaceLiveness_Error", body: response)
    }

  // Auxiliar functions

  func saveImageToDocumentsDirectory(image: UIImage, withName: String) -> String? {
        if let data = image.jpegData(compressionQuality: 0.8) {
            let dirPath = getDocumentsDirectory()
            let filename = dirPath.appendingPathComponent(withName)
            do {
                try data.write(to: filename)
                print("Successfully saved image at path: \(filename)")
                return filename.path
            } catch {
                print("Error saving image: \(error)")
            }
        }
        return nil
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }

  override func supportedEvents() -> [String]! {
    return ["PassiveFaceLiveness_Success", "PassiveFaceLiveness_Cancel", "PassiveFaceLiveness_Error"]
  }

}
