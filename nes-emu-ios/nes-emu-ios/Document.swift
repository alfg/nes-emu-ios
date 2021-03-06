//
//  NesRomDocument.swift
//  nes-emu-ios
//
//  Created by Tom Salvo on 6/4/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import UIKit

struct NesRom
{
    let data: Data
}

class NesRomDocument: UIDocument
{
    var nesRom: NesRom?
    
    override func contents(forType typeName: String) throws -> Any
    {
        // Encode your document with an instance of NSData or NSFileWrapper
        return self.nesRom?.data ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws
    {
        // Load your document from contents
        if let safeRomData: Data = contents as? Data
        {
            self.nesRom = NesRom(data: safeRomData)
        }
    }
}

