require_relative 'consumer_macro_flags'

def inject_debug_menu_kit_swift_flags_if_needed(installer)
  inject_macro_flags(installer, 'DebugMenuKit', 'DebugMenuKitMacros', ['-enable-experimental-feature', 'SymbolLinkageMarkers'])
end
