unit AutUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, Grids, DBGrids, DB, DBClient;

type
  TAutorForm = class(TForm)
    OKBtn: TSpeedButton;
    LB: TListBox;
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses DataModule;

procedure TAutorForm.FormShow(Sender: TObject);
var
  CDS  : TClientDataSet;
  pint : ^integer;
begin
  CDS:=TClientDataSet.Create(self);
  CDS.CloneCursor(DataMod.PersonCDS,true,false);
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

procedure TAutorForm.OKBtnClick(Sender: TObject);
var
  pint : ^integer;
begin
  if LB.ItemIndex>-1 then begin
    pint:=pointer(LB.Items.Objects[LB.ItemIndex]);
    self.Tag:=pint^;
    self.ModalResult:=mrOK;
  end else self.Close;
end;

end.
