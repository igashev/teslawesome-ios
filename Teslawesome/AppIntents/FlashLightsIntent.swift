//
//  FlashLightsIntent.swift
//  Teslawesome
//
//  Created by Ivaylo Gashev on 13.10.22.
//

import Foundation
import AppIntents

struct FlashLightsIntent: AppIntent {
    static var title: LocalizedStringResource = "Flash Tesla lights"
    
    func perform() async throws -> some IntentResult & ProvidesDialog {
        print("Coool")
        return .result(dialog: "Ok COOl!")
    }
}

struct TeslaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        print(AppShortcutPhraseToken.applicationName)
        return [
            .init(
                intent: FlashLightsIntent(),
                phrases: ["car lights", "Tesla lights on"],
                shortTitle: "Cool stuff",
                systemImageName: "pencil"
            )
        ]
    }
}
