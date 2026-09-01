# SkiaCustomThreadedBase
This is a high-performance, thread-rendered FMX component skeleton   
   
TSkiaCustomThreadedBase v0.4     
     
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/LaMitaOne/SkiaCustomThreadedBase)    
      
<img width="799" height="628" alt="Unbenannt" src="https://github.com/user-attachments/assets/e55fa704-ff24-445f-8948-82ac415637d9" />
   
It started as the engine of my vcl flowmotion, then morphed to skia flowmotion and now its in almost all i made for skia4delphi, so i thought maybe some base would be not bad to start from always....and maybe some of you can use it somehow too or ...make it better :)      
   
With this base, I can finally do all the things I always wanted to create... or probably more ^^  but sleep not so much anymore lol      

and now YOU can do everything you ever wanted TOO   
   
有 志 者，事 竟 成 (Yǒu zhì zhě, shì jìng chéng)   
"Where there is a will, there is a way."    
   
.How that Works:     
     
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
     

Latest Changes:       

 v 0.4:    
   - Added RealFPS monitoring (measures actual UI presentation rate).    
   - Frame counter based on TStopwatch (QPC), updated inside Draw().    
    
 v 0.3:    
   - QPC absolute-deadline frame pacing (render time is subtracted).    
   - Hybrid Sleep/SpinWait + timeBeginPeriod(1) on Windows    
   - DeltaTime now uses QPC    
   - StopThread: real WaitFor instead of the old Sleep(100)
        
 v 0.2:    
   - Implemented Doublebuffering logic.    
       
Sample Project included       
    
The included Unit9 creates everything dynamically at runtime. It shows how to start/stop the thread and control the FPS without a single component dropped on the form designer.    
    
This is a base of that engine, showing only a little sample. It might not be "perfect," but it gets things running. Thought maybe some would like that, enjoy!     
     
   
If you want to tip me a coffee.. :)   
    
<p align="center">
  <a href="https://www.paypal.com/donate/?hosted_button_id=RX5KTTMXW497Q">
    <img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif" alt="Donate with PayPal"/>
  </a>
</p>
        

      
🎨 Skia4Delphi Components:    
   Alive Progress/Loading circle https://github.com/LaMitaOne/SkiaAliveProgress   
   Audio Visualizer https://github.com/LaMitaOne/SkiaAVisualizer        
   Skia Alive Grid https://github.com/LaMitaOne/Skia-AliveGrid    
   Skia-Flowmotion animated image grid https://github.com/LaMitaOne/skia-flowmotion   
   Skia-Slideshow https://github.com/LaMitaOne/Skia-Slideshow   
   Skia-Circlepopup https://github.com/LaMitaOne/skia-circlepopup  
   Skia-CubesPopup https://github.com/LaMitaOne/SkiaCubesPopup   
   Skia-Button https://github.com/LaMitaOne/SkiaButton    
   Skia Desktop Pet https://github.com/LaMitaOne/SkiaDesktopPetBase    
         
🧪 Skia4Delphi experimental Components:    
   CustomMultithreadedBase  https://github.com/LaMitaOne/SkiaCustomMultiThreadedBase    
   Page Control https://github.com/LaMitaOne/SkiaPageControl   
   Surface Widget/modules rendering engine https://github.com/LaMitaOne/MRX-Skia-Surface   
   LCARS fluid engine https://github.com/LaMitaOne/Skia-LCARS-Fluid-Engine   
   Fluid Magma effect https://github.com/LaMitaOne/Fluid-Magma-Effect    
      
