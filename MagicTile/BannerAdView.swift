//
//  BannerAdView.swift
//  MagicTile
//
//  A small AdMob banner, wrapped for SwiftUI.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = AdConfig.bannerUnitID
        banner.rootViewController = rootViewController()
        banner.load(GADRequest())
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // Nothing to update.
    }
    
    private func rootViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .first { $0.activationState == .foregroundActive } as? UIWindowScene
        return scene?.windows.first(where: { $0.isKeyWindow })?.rootViewController
    }
    
}
