unit MovUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons;

type
  TMovForm = class(TForm)
    SB1: TSpeedButton;
    SB2: TSpeedButton;
    SB3: TSpeedButton;
    SB4: TSpeedButton;
    SB5: TSpeedButton;
    CnlBtn: TSpeedButton;
    procedure CnlBtnClick(Sender: TObject);
    procedure SB1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Descr: string;
    Sign : integer;
  end;

implementation

{$R *.dfm}

procedure TMovForm.CnlBtnClick(Sender: TObject);
begin
  self.Close;
end;

procedure TMovForm.SB1Click(Sender: TObject);
begin
  Descr:=(Sender as TSpeedButton).Caption;
  Sign:=(Sender as TSpeedButton).Tag;
  self.ModalResult:=mrOK;
end;

end.
