//
//  ViewController.swift
//  Rockfax
//
//  Created by Stephen Horne on 15/03/2020.
//  Copyright © 2020 Rockfax. All rights reserved.
//

import UIKit

@objc open class ViewController: UIViewController {
  
  
  private var _viewDidAppearAtLeastOnce: Bool = false
    

  /// Override if you like
  @objc dynamic open func viewDidAppearFirstTime(_ animated: Bool) {
    
  }
  

}




extension ViewController {

  
  override open func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !_viewDidAppearAtLeastOnce {
      _viewDidAppearAtLeastOnce = true
      viewDidAppearFirstTime(animated)
    }
  }

  
}
