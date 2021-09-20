program SFXSnapshot;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  unique_utils,
  SysUtils,
  Dialogs,
  SelectUnit;

var
  MyProg: TUniqueInstance;

{$R *.res}

begin
  Application.Scaled:=True;
  Application.Title:='SFXSnapshot v0.1';
  //Создаём объект с уникальным идентификатором
  MyProg := TUniqueInstance.Create('SFXSnapshot');

  //Проверяем, нет ли в системе объекта с таким ID
  if MyProg.IsRunInstance then
  begin
    MessageDlg('Application is running!', mtWarning, [mbOK], 0);
    MyProg.Free;
    Halt(1);
  end
  else
    MyProg.RunListen;

  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TSelectForm, SelectForm);
  Application.Run;
end.
