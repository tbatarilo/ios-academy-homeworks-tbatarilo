//
//  LoginViewController.swift
//  TVShow
//
//  Created by Infinum Student Academy on 11/07/2018.
//  Copyright © 2018 Tomislav Batarilo. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var IBOutlet: UILabel!
    
    // MARK: -Private-
    private var numberOfTaps:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        IBOutlet.text = String("Tap on button")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonTapAction(_ sender: Any) {
        numberOfTaps = numberOfTaps + 1
        IBOutlet.text = String("Number of taps: ") + String(numberOfTaps)
        //print("TAP")
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}