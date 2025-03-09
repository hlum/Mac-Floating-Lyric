//
//  Rabbit.swift
//  Lyrics
//
//  Created by Hlwan Aung Phyo on 2025/03/09.
//

import Foundation


//
//  Rabbit.swift
//  Rabbit
//
//  Created by Saturngod on 27/1/15.
//  Copyright (c) 2015 comquas. All rights reserved.
//

public struct Rabbit {
    
    public static func isZawgyiV2(_ text: String) -> Bool {
        // Define a regex pattern for Zawgyi characters (non-standard Unicode characters)
        let zawgyiPattern = "[\u{1039}\u{1040}-\u{1049}\u{104E}\u{1050}-\u{1057}\u{1060}-\u{1069}]"
        
        // Create a regular expression from the pattern
        let regex = try! NSRegularExpression(pattern: zawgyiPattern)
        
        // Perform the search
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = regex.matches(in: text, options: [], range: range)
        
        // If any match is found, it is likely Zawgyi encoded
        return !matches.isEmpty
    }
    
    public static func isZawgyi(_ text: String) -> Bool {
        // If empty, return false
        if text.isEmpty {
            return false
        }
        
        // Check for Myanmar characters first to avoid unnecessary processing
        let myanmarDetectionRegex = try? NSRegularExpression(pattern: "[\u{1000}-\u{109F}\u{AA60}-\u{AA7F}]", options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if let matches = myanmarDetectionRegex?.matches(in: text, options: [], range: range), matches.isEmpty {
            return false // No Myanmar characters, so not Zawgyi
        }
        
        // Calculate Myanmar character ratio - if too low, likely mixed text which is harder to classify
        let myanmarCharCount = myanmarDetectionRegex?.numberOfMatches(in: text, options: [], range: range) ?? 0
        let myanmarRatio = Double(myanmarCharCount) / Double(text.count)
        
        // For very small Myanmar text fragments, require stronger evidence
        let requiresStrongerEvidence = myanmarRatio < 0.5 && myanmarCharCount < 10
        
        // Detect character combinations highly specific to Zawgyi (high confidence patterns)
        let zawgyiHighConfidencePatterns = [
            // Zawgyi-specific characters that never appear in Unicode
            "[\u{1060}-\u{1063}\u{1065}-\u{1069}\u{106C}-\u{106D}\u{1070}-\u{107C}\u{1085}-\u{1086}\u{108E}]",
            
            // Zawgyi specific medial Ra forms
            "[\u{107E}-\u{1084}]",
            
            // Incorrect ordering that's Zawgyi-specific
            "\u{1031}[\u{1000}-\u{1021}]\u{103b}",   // Vowel E + consonant + medial Ra (wrong order)
            "\u{1031}\u{1039}[\u{1000}-\u{1021}]",   // Vowel E + virama + consonant (wrong order)
            "\u{1037}\u{103a}",                      // Dot below + asat (wrong order)
            
            // Specific character combinations only in Zawgyi
            "[\u{1000}-\u{1021}]\u{108B}",          // Consonant + kinzi forms
            "[\u{1000}-\u{1021}]\u{108C}",
            "[\u{1000}-\u{1021}]\u{108D}",
            
            // Zawgyi-specific sequence patterns
            "\u{103d}\u{103c}",                     // Medial wa + medial ya (wrong order)
            "\u{103a}\u{103c}",                     // Asat + medial ya (wrong order)
            
            // Specific Zawgyi abbreviations and usage patterns
            "[\u{1000}-\u{1021}]\u{1064}\u{1039}",  // Consonant + specific Zawgyi pattern
        ]
        
        // Medium confidence Zawgyi patterns (common but not definitive)
        let zawgyiMediumConfidencePatterns = [
            // Common medial combinations in Zawgyi
            "[\u{103b}\u{107e}-\u{1084}][\u{1000}-\u{1021}]", // Medial Ra before consonant (wrong order)
            "\u{1031}[\u{107e}-\u{1084}][\u{1000}-\u{1021}]", // E + medial Ra variant + consonant
            "\u{1031}\u{1037}\u{103a}",             // E + dot below + asat (wrong ordering)
            
            // Stacked consonant patterns in Zawgyi
            "\u{1039}[\u{1060}-\u{1063}]",          // Virama + specific Zawgyi characters
            "[\u{1060}-\u{1063}]\u{1039}",          // Specific Zawgyi characters + virama
            
            // Multiple consonant patterns
            "[\u{1000}-\u{1021}]\u{1060}",          // Base character + specific Zawgyi medial
            "[\u{1000}-\u{1021}]\u{1061}",
            
            // Kinzi patterns in Zawgyi
            "\u{1064}[\u{103b}\u{107e}-\u{1084}]",  // Kinzi + medial Ra
            "\u{1064}\u{103a}",                     // Kinzi + asat
            
            // Visarga patterns
            "\u{1038}[\u{103b}\u{107e}-\u{1084}]",  // Visarga + medial Ra
            "\u{1038}\u{103a}",                     // Visarga + asat
        ]
        
        // Lower confidence patterns that appear in Zawgyi but might have false positives
        let zawgyiLowerConfidencePatterns = [
            "\u{1031}\u{1037}",                     // E + dot below (can exist in some Unicode texts)
            "\u{1039}[\u{1091}-\u{1094}]",          // Virama + specific Zawgyi characters
            "[\u{1000}-\u{1021}][\u{108F}\u{1090}]", // Base + specific Zawgyi characters
            "\u{108f}[\u{1000}-\u{1021}]",          // Specific character + base (wrong order)
            "\u{1039}\u{107a}",                     // Virama + specific Zawgyi character
        ]
        
        // Check for high confidence patterns first
        let highConfidencePattern = zawgyiHighConfidencePatterns.joined(separator: "|")
        let highConfidenceRegex = try? NSRegularExpression(pattern: highConfidencePattern, options: [])
        
        if let matches = highConfidenceRegex?.matches(in: text, options: [], range: range), !matches.isEmpty {
            // Found high confidence patterns, very likely Zawgyi
            return true
        }
        
        // Check for medium confidence patterns
        let mediumConfidencePattern = zawgyiMediumConfidencePatterns.joined(separator: "|")
        let mediumConfidenceRegex = try? NSRegularExpression(pattern: mediumConfidencePattern, options: [])
        
        if let matches = mediumConfidenceRegex?.matches(in: text, options: [], range: range) {
            if !matches.isEmpty {
                // For regular text, medium confidence is enough
                if !requiresStrongerEvidence {
                    return true
                }
                
                // For text requiring stronger evidence, count instances
                if matches.count >= 2 {
                    return true
                }
            }
        }
        
        // For text not requiring stronger evidence, check lower confidence patterns
        if !requiresStrongerEvidence {
            let lowerConfidencePattern = zawgyiLowerConfidencePatterns.joined(separator: "|")
            let lowerConfidenceRegex = try? NSRegularExpression(pattern: lowerConfidencePattern, options: [])
            
            if let matches = lowerConfidenceRegex?.matches(in: text, options: [], range: range), !matches.isEmpty {
                // Check for Unicode counterevidence before concluding
                if !hasUnicodeCounterEvidence(text: text, range: range) {
                    return true
                }
            }
        }
        
        // Check character frequency heuristics as a fallback
        return characterFrequencyHeuristic(text: text, range: range, requiresStrongerEvidence: requiresStrongerEvidence)
    }

    private static func hasUnicodeCounterEvidence(text: String, range: NSRange) -> Bool {
        let unicodeSpecificPatterns = [
            "[\u{1000}-\u{1021}]\u{103c}\u{103d}\u{103e}",
            "[\u{1000}-\u{1021}]\u{103b}\u{103c}\u{103d}",
            "[\u{1000}-\u{1021}]\u{103b}\u{103c}",
            "[\u{1000}-\u{1021}]\u{103c}\u{103d}",
            "\u{103c}\u{103d}",
            "\u{103b}\u{103c}",
            "\u{1004}\u{103a}\u{1039}",
            "[\u{1000}-\u{1021}]\u{103c}\u{1031}",
            "[\u{1000}-\u{1021}]\u{1039}[\u{1000}-\u{1021}]\u{103c}"
        ]
        
        let pattern = unicodeSpecificPatterns.joined(separator: "|")
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        if let matches = regex?.matches(in: text, options: [], range: range), !matches.isEmpty {
            return true
        }
        
        return false
    }


    // Helper function that uses character frequency analysis
    private static func characterFrequencyHeuristic(text: String, range: NSRange, requiresStrongerEvidence: Bool) -> Bool {
        // Extended Zawgyi indicator characters (includes all significant Zawgyi-specific forms)
        let zawgyiIndicatorChars = try? NSRegularExpression(pattern: "[\u{1031}\u{103b}\u{107e}-\u{1084}\u{1064}\u{1065}-\u{1069}\u{106c}-\u{107d}\u{1085}-\u{108a}\u{108e}-\u{1097}]", options: [])
        
        // Unicode Myanmar-specific characters and sequences
        let unicodeIndicatorChars = try? NSRegularExpression(pattern: "[\u{1000}-\u{1021}]\u{103c}|[\u{103c}\u{103d}\u{103e}]", options: [])
        
        var zawgyiIndicatorCount = 0
        var unicodeIndicatorCount = 0
        
        if let matches = zawgyiIndicatorChars?.matches(in: text, options: [], range: range) {
            zawgyiIndicatorCount = matches.count
        }
        
        if let matches = unicodeIndicatorChars?.matches(in: text, options: [], range: range) {
            unicodeIndicatorCount = matches.count
        }
        
        // Total Myanmar character count for normalization
        let myanmarDetectionRegex = try? NSRegularExpression(pattern: "[\u{1000}-\u{109F}\u{AA60}-\u{AA7F}]", options: [])
        let totalMyanmarChars = myanmarDetectionRegex?.numberOfMatches(in: text, options: [], range: range) ?? 1
        
        // Normalize counts by Myanmar character count
        let zawgyiRatio = Double(zawgyiIndicatorCount) / Double(totalMyanmarChars)
        let unicodeRatio = Double(unicodeIndicatorCount) / Double(totalMyanmarChars)
        
        // If strong evidence is required (for short or mixed texts)
        if requiresStrongerEvidence {
            // Need significantly more Zawgyi indicators than Unicode
            return zawgyiRatio > 0.2 && zawgyiRatio > unicodeRatio * 3
        } else {
            // For normal text, use a more relaxed threshold
            return zawgyiRatio > 0.15 && zawgyiRatio > unicodeRatio * 2
        }
    }
    
    public static func uni2zg(_ unicode:String) ->String {
        
        let json = """
        [ { "from": "\u{1004}\u{103a}\u{1039}", "to": "\u{1064}" }, { "from": "\u{1039}\u{1010}\u{103d}", "to": "\u{1096}" }, { "from": "\u{102b}\u{103a}", "to": "\u{105a}" }, { "from": "\u{102d}\u{1036}", "to": "\u{108e}" }, { "from": "\u{104e}\u{1004}\u{103a}\u{1038}", "to": "\u{104e}" }, { "from": "[\u{1025}\u{1009}](?=\u{1039})", "to": "\u{106a}" }, { "from": "\u{1009}(?=[\u{102f}\u{1030}])", "to": "\u{1025}" }, { "from": "[\u{1025}\u{1009}](?=[\u{1037}]?[\u{103a}])", "to": "\u{1025}" }, { "from": "\u{100a}(?=[\u{1039}\u{103d}])", "to": "\u{106b}" }, { "from": "(\u{1039}[\u{1000}-\u{1021}])(\u{102D}){0,1}\u{102f}", "to": "$1$2\u{1033}" }, { "from": "(\u{1039}[\u{1000}-\u{1021}])\u{1030}", "to": "$1\u{1034}" }, { "from": "\u{1014}(?=[\u{102d}\u{102e}\u{102f}\u{103A}]?[\u{1030}\u{103d}\u{103e}\u{102f}\u{1039}])", "to": "\u{108f}" }, { "from": "\u{1014}(?=\u{103A}\u{102F} )", "to": "\u{108f}" }, { "from" : "\u{1014}\u{103c}", "to" : "\u{108f}\u{103c}" }, { "from": "\u{1039}\u{1000}", "to": "\u{1060}" }, { "from": "\u{1039}\u{1001}", "to": "\u{1061}" }, { "from": "\u{1039}\u{1002}", "to": "\u{1062}" }, { "from": "\u{1039}\u{1003}", "to": "\u{1063}" }, { "from": "\u{1039}\u{1005}", "to": "\u{1065}" }, { "from": "\u{1039}\u{1006}", "to": "\u{1066}" }, { "from": "\u{1039}\u{1007}", "to": "\u{1068}" }, { "from": "\u{1039}\u{1008}", "to": "\u{1069}" }, { "from": "\u{1039}\u{100b}", "to": "\u{106c}" }, { "from": "\u{100b}\u{1039}\u{100c}", "to": "\u{1092}" }, { "from": "\u{1039}\u{100c}", "to": "\u{106d}" }, { "from": "\u{100d}\u{1039}\u{100d}", "to": "\u{106e}" }, { "from": "\u{100d}\u{1039}\u{100e}", "to": "\u{106f}" }, { "from": "\u{1039}\u{100f}", "to": "\u{1070}" }, { "from": "\u{1039}\u{1010}", "to": "\u{1071}" }, { "from": "\u{1039}\u{1011}", "to": "\u{1073}" }, { "from": "\u{1039}\u{1012}", "to": "\u{1075}" }, { "from": "\u{1039}\u{1013}", "to": "\u{1076}" }, { "from": "\u{1039}[\u{1014}\u{108f}]", "to": "\u{1077}" }, { "from": "\u{1039}\u{1015}", "to": "\u{1078}" }, { "from": "\u{1039}\u{1016}", "to": "\u{1079}" }, { "from": "\u{1039}\u{1017}", "to": "\u{107a}" }, { "from": "\u{1039}\u{1018}", "to": "\u{107b}" }, { "from": "\u{1039}\u{1019}", "to": "\u{107c}" }, { "from": "\u{1039}\u{101c}", "to": "\u{1085}" }, { "from": "\u{103f}", "to": "\u{1086}" }, { "from": "\u{103d}\u{103e}", "to": "\u{108a}" }, { "from": "(\u{1064})([\u{1000}-\u{1021}])([\u{103b}\u{103c}]?)\u{102d}", "to": "$2$3\u{108b}" }, { "from": "(\u{1064})([\u{1000}-\u{1021}])([\u{103b}\u{103c}]?)\u{102e}", "to": "$2$3\u{108c}" }, { "from": "(\u{1064})([\u{1000}-\u{1021}])([\u{103b}\u{103c}]?)\u{1036}", "to": "$2$3\u{108d}" }, { "from": "(\u{1064})([\u{1000}-\u{1021}\u{1040}-\u{1049}])([\u{103b}\u{103c}]?)([\u{1031}]?)", "to": "$2$3$4$1" }, { "from": "\u{101b}(?=([\u{102d}\u{102e}]?)[\u{102f}\u{1030}\u{103d}\u{108a}])", "to": "\u{1090}" }, { "from": "\u{100f}\u{1039}\u{100d}", "to": "\u{1091}" }, { "from": "\u{100b}\u{1039}\u{100b}", "to": "\u{1097}" }, { "from": "([\u{1000}-\u{1021}\u{108f}\u{1029}\u{106a}\u{106e}\u{106f}\u{1086}\u{1090}\u{1091}\u{1092}\u{1097}\u{1096}])([\u{1060}-\u{1069}\u{106c}\u{106d}\u{1070}-\u{107c}\u{1085}\u{108a}])?([\u{103b}-\u{103e}]*)?\u{1031}", "to": "\u{1031}$1$2$3" }, { "from": "\u{103c}\u{103e}", "to": "\u{103c}\u{1087}" }, { "from": "([\u{1000}-\u{1021}\u{108f}\u{1029}])([\u{1060}-\u{1069}\u{106c}\u{106d}\u{1070}-\u{107c}\u{1085}])?(\u{103c})", "to": "$3$1$2" }, { "from": "\u{103a}", "to": "\u{1039}" }, { "from": "\u{103b}", "to": "\u{103a}" }, { "from": "\u{103c}", "to": "\u{103b}" }, { "from": "\u{103d}", "to": "\u{103c}" }, { "from": "\u{103e}", "to": "\u{103d}" }, { "from": "([^\u{103a}\u{100a}])\u{103d}([\u{102d}\u{102e}]?)\u{102f}", "to": "$1\u{1088}$2" }, { "from": "([\u{101b}\u{103a}\u{103c}\u{108a}\u{1088}\u{1090}])([\u{1030}\u{103d}])?([\u{1032}\u{1036}\u{1039}\u{102d}\u{102e}\u{108b}\u{108c}\u{108d}\u{108e}]?)(\u{102f})?\u{1037}", "to": "$1$2$3$4\u{1095}" }, { "from": "([\u{102f}\u{1014}\u{1030}\u{103d}])([\u{1032}\u{1036}\u{1039}\u{102d}\u{102e}\u{108b}\u{108c}\u{108d}\u{108e}]?)\u{1037}", "to": "$1$2\u{1094}" }, { "from": "([\u{103b}])([\u{1000}-\u{1021}])([\u{1087}]?)([\u{1036}\u{102d}\u{102e}\u{108b}\u{108c}\u{108d}\u{108e}]?)\u{102f}", "to": "$1$2$3$4\u{1033}" }, { "from": "([\u{103b}])([\u{1000}-\u{1021}])([\u{1087}]?)([\u{1036}\u{102d}\u{102e}\u{108b}\u{108c}\u{108d}\u{108e}]?)\u{1030}", "to": "$1$2$3$4\u{1034}" }, { "from": "([\u{103a}\u{103c}\u{100a}\u{1008}\u{100b}\u{100c}\u{100d}\u{1020}\u{1025}])([\u{103d}]?)([\u{1036}\u{102d}\u{102e}\u{108b}\u{108c}\u{108d}\u{108e}]?)\u{102f}", "to": "$1$2$3\u{1033}" }, { "from": "([\u{103a}\u{103c}\u{100a}\u{1008}\u{100b}\u{100c}\u{100d}\u{1020}\u{1025}])(\u{103d}?)([\u{1036}\u{102d}\u{102e}\u{108b}\u{108c}\u{108d}\u{108e}]?)\u{1030}", "to": "$1$2$3\u{1034}" }, { "from": "([\u{100a}\u{1020}\u{1009}])\u{103d}", "to": "$1\u{1087}" }, { "from": "\u{103d}\u{1030}", "to": "\u{1089}" }, { "from": "\u{103b}([\u{1000}\u{1003}\u{1006}\u{100f}\u{1010}\u{1011}\u{1018}\u{101a}\u{101c}\u{101a}\u{101e}\u{101f}])", "to": "\u{107e}$1" }, { "from": "\u{107e}([\u{1000}\u{1003}\u{1006}\u{100f}\u{1010}\u{1011}\u{1018}\u{101a}\u{101c}\u{101a}\u{101e}\u{101f}])([\u{103c}\u{108a}])([\u{1032}\u{1036}\u{102d}\u{102e}\u{108b}\u{108c}\u{108d}\u{108e}])", "to": "\u{1084}$1$2$3" }, { "from": "\u{107e}([\u{1000}\u{1003}\u{1006}\u{100f}\u{1010}\u{1011}\u{1018}\u{101a}\u{101c}\u{101a}\u{101e}\u{101f}])([\u{103c}\u{108a}])", "to": "\u{1082}$1$2" }, { "from": "\u{107e}([\u{1000}\u{1003}\u{1006}\u{100f}\u{1010}\u{1011}\u{1018}\u{101a}\u{101c}\u{101a}\u{101e}\u{101f}])([\u{1033}\u{1034}]?)([\u{1032}\u{1036}\u{102d}\u{102e}\u{108b}\u{108c}\u{108d}\u{108e}])", "to": "\u{1080}$1$2$3" }, { "from": "\u{103b}([\u{1000}-\u{1021}])([\u{103c}\u{108a}])([\u{1032}\u{1036}\u{102d}\u{102e}\u{108b}\u{108c}\u{108d}\u{108e}])", "to": "\u{1083}$1$2$3" }, { "from": "\u{103b}([\u{1000}-\u{1021}])([\u{103c}\u{108a}])", "to": "\u{1081}$1$2" }, { "from": "\u{103b}([\u{1000}-\u{1021}])([\u{1033}\u{1034}]?)([\u{1032}\u{1036}\u{102d}\u{102e}\u{108b}\u{108c}\u{108d}\u{108e}])", "to": "\u{107f}$1$2$3" }, { "from": "\u{103a}\u{103d}", "to": "\u{103d}\u{103a}" }, { "from": "\u{103a}([\u{103c}\u{108a}])", "to": "$1\u{107d}" }, { "from": "([\u{1033}\u{1034}])(\u{1036}?)\u{1094}", "to": "$1$2\u{1095}" }, { "from": "\u{108F}\u{1071}", "to" : "\u{108F}\u{1072}" }, { "from": "\u{108F}\u{1073}", "to" : "\u{108F}\u{1074}" }, { "from": "([\u{1000}-\u{1021}])([\u{107B}\u{1066}])\u{102C}", "to": "$1\u{102C}$2" }, { "from": "\u{102C}([\u{107B}\u{1066}])\u{1037}", "to": "\u{102C}$1\u{1094}" }, { "from": "\u{1047}((?=[\u{1000}-\u{1021}]\u{1039})|(?=[\u{102c}-\u{1030}\u{1032}\u{1036}-\u{1038}\u{103c}\u{103d}]))", "to": "\u{101b}" }]
        """
        let data = json.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        let rule:NSArray = (try! JSONSerialization.jsonObject(with: data!, options: [])) as! NSArray
        
        return replaceRule(rule, original: unicode)
        
    }
    
    public static func zg2uni(_ zawgyi:String) ->String {
        
        let json = """
        [ { "from" : "([\u{102D}\u{102E}\u{103D}\u{102F}\u{1037}\u{1095}])\\\\1+", "to" : "$1" }, { "from": "\u{200B}", "to": "" }, { "from" : "\u{103d}\u{103c}", "to" : "\u{108a}" }, { "from": "(\u{103d}|\u{1087})", "to": "\u{103e}" }, { "from": "\u{103c}", "to": "\u{103d}" }, { "from": "(\u{103b}|\u{107e}|\u{107f}|\u{1080}|\u{1081}|\u{1082}|\u{1083}|\u{1084})", "to": "\u{103c}" }, { "from": "(\u{103a}|\u{107d})", "to": "\u{103b}" }, { "from": "\u{1039}", "to": "\u{103a}" }, { "from": "(\u{1066}|\u{1067})", "to": "\u{1039}\u{1006}" }, { "from": "\u{106a}", "to": "\u{1009}" }, { "from": "\u{106b}", "to": "\u{100a}" }, { "from": "\u{106c}", "to": "\u{1039}\u{100b}" }, { "from": "\u{106d}", "to": "\u{1039}\u{100c}" }, { "from": "\u{106e}", "to": "\u{100d}\u{1039}\u{100d}" }, { "from": "\u{106f}", "to": "\u{100d}\u{1039}\u{100e}" }, { "from": "\u{1070}", "to": "\u{1039}\u{100f}" }, { "from": "(\u{1071}|\u{1072})", "to": "\u{1039}\u{1010}" }, { "from": "\u{1060}", "to": "\u{1039}\u{1000}" }, { "from": "\u{1061}", "to": "\u{1039}\u{1001}" }, { "from": "\u{1062}", "to": "\u{1039}\u{1002}" }, { "from": "\u{1063}", "to": "\u{1039}\u{1003}" }, { "from": "\u{1065}", "to": "\u{1039}\u{1005}" }, { "from": "\u{1068}", "to": "\u{1039}\u{1007}" }, { "from": "\u{1069}", "to": "\u{1039}\u{1008}" }, { "from": "(\u{1073}|\u{1074})", "to": "\u{1039}\u{1011}" }, { "from": "\u{1075}", "to": "\u{1039}\u{1012}" }, { "from": "\u{1076}", "to": "\u{1039}\u{1013}" }, { "from": "\u{1077}", "to": "\u{1039}\u{1014}" }, { "from": "\u{1078}", "to": "\u{1039}\u{1015}" }, { "from": "\u{1079}", "to": "\u{1039}\u{1016}" }, { "from": "\u{107a}", "to": "\u{1039}\u{1017}" }, { "from": "\u{107c}", "to": "\u{1039}\u{1019}" }, { "from": "\u{1085}", "to": "\u{1039}\u{101c}" }, { "from": "\u{1033}", "to": "\u{102f}" }, { "from": "\u{1034}", "to": "\u{1030}" }, { "from": "\u{103f}", "to": "\u{1030}" }, { "from": "\u{1086}", "to": "\u{103f}" }, { "from": "\u{1036}\u{1088}", "to": "\u{1088}\u{1036}" }, { "from": "\u{1088}", "to": "\u{103e}\u{102f}" }, { "from": "\u{1089}", "to": "\u{103e}\u{1030}" }, { "from": "\u{108a}", "to": "\u{103d}\u{103e}" }, { "from": "\u{103B}\u{1064}", "to": "\u{1064}\u{103B}" }, { "from": "\u{103c}([\u{1000}-\u{1021}])([\u{1064}\u{108b}\u{108d}])", "to": "$1\u{103c}$2" }, { "from": "(\u{1031})?([\u{1000}-\u{1021}\u{1040}-\u{1049}])(\u{103c})?\u{1064}", "to": "\u{1004}\u{103a}\u{1039}$1$2$3" }, { "from": "(\u{1031})?([\u{1000}-\u{1021}])(\u{103b}|\u{103c})?\u{108b}", "to": "\u{1004}\u{103a}\u{1039}$1$2$3\u{102d}" }, { "from": "(\u{1031})?([\u{1000}-\u{1021}])(\u{103b})?\u{108c}", "to": "\u{1004}\u{103a}\u{1039}$1$2$3\u{102e}" }, { "from": "(\u{1031})?([\u{1000}-\u{1021}])([\u{103b}\u{103c}])?\u{108d}", "to": "\u{1004}\u{103a}\u{1039}$1$2$3\u{1036}" }, { "from": "\u{108e}", "to": "\u{102d}\u{1036}" }, { "from": "\u{108f}", "to": "\u{1014}" }, { "from": "\u{1090}", "to": "\u{101b}" }, { "from": "\u{1091}", "to": "\u{100f}\u{1039}\u{100d}" }, { "from": "\u{1092}", "to": "\u{100b}\u{1039}\u{100c}" }, { "from": "\u{1019}\u{102c}(\u{107b}|\u{1093})", "to": "\u{1019}\u{1039}\u{1018}\u{102c}" }, { "from": "(\u{107b}|\u{1093})", "to": "\u{1039}\u{1018}" }, { "from": "(\u{1094}|\u{1095})", "to": "\u{1037}" }, { "from": "([\u{1000}-\u{1021}])\u{1037}\u{1032}", "to": "$1\u{1032}\u{1037}" }, { "from": "\u{1096}", "to": "\u{1039}\u{1010}\u{103d}" }, { "from": "\u{1097}", "to": "\u{100b}\u{1039}\u{100b}" }, { "from": "\u{103c}([\u{1000}-\u{1021}])([\u{1000}-\u{1021}])?", "to": "$1\u{103c}$2" }, { "from": "([\u{1000}-\u{1021}])\u{103c}\u{103a}", "to": "\u{103c}$1\u{103a}" }, { "from": "\u{1047}(?=[\u{102c}-\u{1030}\u{1032}\u{1036}-\u{1038}\u{103d}\u{1038}])", "to": "\u{101b}" }, { "from": "\u{1031}\u{1047}", "to": "\u{1031}\u{101b}" }, { "from": "\u{1040}(\u{102e}|\u{102f}|\u{102d}\u{102f}|\u{1030}|\u{1036}|\u{103d}|\u{103e})", "to": "\u{101d}$1" }, { "from": "([^\u{1040}\u{1041}\u{1042}\u{1043}\u{1044}\u{1045}\u{1046}\u{1047}\u{1048}\u{1049}])\u{1040}\u{102b}", "to": "$1\u{101d}\u{102b}" }, { "from": "([\u{1040}\u{1041}\u{1042}\u{1043}\u{1044}\u{1045}\u{1046}\u{1047}\u{1048}\u{1049}])\u{1040}\u{102b}(?!\u{1038})", "to": "$1\u{101d}\u{102b}" }, { "from": "^\u{1040}(?=\u{102b})", "to": "\u{101d}" }, { "from": "\u{1040}\u{102d}(?!\u{0020}?/)", "to": "\u{101d}\u{102d}" }, { "from": "([^\u{1040}-\u{1049}])\u{1040}([^\u{1040}-\u{1049}\u{0020}]|[\u{104a}\u{104b}])", "to": "$1\u{101d}$2" }, { "from": "([^\u{1040}-\u{1049}])\u{1040}(?=[\\\\f\\\\n\\\\r])", "to": "$1\u{101d}" }, { "from": "([^\u{1040}-\u{1049}])\u{1040}$", "to": "$1\u{101d}" }, { "from": "\u{1031}([\u{1000}-\u{1021}\u{103f}])(\u{103e})?(\u{103b})?", "to": "$1$2$3\u{1031}" }, { "from": "([\u{1000}-\u{1021}])\u{1031}([\u{103b}\u{103c}\u{103d}\u{103e}]+)", "to": "$1$2\u{1031}" }, { "from": "\u{1032}\u{103d}", "to": "\u{103d}\u{1032}" }, { "from": "([\u{102d}\u{102e}])\u{103b}", "to": "\u{103b}$1" }, { "from": "\u{103d}\u{103b}", "to": "\u{103b}\u{103d}" }, { "from": "\u{103a}\u{1037}", "to": "\u{1037}\u{103a}" }, { "from": "\u{102f}(\u{102d}|\u{102e}|\u{1036}|\u{1037})\u{102f}", "to": "\u{102f}$1" }, { "from": "(\u{102f}|\u{1030})(\u{102d}|\u{102e})", "to": "$2$1" }, { "from": "(\u{103e})(\u{103b}|\u{103c})", "to": "$2$1" }, { "from": "\u{1025}(?=[\u{1037}]?[\u{103a}\u{102c}])", "to": "\u{1009}" }, { "from": "\u{1025}\u{102e}", "to": "\u{1026}" }, { "from": "\u{1005}\u{103b}", "to": "\u{1008}" }, { "from": "\u{1036}(\u{102f}|\u{1030})", "to": "$1\u{1036}" }, { "from": "\u{1031}\u{1037}\u{103e}", "to": "\u{103e}\u{1031}\u{1037}" }, { "from": "\u{1031}\u{103e}\u{102c}", "to": "\u{103e}\u{1031}\u{102c}" }, { "from": "\u{105a}", "to": "\u{102b}\u{103a}" }, { "from": "\u{1031}\u{103b}\u{103e}", "to": "\u{103b}\u{103e}\u{1031}" }, { "from": "(\u{102d}|\u{102e})(\u{103d}|\u{103e})", "to": "$2$1" }, { "from": "\u{102c}\u{1039}([\u{1000}-\u{1021}])", "to": "\u{1039}$1\u{102c}" }, { "from": "\u{1039}\u{103c}\u{103a}\u{1039}([\u{1000}-\u{1021}])", "to": "\u{103a}\u{1039}$1\u{103c}" }, { "from": "\u{103c}\u{1039}([\u{1000}-\u{1021}])", "to": "\u{1039}$1\u{103c}" }, { "from": "\u{1036}\u{1039}([\u{1000}-\u{1021}])", "to": "\u{1039}$1\u{1036}" }, { "from": "\u{104e}", "to": "\u{104e}\u{1004}\u{103a}\u{1038}" }, { "from": "\u{1040}(\u{102b}|\u{102c}|\u{1036})", "to": "\u{101d}$1" }, { "from": "\u{1025}\u{1039}", "to": "\u{1009}\u{1039}" }, { "from": "([\u{1000}-\u{1021}])\u{103c}\u{1031}\u{103d}", "to": "$1\u{103c}\u{103d}\u{1031}" }, { "from": "([\u{1000}-\u{1021}])\u{103b}\u{1031}\u{103d}(\u{103e})?", "to": "$1\u{103b}\u{103d}$2\u{1031}" }, { "from": "([\u{1000}-\u{1021}])\u{103d}\u{1031}\u{103b}", "to": "$1\u{103b}\u{103d}\u{1031}" }, { "from": "([\u{1000}-\u{1021}])\u{1031}(\u{1039}[\u{1000}-\u{1021}]\u{103d}?)", "to": "$1$2\u{1031}" }, { "from": "\u{1038}\u{103a}", "to": "\u{103a}\u{1038}" }, { "from": "\u{102d}\u{103a}|\u{103a}\u{102d}", "to": "\u{102d}" }, { "from": "\u{102d}\u{102f}\u{103a}", "to": "\u{102d}\u{102f}" }, { "from": "\u{0020}\u{1037}", "to": "\u{1037}" }, { "from": "\u{1037}\u{1036}", "to": "\u{1036}\u{1037}" }, { "from": "[\u{102d}]+", "to": "\u{102d}" }, { "from": "[\u{103a}]+", "to": "\u{103a}" }, { "from": "[\u{103d}]+", "to": "\u{103d}" }, { "from": "[\u{1037}]+", "to": "\u{1037}" }, { "from": "[\u{102e}]+", "to": "\u{102e}" }, { "from": "\u{102d}\u{102e}|\u{102e}\u{102d}", "to": "\u{102e}" }, { "from": "\u{102f}\u{102d}", "to": "\u{102d}\u{102f}" }, { "from": "\u{1037}\u{1037}", "to": "\u{1037}" }, { "from": "\u{1032}\u{1032}", "to": "\u{1032}" }, { "from": "\u{1044}\u{1004}\u{103a}\u{1038}", "to": "\u{104E}\u{1004}\u{103a}\u{1038}" }, { "from": "([\u{102d}\u{102e}])\u{1039}([\u{1000}-\u{1021}])", "to": "\u{1039}$2$1" }, { "from": "(\u{103c}\u{1031})\u{1039}([\u{1000}-\u{1021}])", "to": "\u{1039}$2$1" }, { "from": "\u{1036}\u{103d}", "to": "\u{103d}\u{1036}" }, { "from": "\u{1047}((?=[\u{1000}-\u{1021}]\u{103a})|(?=[\u{102c}-\u{1030}\u{1032}\u{1036}-\u{1038}\u{103d}\u{103e}]))", "to": "\u{101b}" }]
        """
        let data = json.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        let rule:NSArray = (try! JSONSerialization.jsonObject(with: data!, options: [])) as! NSArray
        
        return replaceRule(rule, original: zawgyi)
        
    }
    
    static func replaceRule(_ rule:NSArray,original:String) -> String {
        
        var output = original
        let maxLoop = rule.count
        
        //for(i = 0 ; i < maxLoop ; i += 1) {
        for i in 0..<maxLoop {
            let data:NSDictionary = rule[i] as! NSDictionary
            let from:String = data["from"] as! String
            let to:String = data["to"] as! String
            

            let range = output.startIndex ..< output.endIndex
            output = output.replacingOccurrences(of: from, with: to, options: .regularExpression, range: range)

            
        }
        
        return output
        
    }
    
}
