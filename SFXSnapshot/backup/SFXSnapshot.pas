program SFXSnapshot;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  SysUtils,
  Dialogs,
  SelectUnit;

{$R *.res}

begin
  Application.Scaled := True;
  Application.Title := 'SFXSnapshot v0.1';
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSelectForm, SelectForm);
  Application.Run;
end.
