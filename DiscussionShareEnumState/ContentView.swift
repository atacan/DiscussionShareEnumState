import SwiftUI
import ComposableArchitecture

@Reducer
public struct Content {
    @Reducer
    public enum Destination {
        case single(SingleItemContent)
        case multi(MultiItemContent)
    }
    
    @ObservableState
    public struct State {
        @Presents var destination: Destination.State?
        
        @Shared var items: IdentifiedArrayOf<Item>
        var selectedItemIDs: Set<Item.ID> = []
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .binding(\.selectedItemIDs):
                if state.selectedItemIDs.isEmpty {
                    state.destination = nil
                    return .none
                }
                else if state.selectedItemIDs.count == 1 {
                    guard let id = state.selectedItemIDs.first,
                          var itemSelected = state.items[id: id]
                    else {
                        return .none
                    }
                    state.destination = .single(.init(item: Shared(itemSelected)))
                } else {
                    let itemsSelected = state.selectedItemIDs.compactMap { state.items[id: $0] }
                    state.destination = .multi(.init(items: itemsSelected))
                }
                return .none
                
            case .binding:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct ContentView: View {
    @Bindable var store: StoreOf<Content>
    
    var body: some View {
        HStack {
            List(selection: $store.selectedItemIDs) {
                ForEach(store.$items.elements) { $item in
                    Text(item.title)
                        .tag(item.id)
                        .contentShape(Rectangle())
                }
            }
            .frame(maxWidth: 150)
            
//            if let destination = store[KeyPath<Content.State, Content.Destination.State?>]  {
                switch store.destination {
                case .single:
//                    SingleItemContentView(store: store.scope(
//                        state: \.destination,
//                        action: \.destination.single))
                    EmptyView()
                case .multi:
                    EmptyView()
                case .none:
                    EmptyView()
                }
//            }
            
            
            Spacer()
        }
        .padding()
    }
}

@Reducer
public struct MultiSingleSelectionContent {
    @ObservableState
    public enum State: Equatable {
        case single(SingleItemContent.State)
        case multi(MultiItemContent.State)
    }
    
    public enum Action {
        case single(SingleItemContent.Action)
        case multi(MultiItemContent.Action)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .single:
                return .none
            case .multi:
                return .none
            }
        }
        .ifCaseLet(\.single, action: \.single) {
            SingleItemContent()
        }
        .ifCaseLet(\.multi, action: \.multi) {
            MultiItemContent()
        }
    }
}

struct MultiSingleSelectionContentView: View {
    @Bindable var store: StoreOf<MultiSingleSelectionContent>
    
    var body: some View {
        switch store.state {
        case .single:
            if let store = store.scope(state: \.single, action: \.single) {
                SingleItemContentView(store: store)
            }
        case .multi:
            if let store = store.scope(state: \.multi, action: \.multi) {
                MultiItemContentView(store: store)
            }
        }
        
    }
}

@Reducer
public struct SingleItemContent {
    @ObservableState
    public struct State: Equatable {
        @Shared var item: Item
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case buttonTouched
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
            case .buttonTouched:
                return .none
            }
        }
    }
}

@Reducer
public struct MultiItemContent {
    @ObservableState
    public struct State: Equatable {
        var items: [Item]
    }
    
    public enum Action {
        case buttonTouched
    }
    
    public var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .buttonTouched:
                return .none
            }
        }
    }
}

struct MultiItemContentView: View {
    @Bindable var store: StoreOf<MultiItemContent>
    
    var body: some View {
        VStack {
            ForEach(store.items) { item in
                Text(item.title)
            }
        }
    }
}

struct SingleItemContentView: View {
    @Bindable var store: StoreOf<SingleItemContent>
    var body: some View {
        VStack{
            TextField("Item", text: $store.item.title)
            Button("Button") {
                store.send(.buttonTouched)
            }
        }
    }
}

public struct Item: Identifiable, Equatable {
    public var id: UUID = .init()
    public var title: String
}

extension IdentifiedArray where Element == Item, ID == Item.ID {
    public static let mock = IdentifiedArray(uniqueElements: [
        Item(title: "Item 1"),
        Item(title: "Item 2"),
        Item(title: "Item 3"),
        Item(title: "Item 4"),
        Item(title: "Item 5"),
    ])
}

#Preview {
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

