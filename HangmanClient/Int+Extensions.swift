//
//  Int+Extensions.swift
//  ConsoleClient
//
//  Created by Przemek Ambroży on 28/12/2020.
//

import Foundation

extension UInt32 {

    /// Create from big endian data
    init(bigEndian data: Data) {
        self = Self(bigEndian: data.withUnsafeBytes { $0.load(as: Self.self) })
    }

    /// Convert to big endian data
    var bigEndianData: Data {
        var data = Data()
        var bigEndian = self.bigEndian
        withUnsafeBytes(of: &bigEndian) { data.append(contentsOf: $0) }
        return data
    }
}

extension UInt16 {

    /// Create from big endian data
    init(bigEndian data: Data) {
        self = Self(bigEndian: data.withUnsafeBytes { $0.load(as: Self.self) })
    }

    /// Convert to big endian data
    var bigEndianData: Data {
        var data = Data()
        var bigEndian = self.bigEndian
        withUnsafeBytes(of: &bigEndian) { data.append(contentsOf: $0) }
        return data
    }
}
