program PatchCreator;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  unique_utils,
  SysUtils,
  Dialogs,
  Unit2 { you can add units after this };

var
  MyProg: TUniqueInstance;

{$R *.res}

begin
  Application.Title:='PatchCreator v0.8-0';
  //Создаём объект с уникальным идентификатором
  MyProg := TUniqueInstance.Create('PatchCreator');

  //Проверяем, нет ли в системе объекта с таким ID
  if MyProg.IsRunInstance then
  begin
    MessageDlg('Приложение уже запущено!', mtWarning, [mbOK], 0);
    MyProg.Free;
    Halt(1);
  end
  else
    MyProg.RunListen;

  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TSelectForm, SelectForm);
  Application.Run;
end.
