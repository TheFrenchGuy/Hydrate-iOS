//
//  Autofiller Name.swift
//  Hydrate (iOS)
//
//  Created by Noe De La Croix on 29/01/2021.
//

import Foundation
import SwiftUI

class Autofiller {
    
    enum NameComponent {
        case givenName
        case familyName
        case fullNameInCurrentPersonNameComponentsFormatterStyle
    }
    
    /// Proposes a localized name based on UIDevice.current.name (under the assumption that it contains a name).
    /// - Returns: A user's probable first, last, or full name — or a default if detection fails.
    ///
    /// Be aware that:
    /// * Non-name words may slip through
    /// ```
    /// Paul The Great // Paul the Great
    /// Paul's Really Old iPhone // Paul
    /// ```
    /// * This is only tested for romance languages and Chinese.
    /// * Chinese names return full name in `givenName` only mode. Options require uncommenting internal code.
    ///
    /// - Parameter name: Choose between given, family, and full name
    /// - Parameter style: Options for [PersonNameComponentsFormatter](https://developer.apple.com/documentation/foundation/personnamecomponentsformatter)
    /// - Parameter defaultUponFailure: Specify your default string should guessing fail
    func guessNameOfDeviceOwner(name: NameComponent,
                                style: PersonNameComponentsFormatter.Style = .default,
                                placeholderUponFailure: String = "Good Looking") -> String {
        
        let deviceName = UIDevice.current.name
        let nameFormatter = PersonNameComponentsFormatter()
        nameFormatter.style = style
        
        if let chineseName = extractNameComponentsInChinese(from: deviceName) {
            switch name {
            case .givenName:
                return nameFormatter.string(from: chineseName)
            // DEFAULT: RETURN FULL NAME (EVEN WHEN OTHER LANGUAGES RETURN GIVEN ONLY)
            // OPTION: CUTESY INFORMAL GIVEN NAME
            // if let givenName = chineseName.givenName {
            // return String("小").appending(givenName)
            case .familyName:
                if let familyName = chineseName.familyName {
                    return familyName
                }
            // OPTION: RESPECTFUL FAMILY NAME
            // if let familyName = chineseName.familyName {
            // return String("老").appending(familyName)
            case .fullNameInCurrentPersonNameComponentsFormatterStyle:
                return nameFormatter.string(from: chineseName)
            }
        }
        
        if let latinName = extractNameComponentsByPrefixOrSuffix(from: deviceName) {
            switch name {
            case .givenName:
                if let givenName = latinName.givenName {
                    return givenName
                }
            case .familyName:
                if let familyName = latinName.familyName {
                    return familyName
                }
            case .fullNameInCurrentPersonNameComponentsFormatterStyle:
                return nameFormatter.string(from: latinName)
            }
        }
        
        return placeholderUponFailure
    }
    
    /// Process common styles for English (Ryan's iPhone), Swedish (Ryan iPhone), French (iPhone de Ryan)
    private func extractNameComponentsByPrefixOrSuffix(from input: String) -> PersonNameComponents? {
        let formatter = PersonNameComponentsFormatter()
        
        let prefixes = ["iPhone de ",
                        "iPad de ",
                        "iPod de "
        ]
        
        for prefix in prefixes {
            guard input.contains(prefix) else { continue }
            var inputComponents = input.components(separatedBy: prefix)
            // First element is either empty or assumed to be extraneous
            inputComponents.removeFirst()
            let possibleName = inputComponents.joined()
            // Note: .personNameComponents(from:) will ignore brackets, parentheses
            guard let nameComponents = formatter.personNameComponents(from: possibleName) else { return nil }
            return nameComponents
        }
        
        let suffixes = ["'s iPhone",
                        "'s iPad'",
                        "'s iPod",
                        "'s ", // Capture if user removed "i" or has a descriptor (e.g., Paul's Really Old iPhone)
                        "iPhone", // For Swedish style, reached if posessive language not present
                        "iPad",
                        "iPod",
                        "Phone", // Latter iterations, if reached, cover an edge case like me, a nerd who named his phone "RyPhone"
                        "Pad",
                        "Pod"
        ]
        
        for suffix in suffixes {
            guard input.contains(suffix) else { continue }
            var inputComponents = input.components(separatedBy: suffix)
            
            // The last component is either emptty, contains the model (e.g., "XS"), or duplicate device number (e.g., "(2)")
            inputComponents.removeLast()
            let possibleName = inputComponents.joined()
            guard let nameComponents = formatter.personNameComponents(from: possibleName) else { return nil }
            return nameComponents
        }
        
        // If no prefix/suffix matches, attempt to parse a name. Otherwise return nil to indicate failure.
        guard let possibleName = formatter.personNameComponents(from: input) else { return nil }
        return possibleName
    }
    
    /// Process for Chinese name apart from neighboring English (e.g., "某人的iPhone")
    private func extractNameComponentsInChinese(from input: String) -> PersonNameComponents? {
        guard let range = input.range(of: "\\p{Han}*\\p{Han}", options: .regularExpression) else { return nil }
        // Extract of only Chinese characters, ignoring "iPhone" etc
        var possibleName = input[range]
        // Remove possible instance of "cell phone"
        possibleName = Substring(String(possibleName).replacingOccurrences(of: "手机", with: ""))
        // Remove possible posessive referring to iPhone or cell phone
        if possibleName.last == "的" { possibleName.removeLast(1) }
        let formatter = PersonNameComponentsFormatter()
        guard let nameComponents = formatter.personNameComponents(from: String(possibleName)) else { return nil }
        return nameComponents
    }
}
