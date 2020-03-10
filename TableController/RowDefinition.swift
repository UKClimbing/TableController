//
//  BaseRowDefinition.swift
//  Rockfax
//
//  Created by Stephen Horne on 09/01/2019.
//  Copyright © 2019 Rockfax. All rights reserved.
//

import UIKit


@objc open class TableViewHeaderFooterBlockContext: NSObject {
  
  open var view: UIView
  open var section: Int
  open var sectionDefinition: SectionDefinition
  
  
  public init(view: UIView, section: Int, sectionDefinition: SectionDefinition) {
    self.view = view
    self.section = section
    self.sectionDefinition = sectionDefinition
    super.init()
  }
  
}



@objc open class TableViewHeaderFooterBlockContextWithController: TableViewHeaderFooterBlockContext {
  
  open var controller: TableController
  
  public init(controller: TableController, view: UIView, section: Int, sectionDefinition: SectionDefinition) {
    self.controller = controller
    super.init(view: view, section: section, sectionDefinition: sectionDefinition)
  }
}




@objc open class TableViewCellBlockContext: NSObject {
  
  open var cell: UITableViewCell
  open var indexPath: IndexPath
  open var rowDefinition: RowDefinition
  
  
  public init(cell: UITableViewCell, indexPath: IndexPath, rowDefinition: RowDefinition) {
    self.cell = cell
    self.indexPath = indexPath
    self.rowDefinition = rowDefinition
    super.init()
  }
  
}



@objc open class TableViewCellBlockContextWithController: TableViewCellBlockContext {
  
  open var controller: TableController
  
  public init(controller: TableController, cell: UITableViewCell, indexPath: IndexPath, rowDefinition: RowDefinition) {
    self.controller = controller
    super.init(cell: cell, indexPath: indexPath, rowDefinition: rowDefinition)
  }
}



@objc open class TableViewCellBlockContextWithTableView: TableViewCellBlockContext {
  
  open var tableView: UITableView
  
  
  public init(tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, rowDefinition: RowDefinition) {
    self.tableView = tableView
    super.init(cell: cell, indexPath: indexPath, rowDefinition: rowDefinition)
  }
}



public enum DisplayState {
  case onScreen
  case offScreen
}



/// This class is designed to be subclassed. It provides the basic funtionality surrounding the row selection and willDisplay stuff.
@objc open class RowDefinition: NSObject {
  
  public typealias OnSelectBlock = (TableViewCellBlockContextWithController)->Void
  public typealias ConfigureCellBlock = (TableViewCellBlockContextWithTableView)->Void
  public typealias OnDeselectBlock = OnSelectBlock
  public typealias BeforeDisplayBlock = OnSelectBlock
  public typealias AfterDisplayBlock = OnSelectBlock
  public typealias ScrollViewBlock = (UIScrollView, RowDefinition)->Void
  
  
  open weak var section: SectionDefinition?
  open weak var controller: TableController?
  open weak var cell: UITableViewCell?
  
  public var backgroundColor: UIColor? {
    didSet {
      cell?.backgroundColor = backgroundColor
    }
  }

  public var indexPath: IndexPath {
    guard let sec = section?.section else {
      fatalError("\(self) had no section set")
    }
    return IndexPath(row: row, section: sec)
  }
  
  // -1 is 'unset'
  open var row: Int = -1
  
  
  open var displayState: DisplayState = .offScreen
  
  
  public var isOnScreen: Bool { return displayState == .onScreen }
  
  
  // override this if you want to be able to identify the rows by their contents
  open var identifier: String { return NSStringFromClass(type(of: self)) }
  
  
  open var cellIdentifier: String {
    return NSStringFromClass(cellClass)
  }

  
  open var cellClass: AnyClass = UITableViewCell.self
    
  
  /// The base implementaion of tableView(tableView:, didDisplay:, forRowAt:) calls this block if it exists.
  /// Set this block if you prefer to use a declarative style of behaviour definition.
  open var configureCell: ConfigureCellBlock?
  
  
  /// The base implementaion of tableView(tableView:, didDisplay:, forRowAt:) calls this block if it exists.
  // Set this block if you prefer to use a declarative style of behaviour definition.
  open var beforeDisplay: BeforeDisplayBlock?
  
  /// The base implementaion of tableView(tableView:, willDisplay:, forRowAt:) calls this block if it exists.
  /// Set this block if you prefer to use a declarative style of behaviour definition.
  open var afterDisplay: AfterDisplayBlock?
  
