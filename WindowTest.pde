import com.sun.jna.platform.win32.*;
import com.sun.jna.*;
import com.sun.jna.platform.win32.WinDef.*;
import java.util.ArrayList;

int strBuffSize;
char[] windowText;
char[] classText;
String windowTitle;
ArrayList<RECT> aboveWindows;
RECT rectOfInterest;
HWND windowOfInterest;
boolean newState = true;
boolean stateChanged = true;
boolean overlapped = false;

void setup()
{
  size(200, 200);
  strBuffSize = 512;
  windowText = new char[strBuffSize];
  classText = new char[strBuffSize];
  windowTitle = "WindowTest";
  aboveWindows = new ArrayList<RECT>();
  rectOfInterest = new RECT();
  windowOfInterest = User32.INSTANCE.GetForegroundWindow();
}

void draw()
{
  HWND currWindow = User32.INSTANCE.GetForegroundWindow();
  int i = 0;

  //get all the size/positions of windows above the window of interest
  while (true)
  {
    if(i ==  1000)
    {
      break;
    }
    /*if(stateChanged)
    {
      char[] asdf = new char[200];
      User32.INSTANCE.GetWindowText(currWindow, asdf, 200);
      println(Native.toString(asdf));
    }*/
    RECT currRect = new RECT();
    User32.INSTANCE.GetWindowRect(currWindow, currRect);
    User32.INSTANCE.GetWindowText(currWindow, windowText, strBuffSize);
    
    //see we are at the window of interest
    //if we are, save the size/position and exit search
    if(Native.toString(windowText).compareTo(windowTitle) == 0)
    {
      rectOfInterest = currRect;
      break;
    }
    else
    {
      //add positions/size of current window and get next window
      aboveWindows.add(currRect);
      currWindow = User32.INSTANCE.GetWindow(currWindow, new DWORD(User32.GW_HWNDNEXT));
      i++;
    }
  }
  stateChanged = false;
  checkOverlap();
  aboveWindows.clear();
}

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
    if(!overlapped)
    {
      overlapped = true;
      newState = true;
      stateChanged = true;
    }
    if(newState)
    {
      println("OVERLAP");
      newState = false;
    }
    return;
  }
  if(overlapped)
  {
    overlapped = false;
    newState = true;
    stateChanged = true;
  }
  if(newState)
  {
    println("NO OVERLAP");
    newState = false;
  }
}

