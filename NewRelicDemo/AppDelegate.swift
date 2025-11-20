//
//  AppDelegate.swift
//  NewRelicDemo
//
//  Created by Anna Shabalina on 11/19/2025.
//

import UIKit
import OSLog
import NewRelic

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configureNewRelic()
        return true
    }

    private func configureNewRelic() {
        // Read optional environment variable to disable specific features without code changes.
        // Example: NR_DISABLE_FLAGS=DefaultInteractions,InteractionTracing,AutoCollectLogs
            let env = ProcessInfo.processInfo.environment["NR_DISABLE_FLAGS"] ?? ""
            let requested = Set(env.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
            var flags: NRMAFeatureFlags = []
            if requested.contains("DefaultInteractions") { flags.insert(.NRFeatureFlag_DefaultInteractions) }
            if requested.contains("InteractionTracing") { flags.insert(.NRFeatureFlag_InteractionTracing) }
            if requested.contains("AutoCollectLogs") { flags.insert(.NRFeatureFlag_AutoCollectLogs) }
            if !flags.isEmpty {
                NewRelic.disableFeatures(flags)
                Logger.performance.info("🔧 Disabled NR features: \(requested.joined(separator: ","))")
            } else {
                Logger.performance.info("🔧 New Relic running with all features enabled")
            }
            Logger.performance.info("🚀 Starting New Relic Agent (version set via SPM)")
            NewRelic.start(withApplicationToken: "YOUR_API_KEY")
            Logger.performance.info("✅ New Relic Agent started")
    }
}

// Central OSLog for performance metrics.
extension Logger {
    static let performance = Logger(subsystem: "com.cincas.NewRelicDemo", category: "perf")
}
