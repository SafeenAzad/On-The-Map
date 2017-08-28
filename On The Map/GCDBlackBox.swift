//
//  GCDBlackBox.swift
//  On The Map
//
//  Created by Safeen Azad on 8/26/17.
//  Copyright © 2017 SafeenAzad. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
        
    }
}
