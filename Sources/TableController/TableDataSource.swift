//
//  TableDataSource.swift
//  Rockfax
//
//  Created by Stephen Horne on 09/01/2019.
//  Copyright © 2019 Rockfax. All rights reserved.
//


/**
 Subclass this class to create a datasource to go with a subclass of TableController.
 
 
 This class can either automatically manage registering classes with the tableView (nibs are not supported), or semi-automatically manage the registration.
 
 - To manage automatically: each tableRow you create needs to return a value for both `cellClass` and `cellIdentifier`. These are registered with the tableView the first time these definitions are included in the `dataSource.sections`'s `rows`.
   In addition, you should return values for the `tableSection`'s `headerViewIdentifier` and `headerViewClass`. These will be used in the same way.
 
 - To manage in a semi-automatic fashion, which will require less overhead each time you set the `sections` property (ie filter the dataSource) and is therefore perhaps preferable for very long tableviews, set `automaticallyRegistersClasses` to `false` and set up the properties `tableViewHeaderClasses` and `tableViewClasses` in your dataSource subclass.
 
*/

import UIKit
import KeyboardMonitor

open class TableDataSource: NSObject, UITableViewDataSource, UITableViewDataSourcePrefetching, KeyboardMonitorDelegate {
  
  open weak var controller: TableController?
  
  /// A set to keep track of what classes area registered already
  private var registeredRowIdentifiers = Set<String>()
  private var registeredHeaderIdentifiers = Set<String>()
  
  private var scrollViewDelegates = Set<TableRow>()
  
  open var automaticallyRegistersClasses: Bool = true
  
  // Set this if you want to display a specific view when there are no results to display
  open var emptyDatasetView: UIView?
  open var adjustEmptyDatasetViewPositionForKeyboard: Bool = true
  
  
  open var cellToRowMap: [ UITableViewCell: TableRow ] = [ UITableViewCell: TableRow ]()
  

  open var tableView: UITableView?
  open var tableSections = [TableSection]() { didSet { _sectionsDidSet() } }
  open var tableRows: [TableRow] { return tableSections.map { $0.tableRows }.flatMap { $0 } }
  
  private func _sectionsDidSet() {
    for (index, section) in tableSections.enumerated() { 
      section.section = index
      section.controller = controller 
    }
    if automaticallyRegistersClasses == true, let tableView = tableView {
      registerClasses(tableView: tableView)
    }
    if let emptyDatasetView = emptyDatasetView {
      if adjustEmptyDatasetViewPositionForKeyboard {
        KeyboardMonitor.shared.register(delegate: self)
      }
      if tableSections.isEmpty {
        emptyDatasetView.isHidden = false
        tableView?.isScrollEnabled = false
        tableView?.addSubview(emptyDatasetView)
        setEmptyDatasetViewFrameIfNeeded()
      } else {
        emptyDatasetView.isHidden = true
        tableView?.isScrollEnabled = true
      }
    }
  }
  
  private func _heightForEmptyDatasetView() -> CGFloat {
    guard let tv = tableView else { return 0 }
    let tvFrame = tv.convert(tv.bounds, to: tv.window)
    let kbRect = KeyboardMonitor.shared.keyboardFrame
    let diff = kbRect.minY - tvFrame.minY - tv.contentInset.top
    return [diff, tv.frame.height - (tv.tableHeaderView?.frame.height ?? tv.contentInset.top)].min()!
  }

  
  // This calculates the required height of all the rows
  open var calculatedContentSize: CGFloat { return tableSections.flatMap { $0.tableRows }.reduce(0) { result, next in return result + next.preferredCellHeightCalculated } }
  
  /// Override this property to provide the identifiers and classes for the tableView
  /// to register. This will only be used if you also set `automaticallyRegistersClasses` to `false`.
  /// The default setting of `true` will cause the dataSource to register the classes and identifiers supplied by the tableRows every time that the `sections` property is set. This might be non-performant if you have a very big tableView however, so this property allows you a semi-automatic way of handling class registration.
  open var tableViewClasses: [String: AnyClass]? { return [NSStringFromClass(UITableViewCell.self): UITableViewCell.self] }
  
  /// Override this property to provide the identifiers and classes for the tableView
  /// to register.
  open var tableViewHeaderClasses: [String: AnyClass]? { return [String: AnyClass]() }
  
  
  /// Override this function to specifiy the identifier to use for a specific indexPath.
  /// Normally you should just specify the identifier in the definition.
  open func identifier(forIndexPath indexPath: IndexPath) -> String {
    if let def = tableRow(atIndexPath: indexPath) {
      return def.cellIdentifier
    }
    return NSStringFromClass(UITableViewCell.self)
  }
  
  
  final func _setupForTableView(_ tableView: UITableView) {
    self.tableView = tableView
    tableView.dataSource = self
    setupForTableView(tableView)
    generateSections()
    if automaticallyRegistersClasses == false {
      semiAutoRegisterClasses(tableView: tableView)
    }
  }
  
  
  
