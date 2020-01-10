//
//  Spotify.swift
//  SongMaps
//
//  Created by Polecat on 11/13/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Spotify {
    
    let client_id: String
    let client_secret: String
    var state: String!
    let redirectURL = "song-maps://spotify-login-callback"
    var accessToken: String?
    var refreshToken: String?
    var artists = Set<String>()
    let limit = 50
    
    init() {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
           let nsDictionary = NSDictionary(contentsOfFile: path)
            client_id = nsDictionary!["spotify_client_id"] as! String
        } else {
            fatalError("Spotify client id not found")
        }
        
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
           let nsDictionary = NSDictionary(contentsOfFile: path)
            client_secret = nsDictionary!["spotify_client_secret"] as! String
        } else {
            fatalError("Spotify secret id not found")
        }
        
        state = randomString(length: 64)
    }
    
    func authorize() -> URL {
        return requestAuthorization()
    }
    
    func authorizationResponse(code: String, state: String, progress: @escaping (Float) -> (), completion: @escaping ([String]) -> (), error: @escaping (String) -> ()) {
        if state != self.state {
            error("Authentication error, states did not match")
            return
        }
        
        getAccessToken(code: code, progress: progress, completion: completion, error: error)
    }
    
    private func getAccessToken(code: String, progress: @escaping (Float) -> (), completion: @escaping ([String]) -> (), error errorCallback: @escaping (String) -> ()) {
        let url = "https://accounts.spotify.com/api/token"
        let parameters: [String: String] = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURL,
        ]
        
        let headers: HTTPHeaders = [
            .authorization(username: client_id, password: client_secret),
        ]
        
        AF.request(url, method: .post, parameters: parameters, encoder: URLEncodedFormParameterEncoder(destination: .httpBody), headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let accessToken = json["access_token"].string else {
                    errorCallback("Missing Access Token")
                    return
                }
                
                guard let refreshToken = json["refresh_token"].string else {
                    errorCallback("Missing Refresh Token")
                    return
                }
                
                self.accessToken = accessToken
                self.refreshToken = refreshToken
                
                self.getUsername(after: nil, progress: progress, completion: completion, error: errorCallback)
            case .failure(let error):
             print(error)
             errorCallback("Error Requesting Authorization")
            }
        }
    }
    
    private func getUsername(after: String?, progress: @escaping (Float) -> (), completion: @escaping ([String]) -> (), error errorCallback: @escaping (String) -> ()) {
        let url = "https://api.spotify.com/v1/me"
    
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken!)
        ]
        
        AF.request(url, method: .get, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                guard let username = json["display_name"].string else {
                    return
                }
                
                if (username.lowercased() == settings.spotifyTestName.lowercased()) {
                    settings.demoMode = true
                } else {
                    settings.demoMode = false
                }
                
                self.getFollowedArtists(after: nil, progress: progress, completion: completion, error: errorCallback)

            case .failure(let error):
                if response.response?.statusCode == 429 {
                    if let retryTime = response.response?.allHeaderFields["Retry-After"] as? String {
                        if let retrySeconds = Int(retryTime) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(retrySeconds)) {
                                self.getUsername(after: nil, progress: progress, completion: completion, error: errorCallback)
                            }
                            return
                        }
                    }
                }
                print(error)
                errorCallback("Error Getting Username")
            }
        }
    }
    
    private func getFollowedArtists(after: String?, progress: @escaping (Float) -> (), completion: @escaping ([String]) -> (), error errorCallback: @escaping (String) -> ()) {
        let url = "https://api.spotify.com/v1/me/following?type=artist"
        
        var parameters: Parameters = [
            "type": "artist",
            "limit": limit
        ]
        
        if let after = after {
            parameters["after"] = after
        }
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken!)
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let total = json["artists"]["total"].int else {
                    errorCallback("Malformed JSON")
                    return
                }
                
                guard let artists = json["artists"]["items"].array else {
                    errorCallback("Malformed JSON")
                    return
                }
                
                var currentProgress = Float(artists.count)/Float(total)
                
                if currentProgress > 0.5 {
                    currentProgress = 0.5
                }
                
                if artists.count == 0 && total == 0 {
                    currentProgress = 0.5
                }
                progress(currentProgress / 2)
                
                for artist in artists {
                    if let name = artist["name"].string {
                        self.artists.insert(name)
                    }
                }
                
                if let newAfter = json["cursors"]["after"].string {
                    self.getFollowedArtists(after: newAfter, progress: progress, completion: completion, error: errorCallback)
                } else {
                    self.getTopArtists(progress: progress, completion: completion, error: errorCallback)
                }

            case .failure(let error):
                if response.response?.statusCode == 429 {
                    if let retryTime = response.response?.allHeaderFields["Retry-After"] as? String {
                        if let retrySeconds = Int(retryTime) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(retrySeconds)) {
                                self.getFollowedArtists(after: after, progress: progress, completion: completion, error: errorCallback)
                            }
                            return
                        }
                    }
                }
                print(error)
                errorCallback("Error Getting Artists")
            }
        }
    }
    
    private func getTopArtists(offset: Int = 0, progress: @escaping (Float) -> (), completion: @escaping ([String]) -> (), error errorCallback: @escaping (String) -> ()) {
        let url = "https://api.spotify.com/v1/me/top/artists"
        
        let parameters: Parameters = [
            "offset": offset,
            "limit": limit
        ]
        
        let headers: HTTPHeaders = [
            .authorization(bearerToken: accessToken!)
        ]
        
        AF.request(url, method: .get, parameters: parameters, headers: headers).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                guard let total = json["total"].int else {
                    errorCallback("Malformed JSON")
                    return
                }
                
                guard let artists = json["items"].array else {
                    errorCallback("Malformed JSON")
                    return
                }
                
                var currentProgress = Float(artists.count)/Float(total)
                
                if currentProgress > 0.5 {
                    currentProgress = 0.5
                }
                
                currentProgress += 0.5
                
                if artists.count == 0 && total == 0 {
                    currentProgress = 1
                }
                
                progress(currentProgress)
                
                for artist in artists {
                    if let name = artist["name"].string {
                        self.artists.insert(name)
                    }
                }
                
                if let _ = json["next"].string {
                    self.getTopArtists(offset: offset + self.limit, progress: progress, completion: completion, error: errorCallback)
                } else {
                    completion(Array(self.artists))
                }

            case .failure(let error):
                if response.response?.statusCode == 429 {
                    if let retryTime = response.response?.allHeaderFields["Retry-After"] as? String {
                        if let retrySeconds = Int(retryTime) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(retrySeconds)) {
                                self.getTopArtists(offset: offset, progress: progress, completion: completion, error: errorCallback)
                            }
                            return
                        }
                    }
                }
                print(error)
                errorCallback("Error Getting Top Artists")
            }
        }
    }
    
    private func requestAuthorization() -> URL {
        let queryItems = [URLQueryItem(name: "client_id", value: client_id), URLQueryItem(name: "response_type", value: "code"), URLQueryItem(name: "redirect_uri", value: redirectURL),
        URLQueryItem(name: "state", value: state), URLQueryItem(name: "scope", value: "user-follow-read user-top-read")]
        let urlComps = NSURLComponents(string: "https://accounts.spotify.com/authorize")!
        urlComps.queryItems = queryItems
        let url = urlComps.url!

        return url
    }
    
    private func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

protocol SpotifyHandler {
    func spotifyAuthResponse(code: String, state: String, error: String?)
}
