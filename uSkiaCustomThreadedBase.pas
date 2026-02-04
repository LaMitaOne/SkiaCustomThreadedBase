unit uSkiaCustomThreadedBase;

interface

uses
  System.SysUtils, System.Types, System.Classes, System.Math, System.UITypes,
  System.SyncObjs,
  FMX.Types, FMX.Controls, FMX.Skia,
  System.Skia;

type
  { TSkiaCustomThreadedBase
    A high-performance, thread-rendered FMX Skia component.

    Features:
    - Logic runs in a background thread (Non-blocking UI).
    - Rendering is synchronized to the UI thread (Safe).
    - Uses ISkCanvas for hardware-accelerated drawing.

    Usage:
    Inherit from this class and override:
    1. UpdateLogic: Calculate math, physics, and state.
    2. RenderEffect: Draw to the ISkCanvas.
  }
  TSkiaCustomThreadedBase = class(TSkCustomControl)
  private
    { Threading & Sync }
    FThread: TThread;
    FLock: TCriticalSection;
    FTargetFPS: Integer;
    FThreadActive: Boolean;
    FPaused: Boolean;

    { Logic Properties }
    FActive: Boolean;

    { Demo Mode State (To prove functionality when inherited directly) }
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
    begin
      LastTime := TThread.GetTickCount;

      while not TThread.CheckTerminated do
      begin
        CurrentTime := TThread.GetTickCount;
        DeltaSec := (CurrentTime - LastTime) / 1000.0;
        LastTime := CurrentTime;

        if not FPaused then
          UpdateLogic(DeltaSec);

        ThreadSafeInvalidate;

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
  begin
    FThread.Terminate;
    Sleep(50);
  end;
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
begin
  RenderEffect(ACanvas, ADest, TThread.GetTickCount / 1000.0);
end;

{------------------------------------------------------------------------------
  DEMO MODE (Built-in visualization)
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
