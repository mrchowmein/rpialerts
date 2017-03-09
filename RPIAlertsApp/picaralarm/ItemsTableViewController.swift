import UIKit
import Firebase
import AVFoundation


class ItemsTableViewController: UITableViewController {
    
    var player:AVAudioPlayer = AVAudioPlayer()
    
    var alertItems = [Item]()
    
    var ref: FIRDatabaseReference!
    
    private var databaseHandle: FIRDatabaseHandle!
    
    
    //Logout button
    @IBAction func logoutButton(_ sender: Any) {
        
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    //Send your Pi1 a message
    @IBAction func didTapAddItem(_ sender: UIBarButtonItem) {
        let prompt = UIAlertController(title: "Message Pi", message: "Send your Pi a Message", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            self.ref.child("notifypi1").setValue(userInput)
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil);
        
    }
    
    // Observer
    func startObservingDatabase () {
        
        databaseHandle = ref.child("alerts").observe(.value, with: { (snapshot) in
            var newItems = [Item]()
            
            for itemSnapShot in snapshot.children {
                let item = Item(snapshot: itemSnapShot as! FIRDataSnapshot)
                newItems.append(item)
                
                //Play audio when there is a change
                self.player.play()
            }
            self.alertItems = newItems
            self.tableView.reloadData()
        })
    }
    
    
    //Check auth state when view appears
    override func viewDidAppear(_ animated: Bool) {
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth:FIRAuth, user:FIRUser?) in
            
            let user = FIRAuth.auth()?.currentUser
            if user != nil {
                print("logged in")
                
            } else {
                print("No user, please log in")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    
    //when view loads, create a Firebase DB reference and call observer function.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference()
        startObservingDatabase()
        
        do{
            let audioPath = Bundle.main.path(forResource: "gameover", ofType: "mp3")
            try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            
        }
            
        catch{
            
        }
        
    }
    
    // Tableview
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alertItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = alertItems[indexPath.row]
        cell.textLabel?.text = item.title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = alertItems[indexPath.row]
            item.ref?.removeValue()
        }
    }
}
