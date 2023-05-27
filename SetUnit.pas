unit SetUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, Grids, DBGrids, ExtCtrls, DBCtrls, ToolWin, ComCtrls, StdCtrls,
  IniFiles, Buttons;

type
  TSetForm = class(TForm)
    ModelsDS: TDataSource;
    PersonDS: TDataSource;
    Pages: TPageControl;
    MainPage: TTabSheet;
    ModelsPage: TTabSheet;
    ToolBar2: TToolBar;
    ModelsNav: TDBNavigator;
    ModelsGrid: TDBGrid;
    PersonPage: TTabSheet;
    PersonTB: TToolBar;
    PersonNav: TDBNavigator;
    PersonGrid: TDBGrid;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    FromED: TEdit;
    HostED: TEdit;
    Label3: TLabel;
    PortED: TEdit;
    LoginED: TEdit;
    Label4: TLabel;
    PasswordED: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    RecipMemo: TMemo;
    GroupBox2: TGroupBox;
    ScanGearPathED: TEdit;
    ScanGearPathBtn: TSpeedButton;
    RepTablePage: TTabSheet;
    ToolBar1: TToolBar;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    ReportDS: TDataSource;
    DataDS: TDataSource;
    DataTablePage: TTabSheet;
    ToolBar3: TToolBar;
    DBNavigator2: TDBNavigator;
    DBGrid2: TDBGrid;
    CheckOTKCB: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



implementation

{$R *.dfm}

uses DataModule;

procedure TSetForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  IniFile : TIniFile;
  i : integer;
begin
  //запись таблиц авторов и моделей
  if DataMod.PersonCDS.Modified then DataMod.PersonCDS.Post;
  if DataMod.ModelsCDS.Modified then DataMod.ModelsCDS.Post;
  if DataMod.ReportCDS.Modified then DataMod.ReportCDS.Post;
  if DataMod.DataCDS.Modified then DataMod.DataCDS.Post;
  DataMod.ModelsCDS.SaveToFile;
  DataMod.PersonCDS.SaveToFile;
  DataMod.ReportCDS.SaveToFile;
  DataMod.DataCDS.SaveToFile;
  //запись свойств почтового клиента
  MailSettings.port := StrToIntDef(PortED.Text,0);
  MailSettings.host := HostED.Text;
  MailSettings.login := LoginED.Text;
  MailSettings.password := PasswordED.Text;
  MailSettings.from := FromED.Text;
  MailSettings.Recipients.Clear;
  for I := 0 to RecipMemo.Lines.Count - 1 do
    if (length(RecipMemo.Lines[i])>0) then MailSettings.Recipients.Add(RecipMemo.Lines[i]);
  //данные ОТК
  ScanGearPath:=ScanGearPathED.Text;
  CheckScanGear:=self.CheckOTKCB.Checked;
  //запись в файл
  IniFile:=TIniFile.Create(path+'mainini.ini');
  IniFile.WriteInteger('MAILSET','PORT',MailSettings.port);
  IniFile.WriteString('MAILSET','HOST',MailSettings.host);
  IniFile.WriteString('MAILSET','LOGIN',MailSettings.login);
  IniFile.WriteString('MAILSET','PASSWORD',MailSettings.password);
  IniFile.WriteString('MAILSET','FROM',MailSettings.from);
  IniFile.WriteInteger('MAILRECIP','RECIPCNT',MailSettings.Recipients.Count);
  for I := 0 to MailSettings.Recipients.Count - 1 do
    IniFile.WriteString('MAILRECIP','ADDR'+IntToStr(i+1),MailSettings.Recipients[i]);
  IniFile.WriteString('SCANGEAR','PATH',ScanGearPath);
  IniFile.WriteBool('SCANGEAR','CHECK',CheckScanGear);
  IniFile.Free;
end;

procedure TSetForm.FormResize(Sender: TObject);
begin
  ModelsGrid.Columns[0].Width:=round(self.Width*0.18);
  ModelsGrid.Columns[1].Width:=round(self.Width*0.08);
  ModelsGrid.Columns[2].Width:=round(self.Width*0.12);
  ModelsGrid.Columns[3].Width:=round(self.Width*0.1);
  ModelsGrid.Columns[4].Width:=round(self.Width*0.1);
  ModelsGrid.Columns[5].Width:=round(self.Width*0.1);
  ModelsGrid.Columns[6].Width:=round(self.Width*0.08);
  ModelsGrid.Columns[7].Width:=round(self.Width*0.14);
  PersonGrid.Columns[0].Width:=round(self.Width*0.3);
  PersonGrid.Columns[1].Width:=round(self.Width*0.15);
  PersonGrid.Columns[2].Width:=round(self.Width*0.15);
  PersonGrid.Columns[3].Width:=round(self.Width*0.31);
  ModelsGrid.Columns[3].PickList:=ModelLst;
  ModelsGrid.Columns[4].PickList:=MarkLst;
end;

procedure TSetForm.FormShow(Sender: TObject);
var
  i : integer;
begin
  //список выбора прав автора
  Pages.TabIndex:=0;
  PersonGrid.Columns[1].PickList.Add(acsShift);
  PersonGrid.Columns[1].PickList.Add(acsShop);
  PersonGrid.Columns[1].PickList.Add(acsAdmin);
  //вывод свойств почтового клиента
  FromED.Text:=MailSettings.from;
  HostED.Text:=MailSettings.host;
  PortED.Text:=IntToStr(MailSettings.port);
  LoginED.Text:=MailSettings.login;
  PasswordED.Text:=MailSettings.password;
  RecipMemo.Lines.Clear;
  for I := 0 to MailSettings.Recipients.Count - 1 do
    RecipMemo.Lines.Add(MailSettings.Recipients[i]);
  //сверка с ОТК
  ScanGearPathED.Text:=ScanGearPath;
  self.CheckOTKCB.Checked:=CheckScanGear;
end;

end.
