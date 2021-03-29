import netP5.*;
import oscP5.*;

import java.net.URLEncoder;

PShader blur;

OscP5 oscP5;

int numSpeakers = 25;
ArrayList<Speaker> speakers = new ArrayList<Speaker>();

 
JSONArray audios;

void setup() {
  size(800, 800, P2D);

  stroke(255);
  
  blur = loadShader("blur.glsl"); 
  
  PFont f = createFont("Courier New",40,true);
  textFont(f);
  textSize(18);
  
  oscP5 = new OscP5(this,32000);
  
  ellipseMode(RADIUS);
  // textAlign(CENTER);
  
  loadJSON();
  background(0);
  smooth();
}


JSONObject json;
void loadJSON() {
  json = loadJSONObject("data.json");
  audios = json.getJSONArray("audios");
  JSONArray participants = json.getJSONArray("speakers");
  for (int i = 0; i < participants.size(); i++) {    
    JSONObject item = participants.getJSONObject(i); 
    int id = item.getInt("id");    
    Speaker n = new Speaker(i, id);
    speakers.add(n);
  }
}

void draw() {
  // background(0, 10);
  // filter(BLUR, 1);
  
  filter(blur);
  strokeWeight(1);
  stroke(255);
  noFill();
  // ellipse(width/2, height/2, height/2,height/2);
  stroke(255);
  for(int i = 0; i < speakers.size(); i++) {
    speakers.get(i).display();
  }
}

int getSpeakerIndexFromId (int _id) {
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
    int speaker_id = theOscMessage.get(0).intValue();
    int audio_id = theOscMessage.get(1).intValue();
    // String word = URLDecoder.decode(theOscMessage.get(2).stringValue());
    String word = getAudioTextFromId(audio_id);
    // get speaker index
    int index = getSpeakerIndexFromId(speaker_id);
    // show word
    println("word: ", word);
    speakers.get(index).appear(word);
    return;
  }
  
  if (theOscMessage.checkAddrPattern("/end")==true) {
    int speaker_id = theOscMessage.get(0).intValue();  
    int audio_id = theOscMessage.get(1).intValue();
    // get speaker index
    int index = getSpeakerIndexFromId(speaker_id);
    // hide word
    println("end", index);
    speakers.get(index).hide();
    return;
  }
}

void keyPressed () {
 if (key == 'k') {
   background(0);
  blur = loadShader("blur.glsl"); 
 }
}
