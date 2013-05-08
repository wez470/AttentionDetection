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

void setup()
{
  cam = new SimpleOpenNI(this); //initialize kinect camera
  cam.setMirror(true);
  cam.enableRGB();
  cam.enableDepth();
  cam.enableScene();
  
  opencv = new OpenCV(this);
  opencv.allocate(cam.rgbWidth(), cam.rgbHeight()); //size of image buffer
  opencv.cascade("C:/opencv/data/haarcascades/", "haarcascade_frontalface_alt_tree.xml"); //initialize detection of face
  
  size(cam.rgbWidth() * 2, cam.rgbHeight()); //size of window
}

//detecting how many people are in the scene
int findNumPeople()
{
  int[] objectMap = cam.sceneMap();
  ArrayList<Integer> maxPeople = new ArrayList<Integer>();
  for(int i = 0; i < objectMap.length; i++)
  {
    if(!maxPeople.contains(objectMap[i]))
    {
      maxPeople.add(objectMap[i]);
    }
  }
  return (maxPeople.size() - 1);
}

//for printing output only when it changes
int prevFaces = -1;
int prevLongFaces = -1;
int prevPeople = -1;
int prevTime = -1000;
int tenSecondTimer = 0;
boolean updateOutput = true;
boolean notificationSent = false;

//print findings to the terminal
void printOutput(int numFaces, int numPeople)
{
  //only update when the face state has changed for more than 500 milli seconds or the number of people have changed
  if((millis() - prevTime >= 500 && prevFaces == numFaces && updateOutput) || prevPeople != numPeople)
  {
    if(prevLongFaces != numFaces || prevPeople != numPeople)
    {
      println("Number of people: " + numPeople + "\tNumber paying attention: " + numFaces);
      //reset ability to send not paying attention message because someone is looking now
      if(numFaces > 0)
      {
        notificationSent = false;
      }
    }
    prevLongFaces = numFaces;
    updateOutput = false;
  }
  if(numFaces != prevFaces)
  {
    prevTime = millis();
    updateOutput = true;
  } 
  
  if(numFaces == 0 && prevFaces == 0 && !notificationSent)
  {
    if(millis() - tenSecondTimer > 10000)
    {
      println("3 seconds have gone by since you looked");
      tenSecondTimer = millis();
      notificationSent = true;
    }
  }
  else
  {
    //restart timer
    tenSecondTimer = millis();
  }
  
  prevFaces = numFaces;
  prevPeople = numPeople;
}

void draw()
{
  cam.update(); //get new frame/info from kinect
  opencv.copy(cam.rgbImage()); //get the current frame into opencv
  faceRect = opencv.detect(false); //get rectangle array of faces
  int numFaces = faceRect.length;
  int numPeople = findNumPeople();
  
  printOutput(numFaces, numPeople);
  
  image(cam.rgbImage(), 0, 0); //draw the rgb image on screen
  image(cam.sceneImage(), cam.sceneWidth(), 0); //draw scene image on screen
  opencv.drawRectDetect (false); //draw rectangles on faces on rgb image
}

