//
//  File.swift
//  
//
//  Created by Stephen Horne on 12/03/2020.
//

import UIKit


open class UITableViewCellRow: TableRow {
  
  open override var preferredCellHeightCalculated: CGFloat {
    guard let t = title, 
          var width = controller?.view.margins.width else {
      return preferredCellHeight
    }
    let key = heightCacheKey(for: width)
    if let cached = TextRow.heightCache[ key ] {
      return cached
    }
    guard let cell = cell as? TextCell,
          let textFont = cell.textLabel?.font else {
      return preferredCellHeight
    }
    width = cell.margins.width
    let modifier = cell.layoutMargins.top + cell.layoutMargins.bottom // + Units.small // for the gap
    let textHeight = t.height(with: textFont, width: width)
    let total = textHeight + modifier
    let newKey = heightCacheKey(for: width)
    TextRow.heightCache[ newKey ] = total
    return total
  }
  
  
  open var title: String?
  open var textColor: UIColor = Colors.darkText
  open var font = Fonts.body
  open var numberOfLines: Int = 1
  
  
  open override func configure(cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) {
    super.configure(cell: cell, tableView: tableView, indexPath: indexPath)
    cell.textLabel?.text = title
    cell.textLabel?.font = font
    cell.textLabel?.textColor = textColor
    cell.textLabel?.numberOfLines = numberOfLines
  }
  
}
