//
//  GoogleHelper.swift
//  UST-Test
//
//  Created by Ajith Mohan on 15/10/24.
//

import Foundation
import GoogleSignIn


class GoogleHelper{
    
    static func signin(sender: UIViewController) async throws -> Bool {
            return try await withCheckedThrowingContinuation { continuation in
                GIDSignIn.sharedInstance.signIn(withPresenting: sender) { signInResult, error in
                    if let error = error {
                        continuation.resume(returning: false)
                    } else {
                        continuation.resume(returning: true)
                    }
                }
            }
    }
    
    static func signinSilently() async throws -> Bool {
            return try await withCheckedThrowingContinuation { continuation in
                GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                    if let error = error {
                        signOut()
                        continuation.resume(returning: false)
                    } else if user != nil {
                        continuation.resume(returning: true)
                    } else {
                        signOut()
                        continuation.resume(returning: false)
                    }
                }
            }
        }
    
    static func signOut(){
        GIDSignIn.sharedInstance.signOut()
    }
}

