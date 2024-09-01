import SwiftUI
import ComposableArchitecture

@Reducer
public struct Content {
    @ObservableState
    public struct State: Equatable {
        @Shared var items: IdentifiedArrayOf<Item>
        var selectedItemIDs: Set<Item.ID> = []
        
        var multiSingleSelection: MultiSingleSelectionContent.State?
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case multiSingleSelection(MultiSingleSelectionContent.Action)
    }
    
    public var body: some Reducer<State, Action> {
        BindingReducer()
            .onChange(of: \.selectedItemIDs) { oldValue, newValue in
                Reduce { state, action in
                    if newValue.isEmpty {
                        state.multiSingleSelection = nil
                        return .none
                    }
                    else if newValue.count == 1 {
                        guard let id = newValue.first,
                              let itemSelected = state.items[id: id] else {
                            return .none
                        }
                        state.multiSingleSelection = .single(.init(item: itemSelected))
                    } else {
                        let itemsSelected = state.selectedItemIDs.compactMap { state.items[id: $0] }
                        state.multiSingleSelection = .multi(.init(items: itemsSelected))
                    }
                    return .none
                }
            }
        Reduce<State, Action> { state, action in
            switch action {
            case .binding:
                return .none
            case .multiSingleSelection:
                return .none
            }
        }
    }
}

struct ContentView: View {
    @Bindable var store: StoreOf<Content>
    
    var body: some View {
        HStack {
            List(selection: $store.selectedItemIDs) {
                ForEach(store.items) { item in
                    Text(item.title)
                        .tag(item.id)
                        .contentShape(Rectangle())
                }
            }
//            .frame(maxWidth: 120)
            
            if let multiSingleSelectionStore = store.scope(state: \.multiSingleSelection, action: \.multiSingleSelection) {
                MultiSingleSelectionContentView(store: multiSingleSelectionStore)
            } else {
                Text("Select an item")
            }
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
            case .single(let action):
                return .none
            case .multi(let action):
                return .none
            }
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
        var item: Item
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

