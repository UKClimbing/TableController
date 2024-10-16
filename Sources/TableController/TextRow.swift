//
//  TextRow.swift
//  rfdigital
//
//  Created by Stephen Horne on 18/10/2023.
//  Copyright © 2023 Rockfax. All rights reserved.
//

import Foundation


@objc class TextRow: TableRow {
  
  
  override var preferredCellHeightCalculated: CGFloat {
    guard var width = controller?.view.margins.width,
          let cell = cell as? TextCell,
          let textFont = cell.textLabel?.font
      else { return preferredCellHeight }
    width = cell.margins.width
    let modifier = cell.layoutMargins  .top + cell.layoutMargins.bottom + Units.small // for the gap
    let textHeight = text.height(with: textFont, width: width)
    let total = textHeight + modifier
    return total
  }
  
  
  
  @objc var text: String
  @objc var font: UIFont?
  @objc var textColor = Colors.darkText
  @objc var textAlignment = NSTextAlignment.left
  
  
  @objc init(text: String) {
    self.text = text
    super.init()
    cellClass = TextCell.self
    preferredCellHeight = 44
  }
  
  
  override func tableController(_ controller: TableController, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    super.tableController(controller, willDisplay: cell, forRowAt: indexPath)
    guard let cell = cell as? TextCell else { return }
    cell.infoLabel.font = font ?? cell.infoLabel.font
    cell.infoLabel.text = text
    cell.infoLabel.textAlignment = textAlignment
    cell.infoLabel.textColor = textColor
  }
  
  
}
