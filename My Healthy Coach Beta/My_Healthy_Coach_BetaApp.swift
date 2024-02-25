

import SwiftUI

@main
struct My_Healthy_Coach_BetaApp: App {
    var body: some Scene {
        WindowGroup {
            let tDate = Dates()
            ContentView().environmentObject(tDate)
        }
    }
}