  /// The base implementaion of performSelect(forTableNode:, cell:, indexPath:) calls this block if it exists.
  /// Set this block if you prefer to use a declarative style of behaviour definition.
  open var onSelect: OnSelectBlock?
  
  
  /// The base implementaion of performDeselect(forTableNode:, cell:, indexPath:) calls this block if it exists.
  /// Set this block if you prefer to use a declarative style of behaviour definition.
  open var onDeselect: OnDeselectBlock?
  
  
  open var scrollViewDidScroll: ScrollViewBlock?
  
  
  open var selectionStyle: UITableViewCell.SelectionStyle = .none
  
  
  open var preferredCellHeight: CGFloat = 44
  
  // This is the one that's used, but you can use the stored property to set it instead of this computed one
  open var preferredCellHeightCalculated: CGFloat { return preferredCellHeight }
  
  
  @objc public override init() {
    super.init()
    selectionStyle = .none
    setup()
  }
  
  
  
  /// Override this function to perform any additional setup
  open func setup() {
    
  }
  
  
  
  /// Override this method if you want more control over the select code, or if you prefer not to use the block API.
  /// The method is called by the TableController in the UITableViewDelegate function tableView(didSelectRow:, indexPath:)
  ///
  /// - Parameters:
  ///   - tableView: The table view.
  ///   - cell: The deselected cell.
  ///   - indexPath: The index path for the cell.
  open func performSelect(forTableViewController controller: TableController, cell: UITableViewCell, indexPath: IndexPath) {
    let context = TableViewCellBlockContextWithController(controller: controller, cell: cell, indexPath: indexPath, rowDefinition: self)
    onSelect?(context)
  }
  
  
  
  /// Override this method if you want more control over the deselect code, or if you prefer not to use the block API.
  /// The method is called by the TableController in the UITableViewDelegate function tableView(didDeselectRow:, indexPath:)
  ///
  /// - Parameters:
  ///   - tableView: The table view.
  ///   - cell: The deselected cell.
  ///   - indexPath: The index path for the cell.
  open func perform__Deselect__(forTableViewController controller: TableController, cell: UITableViewCell, indexPath: IndexPath) {
    let context = TableViewCellBlockContextWithController(controller: controller, cell: cell, indexPath: indexPath, rowDefinition: self)
    onDeselect?(context)
  }
  
  
  
  open func configure(cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) {
    if let backgroundColor = backgroundColor {
      cell.backgroundColor = backgroundColor
    }
    let context = TableViewCellBlockContextWithTableView(tableView: tableView, cell: cell, indexPath: indexPath, rowDefinition: self)
    configureCell?(context)
  }
  
  
  open func prefetchData(for indexPath: IndexPath) {
    
  }
  
  
  open func cancelPrefetchData(for indexPath: IndexPath) {
    
  }
  
  
  
  /// Override this method if you want more control over the willDisplay code, or if you prefer not to use the block API.
  /// The method is called by the TableController in the UITableViewDelegate function tableView(willDisplayCellForRowAt:, indexPath:)
  /// Overriding it means you will need to set the cell's `selectionStyle` yourself.
  ///
  /// - Parameters:
  ///   - tableView: The table view.
  ///   - cell: The cell that will be diplayed.
  ///   - indexPath: The index path for the cell.
  open func tableViewController(_ controller: TableController, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let context = TableViewCellBlockContextWithController(controller: controller, cell: cell, indexPath: indexPath, rowDefinition: self)
    beforeDisplay?(context)
    cell.setNeedsLayout()
  }
  
  
  /// Override this method if you want more control over the willDisplay code, or if you prefer not to use the block API.
  /// The method is called by the TableController in the UITableViewDelegate function tableView(didEndDisplaying:, indexPath:)
  ///
  /// - Parameters:
  ///   - tableView: The table view.
  ///   - cell: The cell that is leaving the display area.
  ///   - indexPath: The index path for the cell.
  open func tableViewController(_ controller: TableController, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let context = TableViewCellBlockContextWithController(controller: controller, cell: cell, indexPath: indexPath, rowDefinition: self)
    afterDisplay?(context)
  }
  
}



open class UITableViewCellRow: RowDefinition {
  
  open var title: String?
  
  
  open override func configure(cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) {
    super.configure(cell: cell, tableView: tableView, indexPath: indexPath)
    cell.textLabel?.text = title
  }
  
}
