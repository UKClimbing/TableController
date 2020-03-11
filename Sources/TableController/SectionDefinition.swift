//
//  BaseSectionDefinition.swift
//  Rockfax
//
//  Created by Stephen Horne on 17/01/2019.
//  Copyright © 2019 Rockfax. All rights reserved.
//

import UIKit


@objc open class SectionDefinition: NSObject {
  
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
  
  open var rowDefinitions: [RowDefinition] { return _rowDefinitions }
  
  private var _rowDefinitions: [RowDefinition] = [RowDefinition]()
  
  
  override public init() {
    super.init()
    setup()
  }
  
  
  @objc(appendDefinition:)
  open func append(definition: RowDefinition) {
    definition.section = self
    definition.row = _rowDefinitions.count
    _rowDefinitions.append(definition)
  }
  
  
  @objc(insertDefinition:atIndex:)
  open func insert(definition: RowDefinition, at index: Int) {
    definition.section = self
    _rowDefinitions.insert(definition, at: index)
    setDefinitionRows(startOffset: index)
  }
  
  
  @objc(removeDefinition:)
  open func remove(definition: RowDefinition) {
    if let index = _rowDefinitions.firstIndex(of: definition) {
      _rowDefinitions.remove(at: index)
    }
  }
  
  
  @objc(setDefinitions:)
  open func set(definitions: [RowDefinition]) {
    _rowDefinitions = definitions
    setDefinitionRows()
  }
  
  
  private func setDefinitionRows(startOffset: Int = 0) {
    _rowDefinitions.dropFirst(startOffset).enumerated().forEach { idx, element in 
      element.row = idx 
      element.section = self
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
    let context = TableViewHeaderFooterBlockContextWithController(controller: controller, view: view, section: section, sectionDefinition: self)
    beforeDisplay?(context)
  }
  
}