  /// Override this method to perform additional setup of the tableView.
  ///
  /// - Parameter tableView: The tableView.
  open func setupForTableView(_ tableView: UITableView) {
    
  }
  
  
  private func semiAutoRegisterClasses(tableView: UITableView) {
    tableViewClasses?.forEach { (klassName, klass) in
      tableView.register(klass, forCellReuseIdentifier: klassName)
    }
    tableViewHeaderClasses?.forEach { (klassName, klass) in
      tableView.register(klass, forHeaderFooterViewReuseIdentifier: klassName)
    }
  }
  
  
  private func registerClasses(tableView: UITableView) {
    for section in tableSections {
      if let klass = section.headerViewClass {
        guard let identifier = section.headerViewIdentifier else {
          fatalError("A headerViewIdentifier must be provided to go with a headerViewClass")
        }
        if registeredHeaderIdentifiers.contains(identifier) == false {
          registeredHeaderIdentifiers.insert(identifier)
          tableView.register(klass, forHeaderFooterViewReuseIdentifier: identifier)
        }
      }
      for row in section.tableRows {
        let identifier = row.cellIdentifier
        if registeredRowIdentifiers.contains(identifier) == false {
          registeredRowIdentifiers.insert(identifier)
          tableView.register(row.cellClass, forCellReuseIdentifier: identifier)
        }
      }
    }
  }
  
  
  // MARK: UITableViewDataSource
  
  open func sectionDefinition(at index: Int) -> TableSection? {
    if tableSections.count <= index {
      return nil
    }
    
    let definition = tableSections[index]
    
    definition.controller = controller
    
    return definition
  }
  
  
  open func tableRow(atIndexPath indexPath: IndexPath) -> TableRow? {
    guard let section = sectionDefinition(at: indexPath.section) else {
      return nil
    }
    if section.tableRows.count <= indexPath.row {
      return nil
    }
    
    let definition = section.tableRows[indexPath.row]
    
    definition.controller = controller
    
    if definition.scrollViewDidScroll != nil {
      scrollViewDelegates.insert(definition)
    }
    
    return definition
  }
  
  
  open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let identifier = self.identifier(forIndexPath: indexPath)
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    if let def = cellToRowMap[cell] {
      // Wipe this previous relationship because of cell re-use
      def.cell = nil
    }
    if let def = tableRow(atIndexPath: indexPath) {
      def.configure(cell: cell, tableView: tableView, indexPath: indexPath)
      def.cell = cell
    }
    return cell
  }
  
  
  open func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    for indexPath in indexPaths {
      let def = tableRow(atIndexPath: indexPath)
      def?.prefetchData(for: indexPath)
    }
  }
  
  
  open func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
    for indexPath in indexPaths {
      let def = tableRow(atIndexPath: indexPath)
      def?.cancelPrefetchData(for: indexPath)
    }
  }
  
  
  open func numberOfSections(in tableView: UITableView) -> Int {
    return tableSections.count
  }
  
  
  open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.sectionDefinition(at: section)?.tableRows.count ?? 0
  }
  
  
  
  
  
  /// Override in subclasses.
  ///
  /// - Remark: This function should set the property `sections`. It is left to you how to implement this so that you can do the work in the background if necessary.  
  open func generateSections() {
    fatalError("You must override this method in subclasses")
  }
  
  
  
  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    for del in scrollViewDelegates {
      del.scrollViewDidScroll?(scrollView, del)
    }
  }
  
  
  // MARK: KeyboardMonitorDelegate
  
  open func keyboardWillChange(frame: CGRect) {
    animateEmptyDatasetViewFrame()
  }
  
  
  private lazy var queue: OperationQueue = {
    let q = OperationQueue()
    q.maxConcurrentOperationCount = 1
    return q
  }()
  
  
  open func animateEmptyDatasetViewFrame() {
    if self.tableView?.window == nil { return }
    UIView.animate(withDuration: 0.3) {
      self.setEmptyDatasetViewFrameIfNeeded()
    }
  }
  
  
  open func setEmptyDatasetViewFrameIfNeeded() {
    guard let emptyDatasetView = emptyDatasetView else { return }
    var f = _frameForEmptyDataSetView
    if f.size == .zero, let s = tableView?.frame.size {
      f.size = s
    }
    var rect = CGRect.null
    for subview in emptyDatasetView.subviews {
      rect = rect.union(subview.frame)
    }
    rect = rect.integral
    emptyDatasetView.frame = rect
    emptyDatasetView.center = CGPoint(x: f.midX.rounded(), y: f.midY.rounded())
  }
  
  
  private var _frameForEmptyDataSetView: CGRect {
    guard let tv = self.tableView else { return .zero }
    var rect = tv.bounds
    rect.origin.y = 0
    let h = _heightForEmptyDatasetView()
    if h > 0 {
      rect.size.height = h
    }
    return rect
  }
  
  
}




public extension UITableViewCell {
  
  var tableRow: TableRow? {
    guard let tableView = superview as? UITableView else { return nil }
    guard let dataSource = tableView.dataSource as? TableDataSource else { return nil }
    return dataSource.cellToRowMap[self]
  }
  
  
  var tableSection: TableSection? {
    guard let tableView = superview as? UITableView else { return nil }
    guard let dataSource = tableView.dataSource as? TableDataSource else { return nil }
    guard let row = dataSource.cellToRowMap[self] else { return nil }
    return row.tableSection
  }
  
}
