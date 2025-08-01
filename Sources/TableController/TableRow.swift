//
//  TableRow.swift
//  Rockfax
//
//  Created by Stephen Horne on 09/01/2019.
//  Copyright © 2019 Rockfax. All rights reserved.
//

import UIKit


/// This class is designed to be subclassed. It provides the basic funtionality surrounding the row selection and willDisplay stuff.
@objc open class TableRow: NSObject {
  

  public typealias ScrollViewBlock = (UIScrollView, TableRow)->Void
  
  
  open weak var tableSection: TableSection?
  @objc open weak var controller: TableController?
  open weak var cell: UITableViewCell?
  
  open var layoutMargins: UIEdgeInsets = UIEdgeInsets(top: Padding.standard, left: Padding.standard, bottom: Padding.standard, right: Padding.standard)
  
  @objc public var backgroundColor: UIColor? {
    didSet {
      cell?.backgroundColor = backgroundColor
    }
  }

  public var indexPath: IndexPath {
    guard let sec = tableSection?.index else {
      fatalError("\(self) had no section set")
    }
    return IndexPath(row: row, section: sec)
  }
  
  // -1 is 'unset'
  open var row: Int = -1
  
  
  open var displayState: TableController.DisplayState = .hidden
  
  
  public var isOnScreen: Bool { return displayState == .visible }
  
  
  // override this if you want to be able to identify the rows by their contents
  open var identifier: String { return NSStringFromClass(type(of: self)) }
  
  
  open var cellIdentifier: String {
    return NSStringFromClass(cellClass)
  }

  
  open var cellClass: AnyClass = UITableViewCell.self
    
  
  open var onScroll: ScrollViewBlock?
  
  
  open var selectionStyle: UITableViewCell.SelectionStyle = .none
  
  
  open var preferredCellHeight: CGFloat = 44
  
  // This is the one that's used, but you can use the stored property to set it instead of this computed one
  open var preferredCellHeightCalculated: CGFloat { return preferredCellHeight }
  
  
  var baseHeightCacheKey: String? { nil }
  
  
  func heightCacheKey(for width: CGFloat) -> String {
    var mod = ""
    if let cell = cell as? TextCell,
          let textFont = cell.textLabel?.font {
      let modifier = cell.layoutMargins.top + cell.layoutMargins.bottom // + Units.small // for the gap
      mod = "font:\(textFont)_modifier:\(modifier)_cell.layoutMargins.top:\(cell.layoutMargins.top)_cell.layoutMargins.bottom:\(cell.layoutMargins.bottom)_"
    }
    return "\(mod)\(width)_\(baseHeightCacheKey ?? "nowt")_\(String(describing:self))"
  }
  
  
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

  }
  
  
  
  /// Override this method if you want more control over the deselect code, or if you prefer not to use the block API.
  /// The method is called by the TableController in the UITableViewDelegate function tableView(didDeselectRow:, indexPath:)
  ///
  /// - Parameters:
  ///   - tableView: The table view.
  ///   - cell: The deselected cell.
  ///   - indexPath: The index path for the cell.
  open func perform__DESELECT__(forTableViewController controller: TableController, cell: UITableViewCell, indexPath: IndexPath) {

  }
  
  
  open func configure(cell: UITableViewCell, tableView: UITableView, indexPath: IndexPath) {
    if let backgroundColor = backgroundColor {
      cell.backgroundColor = backgroundColor
    }
    cell.layoutMargins.top += layoutMargins.top
    cell.layoutMargins.right += layoutMargins.right
    cell.layoutMargins.bottom += layoutMargins.bottom
    cell.layoutMargins.left += layoutMargins.left
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
  open func tableController(_ controller: TableController, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.backgroundColor = backgroundColor
    cell.layoutMargins = layoutMargins ?? cell.layoutMargins
    cell.setNeedsLayout()
  }
  
  
  /// Override this method if you want more control over the willDisplay code, or if you prefer not to use the block API.
  /// The method is called by the TableController in the UITableViewDelegate function tableView(didEndDisplaying:, indexPath:)
  ///
  /// - Parameters:
  ///   - tableView: The table view.
  ///   - cell: The cell that is leaving the display area.
  ///   - indexPath: The index path for the cell.
  open func tableController(_ controller: TableController, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

  }
  
}


@objc extension TableRow {
  
  @objc public func setLayoutMargins(_ margins: UIEdgeInsets) {
    layoutMargins = margins
  }
  
}



extension TableRow {
  
  static var stickyHeaderScrollHandler: ScrollViewBlock {
    return { scrollView, row in
      row.cell?.y = min(scrollView.contentOffset.y, 0)
    }
  }
  
  static var stickyHeaderScrollHandlerWithDecay: ScrollViewBlock {
    return { scrollView, row in
      let mod = decay(offset: scrollView.contentOffset.y, dimension: scrollView.height) / 4
      row.cell?.y = min(scrollView.contentOffset.y - mod, 0)
    }
  }
  
}
