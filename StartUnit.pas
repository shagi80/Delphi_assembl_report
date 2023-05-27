unit StartUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Buttons, StdCtrls, ImgList, ComCtrls,IniFiles, DB, DBClient,
  Grids, DBGrids, DateUtils;

type
  TStartForm = class(TForm)
    Panel1: TPanel;
    ImgLst: TImageList;
    LW: TListView;
    Panel2: TPanel;
    Label1: TLabel;
    ExitBtn: TSpeedButton;
    DocSB: TSpeedButton;
    AutLB: TLabel;
    SettingBtn: TSpeedButton;
    ClientDataSet1: TClientDataSet;
    procedure AutLBMouseLeave(Sender: TObject);
    procedure AutLBMouseEnter(Sender: TObject);
    procedure AutLBClick(Sender: TObject);
    procedure LWDblClick(Sender: TObject);
    procedure DocSBClick(Sender: TObject);
    procedure ExitBtnClick(Sender: TObject);
    procedure SettingBtnClick(Sender: TObject);
    procedure UpdateLW;
    procedure FormShow(Sender: TObject);
    function  SetAutor: boolean;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  StartForm: TStartForm;

implementation

{$R *.dfm}

uses DataModule, DocUnit, AutUnit, SetUnit, PasswordUnit, MsgFormUnit;

// обновление контролов

procedure TStartForm.UpdateLW;
var
  CDS : TClientDataSet;
  frstdt, enddt  : TDate;
  Itm : TListItem;
  pint : ^integer;
  LastID : integer;
begin
  CDS:=TClientDataSet.Create(self);
  CDS.CloneCursor(DataMod.ReportCDS,true,false);
  CDS.IndexFieldNames:='DATE';
  CDS.Last;
  LastID:=CDS.FieldByName('ID').AsInteger;
  enddt:=CDS.FieldByName('DATE').AsDateTime;
  frstdt:=IncDay(enddt,-30);
  CDS.Filter:='DATE>='+QuotedSTR(FormatDateTime('dd.mm.yyyy',frstdt))+
    ' AND DATE<='+QuotedSTR(FormatDateTime('dd.mm.yyyy',enddt));
  CDS.Filtered:=true;
  CDS.First;
  LW.Items.Clear;
  while not CDS.Eof do begin
    Itm:=LW.Items.Add;
    Itm.Caption:=FormatDateTime('dd.mm.yy (dddd)',CDS.FieldByName('DATE').AsDateTime);
    new(pint);
    pint^:=CDS.FieldByName('ID').AsInteger;
    Itm.Data:=pint;
    if CDS.FieldByName('ID').AsInteger=LastID then Itm.ImageIndex:=1 else Itm.ImageIndex:=0;
    CDS.Next;
  end;
  CDS.Free;
end;

function TStartForm.SetAutor: boolean;
var
  Form: TAutorForm;
begin
  result:=false;
  Form:= TAutorForm.Create(application);
  Form.Tag:=0;
  if Form.ShowModal=mrOK then begin
    AutorID:=Form.Tag;
    AutLB.Caption:='Текущий автор'+chr(13)+DataMod.PersonCDS.Lookup('ID',AutorID,'DESCR');
    result:=true;
  end;
  form.Free;
end;

// события формы

procedure TStartForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if MailIsBeingSent then begin
    MessageDlg('Идет процесс отравки почты !'+chr(13)+'Пожалуйста подождите.',mtError,[mbOK],0);
    Action:=caNone;
  end;
end;

procedure TStartForm.FormShow(Sender: TObject);
begin
  self.UpdateLW;
  AutLB.Caption:='Текущий автор'+chr(13)+'не определен';
end;

//события контролов

procedure TStartForm.SettingBtnClick(Sender: TObject);
var
  Form: TSetForm;
begin
  if AutorID>0 then begin
    if GetPassword(AutorID) then begin
      Form:=TSetForm.Create(application);
      Form.ShowModal;
      Form.Free;
    end;
  end else
    if MsgForm.ShowMessageForm('Автор не выбран !'+chr(13)+'Хотите это сделать ?')=mrYes then
      if self.SetAutor then self.SettingBtnClick(self);
end;

procedure TStartForm.ExitBtnClick(Sender: TObject);
begin
  self.Close;
end;

procedure TStartForm.LWDblClick(Sender: TObject);
var
  pint : ^integer;
  canedit  : boolean;
begin
  if LW.SelCount>0 then begin
    canedit:=false;
    if LW.Selected.ImageIndex=1 then
      if(AutorID>0)or((AutorID=0)and(self.SetAutor))then canedit:=true;
    pint:=LW.Selected.Data;
    if ShowReport(pint^,canedit) then self.UpdateLW;
  end;
end;

procedure TStartForm.AutLBClick(Sender: TObject);
begin
  self.SetAutor;
end;

procedure TStartForm.AutLBMouseEnter(Sender: TObject);
begin
  (Sender as TLabel).Font.Color:=clRed;
end;

procedure TStartForm.AutLBMouseLeave(Sender: TObject);
begin
  (Sender as TLabel).Font.Color:=clNavy;
end;

procedure TStartForm.DocSBClick(Sender: TObject);
begin
  if(AutorID>0)or((AutorID=0)and(self.SetAutor))then begin
    if DataMod.ReportCDS.Lookup('DATE',FormatDateTime('dd.mm.yyyy',now),'ID')<>NULL then begin
        if ShowReport(DataMod.ReportCDS.Lookup('DATE',FormatDateTime('dd.mm.yyyy',now),'ID'),true) then self.UpdateLW;
      end else if ShowReport(0,true) then self.UpdateLW;
  end;
end;

end.
