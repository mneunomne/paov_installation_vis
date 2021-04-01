// Noise Walker
class Speaker {
  long id;
  float posX = 0;
  float posY = 0;
  boolean loaded = false;
  String curWord;
  float curWordWidth; 
  boolean showWord = false;
  int index;
  float curPosX;
  float curPosY;
  float curTheta;
  float curRadius; 
  float theta, radius; 
  Speaker (int _index, long _id) {
    id = _id;
    index = _index;
  }
  
  void display () {
    if (!loaded) return;
    offscreen.pushMatrix();
    posX = posX + (curPosX - posX) * 0.1;
    posY = posY + (curPosY - posY) * 0.1;
    
    theta = theta + (curTheta - theta) * 0.1;
    radius = radius + (curRadius - radius) * 0.1;
    // drawCharacters("tesettese");
     // point(posX, posY);
     offscreen.strokeWeight(2);
     offscreen.translate(offscreen.width/2, offscreen.height/2);
     if (showWord) {
        drawCharacters(curWord);
        // translate(-curWordWidth/2, 0);
        // text(curWord, 0, 0);
      } else {
        offscreen.point(posX, posY);
      }
    offscreen.popMatrix();
  }
  
  void drawCharacters (String word) {
    float arclength = -curWordWidth/2;
    // For every box
    for (int i = 0; i < word.length(); i++)
    {
      // Instead of a constant width, we check the width of each character.
      char currentChar = word.charAt(i);
      float w = offscreen.textWidth(currentChar);
  
      // Each box is centered so we move half the width
      arclength += w/2;
      
      float angle = theta + arclength / radius;    
  
      offscreen.pushMatrix();
      // translate(width/2, height/2);
      // Polar to cartesian coordinate conversion
      offscreen.translate(radius*cos(angle), radius*sin(angle));
      // Rotate the box
      offscreen.rotate(angle+PI/2); // rotation is offset by 90 degrees
      // Display the character
      offscreen.fill(255);
      offscreen.text(currentChar,0,0);
      offscreen.popMatrix();
      // Move halfway again
      arclength += w/2;
    }
  }
  
  void updatePos(float _theta, float _radius) {
    loaded = true; 
    curTheta = _theta;
    curRadius = _radius;
    if (posX == 0 && posY == 0) {
      posX = radius * cos( theta );
      posY = radius * sin( theta );
      theta = _theta;
      radius = _radius;
    }
    curPosX = radius * cos( theta );
    curPosY = radius * sin( theta );
  }
  
  void appear (String word) {
    if (word == null) return;
    showWord = true;
    curWord = word;
    curWordWidth = textWidth(curWord);
  }
  
  void hide () {
    showWord = false;
  }
}
