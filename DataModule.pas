unit DataModule;

interface

uses
  SysUtils, Classes, DB, DBClient, Dialogs, Forms, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP, IdMessage, IdIOHandler,
  IdIOHandlerSocket, IdSSLOpenSSL, IdSocks, IniFiles, WinTypes, Messages,
  IdCoder, IdCoder3to4, IdCoderMIME;

const
  ininame='mainini.ini';
  acsShift='��������� �����';
  acsShop ='��������� ����';
  acsAdmin='�������������';
  mdASSEMBL      =1;
  mdFINALBALANCE =2;
  mdFROMWIREHOUSE=3;
  mdTOWIREHOUSE  =4;
  mdSHIPMENT     =5;
  mdFORREPEAR    =6;
  mdFORSALE      =7;
  mdSTARTBALANCE =8;
  mdPREVBALANCE  =9;
  mdLOTASSEMBL   =10;
  wmMailThreadTerminated = wm_User+1;

type
  TDataMod = class(TDataModule)
    ModelsCDS: TClientDataSet;
    PersonCDS: TClientDataSet;
    ReportCDS: TClientDataSet;
    DataCDS: TClientDataSet;
    procedure ConnectToBase;
    procedure DataModuleCreate(Sender: TObject);
    procedure SendEMail(Handle : HWND);
    function  GetLogCnt(fname,id : string):integer;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  //����� ������� ��������� ������� (��� �������� � �����)
  TMailSettings = class(TObject)
  public
    port : integer;
    host, login, password,
    from, subject, attrachfilename : string;
    Recipients,Body : TStringList;
    destructor  Destroy; override;
  private
    constructor Create;
  end;

  //��������� ����� ��� ��������� �������� ���������
  TMailThread = class(tthread)
  public
    settings : TMailSettings;
    ParentFormHandle : HWND;
  protected
    procedure execute; override;
  end;


var
  DataMod : TDataMod;
  AutorID           : integer=0;           //ID ������ ������
  ModelLst, MarkLst : TStringList;         //������ ID �������, ������ ��������
  Path              : string = 'base\';    //���� � ���� ������
  RepPath           : string = 'reports\'; //���� � ���� �������
  MailSettings      : TMailSettings;       //��������� ��������� �������
  MailtHread        : TMailThread;         //����� ��� �������� �����
  MailIsBeingSent   : boolean = false;     //���� "����� ������������"
  ScanGearPath      : string = '';         //���� � ������ ���
  CheckScanGear     : boolean = true;      //������� ������������ � ���

implementation

{$R *.dfm}


procedure TDataMod.ConnectToBase;
var
  IniFile : TIniFile;
  cnt,i : integer;
begin
  Path:=ExtractFilePath(application.ExeName)+Path;
  RepPath:=ExtractFilePath(application.ExeName)+RepPath;
  if not DirectoryExists(path) then CreateDir(path);
  if not DirectoryExists(reppath) then CreateDir(reppath);
  self.ModelsCDS.CreateDataSet;
  self.PersonCDS.CreateDataSet;
  self.ReportCDS.CreateDataSet;
  self.DataCDS.CreateDataSet;
  self.ModelsCDS.FileName:=path+'modelsttable.xml';
  self.PersonCDS.FileName:=path+'persontable.xml';
  self.ReportCDS.FileName:=path+'reporttable.xml';
  self.DataCDS.FileName:=path+'datatable.xml';
  if FileExists(self.ModelsCDS.FileName) then self.ModelsCDS.LoadFromFile;
  if FileExists(self.PersonCDS.FileName) then self.PersonCDS.LoadFromFile;
  if FileExists(self.ReportCDS.FileName) then self.ReportCDS.LoadFromFile;
  if FileExists(self.DataCDS.FileName) then self.DataCDS.LoadFromFile;
  ModelLst:=TStringList.Create;
  if FileExists(path+'modellst.txt') then ModelLst.LoadFromFile(path+'modellst.txt');
  MarkLst:=TStringList.Create;
  if FileExists(path+'marklst.txt') then MarkLst.LoadFromFile(path+'marklst.txt');
  MailSettings := TMailSettings.Create;
  if FileExists(path+'mainini.ini') then begin
    IniFile:=TIniFile.Create(path+'mainini.ini');
    MailSettings.port := IniFile.ReadInteger('MAILSET','PORT',0);
    MailSettings.host := IniFile.ReadString('MAILSET','HOST','');
    MailSettings.login := IniFile.ReadString('MAILSET','LOGIN','');
    MailSettings.password := IniFile.ReadString('MAILSET','PASSWORD','');
    MailSettings.from := IniFile.ReadString('MAILSET','FROM','');
    cnt:=IniFile.ReadInteger('MAILRECIP','RECIPCNT',0);
    for I := 0 to cnt - 1 do
      MailSettings.Recipients.Add(IniFile.ReadString('MAILRECIP','ADDR'+IntToStr(i+1),''));
    ScanGearPath := IniFile.ReadString('SCANGEAR','PATH','');
    CheckScanGear:= IniFile.ReadBool('SCANGEAR','CHECK',true);
    IniFile.Free;
  end;
