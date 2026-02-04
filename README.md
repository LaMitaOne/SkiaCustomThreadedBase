# SkiaCustomThreadedBase
This is a high-performance, thread-rendered FMX component skeleton   
   
TSkiaCustomThreadedBase 
   
<img width="645" height="519" alt="Unbenannt" src="https://github.com/user-attachments/assets/2dceac2f-9dc1-481c-997d-45c82577d225" />
 
This is a high-performance, thread-rendered FMX component skeleton. It started as the engine of my vcl flowmotion, then of skia flowmotion and now its in almost all i made for sk4d,  so i thought maybe some base would be not bad to start from always....and maybe some of you can use it somehow too or ...make it better :)      
   
With this base, I can finally do all the things I always wanted to create... or probably more ^^  but sleep no tso much anymore lol        
   
How It Works:     
     
It splits the work into two distinct parts so your UI never freezes:    
    
    The Brain (Background Thread):   
    The engine runs a dedicated background thread. Every frame, it calculates the logic—math, physics, movement positions,    
    or transition steps—without touching the UI. This keeps your application responsive even during heavy calculations.    
    
    The Artist (Main UI Thread):   
    Once the math is done, the engine sends a safe signal to the Main Thread (UI).    
    The Main Thread then takes those coordinates and uses Skia4Delphi to draw them instantly to the screen.      
    
The Loop:    
Thread Logic -> Queue Safe Update -> UI Draw -> Repeat.     
Features     
    
     Non-Blocking UI: Logic runs in a background thread; rendering runs on the UI thread.    
     Hardware Accelerated: Uses Skia4Delphi for smooth, 60FPS+ graphics.    
     Virtual Methods: Override UpdateLogic for math and RenderEffect for drawing.    
     Built-In Demo: Includes a bouncing, pulsing rectangle to prove the thread is working.   
     
    
    
Sample Project    
    
The included Unit9 creates everything dynamically at runtime. It shows how to start/stop the thread and control the FPS without a single component dropped on the form designer.  
    
This is a base of that engine, showing only a little sample. It might not be "perfect," but it gets things running. Thought maybe some would like that, enjoy!     
