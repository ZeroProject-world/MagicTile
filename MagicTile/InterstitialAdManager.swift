//
//  InterstitialAdManager.swift
//  MagicTile
//
//  Preloads one full-screen AdMob interstitial and shows it on demand
//  (used when a game ends). Reloads a fresh ad after every show.
//

import GoogleMobileAds
import UIKit

final class InterstitialAdManager: NSObject, FullScreenContentDelegate {
    
    static let shared = InterstitialAdManager()
    
    private var ad: InterstitialAd?
    
    private override init() {
        super.init()
        load()
    }
    
    func load() {
        InterstitialAd.load(with: AdConfig.interstitialUnitID,
                            request: Request()) { [weak self] ad, error in
            if let error = error {
                print("Interstitial failed to load: \(error.localizedDescription)")
                return
            }
            self?.ad = ad
            self?.ad?.fullScreenContentDelegate = self
        }
    }
    
    func show() {
        guard let ad = ad, let root = topViewController() else {
            load()  // Not ready yet — prepare one for next time.
            return
        }
        ad.present(from: root)
    }
    
    private func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
        var controller = scene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
        while let presented = controller?.presentedViewController {
            controller = presented
        }
        return controller
    }
    
    // MARK: - FullScreenContentDelegate
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        self.ad = nil
        load()
    }
    
    func ad(_ ad: FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        self.ad = nil
        load()
    }
    
}
