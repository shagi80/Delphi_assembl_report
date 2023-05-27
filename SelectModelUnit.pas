unit SelectModelUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Tabs, Buttons, ExtCtrls, DB, DBClient;

type
  TSelModeForm = class(TForm)
    CnlBtn: TSpeedButton;
    TS: TTabSet;
    Panel1: TPanel;
    GroupLB: TListBox;
    LB: TListBox;
    procedure FormShow(Sender: TObject);
    procedure TSChange(Sender: TObject; NewTab: Integer;
      var AllowChange: Boolean);
    procedure GroupLBClick(Sender: TObject);
    procedure LBDblClick(Sender: TObject);
    procedure UpdateLB(tabind : integer);
    procedure CnlBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SelModeForm: TSelModeForm;

implementation

{$R *.dfm}

uses DataModule;

procedure TSelModeForm.CnlBtnClick(Sender: TObject);
begin
  self.Close;
end;

procedure TSelModeForm.FormShow(Sender: TObject);
begin
  TS.Tabs.Clear;
  TS.Tabs.Add(' Без сортровки');
  TS.Tabs.Add(' По моделям');
  TS.Tabs.Add(' По маркам');
  TS.TabIndex:=1;
  self.GroupLBClick(self);
end;

procedure TSelModeForm.UpdateLB(tabind : integer);
var
  CDS  : TClientDataSet;
  pint : ^integer;
begin
  if (GroupLB.ItemIndex>=0)or(not GroupLB.Visible) then begin
    CDS:=TClientDataSet.Create(self);
    CDS.CloneCursor(DataMod.ModelsCDS,true,false);
    if TabInd>0 then begin
      case TabInd of
        1 : CDS.Filter:='MODEL='+QuotedStr(GroupLB.Items[GroupLB.ItemIndex]);
        2 : CDS.Filter:='MARK='+QuotedStr(GroupLB.Items[GroupLB.ItemIndex]);
      end;
      CDS.Filtered:=true;
    end;
    CDS.IndexFieldNames:='DESCR';
    CDS.First;
    LB.Items.Clear;
    while not CDS.Eof do begin
      LB.Items.Add(CDS.FieldByName('DESCR').AsString);
      new(pint);
      pint^:=CDS.FieldByName('ID').AsInteger;
      LB.Items.Objects[LB.Items.Count-1]:=TObject(pint);
      CDS.Next;
    end;
    CDS.Free;
    if LB.Items.Count>0 then LB.ItemIndex:=0;
  end;
end;

procedure TSelModeForm.GroupLBClick(Sender: TObject);
begin
  self.UpdateLB(TS.TabIndex);
end;

procedure TSelModeForm.LBDblClick(Sender: TObject);
var
  pint : ^integer;
begin
  pint:=pointer(LB.Items.Objects[LB.ItemIndex]);
  self.Tag:=pint^;
  self.ModalResult:=mrOk;
end;

procedure TSelModeForm.TSChange(Sender: TObject; NewTab: Integer;
  var AllowChange: Boolean);
var
  Strs : TStringList;
  i    : integer;
begin
  GroupLB.Visible:=(NewTab>0);
  Strs:=nil;
  case NewTab of
    1 : Strs:=ModelLst;
    2 : Strs:=MarkLst;
  end;
  GroupLB.Clear;
  if (NewTab>0)and(Strs<>nil) then begin
    for I := 0 to Strs.Count - 1 do GroupLB.Items.Add(Strs[i]);
    if GroupLB.Items.Count>0 then GroupLB.ItemIndex:=0;
  end;
  self.UpdateLB(NewTab);
end;

end.
