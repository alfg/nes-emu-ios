//
//  DocumentBrowserViewController.swift
//  nes-emu-ios
//
//  Created by Tom Salvo on 6/4/20.
//  Copyright © 2020 Tom Salvo. All rights reserved.
//

import UIKit
//import SwiftUI

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate
{
    
#if targetEnvironment(macCatalyst)
    static let segueForNesRom: String = "playROMCrossDissolve"
#else
    static let segueForNesRom: String = "playROM"
#endif
    
    // MARK: - Life Cycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.delegate = self
        
        self.allowsDocumentCreation = false
        self.allowsPickingMultipleItems = false
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL])
    {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        self.presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL)
    {
        // Present the Document View Controller for the new newly created document
        self.presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?)
    {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: - Document Presentation
    
    func presentDocument(at documentURL: URL)
    {
        let document = NesRomDocument(fileURL: documentURL)

        // Access the document
        document.open(completionHandler: { success in
            if success
            {
                self.performSegue(withIdentifier: DocumentBrowserViewController.segueForNesRom, sender: document)
            }
            else
            {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let safeRomVC = segue.destination as? NESRomViewController,
            let document = sender as? NesRomDocument
        {
            safeRomVC.document = document
        }
    }

    func closeDocument(_ document: NesRomDocument)
    {
        self.dismiss(animated: true, completion: {
            document.close(completionHandler: nil)
        })
    }
}
