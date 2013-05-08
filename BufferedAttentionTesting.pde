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
String[] testResults = new String[10];
int currTest = 0;

void setup()
{
  cam = new SimpleOpenNI(this); //initialize kinect camera
  cam.setMirror(true);
  cam.enableRGB();
  
  opencv = new OpenCV(this);
  opencv.allocate(cam.rgbWidth(), cam.rgbHeight()); //size of image buffer
  opencv.cascade("C:/opencv/data/haarcascades/", "haarcascade_frontalface_alt_tree.xml"); //initialize detection of face
  
  size(cam.rgbWidth(), cam.rgbHeight()); //size of window
}

//for printing output only when it changes
int prevFaces = -1;
int prevLongFaces = -1;
int prevTime = -1000;
int buffNumFaces = 0;
boolean updateOutput = true;

//print findings to the terminal
void faceUpdate(int numFaces)
{
  //only update when the face state has changed for more than 1000 milli seconds or the number of people have changed
  if(millis() - prevTime >= 1000 && prevFaces == numFaces && updateOutput)
  {
    if(prevLongFaces != numFaces)
    {
      buffNumFaces = numFaces;
    }
    prevLongFaces = numFaces;
    updateOutput = false;
  }
  if(numFaces != prevFaces)
  {
    prevTime = millis();
    updateOutput = true;
  }    
  prevFaces = numFaces;
}

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
  faceRect = opencv.detect(false); //get rectangle array of faces
  int numFaces = faceRect.length;
  
  faceUpdate(numFaces);
  
  if(spacePress && (millis() - startTime) > 3000)
  {
    if(buffNumFaces == 1)
    {
      testResults[currTest] = "Looking";
    }
    else if(buffNumFaces == 0)
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

  //printOutput(numFaces);
  
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
}
