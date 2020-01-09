//
//  SpotifyViewController.swift
//  SongMaps
//
//  Created by Polecat on 1/10/20.
//  Copyright © 2020 Polecat. All rights reserved.
//

import UIKit
import WebKit

class SpotifyViewController: UIViewController, Storyboarded, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    weak var coordinator: MainCoordinator?
    var spotifyURL: URL!
    var handler: SpotifyHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        let request = URLRequest(url: spotifyURL)
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        
        guard let url = navigationAction.request.url else {
            return
        }
        
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let params = components.queryItems else {
                print("Invalid URL or params missing")
                return
        }
        
        guard (components.scheme == "song-maps") else {
            return
        }
        
        defer {
            coordinator?.goBack()
        }
        
        if components.host == "spotify-login-callback" {
            var state: String?
            var code: String?
            var error: String?
            
            for param in params {
                if param.name == "code" {
                    code = param.value
                }
                
                if param.name == "state" {
                    state = param.value
                }
                
                if param.name == "error" {
                    error = param.value
                }
            }
            
            if let spotifyError = error {
                handler?.spotifyAuthResponse(code: "", state: "", error: spotifyError)
                return
            }
            
            guard let spotifyCode = code, let spotifyState = state else {
                return
            }
            
            handler?.spotifyAuthResponse(code: spotifyCode, state: spotifyState, error: nil)
        }
    }
    
    @IBAction func cancelTap(_ sender: Any) {
        coordinator?.goBack()
    }
    
}
