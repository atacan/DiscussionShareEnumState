//
// https://github.com/atacan
// 01.09.24
	

import SwiftUI
import ComposableArchitecture

@main
struct DiscussionShareEnumStateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(
                    initialState: Content.State(
                        items: Shared(.mock)
                    ), reducer: {
                        Content()
                    }
                )
            )
        }
    }
}
