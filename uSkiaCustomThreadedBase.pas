{*******************************************************************************
  SkiaThreadedRenderer
********************************************************************************
  A high-performance, threaded FMX Skia component.
  Utilizing Skia4Delphi for off-screen rendering.

  Key Features:
  - Threaded Architecture: Separates Logic/Rendering from the UI Thread.
  - Non-Blocking UI: Main thread remains responsive even at high load.
  - Double Buffering: Renders to offscreen surfaces to prevent flickering.

*******************************************************************************}
{ Skia-Threaded-Renderer v0.2                                                   }
{ by The Developer                                                                }
{                                                                              }
{------------------------------------------------------------------------------}
{
  Latest Changes:
   v 0.2:
   - Implemented Doublebuffering logic.
}

unit uSkiaCustomThreadedBase;

interface

uses
  System.SysUtils, System.Types, System.Classes, System.Math, System.UITypes,
  System.SyncObjs,
  FMX.Types, FMX.Controls, FMX.Skia,
  System.Skia;

type
  { TSkiaCustomThreadedBase
    High-performance, thread-rendered FMX Skia component with Double Buffering.

    Changes from standard:
    1. Rendering happens in the background thread (CPU Raster).
    2. The Main Thread only displays the pre-rendered image (Snapshot).
  }
  TSkiaCustomThreadedBase = class(TSkCustomControl)
  private
    { Threading & Sync }
    FThread: TThread;
    FLock: TCriticalSection;
    FTargetFPS: Integer;
    FThreadActive: Boolean;
    FPaused: Boolean;

    { Double Buffering }
    FBackBuffer: ISkImage; // Holds the finished picture from the thread

    { Logic Properties }
    FActive: Boolean;

    { Demo Mode State }
    FDemoRect: TRectF;
    FDemoVelocity: TPointF;
    FAngle: Single;

    { Setters }
    procedure SetActive(const Value: Boolean);
    procedure SetTargetFPS(const Value: Integer);

    { Internal Thread Methods }
    procedure ThreadSafeInvalidate;
    procedure StartThread;
    procedure StopThread;
  protected
    procedure Resize; override;
    // The Main Thread Draw - Just shows the image
    procedure Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single); override;

    { Virtual Methods - Override these in your components }
    { 1. LOGIC: Called inside the thread loop. Update math/physics here. }
    procedure UpdateLogic(const DeltaTime: Double); virtual;
    { 2. RENDER: Called inside the thread loop. Draw to the Offscreen Canvas here. }
    procedure RenderEffect(const ACanvas: ISkCanvas; const ADest: TRectF; const ATime: Double); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property HitTest default True;
    property Opacity;
    property Visible;
    property Width;
    property Height;
    { Component Properties }
    property Active: Boolean read FActive write SetActive default False;
    property TargetFPS: Integer read FTargetFPS write SetTargetFPS default 60;
  end;

implementation

{==============================================================================
  TSkiaCustomThreadedBase
==============================================================================}

constructor TSkiaCustomThreadedBase.Create(AOwner: TComponent);
begin
  inherited;
  FLock := TCriticalSection.Create;
  FThreadActive := False;
  FPaused := True;
  FActive := False;
  FTargetFPS := 60;
  SetBounds(0, 0, 300, 200);
  HitTest := True;
  // Demo Mode Init
  FDemoRect := TRectF.Create(50, 50, 100, 100);
  FDemoVelocity := TPointF.Create(150, 100);
  FAngle := 0.0;
end;

destructor TSkiaCustomThreadedBase.Destroy;
begin
  StopThread;
  FreeAndNil(FLock);
  inherited;
end;

procedure TSkiaCustomThreadedBase.Resize;
begin
  inherited;
  // Optional: If we resized, the thread needs to know to create a new sized surface.
  // Our thread logic handles this by checking Width/Height every frame.
end;

