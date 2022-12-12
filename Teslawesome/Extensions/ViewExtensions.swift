//
//  ViewExtensions.swift
//  Teslawesome
//
//  Created by Ivaylo Gashev on 4.11.22.
//

import SwiftUI

extension View {
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        presentationDetents: Set<PresentationDetent>,
        largestUndimmedIdentifier: UISheetPresentationController.Detent.Identifier,
        interactiveDismissDisabled: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self
            .sheet(isPresented: isPresented) {
                content()
                    .presentationDetents(presentationDetents)
                    .interactiveDismissDisabled(interactiveDismissDisabled)
                    .onAppear {
                        // An awful workaround for enabling background interactivity. This will stay until SwiftUI has a way to do it without reaching UIKit.
                        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                            return
                        }
                        
                        guard let presentedSheetController = scene
                            .windows
                            .first?
                            .rootViewController?
                            .presentedViewController?
                            .presentationController as? UISheetPresentationController
                        else {
                            return
                        }
                        
                        presentedSheetController.largestUndimmedDetentIdentifier = largestUndimmedIdentifier
                    }
            }
    }
}
