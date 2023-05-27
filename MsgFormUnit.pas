unit MsgFormUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls;

type
  TMsgForm = class(TForm)
    YesBtn: TSpeedButton;
    NoBtn: TSpeedButton;
    MainPN: TPanel;
    Image1: TImage;
    Panel2: TPanel;
    lb: TLabel;
    function ShowMessageForm(text : string):TModalResult;
    procedure YesBtnClick(Sender: TObject);
    procedure NoBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MsgForm: TMsgForm;

implementation

{$R *.dfm}

procedure TMsgForm.NoBtnClick(Sender: TObject);
begin
  self.Close;
end;

function TMsgForm.ShowMessageForm(text : string):TModalResult;
begin
  LB.Caption:=text;
  result:=mrNo;
  result:=self.ShowModal;
end;

procedure TMsgForm.YesBtnClick(Sender: TObject);
begin
  self.ModalResult:=mrYes;
end;

end.