procedure TSkiaCustomThreadedBase.StartThread;
begin
  if FThreadActive then Exit;
  FThreadActive := True;

  FThread := TThread.CreateAnonymousThread(
    procedure
    var
      LastTime, CurrentTime: Cardinal;
      DeltaSec: Double;
      SleepTime: Integer;
      LocalSurface: ISkSurface;
      Snapshot: ISkImage;
      TargetRect: TRectF;
    begin
      LastTime := TThread.GetTickCount;
      while not TThread.CheckTerminated do
      begin
        CurrentTime := TThread.GetTickCount;
        DeltaSec := (CurrentTime - LastTime) / 1000.0;
        LastTime := CurrentTime;

        // 1. UPDATE LOGIC
        if not FPaused then
          UpdateLogic(DeltaSec);

        // 2. RENDER TO OFFSCREEN BUFFER (The Magic Part)
        // We check if we have a size to avoid errors
        if (Self.Width > 0) and (Self.Height > 0) then
        begin
          // Create a temporary raster surface in memory.
          // This is safe to do in a background thread.
          LocalSurface := TSkSurface.MakeRaster(Round(Self.Width), Round(Self.Height));

          if Assigned(LocalSurface) then
          begin
            TargetRect := RectF(0, 0, Self.Width, Self.Height);

            // Call the user's drawing code.
            // IMPORTANT: This now runs in the BACKGROUND THREAD!
            RenderEffect(LocalSurface.Canvas, TargetRect, TThread.GetTickCount / 1000.0);

            // Convert the drawing to a snapshot image
            Snapshot := LocalSurface.MakeImageSnapshot;

            // 3. SWAP BUFFERS SAFELY
            // Lock for a very short time just to swap the pointer
            FLock.Acquire;
            try
              FBackBuffer := Snapshot; // The main thread will see this
            finally
              FLock.Release;
            end;
          end;
        end;

        // 4. REQUEST MAIN THREAD UPDATE
        // Tell the UI to refresh (it will just draw the image we just made)
        ThreadSafeInvalidate;

        // FPS Control
        if FTargetFPS > 0 then
          SleepTime := Round(1000 / FTargetFPS)
        else
          SleepTime := 16;
        Sleep(SleepTime);
      end;
      FThreadActive := False;
    end);

  FThread.FreeOnTerminate := True;
  FThread.Start;
end;

procedure TSkiaCustomThreadedBase.StopThread;
begin
  if not FThreadActive then Exit;
  if Assigned(FThread) then
    FThread.Terminate;
    // Wait a bit for the loop to finish gracefully
    Sleep(100);
end;

procedure TSkiaCustomThreadedBase.ThreadSafeInvalidate;
begin
  if csDestroying in ComponentState then Exit;
  TThread.Queue(nil,
    procedure
    begin
      if not (csDestroying in ComponentState) and Assigned(Self) then
        Self.Redraw;
    end);
end;

