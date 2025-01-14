//
//  Embed.swift
//  SwiftGodotKit
//
//  Created by Miguel de Icaza on 4/1/23.
//
import Foundation
import SwiftGodot
import libgodot
import SwiftUI
@_implementationOnly import GDExtension

// Callbacks that the user provides
var loadSceneCb: ((SceneTree) -> ())?
var loadProjectSettingsCb: ((ProjectSettings)->())?
var initHookCb: ((GDExtension.InitializationLevel) -> ())?

func projectSettingsBind (_ x: UnsafeMutableRawPointer?) {
    if let cb = loadProjectSettingsCb, let ptr = x {
        cb (ProjectSettings.createFrom(nativeHandle: ptr))
    }
}

extension GDExtension.InitializationLevel {
    init<T : BinaryInteger>(integerValue: T) {
        self = .init(rawValue: RawValue(integerValue))!
    }
}

func embeddedExtensionInit (userData: UnsafeMutableRawPointer?, l: GDExtensionInitializationLevel) {
    for cb in initCallbacks {
        cb (GDExtension.InitializationLevel(integerValue: l.rawValue))
    }
}

func embeddedExtensionDeinit (userData: UnsafeMutableRawPointer?, l: GDExtensionInitializationLevel) {
    for cb in deinitCallbacks {
        cb (GDExtension.InitializationLevel(integerValue: l.rawValue))
    }
}

// Courtesy of GPT-4
func withUnsafePtr<T> (strings: [String], callback: (UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> T) -> T {
    let cStrings: [UnsafeMutablePointer<Int8>?] = strings.map { string in
        // Convert Swift string to a C string (null-terminated)
        return strdup(string)
    }

    // Allocate memory for the array of C string pointers
    let cStringArray = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>.allocate(capacity: cStrings.count + 1)
    cStringArray.initialize(from: cStrings, count: cStrings.count)

    // Add a null pointer at the end of the array to indicate its end
    cStringArray[cStrings.count] = nil

    let res = callback (cStringArray)
    
    for i in 0..<strings.count {
        free(cStringArray[i])
    }
    cStringArray.deallocate()
    
    return res
}

public enum GodotResult: Int32 {
    case OK
    case ERROR
    case EXIT

    public var rawValue: Int32 {
        switch self {
        case .OK:
            return libgodot.GODOT_OK
        case .EXIT:
            return libgodot.GODOT_EXIT
        default:
            return libgodot.GODOT_ERROR
        }
    }
    
    public init(rawValue: Int32) {
        switch rawValue {
        case libgodot.GODOT_OK:
            self = .OK
        case libgodot.GODOT_EXIT:
            self = .EXIT
        default:
            self = .ERROR
        }
    }
}

var godot_name = ""
var godot_runtime_api: UnsafeMutablePointer<libgodot.GodotRuntimeAPI>? = nil
var initCallbacks: [(_ level: GDExtension.InitializationLevel) -> ()] = []
var deinitCallbacks: [(_ level: GDExtension.InitializationLevel) -> ()] = []
var runAfterStartCallbacks: [() -> ()] = []
var godot_started = false

public func addInitCallback(_ cb: @escaping (_ level: GDExtension.InitializationLevel) -> ()) {
    if godot_started {
        cb(GDExtension.InitializationLevel.scene)
    }
    initCallbacks.append(cb)
}

public func runAfterStart(_ cb: @escaping () -> ()) {
    if godot_started {
        cb()
    } else {
        runAfterStartCallbacks.append(cb)
    }
}

public func initGodot(library_name: String) {
    godot_name = library_name
    godot_runtime_api = libgodot.godot_load_library()
    godot_runtime_api!.pointee.godot_register_extension_library(library_name, { godotGetProcAddr, libraryPtr, extensionInit in
        if let godotGetProcAddr {
            let bit = unsafeBitCast(godotGetProcAddr, to: OpaquePointer.self)
            setExtensionInterface(to: bit, library: OpaquePointer (libraryPtr!))
            extensionInit?.pointee = GDExtensionInitialization(
                minimum_initialization_level: GDEXTENSION_INITIALIZATION_CORE,
                userdata: nil,
                initialize: embeddedExtensionInit,
                deinitialize: embeddedExtensionDeinit)
            return 1
        }
        
        return 0
    })
}

public func godot_load_engine(args: [String]) -> GodotResult {
    var copy = args
    copy.insert(godot_name, at: 0)
    return GodotResult(rawValue: withUnsafePtr(strings: copy, callback: { ptr in
        return godot_runtime_api!.pointee.godot_load_engine(Int32 (copy.count), ptr)
    }))
}

public func godot_start_engine(layer: CALayer) -> GodotResult {
    var result = GodotResult(rawValue: godot_runtime_api!.pointee.godot_start_engine(UInt64(bitPattern:Int64(Int(bitPattern: Unmanaged.passRetained(layer).toOpaque())))))
    if result == GodotResult.OK {
        godot_started = true
    }
    for cb in runAfterStartCallbacks {
        cb()
    }
    runAfterStartCallbacks.removeAll()
    return result
}

public func godot_iterate_engine() -> GodotResult {
    return GodotResult(rawValue: godot_runtime_api!.pointee.godot_iterate_engine())
}

public func godot_shutdown_engine() -> GodotResult {
    var result = GodotResult(rawValue: godot_runtime_api!.pointee.godot_shutdown_engine())
    if result == GodotResult.EXIT {
        godot_started = false
    }
    return result
}

