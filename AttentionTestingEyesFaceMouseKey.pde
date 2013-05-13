//openni and nite wrapper libraries
import SimpleOpenNI.*;

//opencv wrapper libraries
import monclubelec.javacvPro.*;

//for Rectangle
import java.awt.*;

import java.util.ArrayList;

OpenCV opencv; 
SimpleOpenNI cam;
Rectangle[] faceRect;
Rectangle[] eyeRect;
String[] testResults = new String[10];
int currTest = 0;
int numTests = 3;

void setup()
{
  cam = new SimpleOpenNI(this); //initialize kinect camera
  cam.setMirror(true);
  cam.enableRGB();
  
  opencv = new OpenCV(this);
  opencv.allocate(cam.rgbWidth(), cam.rgbHeight()); //size of image buffer
  
  size(cam.rgbWidth(), cam.rgbHeight()); //size of window
}

void keyPressed()
{
  if(key == ' ')
  {
    spacePress = true;
    spaceTimer = millis();
  }
  keyWasPressed = true;
  keyTimer = millis();
}

void mousePressed()
{
  mouseWasPressed = true;
}

int mouseTimer = 0;
int keyTimer = 0;
int spaceTimer = 0;
int currNumFaces = 0;
int currNumEyes = 0;
boolean spacePress = false;
boolean mouseWasPressed = false;
boolean keyWasPressed = false;

void draw()
{
  cam.update(); //get new frame/info from kinect
  opencv.copy(cam.rgbImage()); //get the current frame into opencv
  
  opencv.cascade("C:/opencv/data/haarcascades/", "haarcascade_frontalface_alt_tree.xml"); //initialize detection of face
  faceRect = opencv.detect(false); //get rectangle array of faces
  
  currNumFaces = faceRect.length;
  
  image(cam.rgbImage(), 0, 0); //draw the rgb image on screen
  opencv.drawRectDetect(false); //draw rectangles on faces on rgb image
 
  opencv.cascade("C:/opencv/data/haarcascades/", "haarcascade_eye.xml"); //initialize detection of eyes
  eyeRect = opencv.detect(false); //get rectangle array of eyes
  
  currNumEyes = eyeRect.length;
  
  opencv.drawRectDetect(false); //draw rectangles on eyes on rgb image
  
  //mouse activity detection
  mouseUpdate();
  
  //get results (delay so user can get ready for test)
  if(spacePress && (millis() - spaceTimer) > 3000)
  {
    addResult();
  }
  
  //show results and stops program updating
  if(currTest >= numTests)
  {
    showResults();
  }
}

//updates the time since last activity with the mouse
void mouseUpdate()
{
  if(mouseX != pmouseX || mouseY != pmouseY || mouseWasPressed)
  {
    mouseTimer = millis();
    mouseWasPressed = false;
  }
}

//stores the current state as the result of the current test
void addResult()
{
  if(millis() - keyTimer < 2000)
  {
    testResults[currTest] = "Looking";
  }
  else if(millis() - mouseTimer < 2000)
  {
    testResults[currTest] = "Looking";
  }
  else if(currNumEyes == 2)
  {
    testResults[currTest] = "Looking";
  }
  else if(currNumFaces == 1)
  {
    testResults[currTest] = "Looking";
  }
  else if(currNumFaces == 0)
  {
    testResults[currTest] = "Not Looking";
  }
  else
  {
    testResults[currTest] = "Bad Data";
  }
  println("Data recorded for test " + (currTest + 1)); 
  spacePress = false;
  currTest++;
}

//prints results of tests
void showResults()
{
  noLoop();
  println("\nAll tests completed. Results were as follows:");
  for(int i = 0; i < numTests; i++)
  {
    print("Test " + (i + 1) + ": ");
    println(testResults[i]);
  }
}
