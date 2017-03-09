#Python Script for Pi2
#For personal use only, not for commercial distribution
#https://www.instructables.com/member/imjasonc/

from sense_hat import SenseHat
import time
import pyrebase
import os

config = {
  "apiKey": "apikey",
  "authDomain": "projectid.firebaseapp.com",
  "databaseURL": "https://projectid.firebaseio.com",
  "storageBucket": "projectid.appspot.com"
}

firebase = pyrebase.initialize_app(config)

auth = firebase.auth()
user = auth.sign_in_with_email_and_password("youremail@gmail.com", "yourpassword")
db = firebase.database()

startTime = time.time()
refreshTimer = time.time()
#print(startTime)

sense = SenseHat()
#sense.rotation = 270



while True:
    currentTime = time.time()
    
    #1 10 second DB check loop
    if (currentTime - startTime) >= 10:
        print("checked firebase db: %s" % (time.strftime("%c")))
        #check for new message on db for Pi2
        ledmessage = db.child("notifypi2").get(user["idToken"])
        ledmessage =ledmessage.val()
        while ledmessage != "":
            sense.show_message(ledmessage)
            for event in sense.stick.get_events():
                if event.direction == "middle":
                    sense.clear()
                    ledmessage = ""
                    db.child("notifypi2").set("", user["idToken"]) #turn off notifypi2 notification message
        startTime = currentTime #reset timer

    #refresh user token
    if (currentTime - refreshTimer) >= 1800:
        user = auth.refresh(user["refreshToken"])
        refreshTimer = currentTime #reset refreshtimer
        print("token refresh: %s" % (time.strftime("%c")))
