//
//  TeslaAuthWebView.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 22.08.22.
//

import SwiftUI
import WebKit

struct TeslaAuthWebView: UIViewRepresentable {
    let url: URL
    let onSuccessURLWithAuthCode: (URL) -> Void
    
    func makeUIView(context: Context) -> some UIView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> TeslaAuthWebViewDelegateCoordinator {
        .init(webView: self, onSuccessURLWithAuthCode: onSuccessURLWithAuthCode)
    }
}

final class TeslaAuthWebViewDelegateCoordinator: NSObject, WKNavigationDelegate {
    let webView: TeslaAuthWebView
    let onSuccessURLWithAuthCode: (URL) -> Void
    
    private let teslaCallbackUrlAfterSuccessfulLogin = "https://auth.tesla.com/void/callback"
    
    init(webView: TeslaAuthWebView, onSuccessURLWithAuthCode: @escaping (URL) -> Void) {
        self.webView = webView
        self.onSuccessURLWithAuthCode = onSuccessURLWithAuthCode
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        guard let url = navigationAction.request.url,
              url.absoluteString.starts(with: teslaCallbackUrlAfterSuccessfulLogin)
        else {
            return .allow
        }
        
        await MainActor.run {
            onSuccessURLWithAuthCode(url)
        }
        return .cancel
    }
}
