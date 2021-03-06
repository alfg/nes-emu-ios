//
//  MemoryProtocol.swift
//  nes-emu-ios
//
//  Created by Tom Salvo on 6/5/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import Foundation

protocol MemoryProtocol: class
{
    func read(address aAddress: UInt16) -> UInt8
    func write(address aAddress: UInt16, value aValue: UInt8)
}
