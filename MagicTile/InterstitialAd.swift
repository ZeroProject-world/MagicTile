//
//  InterstitialAd.swift
//  MagicTile
//
//  Preloads one full-screen AdMob interstitial and shows it on demand
//  (used when a game ends). Reloads a fresh ad after every show.
//

import GoogleMobileAds
import UIKit

final class InterstitialAd: NSObject, GADFullScreenContentDelegate {
    
    static let shared = InterstitialAd()
    
    private var ad: GADInterstitialAd?
    
    private override init() {
        super.init()
        load()
    }
    
    func load() {
        GADInterstitialAd.load(withAdUnitID: AdConfig.interstitialUnitID,
                               request: GADRequest()) { [weak self] ad, error in
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
        ad.present(fromRootViewController: root)
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
    
    // MARK: - GADFullScreenContentDelegate
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.ad = nil
        load()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        self.ad = nil
        load()
    }
    
}
