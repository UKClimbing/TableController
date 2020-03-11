//
//  TableSection.swift
//  Rockfax
//
//  Created by Stephen Horne on 17/01/2019.
//  Copyright © 2019 Rockfax. All rights reserved.
//

import UIKit


@objc open class TableSection: NSObject {
  
  public typealias BeforeDisplayBlock = (TableViewHeaderFooterBlockContextWithController)->Void
  public typealias AfterDisplayBlock = (TableViewHeaderFooterBlockContextWithController)->Void
  
  
  /// The base implementaion of tableView(tableView:, didDisplay:, forRowAt:) calls this block if it exists.
  /// Set this block if you prefer to use a declarative style of behaviour definition.
  open var beforeDisplay: BeforeDisplayBlock?
  
  
  open var displayState: DisplayState = .offScreen
  
  open var isOnScreen: Bool { return displayState == .onScreen }
  
  open weak var controller: TableController?
  
  open weak var headerView: UIView?
  
  open var section: Int = 0
  
  open var title: String?
  
  open var sectionHeader: String?
  
  open var sectionFooter: String?
  
  open var headerViewIdentifier: String? {
    if let headerViewClass = headerViewClass { return NSStringFromClass(headerViewClass) }
    return nil
  }
  
  open var headerViewClass: AnyClass?
  
  open var headerHeight: CGFloat = 0
  
  open var tableRows: [TableRow] { return _tableRows }
  
  private var _tableRows: [TableRow] = [TableRow]()
  
  
  override public init() {
    super.init()
    setup()
  }
  
  
  @objc(appendRow:)
  open func append(tableRow: TableRow) {
    tableRow.tableSection = self
    tableRow.row = _tableRows.count
    _tableRows.append(tableRow)
  }
  
  
  @objc(insertRow:atIndex:)
  open func insert(tableRow: TableRow, at index: Int) {
    tableRow.tableSection = self
    _tableRows.insert(tableRow, at: index)
    _setRowInformation(startOffset: index)
  }
  
  
  @objc(removeRow:)
  open func remove(definition: TableRow) {
    if let index = _tableRows.firstIndex(of: definition) {
      _tableRows.remove(at: index)
    }
  }
  
  
  @objc(setRows:)
  open func set(definitions: [TableRow]) {
    _tableRows = definitions
    _setRowInformation()
  }
  
  
  private func _setRowInformation(startOffset: Int = 0) {
    _tableRows.dropFirst(startOffset).enumerated().forEach { idx, element in 
      element.row = idx 
      element.tableSection = self
    }
  }
  
  
  /// Use this function to setup your subclasses if needed.
  open func setup() {
    
  }
  
  
  open func configure(headerView: UITableViewHeaderFooterView?) {
    self.headerView = headerView
  }
  
  
  /// Override this method if you want more control over the willDisplay code, or if you prefer not to use the block API.
  /// The method is called by the TableController in the UITableViewDelegate function tableView(willDisplayCellForRowAt:, indexPath:)
  /// Overriding it means you will need to set the cell's `selectionStyle` yourself.
  ///
  /// - Parameters:
  ///   - controller: The tableView controller.
  ///   - view: The header/footer view that will be diplayed.
  ///   - section: The section for the view.
  open func tableViewController(_ controller: TableController, willDisplayHeaderView view: UIView, forSection section: Int) {
    let context = TableViewHeaderFooterBlockContextWithController(controller: controller, view: view, section: section, tableSection: self)
    beforeDisplay?(context)
  }
  
}