procedure TSkiaCustomThreadedBase.Draw(const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  ImageToDraw: ISkImage;
begin
  // 1. GRAB THE LATEST IMAGE
  FLock.Acquire;
  try
    ImageToDraw := FBackBuffer;
  finally
    FLock.Release;
  end;

  // 2. DRAW IT
  if Assigned(ImageToDraw) then
  begin
    // Simply draw the snapshot.
    // We use High quality sampling just in case of scaling,
    // though NearestNeighbor is faster if 1:1 pixel mapping.
    ACanvas.DrawImage(ImageToDraw, 0, 0, TSkSamplingOptions.High);
  end
  else
  begin
    // Fallback if thread hasn't started yet
    ACanvas.Clear(TAlphaColors.Black);
  end;
end;

{------------------------------------------------------------------------------
  DEMO MODE (Built-in visualization - Runs in Thread now!)
------------------------------------------------------------------------------}

procedure TSkiaCustomThreadedBase.UpdateLogic(const DeltaTime: Double);
var
  NewLeft, NewTop: Single;
begin
  // 1. Move Rectangle
  FDemoRect.Offset(FDemoVelocity.X * DeltaTime, FDemoVelocity.Y * DeltaTime);
  NewLeft := FDemoRect.Left;
  NewTop := FDemoRect.Top;

  if NewLeft < 0 then
  begin
    FDemoVelocity.X := Abs(FDemoVelocity.X);
    FDemoRect.Left := 0;
  end
  else if FDemoRect.Right > Width then
  begin
    FDemoVelocity.X := -Abs(FDemoVelocity.X);
    FDemoRect.Left := Width - FDemoRect.Width;
  end;

  if NewTop < 0 then
  begin
    FDemoVelocity.Y := Abs(FDemoVelocity.Y);
    FDemoRect.Top := 0;
  end
  else if FDemoRect.Bottom > Height then
  begin
    FDemoVelocity.Y := -Abs(FDemoVelocity.Y);
    FDemoRect.Top := Height - FDemoRect.Height;
  end;

  // 2. Animate the Pulse
  FAngle := FAngle + (3.0 * DeltaTime);
end;

procedure TSkiaCustomThreadedBase.RenderEffect(const ACanvas: ISkCanvas; const ADest: TRectF; const ATime: Double);
var
  Paint: ISkPaint;
  Font: ISkFont;
  Typeface: ISkTypeface;
  PulseFactor: Single;
  GVal: Integer;
  CurrentColor: TAlphaColor;
begin
  if not FActive then
  begin
    // Draw "Paused" state
    Paint := TSkPaint.Create;
    Paint.Style := TSkPaintStyle.Fill;
    Paint.Color := $FF1E1E1E;
    ACanvas.DrawRect(ADest, Paint);

    Typeface := TSkTypeface.MakeDefault;
    Font := TSkFont.Create(Typeface, 20);
    Paint.Style := TSkPaintStyle.Fill;
    Paint.Color := TAlphaColors.White;
    ACanvas.DrawSimpleText('Thread Active: Paused', 20, Height / 2, Font, Paint);
    ACanvas.DrawSimpleText('Set Active = True to Demo', 20, (Height / 2) + 30, Font, Paint);
  end
  else
  begin
    // 1. Pulse Math
    PulseFactor := (Sin(FAngle) + 1) / 2;

    // 2. Background
    Paint := TSkPaint.Create;
    Paint.Style := TSkPaintStyle.Fill;
    Paint.Color := $FF000000;
    ACanvas.DrawRect(ADest, Paint);

    // 3. Pulsing Rect
    GVal := Round(255 * PulseFactor);
    CurrentColor := $FF000000 or (GVal shl 8) or $000000FF;
    Paint.Style := TSkPaintStyle.Fill;
    Paint.Color := CurrentColor;
    Paint.AlphaF := 0.8 + (0.2 * PulseFactor);
    Paint.ImageFilter := TSkImageFilter.MakeBlur(10 + (10 * PulseFactor), 10 + (10 * PulseFactor));
    ACanvas.DrawRect(FDemoRect, Paint);

    // 4. Border
    Paint.Style := TSkPaintStyle.Stroke;
    Paint.StrokeWidth := 2;
    Paint.Color := TAlphaColors.White;
    Paint.ImageFilter := nil;
    ACanvas.DrawRect(FDemoRect, Paint);
  end;
end;

procedure TSkiaCustomThreadedBase.SetActive(const Value: Boolean);
begin
  if FActive <> Value then
  begin
    FActive := Value;
    if FActive then
    begin
      if not FThreadActive then
        StartThread;
      FPaused := False;
    end
    else
    begin
      FPaused := True;
    end;
    ThreadSafeInvalidate;
  end;
end;

procedure TSkiaCustomThreadedBase.SetTargetFPS(const Value: Integer);
begin
  if FTargetFPS <> Value then
    FTargetFPS := Value;
end;

end.
