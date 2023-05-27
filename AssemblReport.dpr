program AssemblReport;

uses
  Forms,
  DocUnit in 'DocUnit.pas' {DocForm},
  StartUnit in 'StartUnit.pas' {StartForm},
  DataModule in 'DataModule.pas' {DataMod: TDataModule},
  MovUnit in 'MovUnit.pas' {MovForm},
  AutUnit in 'AutUnit.pas' {AutorForm},
  SetUnit in 'SetUnit.pas' {SetForm},
  SelectModelUnit in 'SelectModelUnit.pas' {SelModeForm},
  MsgFormUnit in 'MsgFormUnit.pas' {MsgForm},
  PasswordUnit in 'PasswordUnit.pas' {PasswordForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDataMod, DataMod);
  Application.CreateForm(TStartForm, StartForm);
  Application.CreateForm(TMsgForm, MsgForm);
  Application.Run;
end.
