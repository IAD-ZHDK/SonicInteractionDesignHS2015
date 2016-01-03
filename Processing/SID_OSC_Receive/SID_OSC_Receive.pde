/**
 * A Example Scetch for recieving OSC message and converting them to MIDI events.
 * For the SID course HS 2015.
 * simon.pfaff@zhdk.ch 
 * oscP5sendreceive by andreas schlegel: "http://www.sojamo.de/oscP5"
 * The MIDIBus by Severin Smith: "http://www.smallbutdigital.com/"
 */

// The OSC Library
import oscP5.*;
import netP5.*;
// The Midi Library
import themidibus.*;

MidiBus myBus;   // Create a Midi Bus Object.

OscP5 oscP5;     // Create a OSC Object. 
//NetAddress myRemoteLocation;

float oldAccX = 0;

void setup() {
  
  // Basic Processing Setup
  size(400,400);
  frameRate(25);
  
  // OSC Setup
  // start oscP5, listening for incoming messages at port 6006
  oscP5 = new OscP5(this,6006);
  
  /* osc plug service
   * osc messages with a specific address pattern can be automatically
   * forwarded to a specific method of an object. in this example 
   * a message with address pattern /accelerometer will be forwarded to a method
   * accelerometer(). below the method test takes 3 arguments - 3 floats. therefore each
   * message with address pattern /accelermoeter and typetag fff will be forwarded to
   * the method accelerometer(float x, float y, float z)
   */
  oscP5.plug(this,"accelerometer","/accelerometer");
  oscP5.plug(this,"gyroscope","/gyroscope");
  oscP5.plug(this,"magnetometer","/magnetometer");
  oscP5.plug(this,"irTemperature","/IrTemperature");
  oscP5.plug(this,"humidity","/humidity");
  oscP5.plug(this,"pressure","/pressure");
  oscP5.plug(this,"luxometer","/luxometer");
  oscP5.plug(this,"buttons","/buttons");
  
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
  myBus = new MidiBus(this, -1, "to Max 1"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
}

// Each of the functions below will be called individually if a OSC message with the respective address is received.
public void accelerometer(String _x, String _y, String _z) {

  // As the values are received as strings they have to be converted to floats
  float x = Float.parseFloat(_x);
  float y = Float.parseFloat(_y);
  float z = Float.parseFloat(_z);
  
  println("### plug event method. received a message /accelerometer.");
  println(" 3 floats received: "+x+", "+y+", "+z);  
  
  // Example for creating a midi note:
  int channel = 0;     // Default channel
  int pitch = 60;      // Middle C 
  int velocity = 100;  // Some velocity
  
  // Example for creating a controller change
  int number = 20;     // CC 20
  
  // Calculate delataX
  float deltaX = abs(oldAccX - x);
  oldAccX = x;
  
  // If the deltaX is bigger than 1 play a sound
  if (deltaX > 1) {
    oldAccX = 0;
    
    // This is for sending MIDI notes
    myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
    delay(200);
    myBus.sendNoteOff(channel, pitch, velocity); // Send a Midi nodeOff
    
    // Clamp the value to a range between 0 and 127
    int value = (int)clamp(x*50,0,127);
    myBus.sendControllerChange(channel, number, value); // Send a controllerChange
  }
}

public void gyroscope(String _x, String _y, String _z) {
  
  float x = Float.parseFloat(_x);
  float y = Float.parseFloat(_y);
  float z = Float.parseFloat(_z);
  
  println("### plug event method. received a message /gyroscope.");
  println(" 3 floats received: "+x+", "+y+", "+z);  
}

public void magnetometer(String _x, String _y, String _z) {
  
  float x = Float.parseFloat(_x);
  float y = Float.parseFloat(_y);
  float z = Float.parseFloat(_z);
  
  println("### plug event method. received a message /magnetometer.");
  println(" 3 floats received: "+x+", "+y+", "+z);  
}

public void irTemperature(String _objectTemperature, String _ambientTemperature) {
  
  float objectTemperature = Float.parseFloat(_objectTemperature);
  float ambientTemperature = Float.parseFloat(_ambientTemperature);
  
  println("### plug event method. received a message /IrTemperature.");
  println(" 2 floats received: "+objectTemperature+", "+ambientTemperature);  
}

public void humidity(String _temperature, String _humidity) {
  
  float temperature = Float.parseFloat(_temperature);
  float humidity = Float.parseFloat(_humidity);
  
  println("### plug event method. received a message /humidity.");
  println(" 2 floats received: "+temperature+", "+humidity);  
}

public void pressure(String _pressure) {
  
  float pressure = Float.parseFloat(_pressure);
  
  println("### plug event method. received a message /pressure.");
  println(" 1 float received: "+pressure);  
}

public void luxometer(String _lux) {
  
  float lux = Float.parseFloat(_lux);
  
  println("### plug event method. received a message /luxometer.");
  println(" 1 float received: "+lux);  
}

public void buttons(int _left, int _right, int _reedRelay) {
  println("### plug event method. received a message /buttons.");
  println(" 3 ints received: "+_left+", "+_right+", "+_reedRelay);  
}


void draw() {
  background(0);
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  /* with theOscMessage.isPlugged() you check if the osc message has already been
   * forwarded to a plugged method. if theOscMessage.isPlugged()==true, it has already 
   * been forwared to another method in your sketch. theOscMessage.isPlugged() can 
   * be used for double posting but is not required.
  */  
  if(theOscMessage.isPlugged()==false) {
  /* print the address pattern and the typetag of the received OscMessage */
  println("### received an osc message.");
  println("### addrpattern\t"+theOscMessage.addrPattern());
  println("### typetag\t"+theOscMessage.typetag());
  }
}

// Clamp values between min and max
public static float clamp(float val, float min, float max) {
    return Math.max(min, Math.min(max, val));
}
