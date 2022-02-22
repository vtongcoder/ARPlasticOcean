//
//  AppStateController.swift
//  arplasticocean
//
//  Created by Yasuhito NAGATOMO on 2022/02/22.
//

import Foundation
import SwiftUI

struct CleanupMedal {
    let level: Int      // [1, 2, 3, 4]
    let count: Int      // [10, 20, 30, 100]
    let imageName: String
}

@MainActor
class AppStateController: ObservableObject {
    @AppStorage("savedCleanupCount") private var savedCleanupCount = 0
    @Published private(set) var cleanupCount = 0

    @Published var isSoundEnable = true

    var cleanupMedal: CleanupMedal? {
        var medal: CleanupMedal?
        if cleanupCount >= 100 {
            medal = CleanupMedal(level: 4, count: 100, imageName: "medal100")
        } else if cleanupCount >= 30 {
            medal = CleanupMedal(level: 3, count: 30, imageName: "medal30")
        } else if cleanupCount >= 20 {
            medal = CleanupMedal(level: 2, count: 20, imageName: "medal20")
        } else if cleanupCount >= 10 {
            medal = CleanupMedal(level: 1, count: 10, imageName: "medal10")
        }
        return medal
    }

    init() {
        cleanupCount = savedCleanupCount
    }

    /// Increment the cleanup count.
    func incrementCleanupCount() {
        setCleanupCount(cleanupCount + 1)
    }

    /// Set the cleanup count.
    /// - Parameter count: clean up count [0...]
    ///
    /// The new cleanup count will be stored into the UserDefaults.
    func setCleanupCount(_ count: Int) {
        assert(count >= 0)
        if count != cleanupCount {
            debugLog("cleanupCount will be changed from \(cleanupCount) to \(count).")
            cleanupCount = count
            savedCleanupCount = count // Save it into the UserDefaults.
        } else {
            // swiftlint:disable line_length
            debugLog("setCleanupCount(\(count)) was called but the value is same as the current value. So it was just ignored.")
        }
    }
}
