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

void setup()
{
  cam = new SimpleOpenNI(this); //initialize kinect camera
  cam.setMirror(true);
  cam.enableRGB();
  
  opencv = new OpenCV(this);
  opencv.allocate(cam.rgbWidth(), cam.rgbHeight()); //size of image buffer
  
  size(cam.rgbWidth(), cam.rgbHeight()); //size of window
}

//for printing output only when it changes
int prevFaces = -1;
int prevLongFaces = -1;
int prevTime = -1000;
boolean updateOutput = true;

void keyPressed()
{
  if(key == ' ')
  {
    spacePress = true;
    startTime = millis();
  }
}

int startTime = 0;
boolean spacePress = false;

void draw()
{
  cam.update(); //get new frame/info from kinect
  opencv.copy(cam.rgbImage()); //get the current frame into opencv
  
  opencv.cascade("C:/opencv/data/haarcascades/", "haarcascade_frontalface_alt_tree.xml"); //initialize detection of face
  faceRect = opencv.detect(false); //get rectangle array of faces
  
  int numFaces = faceRect.length;

  if(spacePress && (millis() - startTime) > 3000)
  {
    if(numFaces == 1)
    {
      testResults[currTest] = "Looking";
    }
    else if(numFaces == 0)
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
  
  if(currTest >= 10)
  {
    noLoop();
    println("\nAll tests completed. Results were as follows:");
    for(int i = 0; i < 10; i++)
    {
      print("Test " + (i + 1) + ": ");
      println(testResults[i]);
    }
  }
  
  image(cam.rgbImage(), 0, 0); //draw the rgb image on screen
  opencv.drawRectDetect(false); //draw rectangles on faces on rgb image
 
  opencv.cascade("C:/opencv/data/haarcascades/", "haarcascade_eye.xml"); //initialize detection of eyes
  eyeRect = opencv.detect(false);
  opencv.drawRectDetect(false);
}
