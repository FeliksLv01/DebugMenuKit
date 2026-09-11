import Foundation
import MachO

private typealias DebugMenuItemMetatypeGetter = @convention(c) () -> UnsafeRawPointer

enum DebugMenuItemScanner {
    static func scan() -> [any DebugMenuItem.Type] {
        var results: [any DebugMenuItem.Type] = []
        let count = _dyld_image_count()

        for index in 0..<count {
            guard let rawHeader = _dyld_get_image_header(index) else {
                continue
            }

            let header = UnsafePointer<mach_header_64>(OpaquePointer(rawHeader))
            results.append(contentsOf: readSection(header: header))
        }

        return results
    }

    private static func readSection(header: UnsafePointer<mach_header_64>) -> [any DebugMenuItem.Type] {
        var size: UInt = 0
        guard let sectionData = getsectiondata(header, "__DATA_CONST", "__debug_menu_kit", &size),
              size > 0 else {
            return []
        }

        let itemSize = MemoryLayout<DebugMenuItemMetatypeGetter>.stride
        let count = Int(size) / itemSize
        let rawPointer = UnsafeRawPointer(sectionData)

        var results: [any DebugMenuItem.Type] = []
        results.reserveCapacity(count)

        for index in 0..<count {
            let getter = rawPointer.load(
                fromByteOffset: index * itemSize,
                as: DebugMenuItemMetatypeGetter.self
            )
            let typePointer = getter()
            let itemType = unsafeBitCast(typePointer, to: Any.Type.self)
            if let debugMenuItemType = itemType as? any DebugMenuItem.Type {
                results.append(debugMenuItemType)
            }
        }

        return results
    }
}
