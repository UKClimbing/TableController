//
//  File.swift
//  
//
//  Created by Stephen Horne on 12/03/2020.
//

import UIKit


@objc open class TableViewHeaderFooterBlockContext: NSObject {
  
  open var view: UIView
  open var sectionIndex: Int
  open var tableSection: TableSection
  
  
  public init(view: UIView, section: Int, tableSection: TableSection) {
    self.view = view
    self.sectionIndex = section
    self.tableSection = tableSection
    super.init()
  }
  
}



@objc open class TableViewHeaderFooterWithControllerBlockContext: TableViewHeaderFooterBlockContext {
  
  open var controller: TableController
  
  public init(controller: TableController, view: UIView, section: Int, tableSection: TableSection) {
    self.controller = controller
    super.init(view: view, section: section, tableSection: tableSection)
  }
}




@objc open class TableViewCellBlockContext: NSObject {
  
  open var cell: UITableViewCell
  open var indexPath: IndexPath
  open var tableRow: TableRow
  
  
  public init(cell: UITableViewCell, indexPath: IndexPath, tableRow: TableRow) {
    self.cell = cell
    self.indexPath = indexPath
    self.tableRow = tableRow
    super.init()
  }
  
}



@objc open class TableViewCellBlockContextWithController: TableViewCellBlockContext {
  
  open var controller: TableController
  
  public init(controller: TableController, cell: UITableViewCell, indexPath: IndexPath, tableRow: TableRow) {
    self.controller = controller
    super.init(cell: cell, indexPath: indexPath, tableRow: tableRow)
  }
}



@objc open class TableViewCellBlockContextWithTableView: TableViewCellBlockContext {
  
  open var tableView: UITableView
  
  
  public init(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, tableRow: TableRow) {
    self.tableView = tableView
    super.init(cell: cell, indexPath: indexPath, tableRow: tableRow)
  }
}
