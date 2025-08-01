//
//  TextRow.swift
//  rfdigital
//
//  Created by Stephen Horne on 18/10/2023.
//  Copyright © 2023 Rockfax. All rights reserved.
//

import Foundation


@objc class TextRow: TableRow {
  
  
  static var heightCache = [ String : CGFloat ]()
  
  
  var numberOfLines = 0
  
  override var baseHeightCacheKey: String? {
    return "\(text)_\(font.signature)_\(textColor.signature)_\(textAlignment.rawValue)"
  }
  
  
  override var preferredCellHeightCalculated: CGFloat {
    guard let width = controller?.view.margins.width else {
      return preferredCellHeight
    }
    let key = heightCacheKey(for: width)
    if let cached = TextRow.heightCache[ key ] {
      return cached
    }
    let modifier = layoutMargins.top + layoutMargins.bottom // + Units.small // for the gap
    let textHeight = text.height(with: font, width: width)
    let total = textHeight + modifier
    let newKey = heightCacheKey(for: width)
    TextRow.heightCache[ newKey ] = total
    controller?.view.setNeedsLayout()
    controller?.view.layoutIfNeeded()
    return total
  }
  
  
  
  @objc var text: String
  @objc var font: UIFont = .body
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
    cell.infoLabel.font = font 
    cell.infoLabel.text = text
    cell.infoLabel.numberOfLines = numberOfLines
    cell.infoLabel.textAlignment = textAlignment
    cell.infoLabel.textColor = textColor
  }
  
  
}



extension UIFont {
  var signature: String {
    let descriptor = self.fontDescriptor
    let name = descriptor.fontAttributes[.name] as? String ?? "Unknown"
    let family = descriptor.fontAttributes[.family] as? String ?? "Unknown"
    let pointSize = String(format: "%.1f", self.pointSize)
    return "\(family)-\(name)-\(pointSize)"
  }
}




extension UIColor {
  var signature: String {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let redHex = String(format: "%02X", Int(red * 255))
    let greenHex = String(format: "%02X", Int(green * 255))
    let blueHex = String(format: "%02X", Int(blue * 255))
    let alphaHex = String(format: "%02X", Int(alpha * 255))
    
    return "#\(redHex)\(greenHex)\(blueHex)\(alphaHex)"
  }
}
