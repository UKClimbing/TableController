//
//  TableSection.swift
//  Rockfax
//
//  Created by Stephen Horne on 17/01/2019.
//  Copyright © 2019 Rockfax. All rights reserved.
//

import UIKit


@objc open class TableSection: NSObject {
  
  
  open var displayState: TableController.DisplayState = .hidden
  
  
  open var isOnScreen: Bool { return displayState == .visible }
  
  
  open weak var controller: TableController?
  
  
  open weak var headerView: UIView?
  
  
  open var index: Int = 0
  
  
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
  
  
  /// Override this method if you want more control over the willDisplay code.
  ///
  /// - Parameters:
  ///   - controller: The tableController.
  ///   - view: The header/footer view that will be diplayed.
  ///   - section: The section for the view.
  open func tableController(_ controller: TableController, willDisplayHeaderView view: UIView, forSection section: Int) {

  }
  
  
}
