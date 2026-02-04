# SkiaCustomThreadedBase
This is a high-performance, thread-rendered FMX component skeleton   
   
TSkiaCustomThreadedBase 
   
<img width="645" height="519" alt="Unbenannt" src="https://github.com/user-attachments/assets/2dceac2f-9dc1-481c-997d-45c82577d225" />
 
It started as the engine of my vcl flowmotion, then morphed to skia flowmotion and now its in almost all i made for skia4delphi, so i thought maybe some base would be not bad to start from always....and maybe some of you can use it somehow too or ...make it better :)      
   
With this base, I can finally do all the things I always wanted to create... or probably more ^^  but sleep not so much anymore lol      

and now YOU can do everything you ever wanted TOO   
   
有 志 者，事 竟 成 (Yǒu zhì zhě, shì jìng chéng)   
"Where there is a will, there is a way."   
ehm yes accidently understood now how chinese signs basically work too :D   
   
But back to skia :D ...How that Works:     
     
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
     
    
Sample Project included       
    
The included Unit9 creates everything dynamically at runtime. It shows how to start/stop the thread and control the FPS without a single component dropped on the form designer.    
    
This is a base of that engine, showing only a little sample. It might not be "perfect," but it gets things running. Thought maybe some would like that, enjoy!     
  
*P.S. I know a hot pic on fb or something would give way easier some likes... but still, you are allowed to click like here too! ;) *
    
and maybe that way you understand now how chinese signs work too....:   
   
<img width="1337" height="1022" alt="Unbenannt" src="https://github.com/user-attachments/assets/875d37af-b07b-4090-b663-ee8402f23eca" />
