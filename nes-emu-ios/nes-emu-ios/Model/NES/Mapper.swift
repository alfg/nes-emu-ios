//
//  Mapper.swift
//  nes-emu-ios
//
//  Created by Tom Salvo on 6/7/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import Foundation
import os

enum MapperIdentifier: UInt8
{
    // see https://wiki.nesdev.com/w/index.php/List_of_mappers
    case NROM = 0,
    MMC1 = 1,
    UxROM = 2,
    CNROM = 3,
    MMC3 = 4,
    MMC5 = 5,
    AxROM = 7,
    MMC2 = 9,
    MMC4 = 10,
    ColorDreams = 11,
    CPROM = 13,
    Multi100In1ContraFunction16 = 15,
    BandaiEPROM = 16,
    JalecoSS8806 = 18,
    Namco163 = 19,
    VRC4a_VRC4c = 21,
    VRC2a = 22,
    VRC2b_VRC4e = 23,
    VRC6a = 24,
    VRC4b_VRC4d = 25,
    VRC6b = 26,
    BNROM_NINA001 = 34,
    RAMBO1 = 64
    
    func mapper(forCartridge aCartridge: CartridgeProtocol) -> MapperProtocol?
    {
        switch self
        {
        case .NROM: return Mapper_NROM(withCartridge: aCartridge)
        default: return nil
        }
    }
    
    var hasExpansionAudio: Bool
    {
        switch self
        {
        case .Namco163, .VRC6a, .VRC6b, .MMC5: return true
        default: return false
        }
    }
}

protocol MapperProtocol: class
{
    func read(address aAddress: UInt16) -> UInt8
    func write(address aAddress: UInt16, value aValue: UInt8)
    func step()
}

class Mapper_NROM: MapperProtocol
{
    init(withCartridge aCartridge: CartridgeProtocol)
    {
        self.prgBanks = aCartridge.prgBlocks.count
        self.prgBank1 = 0
        self.prgBank2 = self.prgBanks - 1
    }
    
    weak var cartridge: CartridgeProtocol?
    
    var prgBanks: Int
    var prgBank1: Int
    var prgBank2: Int
    
    func read(address aAddress: UInt16) -> UInt8
    {
        guard let safeCartridge = self.cartridge else
        {
            return 0
        }
        
        switch aAddress
        {
        case 0x0000 ..< 0x2000: // CHR Block
            if safeCartridge.chrBlocks.count > 0
            {
                return [UInt8](safeCartridge.chrBlocks[0])[Int(aAddress)]
            }
            else
            {
                return 0
            }
        case 0xC000 ..< 0xFFFF: // PRG Block 1 (or mirror of PRG block 0 if only one PRG exists)
            let absoluteIndex = self.prgBank2 * 0x4000 + Int(aAddress - 0xC000)
            let prgBlockIndex = absoluteIndex / 0x4000
            let prgBankOffset = absoluteIndex % 0x4000
            
            if safeCartridge.prgBlocks.count > prgBlockIndex
            {
                return safeCartridge.prgBlocks[prgBlockIndex][prgBankOffset]
            }
            else
            {
                return 0
            }
            
        case 0x8000 ..< 0xC000: // PRG Block 0
            let absoluteIndex = self.prgBank1 * 0x4000 + Int(aAddress - 0x8000)
            let prgBlockIndex = absoluteIndex / 0x4000
            let prgBankOffset = absoluteIndex % 0x4000
            
            if safeCartridge.prgBlocks.count > prgBlockIndex
            {
                return safeCartridge.prgBlocks[prgBlockIndex][prgBankOffset]
            }
            else
            {
                return 0
            }
            
        case 0x6000 ..< 0x8000: // SRAM
            
            // TODO: implement SRAM retrieval
            //index := int(address) - 0x6000
            //return m.SRAM[index]
            return 0
            
        default:
            os_log("unhandled Mapper_NROM read at address: 0x%04X", aAddress)
            return 0
        }
    }
    
    func write(address aAddress: UInt16, value aValue: UInt8)
    {
        switch aAddress {
        case 0x0000 ..< 0x2000: // CHR RAM?
            // TODO: figure out why we'd want this below:
            //m.CHR[address] = value
            break
        case 0x6000 ..< 0x8000: // write to SRAM save
            // TODO: implement SRAM write
            //index := int(address) - 0x6000
            //m.SRAM[index] = aValue
            break
        case 0x8000 ..< 0xFFFF:
            self.prgBank1 = Int(aValue) % self.prgBanks
        default:
            os_log("unhandled Mapper_NROM write at address: 0x%04X", aAddress)
            break
        }
    }
    
    func step()
    {
        
    }
}