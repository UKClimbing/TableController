//
//  TableController.swift
//  Rockfax
//
//  Created by Stephen Horne on 09/01/2019.
//  Copyright © 2019 Rockfax. All rights reserved.
//

import UIKit

@objc open class TableController: UIViewController {
  
  
  public enum DisplayState {
    case hidden
    case visible
  }
  
  
  @objc open var dataSource: TableDataSource
  
  
  @objc open var tableView: UITableView
  
  
  private var _viewDidAppearAtLeastOnce: Bool = false
    
  
  public init(style: UITableView.Style, dataSource: TableDataSource) {
    self.dataSource = dataSource
    tableView = UITableView(frame: .zero, style: style)
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
    fatalError("No one likes storyboards.")
  }
  
  

  /// Override if you like
  open func viewDidAppearFirstTime(_ animated: Bool) {
    
  }
  
  
  public func link(cell: UITableViewCell, with tableRow: TableRow) {
    dataSource.cellToRowMap[ cell ] = tableRow
  }
  

}



extension TableController {
  
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(tableView)
    tableView.frame = view.bounds
    dataSource._setupForTableView(tableView)
  }
  
  
  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if _viewDidAppearAtLeastOnce == false {
      _viewDidAppearAtLeastOnce = true
      viewDidAppearFirstTime(animated)
    }
  }
  
  
  override open func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
  
  
}



extension TableController: UITableViewDelegate {
  
  
  /// If you override this function in your subclass you should make sure you call `link(cell: UITableViewCell, with tableRow: TableRow)`
  /// at some point. This allows you to later reference one from the other like `cell.tableRow` or `tableRow.cell` or `cell.tableSection`.
  /// This relies on the cell being in the view hierachy of a TableController.
  /// - Parameters:
  ///   - tableView: The tableView
  ///   - cell: The cell
  ///   - indexPath: The indexPath
  open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if let row = dataSource.tableRow(atIndexPath: indexPath) {
      row.displayState = .visible
      cell.selectionStyle = row.selectionStyle
      row.tableController(self, willDisplay: cell, forRowAt: indexPath)
      link(cell: cell, with: row)
    }
  }
  
  
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

  
  open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let row = dataSource.tableRow(atIndexPath: indexPath) else { return }
    row.displayState = .hidden
    row.tableController(self, willDisplay: cell, forRowAt: indexPath)
  }
  
  
  open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return dataSource.tableRow(atIndexPath: indexPath)?.preferredCellHeightCalculated ?? 44
  }
  
  
  open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if let section = dataSource.tableSection(at: section) {
      if let identifier = section.headerViewIdentifier {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier)
        section.configure(headerView: view)
        return view
      }
    }
    return nil
  }
  
  
  open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if let section = dataSource.tableSection(at: section) {
      return section.headerHeight
    }
    return 0
  }
  
  
  open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    guard let def = dataSource.tableSection(at: section) else { return }
    def.displayState = .visible
    def.tableController(self, willDisplayHeaderView: view, forSection: section)
  }
  
  
  open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
    guard let def = dataSource.tableSection(at: section) else { return }
    def.displayState = .hidden
  }

  
}



extension TableController /* UIScrollViewDelegate */ {

  
  open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    view.window?.endEditing(true)
  }
  
  
  open func scrollViewDidScroll(_ scrollView: UIScrollView) {
    dataSource.scrollViewDidScroll(scrollView)
  }
  
  
}
