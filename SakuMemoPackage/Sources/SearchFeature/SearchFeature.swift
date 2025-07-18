import ComposableArchitecture
import Foundation
import RepositoryProtocol
import SharedModel

@Reducer
public struct SearchFeature: Sendable {
    public init() {}

    @ObservableState
    public struct State: Sendable {
        public init() {}

        var searchText: String = ""
        var filteredMemos: [MemoSendable] = []
        var selectedCategory: String = "すべて"
        var selectedPriority: PriorityFilter = .all
        var isLoading: Bool = false
        var showFilterSheet: Bool = false

        let categories = ["すべて", "買い物", "todo", "やりたいこと"]
    }

    public enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
        case searchTextChanged(String)
        case categoryChanged(String)
        case priorityChanged(PriorityFilter)
        case showFilterSheet(Bool)
        case memosLoaded([MemoSendable])
        case clearSearch
    }

    @Dependency(\.swiftDataRepository) var swiftDataRepository

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .onAppear:
                return loadMemos()

            case let .searchTextChanged(text):
                state.searchText = text
                return filterMemos(state: &state)

            case let .categoryChanged(category):
                state.selectedCategory = category
                return filterMemos(state: &state)

            case let .priorityChanged(priority):
                state.selectedPriority = priority
                return filterMemos(state: &state)

            case let .showFilterSheet(show):
                state.showFilterSheet = show
                return .none

            case let .memosLoaded(memos):
                state.filteredMemos = memos
                return filterMemos(state: &state)

            case .clearSearch:
                state.searchText = ""
                state.selectedCategory = "すべて"
                state.selectedPriority = .all
                return filterMemos(state: &state)
            }
        }
    }

    private func loadMemos() -> Effect<Action> {
        .run { send in
            let memos = try await swiftDataRepository.fetchMemos()
            await send(.memosLoaded(memos))
        }
    }

    private func filterMemos(state: inout State) -> Effect<Action> {
        .run { [state] send in
            let memos = try await swiftDataRepository.fetchMemos()
            let filtered = memos.filter { memo in
                let matchesSearch = state.searchText.isEmpty ||
                    memo.text.lowercased().contains(state.searchText.lowercased())

                let matchesCategory = state.selectedCategory == "すべて" ||
                    memo.category == state.selectedCategory

                let matchesPriority = state.selectedPriority.matches(memo.priorityValue)

                return matchesSearch && matchesCategory && matchesPriority
            }

            await send(.memosLoaded(filtered))
        }
    }
}

public enum PriorityFilter: String, CaseIterable, Sendable {
    case all = "すべて"
    case high = "高優先度"
    case medium = "中優先度"
    case low = "低優先度"

    func matches(_ priority: Double) -> Bool {
        switch self {
        case .all:
            return true

        case .high:
            return priority >= 0.7

        case .medium:
            return priority >= 0.3 && priority < 0.7

        case .low:
            return priority < 0.3
        }
    }
}
