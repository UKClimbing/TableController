//
//  TableController.swift
//  Rockfax
//
//  Created by Stephen Horne on 09/01/2019.
//  Copyright © 2019 Rockfax. All rights reserved.
//

import UIKit

@objc open class TableController: ViewController {
  
  
  public enum DisplayState {
    case hidden
    case visible
  }
  
  open override var canBecomeFirstResponder: Bool { true }
  
  
  @objc open var dataSource: TableDataSource
  
  @objc open var tableView: BaseTableView
  
  
  public init(style: UITableView.Style, dataSource: TableDataSource) {
    self.dataSource = dataSource
    tableView = BaseTableView(frame: .zero, style: style)
    super.init(nibName: nil, bundle: nil)
    dataSource.controller = self
    tableView.delegate = self
    if #available(iOS 15.0, *) {
      tableView.sectionHeaderTopPadding = 0.0  
    }
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.dataSource = dataSource
    tableView.prefetchDataSource = dataSource
    tableView.estimatedRowHeight = 0
    tableView.separatorStyle = .none
    modalPresentationStyle = .fullScreen
  }
  
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("No one likes storyboards.")
  }
  
  
  public func link(cell: UITableViewCell, with tableRow: TableRow) {
    dataSource.cellToRowMap[ cell ] = tableRow
  }
  

}



extension TableController {
  
  
  override open func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInsetAdjustmentBehavior = .never
    view.addSubview(tableView)
    tableView.frame = view.bounds
    dataSource._setupForTableView(tableView)
  }

  
  override open func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
  
  
}



extension TableController: TableViewFrameDelegate {
  
  
  open func tableViewFrameDidChange(_ tableView: UITableView) {
    dataSource.setEmptyDatasetViewFrameIfNeeded()
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
    if let cell = cell as? PaddingCell {
      if indexPath.section + 1 == dataSource.numberOfSections(in: tableView) && indexPath.row + 1 == dataSource.tableView(tableView, numberOfRowsInSection: indexPath.section) {
        cell.extensionViewHeightModifier = Rockfax.maxScreenEdge()
      } else {
        cell.extensionViewHeightModifier = 0
      }
    }
  }
  
  
  open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = self.tableView.cellForRow(at: indexPath) {
      dataSource.tableRow(atIndexPath: indexPath)?.performSelect(forTableViewController: self, cell: cell, indexPath: indexPath)
    }
  }
  
  
  open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    if let cell = self.tableView.cellForRow(at: indexPath) {
      dataSource.tableRow(atIndexPath: indexPath)?.perform__DESELECT__(forTableViewController: self, cell: cell, indexPath: indexPath)
    }
  }

  
  open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let row = dataSource.tableRow(atIndexPath: indexPath) else { return }
    row.displayState = .hidden
    row.tableController(self, didEndDisplaying: cell, forRowAt: indexPath)
  }
  
  
  open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let height = dataSource.tableRow(atIndexPath: indexPath)?.preferredCellHeightCalculated {
      return height
    }
    return 44
  }
  
  
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return self.tableView(tableView, heightForRowAt: indexPath)
  }
  
  
  public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return self.tableView(tableView, heightForHeaderInSection: section)
  }
  
  
//  public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
//    return self.tableView(tableView, heightForFooterInSection: section)
//  }
  
  
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



extension TableController {
  
  
  @objc func reloadData() {
    dataSource.generateSections()
    tableView.reloadData()
  }
  
  
}



open class BaseTableView: UITableView {
  
  
  var isContentOffsetLocked = false
  
  
  open override var frame: CGRect {
    didSet {
      if let del = delegate as? TableViewFrameDelegate {
        del.tableViewFrameDidChange?(self)
      }
    }
  }
  
  
  open override var contentOffset: CGPoint {
    set {
      if isContentOffsetLocked { return }
      if newValue.y > contentOffset.y {
        var t: String? = ""
        t = nil
      }
      if newValue.y < contentOffset.y {
        var t: String? = ""
        t = nil
      }
      super.contentOffset = newValue
    }
    get {
      return super.contentOffset
    }
  }

  
  var image: UIImage? {
    let renderer = UIGraphicsImageRenderer(size: contentSize)

    return renderer.image { _ in
      let savedContentOffset = contentOffset
      let savedFrame = frame
      
      let size = contentSize
      if size.width == 0 || size.height == 0 {
        return
      }

      contentOffset = .zero
      frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)

      layer.render(in: UIGraphicsGetCurrentContext()!)

      contentOffset = savedContentOffset
      frame = savedFrame
    }
  }
  
  
  public override init(frame: CGRect, style: UITableView.Style) {
    super.init(frame: frame, style: style)
  }
  
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}


@objc public protocol TableViewFrameDelegate: UITableViewDelegate {
  
  
  @objc optional func tableViewFrameDidChange(_ tableView: UITableView)
  
  
}
