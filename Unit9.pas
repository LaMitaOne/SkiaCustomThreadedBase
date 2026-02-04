unit Unit9;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.Controls.Presentation,
  // Add your custom unit here
  uSkiaCustomThreadedBase;

type
  TForm9 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private-Deklarationen }
    // FIX: Updated type name to match the new unit
    FSkiaView: TSkiaCustomThreadedBase;

    btnStart: TButton;
    btnStop: TButton;
    btnToggleFPS: TButton;

    procedure OnStartClick(Sender: TObject);
    procedure OnStopClick(Sender: TObject);
    procedure OnToggleFPSClick(Sender: TObject);
  public
    { Public-Deklarationen }
  end;

var
  Form9: TForm9;

implementation

{$R *.fmx}

procedure TForm9.FormCreate(Sender: TObject);
begin
  // 1. Create the Custom Skia Component
  FSkiaView := TSkiaCustomThreadedBase.Create(Self);
  FSkiaView.Parent := Self;
  FSkiaView.Align := TAlignLayout.Client;
  FSkiaView.Margins.Rect := TRectF.Create(10, 10, 10, 10);
  FSkiaView.HitTest := False;
  FSkiaView.Active := False;

  // 2. Create Start Button
  btnStart := TButton.Create(Self);
  btnStart.Parent := Self;
  btnStart.Text := 'Start Animation';
  btnStart.Width := 120;
  btnStart.Height := 40;
  btnStart.Position.X := 20;
  btnStart.Position.Y := 20;
  btnStart.OnClick := OnStartClick;

  // 3. Create Stop Button
  btnStop := TButton.Create(Self);
  btnStop.Parent := Self;
  btnStop.Text := 'Stop Animation';
  btnStop.Width := 120;
  btnStop.Height := 40;
  btnStop.Position.X := 150;
  btnStop.Position.Y := 20;
  btnStop.OnClick := OnStopClick;

  // 4. Create Toggle FPS Button
  btnToggleFPS := TButton.Create(Self);
  btnToggleFPS.Parent := Self;
  btnToggleFPS.Text := 'Toggle 30/60 FPS';
  btnToggleFPS.Width := 140;
  btnToggleFPS.Height := 40;
  btnToggleFPS.Position.X := 280;
  btnToggleFPS.Position.Y := 20;
  btnToggleFPS.OnClick := OnToggleFPSClick;
end;

procedure TForm9.FormDestroy(Sender: TObject);
begin
  // No need to explicitly free FSkiaView or Buttons
  // because we passed "Self" (Form) as Owner.
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

procedure TForm9.OnToggleFPSClick(Sender: TObject);
begin
  if Assigned(FSkiaView) then
  begin
    if FSkiaView.TargetFPS = 60 then
      FSkiaView.TargetFPS := 30
    else
      FSkiaView.TargetFPS := 60;

    if Assigned(btnToggleFPS) then
      btnToggleFPS.Text := 'FPS: ' + IntToStr(FSkiaView.TargetFPS);
  end;
end;

end.
