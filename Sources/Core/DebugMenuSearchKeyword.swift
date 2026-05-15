import Foundation

extension String {
    var debugMenuSearchKeyword: String {
        let filtered = unicodeScalars
            .filter { CharacterSet.letters.contains($0) }
            .map(String.init)
            .joined()

        guard !filtered.isEmpty else {
            return lowercased()
        }

        let pinyin = filtered.debugMenuPinyin
        let compactPinyin = pinyin.replacingOccurrences(of: " ", with: "")
        let initials = pinyin
            .split(separator: " ")
            .compactMap(\.first)
            .map(String.init)
            .joined()

        return [self, compactPinyin, initials]
            .filter { !$0.isEmpty }
            .joined(separator: ";")
            .lowercased()
    }

    private var debugMenuPinyin: String {
        let mutable = NSMutableString(string: self)
        CFStringTransform(mutable, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutable, nil, kCFStringTransformStripCombiningMarks, false)

        var pinyin = (mutable as String).lowercased()
        [
            "diao shi": "tiao shi",
            "zhong zhi": "chong zhi"
        ].forEach { from, to in
            pinyin = pinyin.replacingOccurrences(of: from, with: to)
        }
        return pinyin
    }
}
