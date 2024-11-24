//
//  TextCell.swift
//  rfdigital
//
//  Created by Stephen Horne on 18/10/2023.
//  Copyright © 2023 Rockfax. All rights reserved.
//

import Foundation



class TextCell: ShrinksOnTouchCell {
  
  
  var infoLabel = UILabel()

  
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(infoLabel)
    infoLabel.font = Fonts.regular
    infoLabel.numberOfLines = 0
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  override func layoutSubviews() {
    super.layoutSubviews()
    let m = margins
    
    infoLabel.frame = m.frame
  }

  
}

