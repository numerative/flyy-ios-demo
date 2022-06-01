//
//  ViewController.swift
//  FlyyX Integration
//
//  Created by Michael Hathi on 31/05/22.
//

import UIKit
import FlyyFramework

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Flyy.sharedInstance.setUser(externalUserId: "test_user_ios")
        // Do any additional setup after loading the view.
    }


    @IBAction func openOffers(_ sender: Any) {
        //TODO: 1. Navigate to Offers Page
        Flyy.sharedInstance.openOffersPage()
    }
    @IBAction func openCart(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
}

