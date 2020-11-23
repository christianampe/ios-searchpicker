// Copyright © 2020 Sofic. All rights reserved.

import Combine
import SwiftUI

/// A view  representing a picker with a search bar.
public struct SearchPicker<Option: SearchPickerOption, Content: View>: View {
    private let title: String
    @Binding var selection: Option?
    @Binding var search: String
    @Binding var options: [Option]
    @State private var isPresentingPicker = false
    private let placeholder: String?
    private let onPickerPresentation: (() -> Void)?
    private let content: ((Option) -> Content)
    
    /// Primary initializer used to construct the `SearchPicker`.
    ///
    /// The picker options must conform to the protocol `SearchPickerOption` which requires
    /// the option contain a property `optionTitle`
    ///
    ///     var optionTitle: String { get }
    ///
    /// which will be used as the detail text for the picker.
    ///
    /// - Parameters:
    ///   - title: Primary text of the picker.
    ///   - selection: Currently selected option of the picker.
    ///   - search: Text entered in the search bar
    ///   - options: Current options presented in the picker.
    ///   - placeholder: Text placeholder shown in search bar.
    ///   - isPresentingPicker: Flag dictating the presentation state of the picker.
    ///   - onPickerPresentation: Closure called when the picker is presented.
    ///   - content: `ViewBuilder` for creating custom picker rows.
    public init(title: String,
                selection: Binding<Option?>,
                search: Binding<String>,
                options: Binding<[Option]>,
                placeholder: String? = nil,
                isPresentingPicker: Bool = false,
                onPickerPresentation: (() -> Void)? = nil,
                @ViewBuilder content: @escaping (Option) -> Content) {
        self.title = title
        self._search = search
        self._selection = selection
        self._options = options
        self.placeholder = placeholder
        self.onPickerPresentation = onPickerPresentation
        self.content = content
    }
    
    public var body: some View {
        Button {
            isPresentingPicker.toggle()
            onPickerPresentation?()
        } label: {
            HStack {
                Text(title)
                Spacer()
                if let selection = selection {
                    Text(selection.optionDescription)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .sheet(isPresented: $isPresentingPicker) {
            List {
                Section(header: SearchBar(text: $search, placeholder: placeholder)) {
                    ForEach(options) { option in
                        Button {
                            selection = option
                            isPresentingPicker = false
                        } label: {
                            content(option)
                        }
                    }
                }
            }
        }
    }
}

struct SearchPicker_Previews: PreviewProvider {
    
    // MARK: - Preview Definition
    
    static var previews: some View {
        NavigationView {
            UserSearchPicker()
                .navigationBarTitle("New Event")
                .environmentObject(Controller())
        }
    }
    
    // MARK: - Sample Search Picker Interface
    
    struct UserSearchPicker: View {
        @EnvironmentObject private var controller: Controller
        
        var body: some View {
            Form {
                SearchPicker(
                    title: "Select User",
                    selection: $controller.selection,
                    search: $controller.search,
                    options: $controller.options,
                    placeholder: "Enter name...",
                    onPickerPresentation: {}
                ) { option in
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle")
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .font(.title)
                        VStack(alignment: .leading) {
                            Text(option.name)
                                .font(.headline)
                            Text(option.description)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
        }
    }
    
    // MARK: - Sample Search Picker Option Model
    
    struct Option: SearchPickerOption {
        let id: String
        let name: String
        let description: String
        
        var optionDescription: String {
            name
        }
    }
    
    // MARK: - Sample Search Picker Controller
    
    final class Controller: ObservableObject {
        @Published var search = ""
        @Published var selection: Option?
        @Published var options = [Option]()
        private var allOptions = [Option]()
        private var bag = Set<AnyCancellable>()
        
        init() {
            options = users
            allOptions = users
            $search
                .receive(on: RunLoop.main)
                .sink { query in
                    self.options = query.isEmpty
                        ? self.allOptions
                        : self.allOptions.filter { $0.name.localizedCaseInsensitiveContains(query) }
                }
                .store(in: &bag)
        }
    }
    
    // MARK: - Sample Search Picker Option Data
    
    static let users: [Option] = [
        .init(id: "0", name: "John Smith", description: "Lorem ipsum dolor sit amet"),
        .init(id: "1", name: "Mary Kim", description: "Lorem ipsum dolor sit amet"),
        .init(id: "2", name: "James Appleseed", description: "Lorem ipsum dolor sit amet"),
        .init(id: "3", name: "Linda Cook", description: "Lorem ipsum dolor sit amet"),
        .init(id: "4", name: "Sarah Adams", description: "Lorem ipsum dolor sit amet"),
        .init(id: "5", name: "Thomas Booker", description: "Lorem ipsum dolor sit amet")
    ]
}
