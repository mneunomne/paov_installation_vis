import deadpixel.keystone.*;


Keystone ks;
CornerPinSurface surface;

PGraphics offscreen;
PFont font;

import netP5.*;
import oscP5.*;

import java.net.URLEncoder;

PShader blur;

OscP5 oscP5;

int numSpeakers = 25;
ArrayList<Speaker> speakers = new ArrayList<Speaker>();

 
JSONArray audios;

void setup() {
  size(displayWidth, displayHeight, P3D);
  
  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(width, height, 20);
  offscreen = createGraphics(width, height, P3D);
  blur = loadShader("blur.glsl"); 
  
  font = createFont("Courier New",40,true);
  offscreen.textFont(font);

   
  oscP5 = new OscP5(this, 32000);
 
  loadJSON();
}


JSONObject json;
void loadJSON() {
  json = loadJSONObject("data.json");
  audios = json.getJSONArray("audios");
  JSONArray participants = json.getJSONArray("speakers");
  for (int i = 0; i < participants.size(); i++) {    
    JSONObject item = participants.getJSONObject(i); 
    long id = item.getLong("id");    
    Speaker n = new Speaker(i, id);
    speakers.add(n);
  }
}

void draw() {
  // background(0, 10);
  // filter(BLUR, 1);
  
  offscreen.beginDraw();
  offscreen.textSize(18);
  offscreen.ellipseMode(RADIUS);
  // offscreen.background(0);
  offscreen.smooth();
  offscreen.filter(blur);
  offscreen.fill(0,67);
  offscreen.rect(-10, -10, width + 20, height + 20);
  // filter(THRESHOLD);
  offscreen.strokeWeight(1);
  offscreen.stroke(255);
  offscreen.noFill();
  offscreen.ellipse(width/2, height/2, height/2,height/2);
  offscreen.stroke(255);
  for(int i = 0; i < speakers.size(); i++) {
    speakers.get(i).display();
  }
  offscreen.endDraw();
  
  background(0);
  
  surface.render(offscreen);
}

int getSpeakerIndexFromId (long _id) {
  int index = 0;
  for(int i = 0; i < numSpeakers; i++) {
    if (_id == speakers.get(i).id) {
      println("found index!", i);
      index = i;
    }
  } 
  return index;
}

String getAudioTextFromId (int _id) {
  String text = "";
  for(int i = 0; i < audios.size(); i++) {
    JSONObject item = audios.getJSONObject(i);
    if (item.getInt("id") == _id) {
     text = item.getString("text");
    }
  }
  println("text", text);
  return text;
}


void oscEvent(OscMessage theOscMessage) {
  /* get and print the address pattern and the typetag of the received OscMessage */
  // println("### received an osc message with addrpattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
  // theOscMessage.print();

  if (speakers.size() == 0) return;
  
  if (theOscMessage.checkAddrPattern("/pos")==true) {
    int index = theOscMessage.get(0).intValue();  
    float theta = theOscMessage.get(1).floatValue();
    float radius = theOscMessage.get(2).floatValue() * height; 
    // set speaker position
    speakers.get(index).updatePos(theta, radius);
    return;
  }

  
  if (theOscMessage.checkAddrPattern("/play")==true) {
    String speaker_id = theOscMessage.get(0).stringValue();
    
    int audio_id = theOscMessage.get(1).intValue();
    // String word = URLDecoder.decode(theOscMessage.get(2).stringValue());
    String word = getAudioTextFromId(audio_id);
    // get speaker index
    int index = getSpeakerIndexFromId(Long.parseLong(speaker_id));
    // show word
    println("speaker_id: ", speaker_id);
    speakers.get(index).appear(word);
    return;
  }
  
  if (theOscMessage.checkAddrPattern("/end")==true) {
    String speaker_id = theOscMessage.get(0).stringValue();  
    int audio_id = theOscMessage.get(1).intValue();
    // get speaker index
    int index = getSpeakerIndexFromId(Long.parseLong(speaker_id));
    // hide word
    println("end", index);
    speakers.get(index).hide();
    return;
  }
}

void keyPressed () {
 switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped 
    // and moved
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load();
    break;

  case 's':
    // saves the layout
    ks.save();
    break;
  case 'r':
    background(0);
    blur = loadShader("blur.glsl"); 
    break;
  }
}
