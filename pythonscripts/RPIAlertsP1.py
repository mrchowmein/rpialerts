#Python Script for Pi1
#For personal use only, not for commercial distribution
#https://www.instructables.com/member/imjasonc/

#1
from sense_hat import SenseHat
import time
import pyrebase
import os
from twilio.rest import TwilioRestClient

#2 setup firebase and twilio
#firebase
config = {
  "apiKey": "yourapikey",
  "authDomain": "projectid.firebaseapp.com",
  "databaseURL": "https://projectid.firebaseio.com",
  "storageBucket": "projectid.appspot.com"
}
firebase = pyrebase.initialize_app(config)

#twilo
accountSID = "Your_SID"
authToken = "Your_authToken"
twilioCli = TwilioRestClient(accountSID, authToken)
myTwilioNumber = "+1your_twilio_number"
myCellPhone = "+1yourcell_phone_number:

#3 authentication
auth = firebase.auth()
user = auth.sign_in_with_email_and_password("youremail@gmail.com", "yourpassword")
db = firebase.database()


#4 start time when script runs
startTime = time.time()
refreshTimer = time.time()
sense = SenseHat()
#sense.rotation = 270

def get_cpu_temp():
    res = os.popen('vcgencmd measure_temp').readline()
    t = float(res.replace("temp=","").replace("'C\n",""))
    return(t)

#5
while True:

    #6 check current time when loop starts
    currentTime = time.time()
    cpuTemp = get_cpu_temp()

    #get accelerometer values. values represents g forces.
    accel = sense.get_accelerometer_raw()
    x = accel['x']
    y = accel['y']
    z = accel['z']
    x = abs(round(x, 1))
    y = abs(round(y, 1))
    z = abs(round(z, 1))

    #7 Only update Firebase Database and sms user if g force is greater than 1
    if x > 1 or y > 1 or z > 1:
        sense.show_letter("!", text_colour=[255,0,0])
        timestamp = time.strftime("%c")
        print(timestamp)
        message = ("Movement at %s" % (timestamp))
        #message= ("movement! x: %.1fg, y: %.1fg, z: %.1fg" % (x,y,z))
        data = {"alertmessage": message}
        db.child("alerts").push(data, user["idToken"])
        db.child("notifypi2").set("!!!", user["idToken"])
        twilioCli.messages.create(body=("Movement Detected %s" %(timestamp)), from_=myTwilioNumber, to=myCellPhone)
        print(message)
        time.sleep(3)
        sense.clear()

    #8 10 second DB check loop
    if (currentTime - startTime) >= 10:
        #check for new message on db for Pi1
        ledmessage = db.child("notifypi1").get(user["idToken"])
        ledmessage =ledmessage.val()
        if ledmessage != None:
            sense.show_message(ledmessage)
            sense.clear()
            time.sleep(5)
            db.child("notifypi1").set("", user["idToken"])
        print("checked firebase db: %s" % (time.strftime("%c")))
        startTime = currentTime

        #cpu temp notification
        if cpuTemp > 70:
            timestamp = time.strftime("%c")
            message = ("Pi1 %s: CPU Temp %s" % (timestamp, cpuTemp))
            data = {"alertmessage": message}
            db.child("alerts").push(data, user["idToken"])
            db.child("notifypi2").set("Pi1 Temp!", user["idToken"])
            twilioCli.messages.create(body="CPU Temp Warning", from_=myTwilioNumber, to=myCellPhone)
            
    #9 refresh user token
    if (currentTime - refreshTimer) >= 1800:
        user = auth.refresh(user["refreshToken"])
        refreshTimer = currentTime
        print("token refresh: %s" % (time.strftime("%c")))
