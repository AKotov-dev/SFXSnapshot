unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  XMLPropStorage, ExtCtrls, ComCtrls, Menus, Process, DefaultTranslator,
  Buttons;

type

  { TMainForm }

  TMainForm = class(TForm)
    Button1: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    ImageList1: TImageList;
    ImageList2: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    ListBox1: TListBox;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem6: TMenuItem;
    OpenDir: TSelectDirectoryDialog;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    AddBtn: TSpeedButton;
    SFXBtn: TSpeedButton;
    StaticText1: TStaticText;
    MainFormStorage: TXMLPropStorage;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure SFXBtnClick(Sender: TObject);
    procedure StartProcess(command, terminal: string);
    procedure ToolButton10Click(Sender: TObject);
  private

  public

  end;

resourcestring
  SNoSFXName = 'The name of the archive is not listed!';
  SNoDestFolder = 'Destination folder not found!';
  SListFileEmpty = 'The list of files is empty!';

var
  MainForm: TMainForm;
  WorkDir: string;

implementation

uses SelectUnit;

{$R *.lfm}

{ TMainForm }

//Общая процедура запуска команд
procedure TMainForm.StartProcess(command, terminal: string);
var
  ExProcess: TProcess;
begin
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := terminal;  //sh или terminal (sakura)
    if terminal <> 'sh' then
    begin
      ExProcess.Parameters.Add('--font');
      ExProcess.Parameters.Add('10');
      ExProcess.Parameters.Add('--columns');
      ExProcess.Parameters.Add('110');
      ExProcess.Parameters.Add('--rows');
      ExProcess.Parameters.Add('40');
      ExProcess.Parameters.Add('--title');
      ExProcess.Parameters.Add('Make SFX Snapshot');
      ExProcess.Parameters.Add('--execute'); //для xterm '-e'
    end
    else
      ExProcess.Parameters.Add('-c');

    ExProcess.Parameters.Add(command);
    ExProcess.Options := [poWaitOnExit];
    ExProcess.Execute;
  finally
    ExProcess.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TMainForm.ToolButton10Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  StartProcess('find ' + WorkDir + '/* -type f ! -name "*.xml" -delete', 'sh');
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  MainForm.Caption := Application.Title;
end;

procedure TMainForm.Button5Click(Sender: TObject);
begin
  if OpenDir.Execute then
    Edit2.Text := OpenDir.FileName;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //Рабочий каталог
  WorkDir := GetUserDir + '.SFXSnapshot';

  //Проверяем/создаём рабочий каталог
  if not DirectoryExists(WorkDir) then
    MkDir(WorkDir);

  //Настройки
  MainFormStorage.FileName := WorkDir + '/settings.xml';
end;

procedure TMainForm.MenuItem1Click(Sender: TObject);
var
  i: integer;
begin
  if ListBox1.SelCount <> 0 then
  begin
    for i := -1 + ListBox1.Items.Count downto 0 do
      if ListBox1.Selected[i] then
        ListBox1.Items.Delete(i);
  end;
end;

procedure TMainForm.AddBtnClick(Sender: TObject);
begin
  SelectForm.ShowModal;
end;

procedure TMainForm.SFXBtnClick(Sender: TObject);
var
  Root: string;
begin
  ListBox1.SetFocus;

  //Обрезаем пробелы в эдитах
  Edit1.Text := Trim(Edit1.Text);
  Edit2.Text := Trim(Edit2.Text);

  if Edit1.Text = '' then
  begin
    MessageDlg(SNoSFXName, mtWarning, [mbOK], 0);
    Edit1.SetFocus;
    Exit;
  end;

  if not DirectoryExists(Edit2.Text) then
  begin
    MessageDlg(SNoDestFolder, mtWarning, [mbOK], 0);
    Edit2.SetFocus;
    Exit;
  end;

  if ListBox1.Items.Count = 0 then
  begin
    MessageDlg(SListFileEmpty, mtWarning, [mbOK], 0);
    Exit;
  end;

  //Требовать root/su при распаковке SFX?
  if CheckBox1.Checked then
    Root := '--needroot'
  else
    Root := '';

  //Текущая директория
  SetCurrentDir(WorkDir);

  //Сохраняем список файлов/папок в ./files.lst
  ListBox1.Items.SaveToFile('./files.lst');

  //Запускаем sfx-creator.sh
  StartProcess('"' + ExtractFilePath(ParamStr(0)) + 'sfx-snapshot.sh" ' +
    '"' + Edit1.Text + '"' + ' ' + '"' + Edit2.Text + '" ' + Root, 'sakura');
end;

end.
