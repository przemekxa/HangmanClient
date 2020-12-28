//
//  OSLog+Extensions.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 28/12/2020.
//

import Foundation
import OSLog

struct Log {

    init(_ category: String = "default") {
        logger = OSLog(subsystem: "ConsoleClient", category: category)
    }

    private let logger: OSLog

    @inlinable func callAsFunction(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .default, args)
    }

    @inlinable func log(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .default, args)
    }

    @inlinable func info(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .info, args)
    }

    @inlinable func debug(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .debug, args)
    }

    @inlinable func error(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .error, args)
    }

    @inlinable func fault(_ message: StaticString, _ args: CVarArg...) {
        log(message, type: .fault, args)
    }

    @usableFromInline internal func log(_ message: StaticString, type: OSLogType, _ a: [CVarArg]) {
        // The Swift overlay of os_log prevents from accepting an unbounded number of args
        assert(a.count <= 5)
        switch a.count {
        case 5: os_log(message, log: logger, type: type, a[0], a[1], a[2], a[3], a[4])
        case 4: os_log(message, log: logger, type: type, a[0], a[1], a[2], a[3])
        case 3: os_log(message, log: logger, type: type, a[0], a[1], a[2])
        case 2: os_log(message, log: logger, type: type, a[0], a[1])
        case 1: os_log(message, log: logger, type: type, a[0])
        default: os_log(message, log: logger, type: type)
        }
    }

}
