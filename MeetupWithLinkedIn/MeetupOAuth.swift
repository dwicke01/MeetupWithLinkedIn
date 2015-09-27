//
//  MeetupOauth.swift
//  MeetupWithLinkedIn
//
//  Created by Daniel Wickes on 9/26/15.
//  Copyright © 2015 danielwickes. All rights reserved.
//

import Foundation
import Alamofire

class MeetupOAuth {
    var oAuth2URL : NSURL { return NSURL(string : "https://secure.meetup.com/oauth2/")! }
    var asd = "https://secure.meetup.com/oauth2/"
    let authorizeArgs = "authorize?client_id=\(Constants.Meetup.CLIENT_ID)&response_type=code&redirect_uri=dwMeetup://com.danielwickes.MeetupWithLinkedIn"
    
    static let sharedInstance = MeetupOAuth()
 
    
    func loadGroups() {
        if !MeetupOAuth.sharedInstance.hasOAuthToken() {
            MeetupOAuth.sharedInstance.startOAuth2Login()
        }
    }
    
    var OAuthToken : String?
    var refreshToken : String?
    
    func hasOAuthToken() -> Bool {
        guard let token = self.OAuthToken else {
            return false
        }
        return !token.isEmpty
    }
    
    func startOAuth2Login() {
        let oAuth2URLAuthorizeWithoutWeirdBug = NSURL(string : oAuth2URL.URLString.stringByAppendingString(authorizeArgs))
        guard let unwrappedURL : NSURL = oAuth2URLAuthorizeWithoutWeirdBug else {
            return
        }
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(true, forKey: "loadingOAuthToken")
        
        UIApplication.sharedApplication().openURL(unwrappedURL)
    }
    
    func processOAuthStep1Response(url: NSURL)
    {
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        var code:String?
        
        guard let queryItems = components?.queryItems else {
            return
        }
        
        for queryItem in queryItems
        {
            if (queryItem.name.lowercaseString == "code")
            {
                code = queryItem.value
                break
            }
        }
        
        guard let receivedCode = code else {
            return
        }
        
        let getTokenPath:String = "https://secure.meetup.com/oauth2/access"
        let tokenParams = ["client_id": Constants.Meetup.CLIENT_ID,
                "client_secret": Constants.Meetup.CLIENT_SECRET,
                "grant_type": "authorization_code",
                "redirect_uri": "dwMeetup://com.danielwickes.MeetupWithLinkedIn",
                "code": receivedCode
            ]
        
        Alamofire.request(.POST, getTokenPath, parameters: tokenParams)
            .responseJSON {
                (request, response, result) in
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setBool(false, forKey: "loadingOAuthToken")
                
                guard let json : AnyObject = result.value else {
                    return
                }
                
                self.parseOAuthToken(json)
                self.parseRefreshToken(json)
        }
    }
    
    func parseOAuthToken(json : AnyObject) {
        guard let access_token : String? = json["access_token"] as? String else {
            return
        }
        self.OAuthToken = access_token
    }
    
    func parseRefreshToken(json :AnyObject) {
        guard let refreshToken : String? = json["refresh_token"] as? String else {
            return
        }
        self.refreshToken = refreshToken
    }
    
}