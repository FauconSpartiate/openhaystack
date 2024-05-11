//
//  OpenHaystack – Tracking personal Bluetooth devices via Apple's Find My network
//
//  Copyright © 2021 Secure Mobile Networking Lab (SEEMOO)
//  Copyright © 2021 The Open Wireless Link Project
//
//  SPDX-License-Identifier: AGPL-3.0-only
//

import SwiftUI

struct IconSelectionView: View {

    @Binding var selectedNumber: String
    @Binding var selectedColor: Color

    var body: some View {

        ZStack {
            Button(
                action: {
                    withAnimation {
                        //self.showImagePicker.toggle()
                    }
                },
                label: {
                    Circle()
                        .strokeBorder(self.selectedColor, lineWidth: 2)
                        .background(
                            ZStack {
                                Circle().fill(Color("PinColor"))
                                Text(self.selectedNumber)
                                    .colorMultiply(Color("PinImageColor"))
                            }
                        )
                        .frame(width: 32, height: 32)
                }
            )
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct ColorSelectionView_Previews: PreviewProvider {
    @State static var selectedNumber: String = "0"
    @State static var selectedColor: Color = .red

    static var previews: some View {
        Group {
            IconSelectionView(selectedNumber: self.$selectedNumber, selectedColor: self.$selectedColor)
        }

    }
}
