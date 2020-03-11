//
//  TableController.swift
//  Rockfax
//
//  Created by Stephen Horne on 09/01/2019.
//  Copyright © 2019 Rockfax. All rights reserved.
//

import UIKit

open class TableController: UIViewController, TableViewFrameDelegate {
  
  @objc open var dataSource: TableDataSource
  
  @objc open var tableView: BaseTableView
  
  
  private var viewDidAppearAtLeastOnce: Bool = false
    
  
  public init(style: UITableView.Style, dataSource: TableDataSource) {
    self.dataSource = dataSource
    tableView = BaseTableView(frame: .zero, style: style)
    super.init(nibName: nil, bundle: nil)
    dataSource.controller = self
    tableView.delegate = self
    if #available(iOS 11.0, *) {
      tableView.contentInsetAdjustmentBehavior = .never
    }
    tableView.dataSource = dataSource
    if #available(iOS 10.0, *) {
      tableView.prefetchDataSource = dataSource
    }
    tableView.estimatedRowHeight = 0
    tableView.separatorStyle = .none
    modalPresentationStyle = .fullScreen
  }
  
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) is not allowed Use init(style:, dataSource:) instead.")
  }
  
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(tableView)
    tableView.frame = view.bounds
    dataSource._setupForTableView(tableView)
  }
  
  
  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if viewDidAppearAtLeastOnce == false {
      viewDidAppearAtLeastOnce = true
      viewDidAppearFirstTime(animated)
    }
  }
  
  
  override open func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
  
  
  // Override if you like
  open func viewDidAppearFirstTime(_ animated: Bool) {
    
  }
  
  
  open func tableViewFrameDidChange(_ tableView: UITableView) {
    dataSource.setEmptyDatasetViewFrameIfNeeded()
  }
  


  
  // MARK: UITableViewDelegate
  open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = self.tableView.cellForRow(at: indexPath) {
      dataSource.tableRow(atIndexPath: indexPath)?.performSelect(forTableViewController: self, cell: cell, indexPath: indexPath)
    }
  }
  
  
  open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    if let cell = self.tableView.cellForRow(at: indexPath) {
      dataSource.tableRow(atIndexPath: indexPath)?.perform__Deselect__(forTableViewController: self, cell: cell, indexPath: indexPath)
    }
  }
  
  
  open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let row = dataSource.tableRow(atIndexPath: indexPath) {
      row.displayState = .onScreen
      cell.selectionStyle = row.selectionStyle
      row.tableViewController(self, willDisplay: cell, forRowAt: indexPath)
      dataSource.cellToRowMap[ cell ] = row
    }
  }
  
  
  open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let row = dataSource.tableRow(atIndexPath: indexPath) else { return }
    row.displayState = .offScreen
    row.tableViewController(self, didEndDisplaying: cell, forRowAt: indexPath)
  }
  
  
  open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return dataSource.tableRow(atIndexPath: indexPath)?.preferredCellHeightCalculated ?? 44
  }
  
  
  open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let section = dataSource.sectionDefinition(at: section) {
      if let identifier = section.headerViewIdentifier {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        section.configure(headerView: view)
        return view
      }
    }
    return nil
  }
  
  
  open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if let section = dataSource.sectionDefinition(at: section) {
      return section.headerHeight
    }
    return 0
  }
  
  
  
  
  open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    guard let def = dataSource.sectionDefinition(at: section) else { return }
    def.displayState = .onScreen
    def.tableViewController(self, willDisplayHeaderView: view, forSection: section)
  }
  
  
  open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
    guard let def = dataSource.sectionDefinition(at: section) else { return }
    def.displayState = .offScreen
  }
  
  
  
  // MARK: UIScrollViewDelegate
  open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    view.window?.endEditing(true)
  }
  
  
  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    dataSource.scrollViewDidScroll(scrollView)
  }
  
}



open class BaseTableView: UITableView {
  
  open override var frame: CGRect {
    didSet {
      if let del = delegate as? TableViewFrameDelegate {
        del.tableViewFrameDidChange?(self)
      }
    }
  }
  
}


@objc public protocol TableViewFrameDelegate: UITableViewDelegate {
  
  
  @objc optional func tableViewFrameDidChange(_ tableView: UITableView)
  
  
}
