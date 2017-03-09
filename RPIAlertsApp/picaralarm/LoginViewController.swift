

import UIKit
import Firebase


class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    
    //Login button
    @IBAction func loginButton(_ sender: Any) {
        
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
            
            let user = FIRAuth.auth()?.currentUser
            let uid = user?.uid
            print("uid: \(uid)")
            if user != nil {
                self.performSegue(withIdentifier: "segueToAlerts", sender: nil)
            }
            else {
                print("incorrect email and pwd combo")
                
            }
            //reset fields
            self.passwordField.text = ""
            self.emailField.text = ""
        }
    }
    
    //Check Auth State when view loads.
    override func viewDidLoad() {
        super.viewDidLoad()
        FIRAuth.auth()?.addStateDidChangeListener({ (auth:FIRAuth, user:FIRUser?) in
            
            let user = FIRAuth.auth()?.currentUser
            if user != nil {
                print("Welcome! \(user!.email)")
                self.performSegue(withIdentifier: "segueToAlerts", sender: nil)
                
            } else {
                print("No user, please log in")
                
            }
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
