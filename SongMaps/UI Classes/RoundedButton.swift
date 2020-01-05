//
//  RoundedButton.swift
//  SongMaps
//
//  Created by Polecat on 11/12/19.
//  Copyright © 2019 Polecat. All rights reserved.
//

import UIKit

class RoundedButton: UIButton {

    override init(frame: CGRect) {
      super.init(frame: frame)
      setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = 4
        
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 1.0
        layer.shadowColor = UIColor.black.cgColor
        layer.cornerRadius = 1
    }

}