end;

procedure TDataMod.DataModuleCreate(Sender: TObject);
begin
  self.ConnectToBase;
end;

//����� ������� ��������� �������

constructor TMailSettings.Create;
begin
  self.Recipients:=TStringList.Create;
  self.Body:=TStringList.Create;
end;

destructor TMailSettings.Destroy;
begin
  self.Recipients.Free;
  self.Body.Free;
end;

//�������� �����

procedure TMailThread.Execute;
var
  IdSocksInfo : TIdSocksInfo;
  IdSSLIOHandlerSocket : TIdSSLIOHandlerSocket;
  IdSmtp : TIdSmtp;
  IdMessage : TIdMessage;
  IdEncoderMIME : TIdEncoderMIME;
  i : integer;
begin
  IdSocksInfo := TIdSocksInfo.Create(nil);
  IdSSLIOHandlerSocket := TIdSSLIOHandlerSocket.Create(nil);
  IdSmtp := TIdSmtp.Create(nil);
  IdMessage := TIdMessage.Create(nil);
  IdEncoderMIME := TIdEncoderMIME.Create(nil);
  IdSocksInfo.Authentication:= saNoAuthentication;
  IdSocksInfo.Port:=self.settings.port;
  IdSocksInfo.Version:=svNoSocks;
  IdSSLIOHandlerSocket.SocksInfo:= IdSocksInfo;
  IdSSLIOHandlerSocket.SSLOptions.Method:=sslvTLSv1;
  idSmtp.IOHandler:= IdSSLIOHandlerSocket;
  idSmtp.AuthenticationType:=atLogin;
  idSmtp.Host := self.settings.host;
  idSmtp.Password:=self.settings.password;
  idSmtp.Port:=self.settings.port;
  idSmtp.Username:=self.settings.login;
  for I := 0 to self.settings.Body.Count - 1 do
    idMessage.Body.Add(self.settings.Body[i]);
  idMessage.ContentType:='text/plain; charset=Windows-1251;';
  idMessage.From.Address := self.settings.from;
  idMessage.From.Name:='=?'+'Windows-1251'+'?B?'+IdEncoderMIME.Encode('������� ���')+'?=';
  for I := 0 to self.settings.Recipients.Count - 1 do
    idMessage.Recipients.Add.Address:=self.settings.Recipients[i];
  idMessage.Subject := '=?'+'Windows-1251'+'?B?'+IdEncoderMIME.Encode(self.settings.subject)+'?=';
  if FileExists(self.settings.attrachfilename) then
    TIdAttachment.Create(IdMessage.MessageParts,self.settings.attrachfilename); //��������
  i:=0; //���� ���������� �������� �����
  try
    idSmtp.Connect(15000);
    idSmtp.Send(idMessage);
    i:=1; //�������
  finally
    idSmtp.Disconnect;
    IdSocksInfo.Free;
    IdSSLIOHandlerSocket.Free;
    IdSmtp.Free;
    IdMessage.Free;
    IdEncoderMIME.Free;
    PostMessage(self.ParentFormHandle,wmMailThreadTerminated,i,0);
  end;
end;

procedure TDataMod.SendEMail(Handle : HWND);
begin
  MailIsBeingSent:=true;
  mailthread:=TMailThread.Create(true);
  mailthread.freeonterminate := true;
  mailthread.ParentFormHandle:=Handle;
  mailthread.settings:=MailSettings;
  mailthread.resume;
end;

//�������� �����

function  TDataMod.GetLogCnt(fname,id : string):integer;
var
  strs  : TStringList;
  i,cnt : integer;
  str   : string;
begin
  strs := TStringList.Create;
  strs.LoadFromFile(fname);
  cnt:=0;
  for I := 0 to strs.Count - 1 do begin
    str:=strs[i];
    delete(str,1,pos(chr(9),str));
    delete(str,1,pos(chr(9),str));
    strs[i]:=str;
    if copy(str,1,2)=id then inc(cnt);
  end;
  strs.Free;
  result:=cnt;
end;


end.
