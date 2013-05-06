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
  cam.enableRGB(); //using the RGB camera.  Can not use IR camera now.
  cam.enableDepth();
  
  opencv = new OpenCV(this);
  opencv.allocate(cam.rgbWidth(), cam.rgbHeight()); //size of image buffer
  opencv.cascade("C:/opencv/data/haarcascades/", "haarcascade_frontalface_alt_tree.xml"); //initialize detection of face
  
  size(cam.rgbWidth(), cam.rgbHeight()); //size of window
}

void draw()
{
  cam.update(); //get new frame/info from kinect
  opencv.copy(cam.rgbImage()); //get the current frame into opencv
  faceRect = opencv.detect(false); //get rectangle array of faces
  int numFaces = faceRect.length;
  
  
  
  image(cam.depthImage(), 0, 0); //draw the image on the screen
  opencv.drawRectDetect (false); //draw rectangles on faces
}

