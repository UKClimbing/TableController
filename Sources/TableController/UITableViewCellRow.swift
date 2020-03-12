//
//  File.swift
//  
//
//  Created by Stephen Horne on 12/03/2020.
//

import UIKit


open class UITableViewCellRow: TableRow {
  
  open var title: String?
  
  
  open override func configure(cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) {
    super.configure(cell: cell, tableView: tableView, indexPath: indexPath)
    cell.textLabel?.text = title
  }
  
}
