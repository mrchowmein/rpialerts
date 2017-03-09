import Foundation
import FirebaseDatabase

class Item {
    
    var ref: FIRDatabaseReference?
    var title: String?
    
    init (snapshot: FIRDataSnapshot) {
        ref = snapshot.ref
        
        let data = snapshot.value as! Dictionary<String, String>
        title = data["alertmessage"]! as String
    }
    
}
