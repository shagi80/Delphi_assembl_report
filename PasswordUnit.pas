unit PasswordUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TPasswordForm = class(TForm)
    YesBtn: TSpeedButton;
    NoBtn: TSpeedButton;
    Panel1: TPanel;
    Label1: TLabel;
    EditPsw: TEdit;
    procedure NoBtnClick(Sender: TObject);
    procedure YesBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


function GetPassword(id : integer): boolean;

implementation

{$R *.dfm}

uses DataModule;

function GetPassword(id : integer): boolean;
var
  Form: TPasswordForm;
begin
  Form:= TPasswordForm.Create(application);
  result:=(form.ShowModal=mrOk)and(DataMod.PersonCDS.Lookup('ID',id,'PASSWORD')<>NULL)
    and(DataMod.PersonCDS.Lookup('ID',id,'PASSWORD')=Form.EditPsw.Text);
  Form.Free;
end;

procedure TPasswordForm.NoBtnClick(Sender: TObject);
begin
  self.Close;
end;

procedure TPasswordForm.YesBtnClick(Sender: TObject);
begin
  self.ModalResult:=mrOk;
end;

end.
