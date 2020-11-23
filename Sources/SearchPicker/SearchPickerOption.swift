// Copyright © 2020 Sofic. All rights reserved.

/// A protocol used  within the `SearchPicker`.
/// This protocol defines the API for the options.
/// `Identifiable` allows the options to be  organized
/// efficiently in a list.
/// The property `optionDescription` is used as the detail text
/// when an option is selected.
public protocol SearchPickerOption: Identifiable {
    
    /// The description of the option shown in the picker.
    var optionDescription: String { get }
}
