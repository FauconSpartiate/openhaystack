//
//  OpenHaystack – Tracking personal Bluetooth devices via Apple's Find My network
//
//  Copyright © 2021 Secure Mobile Networking Lab (SEEMOO)
//  Copyright © 2021 The Open Wireless Link Project
//
//  SPDX-License-Identifier: AGPL-3.0-only
//

import OSLog
import SwiftUI

struct NRFSoudoplastInstallSheet: View {
    @Binding var accessory: Accessory?
    @Binding var alertType: OpenHaystackMainView.AlertType?
    @Binding var scriptOutput: String?
    @State var isFlashing = false

    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            self.flashView
                .overlay(self.loadingOverlay)
                .frame(minWidth: 80, minHeight: 80, alignment: .center)
        }
        .onAppear {
            if let accessory = self.accessory {
                deployAccessoryToNRFDevice(accessory: accessory);
            }
        }
    }

    var flashView: some View {
        VStack {
        }
    }

    var loadingOverlay: some View {
        ZStack {
            if isFlashing {
         
                    ActivityIndicator(size: .large)
                
            }
        }
    }

    func deployAccessoryToNRFDevice(accessory: Accessory) {
        do {
            self.isFlashing = true

            try NRFSoudoplastController.flashToNRF(
                accessory: accessory,
                completion: { result in
                    presentationMode.wrappedValue.dismiss()

                    self.isFlashing = false
                    switch result {
                    case .success(_):
                        self.alertType = .deployedSuccessfully
                        accessory.isDeployed = true
                    case .failure(let loggingFileUrl, let error):
                        os_log(.error, "Flashing to NRF device failed %@", String(describing: error))
                        self.presentationMode.wrappedValue.dismiss()
                        self.alertType = .nrfDeployFailed
                        do {
                            self.scriptOutput = try String(contentsOf: loggingFileUrl, encoding: .ascii)
                        } catch {
                            self.scriptOutput = "Error while trying to read log file."
                        }
                    }
                })
        } catch {
            os_log(.error, "Preparation or execution of script failed %@", String(describing: error))
            self.presentationMode.wrappedValue.dismiss()
            self.alertType = .deployFailed
            self.isFlashing = false
        }

        self.accessory = nil
    }
}
