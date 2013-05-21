import SimpleOpenNI.*; //for kinect openni libraries
import monclubelec.javacvPro.*; //for opencv libraries
import java.awt.*; //for rectange
import com.sun.jna.platform.win32.*; //for win32 libraries
import com.sun.jna.*; //for JNA libraries
import com.sun.jna.platform.win32.WinDef.*; //for win32 definitions
import java.util.ArrayList;

OpenCV opencv; 
SimpleOpenNI cam;
Rectangle[] faceRect;
Rectangle[] eyeRect;
int strBuffSize = 512;
char[] windowText = new char[strBuffSize];
String windowTitle = "AttentionTestingEyesFaceMouseKeyWindow";
String[] testResults = new String[10];
ArrayList<RECT> aboveWindows = new ArrayList<RECT>();
RECT rectOfInterest = new RECT();
HWND windowOfInterest;
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
  int windowsAway = 6; //the window of interest is six windows above the foreground window at the start
  windowOfInterest = User32.INSTANCE.GetForegroundWindow();
  for(int i = 0; i < windowsAway; i++)
  {
    windowOfInterest = User32.INSTANCE.GetWindow(windowOfInterest, new DWORD(User32.GW_HWNDPREV));
  }
  User32.INSTANCE.GetWindowText(windowOfInterest, windowText, strBuffSize);
  if(windowTitle.compareTo(Native.toString(windowText)) != 0)
  {
    println("ERROR: WRONG WINDOW OF INTEREST FOUND");
    exit();
  }
}


void keyPressed()
{
  if(key == ' ')
  {
    spacePress = true;
    spaceTimer = millis();
  }
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
boolean overlap = false;


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
  
  //window overlap detection
  windowUpdate();
  println(overlap);
  
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


//update whether the program window is overlapped or not
void windowUpdate()
{
  HWND currWindow = User32.INSTANCE.GetForegroundWindow();
  
  //get all the size/positions of windows above the window of interest
  while(true)
  {
    //So we don't get stuck in the loop if can't find the window of interest
    if(currWindow == null)
    {
      break;
    }
    RECT currRect = new RECT();
    User32.INSTANCE.GetWindowRect(currWindow, currRect);
    User32.INSTANCE.GetWindowText(currWindow, windowText, strBuffSize);
    
    //see we are at the window of interest
    //if we are, save the size/position and exit search
    if(windowOfInterest.equals(currWindow))
    {
      rectOfInterest = currRect;
      break;
    }
    else
    {
      //add positions/size of current window and get next window
      aboveWindows.add(currRect);
      currWindow = User32.INSTANCE.GetWindow(currWindow, new DWORD(User32.GW_HWNDNEXT));
    }
  }
  checkOverlap();
  aboveWindows.clear();
}


//check if the window of interest is below any other windows
void checkOverlap()
{
  //compare above window positions to window of interest to see if they overlap
  for(RECT currRect: aboveWindows)
  {
    //four cases of non overlap
    if(rectOfInterest.left > currRect.right) //completely to the right
    {
      continue;
    }
    if(rectOfInterest.right < currRect.left) //completely to the left
    {
      continue;
    }
    if(rectOfInterest.top > currRect.bottom) //completely below
    {
      continue;
    }
    if(rectOfInterest.bottom < currRect.top) //completely above
    {
      continue;
    }
    //since none of the four cases are satisfied, there must be overlap
    overlap = true;
    return;
  }
  //no overlap since we checked all above windows for overlap
  overlap = false;
}


//stores the current state as the result of the current test
void addResult()
{
  if(overlap)
  {
    testResults[currTest] = "Not Looking";
  }
  else if(millis() - keyTimer < 2000)
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
