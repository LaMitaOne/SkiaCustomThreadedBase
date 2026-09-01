unit Unit9;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.Controls.Presentation,
  uSkiaCustomThreadedBase;

type
  TForm9 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FSkiaView: TSkiaCustomThreadedBase;

    // Ein Layout hält die UI stabil, damit FMX beim Neuzeichnen nicht spinnt
    UILayout: TLayout;
    btnStart: TButton;
    btnStop: TButton;
    lblFPS: TLabel;
    tbFPS: TTrackBar;
    FPSTimer: TTimer;

    procedure OnStartClick(Sender: TObject);
    procedure OnStopClick(Sender: TObject);
    procedure OnFPSTracking(Sender: TObject);
    procedure OnFPSTimer(Sender: TObject);
  public
    { Public-Deklarationen }
  end;

var
  Form9: TForm9;

implementation

{$R *.fmx}

procedure TForm9.FormCreate(Sender: TObject);
begin
  Caption := 'Skia Threaded Base Sample';
  ClientWidth := 800;
  ClientHeight := 600;

  // 1. UI Layout (Sorgt dafür, dass die Trackbar nicht flackert/verspringt)
  UILayout := TLayout.Create(Self);
  UILayout.Parent := Self;
  UILayout.Align := TAlignLayout.Top;
  UILayout.Height := 70;
  UILayout.HitTest := True;

  // 2. Create the Custom Skia Component
  FSkiaView := TSkiaCustomThreadedBase.Create(Self);
  FSkiaView.Parent := Self;
  FSkiaView.Align := TAlignLayout.Client;
  FSkiaView.Margins.Rect := TRectF.Create(10, 10, 10, 10);
  FSkiaView.HitTest := False;
  FSkiaView.Active := False;

  // 3. Create Start Button
  btnStart := TButton.Create(Self);
  btnStart.Parent := UILayout;
  btnStart.Text := 'Start Animation';
  btnStart.Width := 120;
  btnStart.Height := 40;
  btnStart.Position.X := 20;
  btnStart.Position.Y := 15;
  btnStart.OnClick := OnStartClick;

  // 4. Create Stop Button
  btnStop := TButton.Create(Self);
  btnStop.Parent := UILayout;
  btnStop.Text := 'Stop Animation';
  btnStop.Width := 120;
  btnStop.Height := 40;
  btnStop.Position.X := 150;
  btnStop.Position.Y := 15;
  btnStop.OnClick := OnStopClick;

  // 5. Create FPS Label
  lblFPS := TLabel.Create(Self);
  lblFPS.Parent := UILayout;
  lblFPS.Text := 'Target: 60 | Real: 0 FPS';
  lblFPS.Position.X := 290;
  lblFPS.Position.Y := 10;
  lblFPS.Width := 200;
  lblFPS.StyledSettings := [];
  lblFPS.TextSettings.Font.Size := 12;

  // 6. Create FPS TrackBar
  tbFPS := TTrackBar.Create(Self);
  tbFPS.Parent := UILayout;
  tbFPS.Min := 1;
  tbFPS.Max := 200;
  tbFPS.Frequency := 1;
  tbFPS.Value := 60;
  tbFPS.Width := 250;
  tbFPS.Position.X := 290;
  tbFPS.Position.Y := 30;
  tbFPS.OnChange := OnFPSTracking;

  // 7. Create FPS Update Timer
  FPSTimer := TTimer.Create(Self);
  FPSTimer.Interval := 500;
  FPSTimer.OnTimer := OnFPSTimer;
  FPSTimer.Enabled := True;
end;

procedure TForm9.FormDestroy(Sender: TObject);
begin
  // Owned components are freed automatically
end;

procedure TForm9.OnStartClick(Sender: TObject);
begin
  if Assigned(FSkiaView) then
    FSkiaView.Active := True;
end;

procedure TForm9.OnStopClick(Sender: TObject);
begin
  if Assigned(FSkiaView) then
    FSkiaView.Active := False;
end;

procedure TForm9.OnFPSTracking(Sender: TObject);
begin
  if Assigned(FSkiaView) and Assigned(tbFPS) then
  begin
    // In FMX nutzt man .Value statt .Position
    FSkiaView.TargetFPS := Round(tbFPS.Value);
  end;
end;

procedure TForm9.OnFPSTimer(Sender: TObject);
begin
  if Assigned(FSkiaView) and Assigned(lblFPS) then
  begin
    lblFPS.Text := Format('Target: %d | Real: %d FPS', [FSkiaView.TargetFPS, FSkiaView.RealFPS]);
  end;
end;

end.
