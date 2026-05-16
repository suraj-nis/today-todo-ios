import SwiftUI

// MARK: - PostScript name constants

private enum FontName {
    // Fraunces 144pt optical size — covers all display/heading usage (22–44pt)
    // Note: weight-500 "medium" is unavailable as a static instance; SemiBold (600)
    // is used for the headline style — visually equivalent at this size.
    static let fraunces300    = "Fraunces144pt-Light"
    static let fraunces300i   = "Fraunces144pt-LightItalic"
    static let fraunces400    = "Fraunces144pt-Regular"
    static let fraunces400i   = "Fraunces144pt-Italic"
    static let fraunces600    = "Fraunces144pt-SemiBold"

    // Geist — UI sans
    static let geist400       = "Geist-Regular"
    static let geist400i      = "Geist-Italic"
    static let geist500       = "Geist-Medium"

    // Geist Mono — timestamps and labels
    static let geistMono400   = "GeistMono-Regular"
}

// MARK: - Font tokens

extension Font {
    /// Fraunces Light 44pt — hero title, empty state heading.
    static let todayDisplay      = Font.custom(FontName.fraunces300,  size: 44)
    /// Fraunces Regular 32pt — screen titles.
    static let todayTitle        = Font.custom(FontName.fraunces400,  size: 32)
    /// Fraunces SemiBold 22pt — section headers.
    static let todayHeadline     = Font.custom(FontName.fraunces600,  size: 22)
    /// Geist Regular 17pt — task text, primary body copy.
    static let todayBody         = Font.custom(FontName.geist400,     size: 17)
    /// Geist Medium 16pt — action labels, sheet nav items.
    static let todayCallout      = Font.custom(FontName.geist500,     size: 16)
    /// Geist Medium 14pt — expiry labels, row meta.
    static let todaySubhead      = Font.custom(FontName.geist500,     size: 14)
    /// Geist Regular 13pt — secondary meta, helper text.
    static let todayFootnote     = Font.custom(FontName.geist400,     size: 13)
    /// Geist Mono Regular 11pt — date stamps, tab labels, captions.
    static let todayCaption      = Font.custom(FontName.geistMono400, size: 11)

    // Screen-level sizes (not in the 8-style type scale; derived from specs-view.jsx anatomy)
    /// Fraunces Regular 38pt — main/archive screen title; spec: "Serif 38/44, weight 400, tracking -0.6".
    static let todayScreenTitle   = Font.custom(FontName.fraunces400,  size: 38)
    /// Fraunces Regular 38pt — hero title on Today screen ("A clean slate." / task count line).
    static let todayHeroTitle     = Font.custom(FontName.fraunces400,  size: 45)
    /// Fraunces Light 18pt — empty-state and sunset subtitle; spec: weight 300, tracking -0.2, line-height 1.33.
    static let todaySubtitle      = Font.custom(FontName.fraunces300i,  size: 22)
    /// Fraunces LightItalic 22pt — empty state prompt "What matters today?"; spec: weight 300, italic, tracking -0.3, lh 30px.
    static let todayEmptyPrompt   = Font.custom(FontName.fraunces300i, size: 22)
    /// Fraunces LightItalic 22pt — empty state headline; weight 300, italic, tracking -0.3, lh 1.36.
    static let todayEmptyHeadline = Font.custom(FontName.fraunces300i, size: 28)
    /// Geist Regular 13pt — empty state footnote; weight 400, tracking 0, lh 1.54.
    static let todayEmptyFootnote = Font.custom(FontName.geist400,     size: 13)
    /// Fraunces Regular 11pt — date kicker label (uppercase, wide tracking).
    static let todayDateKicker    = Font.custom(FontName.fraunces400,  size: 13)

    // Italic variants — true italics, not synthetic slant
    /// Fraunces Italic 32pt — italic title variant.
    static let todayTitleItalic   = Font.custom(FontName.fraunces400i, size: 32)
    /// Fraunces Light Italic 44pt — large editorial italic.
    static let todayDisplayItalic = Font.custom(FontName.fraunces300i, size: 44)
    /// Geist Italic 17pt — add sheet placeholder, italic body.
    static let todayBodyItalic    = Font.custom(FontName.geist400i,    size: 17)
}

// MARK: - Full type style

/// Bundles font + tracking + line spacing for multi-line text blocks.
enum TodayTextStyle {
    case display, displayItalic
    case heroTitle                     // 38pt Regular Fraunces — Today screen hero title
    case screenTitle                   // 38pt Regular Fraunces — main/archive screen header
    case emptyPrompt                   // 22pt LightItalic Fraunces — empty state "What matters today?"
    case emptyFootnote                 // 13pt Regular Geist — empty state instruction text
    case subtitle                      // 18pt LightItalic Fraunces — empty-state / sunset subtitle
    case title, titleItalic
    case headline
    case body, bodyItalic
    case callout
    case subhead
    case footnote
    case caption
    case dateKicker                    // 11pt Regular Fraunces — date kicker, tracking 1.4, uppercase

    var font: Font {
        switch self {
        case .display:        return .todayDisplay
        case .displayItalic:  return .todayDisplayItalic
        case .heroTitle:      return .todayHeroTitle
        case .screenTitle:    return .todayScreenTitle
        case .emptyPrompt:    return .todayEmptyHeadline
        case .emptyFootnote:  return .todayEmptyFootnote
        case .subtitle:       return .todaySubtitle
        case .title:          return .todayTitle
        case .titleItalic:    return .todayTitleItalic
        case .headline:       return .todayHeadline
        case .body:           return .todayBody
        case .bodyItalic:     return .todayBodyItalic
        case .callout:        return .todayCallout
        case .subhead:        return .todaySubhead
        case .footnote:       return .todayFootnote
        case .caption:        return .todayCaption
        case .dateKicker:     return .todayDateKicker
        }
    }

    /// Approximate additional line spacing to reach the spec's line height.
    /// SwiftUI .lineSpacing() adds on top of the font's natural line height,
    /// so these values are intentionally conservative.
    var lineSpacing: CGFloat {
        switch self {
        case .display, .displayItalic:  return 2
        case .heroTitle, .screenTitle:  return 3
        case .emptyPrompt:              return 8   // 22pt × 1.36 ≈ 30px lh
        case .emptyFootnote:            return 4   // 13pt × 1.54 ≈ 20px lh
        case .subtitle:                 return 4
        case .title, .titleItalic:      return 4
        case .headline:                 return 4
        case .body, .bodyItalic:        return 5
        case .callout:                  return 4
        case .subhead:                  return 4
        case .footnote:                 return 3
        case .caption, .dateKicker:     return 2
        }
    }

    /// Letter spacing in pt — matches design token tracking values.
    var tracking: CGFloat {
        switch self {
        case .display, .displayItalic:  return -0.8
        case .heroTitle, .screenTitle:  return -0.6
        case .emptyPrompt:              return -0.3
        case .emptyFootnote:            return  0.0
        case .subtitle:                 return -0.2
        case .title, .titleItalic:      return -0.6
        case .headline:                 return -0.3
        case .body, .bodyItalic:        return -0.2
        case .callout:                  return -0.2
        case .subhead:                  return  0.0
        case .footnote:                 return  0.0
        case .caption:                  return  0.6
        case .dateKicker:               return  1.4
        }
    }
}

// MARK: - View modifier

extension View {
    /// Applies the full type style (font + tracking + line spacing) in one call.
    func todayStyle(_ style: TodayTextStyle) -> some View {
        self
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
    }
}
