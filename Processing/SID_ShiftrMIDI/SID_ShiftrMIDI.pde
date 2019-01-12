// This example sketch connects to shiftr.io
// and forwards the received messages as MIDI
//
// After starting the sketch you can find the
// client here: https://shiftr.io/try.
//
// Note: If you're running the sketch via the
// Android Mode you need to set the INTERNET
// permission in Android > Sketch Permissions.
//
// by Joël Gähwiler
// https://github.com/256dpi/processing-mqtt
// Modified by Simon Pfaff
// www.bleep-o-matic.com

// For ShiftrIO
import mqtt.*;
// For Midi
import themidibus.*;

MQTTClient client; // Create a Shiftr Client
MidiBus myBus;   // Create a Midi Bus Object.

void setup() {
  client = new MQTTClient(this);
  // Conect via Internet
  //client.connect("mqtt://try:try@broker.shiftr.io", "processing");
  
  // Connect To localHost (Use IP Adress of Shiftr Host)
  client.connect("mqtt://try:try@192.168.178.23", "processing");
    
  // MidiBus Setup
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

  // Either you can
  //                   Parent In Out
  //                     |    |  |
  //myBus = new MidiBus(this, 0, 1); // Create a new MidiBus using the device index to select the Midi input and output devices respectively.

  // or you can ...
  //                   Parent         In                   Out
  //                     |            |                     |
  //myBus = new MidiBus(this, "IncomingDeviceName", "OutgoingDeviceName"); // Create a new MidiBus using the device names to select the Midi input and output devices respectively.

  // or for testing you could ...
  //                 Parent  In        Out
  //                   |     |          |
  myBus = new MidiBus(this, -1, "IAC Bus 2"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
}

// Neccesary as otherwise no updates will happen
void draw() {}

void keyPressed() {
  client.publish("/hello", "world");
}

// Shiftr Callbacks
void clientConnected() {
  println("client connected");

  // Subscribe to your Topics Here
  // Gyroscope
  client.subscribe("/p11/gyr");
  // Magnetometer
  client.subscribe("/p11/mag");
}

// Here anything happens when a message comes in.

float[] gyrVals = new float[3];
float magVals = 0;

void messageReceived(String topic, byte[] payload) {
  println("new message: " + topic + " - " + new String(payload));
  
  // The payload is a "char" array, new String () converts that to one string
  String message = new String(payload);
  
  // The Message are CSV so we can split it with ,
  String[] s = split(message, ','); 
  
  float firstValueOfMessageAsFloat = float(s[0]);
  println("First Value Of Message: " + firstValueOfMessageAsFloat);
  
  // Handle the gyroscope:  
  if (topic.equals("/p11/gyr")) {  
    // Save the Values
    for (int i = 0; i < 3; i++) {   
      gyrVals[i] = float(s[i]);    
    }
    // Do Something with them
    GyroscopeMagic();
  }
  
  if (topic.equals("/p11/mag")) {  
    magVals = float(s[0]);
  } 
  
  println("GyrVals: X - " + gyrVals[0] + " Y - " + gyrVals[1] + " Z - " + gyrVals[2] + " MagVals: " +magVals);
  
}

void connectionLost() {
  println("connection lost");
}

void GyroscopeMagic() {

  // Example for creating a midi note:
  int channel = 0;     // Default channel
  int pitch = 60;      // Middle C 
  int velocity = 100;  // Some velocity
  
  // Example for creating a controller change
  int number = 20;     // CC 20
  
  if (gyrVals[0] > 20) {
  myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
  delay(200);
  myBus.sendNoteOff(channel, pitch, velocity); // Send a Midi nodeOff
  }
  
  // Clamp the value to a range between 0 and 127
  int value = (int)clamp(gyrVals[0]*0.5,0.0,127.0);
  myBus.sendControllerChange(channel, number, value); // Send a controllerChange
  
}

// Clamp values between min and max
public static float clamp(float val, float min, float max) {
    return Math.max(min, Math.min(max, val));
}
