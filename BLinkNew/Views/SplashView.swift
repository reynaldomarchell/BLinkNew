//
//  SplashView.swift
//  BLink
//
//  Created by reynaldo on 27/03/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    
    var body: some View {
        if isActive {
            // Check if this is the first launch
            if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
                // Not first launch, go directly to HomeView
                HomeView()
            } else {
                // First launch, show tutorial
                TutorialView()
            }
        } else {
            VStack(spacing: 10) {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 250, height: 250)
                    .cornerRadius(24)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.8)) {
                            logoScale = 1.0
                            logoOpacity = 1.0
                        }
                        // Transition after animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation {
                                self.isActive = true
                            }
                        }
                    }
                //                        .onAppear {
                //                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //                                withAnimation {
                //                                    self.isActive = true
                //                                }
            }
        }
        
    }
}

#Preview {
    SplashView()
}
