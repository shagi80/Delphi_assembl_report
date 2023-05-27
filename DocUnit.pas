unit DocUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls, StdCtrls, Buttons, frxClass, frxExportODF,
  frxExportXLS, frxExportHTML, DateUtils, ComCtrls, DB, DBClient, DBGrids,
  DataModule, DBCtrls, ImgList;

type
  TDocForm = class(TForm)
    BckPn: TPanel;
    StOstSG: TStringGrid;
    Cap1LB: TLabel;
    StOstLb: TLabel;
    DateLB: TLabel;
    Cap2LB: TLabel;
    OutLB: TLabel;
    OutSG: TStringGrid;
    EndOstLb: TLabel;
    EndOstSG: TStringGrid;
    Timer1: TTimer;
    EditBtn: TBitBtn;
    ProdLb: TLabel;
    ProdSG: TStringGrid;
    EditModeTrueImg: TImage;
    EditModeFalseImg: TImage;
    AutorLB: TLabel;
    Panel1: TPanel;
    CloseBtn: TSpeedButton;
    PrintBtn: TSpeedButton;
    EditModeBtnPn: TPanel;
    MailBtn: TSpeedButton;
    SaveBtn: TSpeedButton;
    VerBtn: TSpeedButton;
    Report: TfrxReport;
    HTMLExp: TfrxHTMLExport;
    DelMovBtnPN: TPanel;
    DelMovBtn: TSpeedButton;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    DBGrid2: TDBGrid;
    DataSource2: TDataSource;
    GetOTKDataBtn: TBitBtn;
    MsgPn: TPanel;
    MsgLb: TLabel;
    Timer2: TTimer;
    MsgImg: TImage;
    MsgIL: TImageList;
    procedure MailBtnClick(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure VerBtnClick(Sender: TObject);
    procedure StOstSGMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure StOstSGDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure EditBtnClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SetGridSize(SG: TStringGrid);
    procedure WriteTableTitles;
    procedure StOstSGClick(Sender: TObject);
    function  AddNewModel : boolean;
    procedure FormResize(Sender: TObject);
    procedure OutSGMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure SaveReport(Sender: TObject);
    procedure WriteReport;
    function ClkRes:integer;
    procedure DelMovBtnClick(Sender: TObject);
    procedure UpdateMailBtn;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure StOstSGSetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: string);
    function SendMail(saverep : boolean):boolean;
    procedure ShowStOstEditBtn(row:integer);
    procedure ProdSGMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GetOTKDataBtnClick(Sender: TObject);
    procedure ReportGetValue(const VarName: string; var Value: Variant);
    procedure MyShowMessage(text:string; mtType, time : integer);
    procedure Timer2Timer(Sender: TObject);
    procedure WritePrevBalanse(id : integer);
    procedure CalckLotResult;
  private
    { Private declarations }
    procedure MailThreadTerminated(var msg: TMessage); message wmMailThreadTerminated;
  public
    { Public declarations }
    ModelsInd, MovSign, Faults : array of integer;
    RepID,PrevID  : integer;
    EditMode, Modified, ShowResult : boolean;
  end;

function ShowReport(rep : integer; canedit : boolean):boolean;

implementation

{$R *.dfm}

uses SelectModelUnit, MovUnit, IniFiles, MsgFormUnit;

const
  pmtProgress=0;
  pmtWarning=1;
  pmtError=2;
  pmtInform=3;

var
  ErrorColor : TColor;

function ShowReport(rep : integer; canedit : boolean):boolean;
var
  Form : TDocForm;
begin
  result:=false;
  Form:=TDocForm.Create(application);
  SetLength(form.ModelsInd,0);
  SetLength(form.MovSign,0);
  Form.RepID:=rep;
//  Form.RepID:=1;
  Form.EditMode:=canedit;
  Form.Modified:=false;
  if rep=0 then begin
    Form.DateLb.Caption:=FormatDateTime( 'за dd mmm yyyy г. (dddd)', now);
    Form.Caption:='Отчет за сегодня';
    Form.AutorLb.Caption:=DataMod.PersonCDS.Lookup('ID',AutorID,'DESCR');
    if(DataMod.ReportCDS.RecordCount>0) then begin
      DataMod.ReportCDS.Last;
      Form.PrevID:=DataMod.ReportCDS.FieldByName('ID').AsInteger;
      Form.WritePrevBalanse(Form.PrevID)
    end else Form.PrevID:=0;
    Form.StOstSG.Options:=Form.StOstSG.Options-[goEditing];
  end else
    if DataMod.ReportCDS.Locate('ID',form.RepID,[]) then begin
      Form.DateLb.Caption:=FormatDateTime( 'за dd mmm yyyy г. (dddd)',
        DataMod.ReportCDS.FieldByName('DATE').AsDateTime);
      form.Caption:='Отчет '+Form.DateLb.Caption;
      Form.AutorLb.Caption:=DataMod.PersonCDS.Lookup('ID',DataMod.ReportCDS.FieldByName('AUTOR').AsInteger,'DESCR');
      Form.PrevID:=DataMod.ReportCDS.FieldByName('PARENT').AsInteger;
    end else begin
      MessageDLG('КРИТИЧЕСКАЯ ОШИБКА !'+chr(13)+'Отчет не найден в таблице !',mtError,[mbOK],0);
      Abort;
    end;
  Form.WriteReport;
  Form.ShowResult:=false;
  Form.ShowModal;
  result:=Form.ShowResult;
  Form.Free;
end;

procedure TDocForm.WriteTableTitles;
var
  i     : integer;
  descr : string;
begin
  for I := 0 to high(self.ModelsInd) do begin
    descr:=DataMod.ModelsCDS.Lookup('ID',self.ModelsInd[i],'SHORTDESCR');
    self.StOstSG.Cells[i+1,0]:=descr;
    self.OutSG.Cells[i+1,0]:=descr;
    self.EndOstSG.Cells[i+1,0]:=descr;
    self.ProdSG.Cells[i+1,0]:=descr;
  end;
end;

function  TDocForm.AddNewModel : boolean;
var
  form  : TSelModeForm;
  i : integer;
begin
  result:=false;
  if  MsgForm.ShowMessageForm('Вы хотите добавить в таблицу еще одну модель ?')=mrYes then begin
    form:=TSelModeForm.Create(application);
    if form.ShowModal=mrOK then begin
      i:=0;
      while(i<=high(self.ModelsInd))and(form.Tag<>self.ModelsInd[i])do inc(i);
      if(i>high(self.ModelsInd))then begin
        SetLength(self.ModelsInd,high(self.ModelsInd)+2);
        self.ModelsInd[high(self.ModelsInd)]:=form.Tag;
        self.WriteTableTitles;
        self.Modified:=true;
        if RepID>0 then begin
          DataMod.ReportCDS.Edit;
          DataMod.ReportCDS.FieldByName('SEND').AsBoolean:=false;
          DataMod.ReportCDS.Post;
        end;
        self.UpdateMailBtn;
        result:=true;
      end else self.MyShowMessage('Такая модель уже есть в отчете !',pmtError,3);
    end;
    form.Free;
  end;
end;

procedure TDocForm.UpdateMailBtn;
begin
  if (RepID>0)and(DataMod.ReportCDS.FieldByName('SEND').AsBoolean) then begin
    self.MailBtn.Font.Color:=clRed;
    self.MailBtn.Caption:='Отправлено';
    self.MailBtn.Repaint;
  end else begin
    self.MailBtn.Font.Color:=clBlack;
    self.MailBtn.Caption:='Отправить';
  end;
end;

//------------------------ события формы ---------------------------------------

procedure TDocForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if MailIsBeingSent then begin
    self.MyShowMessage('Идет процесс отравки почты !'+chr(13)+'Пожалуйста подождите.',pmtError,5);
    Action:=caNone;
  end else begin
    if (self.Modified)and( MsgForm.ShowMessageForm('Отчет был изменен.'+chr(13)+'Сохранить изменения ?')=mrYes)then self.SaveBtnClick(self);
    while MailIsBeingSent do application.ProcessMessages;
    if self.Timer2.Enabled then self.Timer2.Enabled:=false;
  end;
end;

procedure TDocForm.FormResize(Sender: TObject);
begin
  self.SetGridSize(StOstSG);
  self.SetGridSize(OutSG);
  self.SetGridSize(EndOstSG);
  self.SetGridSize(ProdSG);
  EditBtn.Visible:=false;
end;

procedure TDocForm.FormShow(Sender: TObject);
var
  lastcol : integer;
begin
  ErrorColor:=RGB(255, 185, 181);
  //Заполнение заголовков таблиц
  lastcol:=StOstSG.ColCount-1;
  self.StOstSG.Cells[lastcol,0]:='Примечание';
  self.OutSG.Cells[lastcol,0]:='Примечание';
  self.EndOstSG.Cells[lastcol,0]:='Примечание';
  self.ProdSG.Cells[lastcol,0]:='Примечание';
  self.EndOstSG.Cells[0,1]:='Остаток на 20:00:';
  self.ProdSG.Cells[0,1]:='За смену:';
  self.ProdSG.Cells[0,2]:='С учетом предыдущего:';
  //настройки разшения на редактирование
  EditModeTrueImg.Left:=5;
  EditModeFalseImg.Left:=5;
  EditModeTrueImg.Visible:=EditMode;
  EditModeFalseImg.Visible:=not EditMode;
  EditModeBtnPn.Visible:=EditMode;
  if not EditMode then begin
    self.StOstSG.Options:=StOstSG.Options-[goEditing];
    self.OutSG.Options:=OutSG.Options-[goEditing];
    self.EndOstSG.Options:=EndOstSG.Options-[goEditing];
    self.ProdSG.Options:=ProdSG.Options-[goEditing];
  end;
  self.FormResize(self);
  self.UpdateMailBtn;
end;

procedure TDocForm.MailThreadTerminated(var msg: TMessage);
begin
  MailIsBeingSent:=false;
  DataMod.ReportCDS.Edit;
  DataMod.ReportCDS.FieldByName('SEND').AsBoolean:=(msg.WParam=1);
  DataMod.ReportCDS.Post;
  if(msg.WParam=1) then begin
    if (self.WindowState<>wsMinimized) then
      self.MyShowMessage('Почта отправлена!',pmtInform,3);
  end;
  self.UpdateMailBtn;
end;

procedure TDocForm.MyShowMessage(text:string; mtType, time : integer);
begin
  self.Timer2.Enabled:=false;
  self.MsgImg.Picture:=nil;
  case mtType of
    pmtProgress :self.MsgIL.GetBitmap(1,self.MsgImg.Picture.Bitmap);
    pmtInform   :self.MsgIL.GetBitmap(3,self.MsgImg.Picture.Bitmap);
    pmtWarning  :self.MsgIL.GetBitmap(2,self.MsgImg.Picture.Bitmap);
    pmtError    :self.MsgIL.GetBitmap(0,self.MsgImg.Picture.Bitmap);
  end;
  case mtType of
    pmtProgress,
    pmtInform   :self.MsgLb.Font.Color:=clBlack;
    pmtWarning  :self.MsgLb.Font.Color:=clNavy;
    pmtError    :self.MsgLb.Font.Color:=clRed;
  end;
  self.MsgLb.Caption:=Text;
  self.MsgImg.Width:=50;
  self.MsgImg.Stretch:=false;
  self.MsgPn.Visible:=true;
  if self.MsgImg.Height<50 then begin
    self.MsgImg.Width:=self.MsgImg.Height;
    self.MsgImg.Stretch:=true;
  end;
  self.MsgPn.Left:=round((self.Width-self.MsgPn.Width)/2);
  if time>0 then begin
    self.Timer2.Interval:=time*1000;
    self.Timer2.Enabled:=true;
  end;
end;

procedure TDocForm.Timer2Timer(Sender: TObject);
begin
  self.MsgPn.Visible:=false;
  self.Timer2.Enabled:=false;
end;

//------------------------ события таблиц --------------------------------------

procedure TDocForm.ShowStOstEditBtn(row:integer);
var
  pt  : TPoint;
begin
  //Показ кнопки "Исправить/Не исправлять" в таблице начального остатка
  pt.X:=StOstSG.CellRect(StOstSG.ColCount-1,row).Left;
  pt.Y:=StOstSG.CellRect(StOstSG.ColCount-1,row).Top;
  pt:=StOstSG.ClientToScreen(pt);
  pt:=EditBtn.Parent.ScreenToClient(pt);
  EditBtn.Top:=pt.Y;
  EditBtn.Left:=pt.X+1;
  if row=1 then EditBtn.Caption:='Исправить' else EditBtn.Caption:='Не исправлять';
  EditBtn.Visible:=true;
  EditBtn.Width:=StOstSG.CellRect(StOstSG.ColCount-1,1).Right-StOstSG.CellRect(StOstSG.ColCount-1,1).Left;
end;

procedure TDocForm.StOstSGClick(Sender: TObject);
var
  grid    : TStringGrid;
  col,row : integer;
  form    : TMovForm;
begin
  grid:=(sender as TStringGrid);
  col:=grid.Selection.Left;
  row:=grid.Selection.Top;
  if (TStringGrid(sender).Name<>'StOstSG')or((TStringGrid(sender).Name='StOstSG')and(row=2)) then
      TStringGrid(sender).Options:=TStringGrid(sender).Options+[goEditing]
    else TStringGrid(sender).Options:=TStringGrid(sender).Options-[goEditing];
  if (goEditing in TStringGrid(sender).Options)and(row>0)and(col>grid.FixedCols+high(self.ModelsInd))
    and(col<grid.ColCount-1) then
      if self.AddNewModel then Grid.Selection:=TGridRect(rect(grid.FixedCols+high(self.ModelsInd),row,
        grid.FixedCols+high(self.ModelsInd),row)) else
        TStringGrid(sender).Options:=TStringGrid(sender).Options-[goEditing];
  if (goEditing in TStringGrid(sender).Options)and(TStringGrid(sender).Name='OutSG')
    and(row-1>high(self.MovSign))then begin
      form:=TMovForm.Create(application);
      if form.ShowModal=mrOK then begin
        SetLength(self.MovSign,high(self.MovSign)+2);
        self.MovSign[high(self.MovSign)]:=form.Sign;
        OutSG.Cells[0,high(self.MovSign)+OutSG.FixedCols]:=form.Descr;
        Grid.Selection:=TGridRect(rect(Grid.Selection.Left,high(self.MovSign)+OutSG.FixedCols,
          Grid.Selection.Left,high(self.MovSign)+OutSG.FixedCols));
      end else TStringGrid(sender).Options:=TStringGrid(sender).Options-[goEditing];
      form.Free;
  end;
end;

procedure TDocForm.SetGridSize(SG: TStringGrid);
var
  i,h : integer;
begin
  //Установка размеров таблиц (общая для всех таблиц)
  h:=0;
  SG.ColWidths[0]:=SG.DefaultColWidth*3;
  SG.ColWidths[SG.ColCount-1]:=SG.DefaultColWidth*4;
  for i := 0 to SG.RowCount - 1 do h:=h+SG.RowHeights[i]+SG.GridLineWidth;
  SG.Height:=h+SG.BevelWidth*2-SG.GridLineWidth;
  h:=0;
  for i := 0 to SG.ColCount - 1 do h:=h+SG.ColWidths[i]+SG.GridLineWidth;
  h:=h+SG.GridLineWidth*6;
  SG.Margins.Left:=round((SG.Parent.Width-h)/2);
  SG.Margins.Right:=round((SG.Parent.Width-h)/2);
end;

procedure TDocForm.StOstSGMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  //Показ кнопки "Исправить" в таблице начального остатка
  if (EditMode)and(StOstSG.MouseCoord(x,y).y>0)and(StOstSG.MouseCoord(x,y).x>0)
    and(StOstSG.MouseCoord(x,y).x<StOstSG.ColCount)then self.ShowStOstEditBtn(StOstSG.RowCount-1);
end;

procedure TDocForm.StOstSGSetEditText(Sender: TObject; ACol, ARow: Integer;
  const Value: string);
begin
  Modified:=true;
  if RepID>0 then begin
    DataMod.ReportCDS.Edit;
    DataMod.ReportCDS.FieldByName('SEND').AsBoolean:=false;
    DataMod.ReportCDS.Post;
    self.UpdateMailBtn;
  end;
end;

procedure TDocForm.OutSGMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  pt : TPoint;
begin
  //Показ кнопки "Удалить строку" в таблице движений
  if (EditMode)and(OutSG.MouseCoord(x,y).X=0)and(OutSG.MouseCoord(x,y).Y-1<=high(self.MovSign))
    and(OutSG.MouseCoord(x,y).Y>0) then begin
    DelMovBtnPN.Tag:=OutSG.MouseCoord(x,y).Y;
    pt.X:=OutSG.CellRect(OutSG.MouseCoord(x,y).X,OutSG.MouseCoord(x,y).Y).Right-DelMovBtn.Width-2;
    pt.Y:=OutSG.CellRect(OutSG.MouseCoord(x,y).X,OutSG.MouseCoord(x,y).Y).Top+2;
    pt:=OutSG.ClientToScreen(pt);
    pt:=DelMovBtnPN.Parent.ScreenToClient(pt);
    DelMovBtnPN.Top:=pt.Y;
    DelMovBtnPN.Left:=pt.X+1;
    DelMovBtnPN.Visible:=true;
  end else DelMovBtnPN.Visible:=false;
end;

procedure TDocForm.ProdSGMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  pt  : TPoint;
  mypath  : string;
begin
  if RepID=0 then mypath:=ScanGearPath+'\'+FormatDateTime('ddmmyy',now)+'.txt'
    else mypath:=ScanGearPath+'\'+FormatDateTime('ddmmyy',DataMod.ReportCDS.FieldByName('DATE').AsDateTime)+'.txt';
  if (EditMode)and(ProdSG.MouseCoord(x,y).y>0)
    and(ProdSG.MouseCoord(x,y).x>0)and(ProdSG.MouseCoord(x,y).x<ProdSG.ColCount)then begin
      pt.X:=ProdSG.CellRect(ProdSG.ColCount-1,1).Left;
      pt.Y:=ProdSG.CellRect(ProdSG.ColCount-1,1).Top;
      pt:=ProdSG.ClientToScreen(pt);
      pt:=EditBtn.Parent.ScreenToClient(pt);
      GetOTKDataBtn.Top:=pt.Y;
      GetOTKDataBtn.Left:=pt.X+1;
      GetOTKDataBtn.Visible:=true;
      GetOTKDataBtn.Width:=ProdSG.CellRect(ProdSG.ColCount-1,1).Right-ProdSG.CellRect(ProdSG.ColCount-1,1).Left;
    end;
end;

procedure TDocForm.StOstSGDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  str  : WideString;
  Flag : Cardinal;
  Rct  : TRect;
  i    : integer;
  Clr  : TColor;
begin
  //Перерисовка таблицы (общая для всех таблиц)
  str :=(Sender as TStringGrid).Cells[Acol,Arow];
  Clr:=clBlack;
  if ((Sender as TStringGrid).Name='StOstSG')and(ARow=2) then Clr:=clRed;
  //выделение цветом прихода и расхода в таблице движения
  if ((Sender as TStringGrid).Name='OutSG')and(ACol=0)and(Arow>0)and(ARow-1<=high(self.MovSign)) then
    if MovSign[Arow-1]>0 then Clr:=clGreen else Clr:=clRed;
  //базовые цвета
  (Sender as TStringGrid).Canvas.Brush.Color:=clWindow;
  (Sender as TStringGrid).Canvas.Font.Color:=Clr;
  //Выделение ошибок ввода
  if (Acol>0)and(ACol<(Sender As TStringGrid).ColCount-2)and
      (ARow>0)and(str<>'')and(StrToIntDef(str,-1)<0) then begin
        (Sender as TStringGrid).Cells[ACol,ARow]:='';
        str:='';
        beep;
        //(Sender as TStringGrid).Canvas.Brush.Color:=clRed;
        //(Sender as TStringGrid).Canvas.Font.Color:=clBlack;
  end;
  //Выделеине ошибко рассчета
  if (high(self.Faults)>=0) then
    for I := 0 to high(self.Faults) do
      if ACol=self.Faults[i]+(Sender as TStringGrid).FixedCols then begin
        (Sender as TStringGrid).Canvas.Brush.Color:=ErrorColor;
        (Sender as TStringGrid).Canvas.Font.Color:=clBlack;
      end;
  //вывод значений
  (Sender as TStringGrid).Canvas.FillRect(Rect);
  Rct:=Rect;
  if ((ACol=0)or(ACol=(Sender As TStringGrid).ColCount-1))and(ARow>0) then Flag := DT_LEFT
    else Flag:=DT_CENTER;
  Inc(Rct.Left,2);
  Inc(Rct.Top,2);
  DrawTextW((Sender as TStringGrid).Canvas.Handle,PWideChar(str),length(str),Rct,Flag);
end;

//-------------------------- обработка данных отчета ---------------------------

procedure TDocForm.WritePrevBalanse(id : integer);
var
  CDS       : TClientDataSet;
  i,col     : integer;
begin
  CDS:=TClientDataSet.Create(self);
  CDS.CloneCursor(DataMod.DataCDS,true,false);
  CDS.Filter:='REPID='+IntToStr(ID)+' AND MODE='+IntToStr(mdFINALBALANCE);
  CDS.Filtered:=true;
  CDS.First;
  while not CDS.Eof do begin
    //определям столбец по индексу моделе в списке индексов (или добавляем новый индекс)
    i:=0;
    while(i<=high(self.ModelsInd))and(self.ModelsInd[i]<>CDS.FieldByName('MODEL').AsInteger)do inc(i);
    if(i<=high(self.ModelsInd))and(self.ModelsInd[i]=CDS.FieldByName('MODEL').AsInteger)then col:=i
      else begin
        SetLength(self.ModelsInd,high(self.ModelsInd)+2);
        self.ModelsInd[high(self.ModelsInd)]:=CDS.FieldByName('MODEL').AsInteger;
        self.WriteTableTitles;
        col:=high(self.ModelsInd);
      end;
    //вывод значений
    self.StOstSG.Cells[col+self.StOstSG.FixedCols,1]:=CDS.FieldByName('COUNT').AsString;
    self.StOstSG.Cells[0,1]:='На конец смены '+FormatDateTime('dd.mm.yy',DataMod.ReportCDS.Lookup('ID',id,'DATE'));
    self.StOstSG.Cells[self.StOstSG.ColCount-1,1]:=CDS.FieldByName('NOTE').AsString;
    CDS.Next;
  end;
  CDS.Free;
end;

procedure TDocForm.SaveReport(Sender: TObject);
var
  r             : integer;
  UpdateRecords : array of integer;
  CDS           : TClientDataSet;

procedure SaveTable(md, row : integer);
var
  i     : integer;
  Grid  : TStringGrid;
begin
  Grid:=nil;
  for I := 0 to high(self.ModelsInd) do begin
    case md of
      mdASSEMBL,
      mdLOTASSEMBL   : Grid:=self.ProdSG;
      mdFINALBALANCE : Grid:=self.EndOstSG;
      mdFROMWIREHOUSE,
      mdTOWIREHOUSE  ,
      mdSHIPMENT     ,
      mdFORREPEAR    ,
      mdFORSALE      : Grid:=self.OutSG;
      mdSTARTBALANCE : if self.StOstSG.RowCount=3 then Grid:=self.StOstSG;
      mdPREVBALANCE  : Grid:=self.StOstSG;
    end;
    //если в соотв ячейке соотв таблицы есзть значение - записываем его
    if (Grid<>nil)and(StrToFloatDef(Grid.Cells[i+Grid.FixedCols,row],-1)>=0)then begin
      //определяем - может быть значение с такими реквизитами уже записано
      CDS.Filter:='REPID='+IntToStr(RepID)+' AND MODE='+IntToStr(md)+' AND MODEL='+IntToStr(self.ModelsInd[i]);
      CDS.Filtered:=true;
      if (not CDS.IsEmpty)and(CDS.RecordCount>1) then begin
        MessageDLG('КРИТИЧЕСКАЯ ОШИБКА !'+chr(13)+'Нарушение структуры таблицы даннх !'+chr(13)+
          'Несколько одинаковых записей!',mtError,[mbOK],0);
        Abort;
      end;
      //если не записано - добавляем полностью все новые данные, если записано - просто
      //обновляем количество
      if CDS.IsEmpty then begin
        CDS.Append;
        CDS.FieldByName('REPID').AsInteger:=RepID;
        CDS.FieldByName('MODE').AsInteger:=md;
        CDS.FieldByName('MODEL').AsInteger:=self.ModelsInd[i];
        CDS.FieldByName('TITLE').AsString:=Grid.Cells[0,row];
      end else CDS.Edit;
      CDS.FieldByName('COUNT').AsFloat:=StrToFloatDef(Grid.Cells[i+Grid.FixedCols,row],-1);
      CDS.FieldByName('NOTE').AsString:=Grid.Cells[Grid.ColCount-1,row];
      CDS.Post;
      //записываем ID строки в массив обновленных строк
      SetLength(UpdateRecords,high(UpdateRecords)+2);
      UpdateRecords[high(UpdateRecords)]:=CDS.FieldByName('ID').AsInteger;
      CDS.Filtered:=false;
    end;
  end;
end;

begin
  if high(self.ModelsInd)<0 then begin
    self.MyShowMessage('Отчет пуст !',pmtError,3);
    Abort;
  end;
  if RepID=0 then begin
    DataMod.ReportCDS.Append;
    DataMod.ReportCDS.FieldByName('DATE').AsDateTime:=now;
    DataMod.ReportCDS.FieldByName('AUTOR').AsInteger:=AutorID;
    DataMod.ReportCDS.FieldByName('PARENT').AsInteger:=PrevID;
    DataMod.ReportCDS.Post;
    self.RepID:=DataMod.ReportCDS.FieldByName('ID').AsInteger;
  end;
  SetLength(UpdateRecords,0);
  CDS:=TClientDataSet.Create(self);
  CDS.CloneCursor(DataMod.DataCDS,true,false);
  SaveTable(mdASSEMBL,1);
  SaveTable(mdLOTASSEMBL,2);
  SaveTable(mdFINALBALANCE,1);
  SaveTable(mdPREVBALANCE,1);
  SaveTable(mdSTARTBALANCE,2);
  if high(self.MovSign)>=0 then
    for r := 0 to high(self.MovSign) do SaveTable(self.MovSign[r],r+1);
  //удаляем строки, которые не были обновлены
  CDS.Filter:='REPID='+IntToStr(RepID);
  CDS.Filtered:=true;
  CDS.First;
  while not CDS.Eof do begin
    r:=0;
    while(r<=high(UpdateRecords))and(CDS.FieldByName('ID').AsInteger<>UpdateRecords[r]) do inc(r);
    if(r>high(UpdateRecords))then CDS.Delete;
    CDS.Next;
  end;
  CDS.Free;
  self.Modified:=false;
end;

procedure TDocForm.WriteReport;

procedure WriteTable(md : integer);
var
  CDS       : TClientDataSet;
  i,col,row : integer;
  Grid      : TStringGrid;
begin
  Grid:=nil;
  CDS:=TClientDataSet.Create(self);
  CDS.CloneCursor(DataMod.DataCDS,true,false);
  CDS.Filter:='REPID='+IntToStr(RepID)+' AND MODE='+IntToStr(md);
  CDS.Filtered:=true;
  CDS.First;
  while not CDS.Eof do begin
    row:=0;
    //определяем таблицу и номер строки вывода
    case md of
      mdASSEMBL      : begin
                        Grid:=self.ProdSG;
                        row:=1;
                       end;
      mdLOTASSEMBL   : begin
                        Grid:=self.ProdSG;
                        row:=2;
                       end;
      mdFINALBALANCE : begin
                        Grid:=self.EndOstSG;
                        row:=1;
                       end;
      mdFROMWIREHOUSE,
      mdTOWIREHOUSE  ,
      mdSHIPMENT     ,
      mdFORREPEAR    ,
      mdFORSALE      : begin
                        Grid:=self.OutSG;
                        i:=0;
                        while(i<=high(self.MovSign))and(self.MovSign[i]<>md)do inc(i);
                        if(i<=high(self.MovSign))and(self.MovSign[i]=md)then row:=i
                          else begin
                            SetLength(self.MovSign,high(self.MovSign)+2);
                            self.MovSign[high(self.MovSign)]:=md;
                            row:=high(self.MovSign);
                          end;
                        row:=row+Grid.FixedRows;
                       end;
      mdSTARTBALANCE : begin
                        Grid:=self.StOstSG;
                        row:=2;
                        if self.StOstSG.RowCount<3 then begin
                          StOstSG.RowCount:=3;
                          self.SetGridSize(StOstSG);
                        end;
                       end;
      mdPREVBALANCE : begin
                        Grid:=self.StOstSG;
                        row:=1;
                       end;
    end;
    //определям столбец по индексу моделе в списке индексов (или добавляем новый индекс)
    i:=0;
    while(i<=high(self.ModelsInd))and(self.ModelsInd[i]<>CDS.FieldByName('MODEL').AsInteger)do
    begin
      inc(i);
    end;
    if(i<=high(self.ModelsInd))and(self.ModelsInd[i]=CDS.FieldByName('MODEL').AsInteger)then col:=i
      else begin
        SetLength(self.ModelsInd,high(self.ModelsInd)+2);
        self.ModelsInd[high(self.ModelsInd)]:=CDS.FieldByName('MODEL').AsInteger;
        self.WriteTableTitles;
        col:=high(self.ModelsInd);
      end;
    //вывод значений
    if (Grid<>nil) then begin
      Grid.Cells[col+Grid.FixedCols,row]:=CDS.FieldByName('COUNT').AsString;
      Grid.Cells[0,row]:=CDS.FieldByName('TITLE').AsString;
      Grid.Cells[Grid.ColCount-1,row]:=CDS.FieldByName('NOTE').AsString;
    end;
    CDS.Next;
  end;
  CDS.Free;
end;

begin
  WriteTable(mdASSEMBL);
  WriteTable(mdLOTASSEMBL);
  WriteTable(mdFINALBALANCE);
  WriteTable(mdSTARTBALANCE);
  WriteTable(mdFROMWIREHOUSE);
  WriteTable(mdTOWIREHOUSE);
  WriteTable(mdSHIPMENT);
  WriteTable(mdFORREPEAR);
  WriteTable(mdFORSALE);
  if RepID>0 then WriteTable(mdPREVBALANCE);
end;

function TDocForm.SendMail(saverep : boolean):boolean;
var
  row,col,cnt1,cnt2 : integer;
  str   : string;
begin
  result:=false;
  self.ClkRes;
  if high(self.Faults)<0 then begin
    if saverep then self.SaveReport(self);
    if not MailIsBeingSent then begin
      self.MyShowMessage('Идет отправка почты !',pmtProgress,0);
      MailSettings.Body.Clear;
      MailSettings.Body.Add('Автор отчета: '+AutorLB.Caption);
      MailSettings.Body.Add('');
      MailSettings.Body.Add('Остаток на начало смены:');
      for col := 0 to high(self.ModelsInd) do begin
        cnt1:=StrToIntDef(StOstSG.Cells[col+StOstSG.FixedCols,1],0);
        if StOstSG.RowCount>2 then cnt2:=StrToIntDef(StOstSG.Cells[col+StOstSG.FixedCols,2],0) else cnt2:=0;
          if (cnt1>0)or(cnt2>0) then begin
            str:=DataMod.ModelsCDS.Lookup('ID', self.ModelsInd[col],'DESCR')+' = '+IntToStr(cnt1);
            if cnt2>0 then str:=str+' / '+IntTostr(cnt2)+' ('+StOstSG.Cells[0,2]+')';
            MailSettings.Body.Add(str);
          end;
      end;
      MailSettings.Body.Add('');
      MailSettings.Body.Add('Движене в течении смены:');
      for  row := 0 to high(self.MovSign) do begin
        case self.MovSign[row] of
          mdFROMWIREHOUSE :  str:='(+) со склада: ';
          mdTOWIREHOUSE   :  str:='(-) на склад: ';
          mdSHIPMENT      :  str:='(-) отгрузка: ';
          mdFORREPEAR     :  str:='(+) принято на ремонт: ';
          mdFORSALE       :  str:='(-) продажа: ';
        end;
        for col := 0 to high(self.ModelsInd) do begin
          cnt1:=StrToIntDef(OutSG.Cells[col+OutSG.FixedCols,row+OutSG.FixedRows],0);
          if cnt1>0 then begin
            str:=str+DataMod.ModelsCDS.Lookup('ID', self.ModelsInd[col],'DESCR')+' = '+IntToStr(cnt1);
            if col<high(self.ModelsInd) then str:=str+', ';
          end;
        end;
        str:=str+' '+OutSG.Cells[OutSG.ColCount-1,row+OutSG.FixedRows];
        MailSettings.Body.Add(inttostr(row+1)+'. '+str);
      end;
      MailSettings.Body.Add('');
      MailSettings.Body.Add('Остаток на конец смены:');
      for col := 0 to high(self.ModelsInd) do begin
        cnt1:=StrToIntDef(EndOstSG.Cells[col+OutSG.FixedCols,1],0);
        if cnt1>0 then
          MailSettings.Body.Add(DataMod.ModelsCDS.Lookup('ID', self.ModelsInd[col],'DESCR')+' = '+IntToStr(cnt1));
      end;
      str:=EndOstSG.Cells[EndOstSG.ColCount-1,1];
      if length(str)>0 then MailSettings.Body.Add(str);
      MailSettings.Body.Add('');
      MailSettings.Body.Add('Производство в течении смены:');
      for col := 0 to high(self.ModelsInd) do begin
        cnt1:=StrToIntDef(ProdSG.Cells[col+OutSG.FixedCols,1],0);
        if cnt1>0 then
          MailSettings.Body.Add(DataMod.ModelsCDS.Lookup('ID', self.ModelsInd[col],'DESCR')+' = '+IntToStr(cnt1));
      end;
      str:=ProdSG.Cells[ProdSG.ColCount-1,1];
      if length(str)>0 then MailSettings.Body.Add(str);
      MailSettings.Body.Add('');
      str:='Отчет отправлен ';
      if AutorID>0 then str:=str+FormatDateTime('dd.mm.yy hh.mm ',Now)+
        DataMod.PersonCDS.Lookup('ID',AutorID,'DESCR') else str:=str+'неизвестно кем';
      MailSettings.Body.Add(str);
      MailSettings.subject:='Отчет сборочного цеха за '+
        FormatDateTime('dd mmm yyyy (dddd)',DataMod.ReportCDS.FieldByName('DATE').AsDateTime);
      //подготовка отчета в HTML-формате
      Report.PrepareReport(true);
      HTMLExp.ShowDialog:=false;
      HTMLExp.FileName:=RepPath+'\'+FormatDateTime('ddmmyy',DataMod.ReportCDS.FieldByName('DATE').AsDateTime)+'.html';
      Report.Export(HTMLExp);
      MailSettings.attrachfilename:=HTMLExp.FileName;
      DataMod.SendEMail(self.Handle);
      result:=true;
    end else self.MyShowMessage('Процесс отравки почты уже идет!',pmtError,3);
  end else begin
    StOstSG.Repaint;
    OutSg.Repaint;
    EndOstSG.Repaint;
    ProdSg.Repaint;
    self.MyShowMessage('Отчет содержит ошибки и неможет быть отправлен !',pmtError,3);
  end;
end;

function TDocForm.ClkRes:integer;
var
  col,row,StOst,EndOst,Mov,Prod,logcnt,i :integer;
  mypath : string;
begin
  //сверка логов
  if CheckScanGear then begin
    if RepID=0 then mypath:=ScanGearPath+'\'+FormatDateTime('ddmmyy',now)+'.txt'
      else mypath:=ScanGearPath+'\'+FormatDateTime('ddmmyy',DataMod.ReportCDS.FieldByName('DATE').AsDateTime)+'.txt';
    if FileExists(mypath) then for col := 0 to high(self.ModelsInd) do begin
      Prod:=StrToIntDef(ProdSG.Cells[col+ProdSG.FixedCols,1],0);
      if (DataMod.ModelsCDS.Lookup('ID',self.ModelsInd[col],'IDFORCODE')<>null)and(Prod>0) then begin
        logcnt:=DataMod.GetLogCnt(mypath,DataMod.ModelsCDS.Lookup('ID',self.ModelsInd[col],'IDFORCODE'));
        if (logcnt>0)and(prod<>logcnt) then
          if MsgForm.ShowMessageForm('Результат производства для модели '+DataMod.ModelsCDS.Lookup('ID',self.ModelsInd[col],'DESCR')+
            ' не соответствует данным с рабочего места ОТК.'+chr(13)+'В отчете - '+IntToStr(Prod)+', по данным ОТК - '+IntToStr(logcnt)+'.'
            +chr(13)+chr(13)+'Исправить производство по данным ОТК ?')=mrYes then ProdSG.Cells[col+ProdSG.FixedCols,1]:=IntToStr(logcnt);
      end;
    end;
  end;
  //Проверка расчетов. Заполняет массив ошибочных столбцов.
  // Возвращает расчетное количество для первого ошибочного столбца.
  SetLength(self.Faults,0);
  result:=0;
  for col := 0 to high(self.ModelsInd) do begin
    if StOstSG.RowCount=2 then StOst:=StrToIntDef(StOstSG.Cells[col+StOstSG.FixedCols,1],0)
        else StOst:=StrToIntDef(StOstSG.Cells[col+StOstSG.FixedCols,2],0);
    EndOst:=StrToIntDef(EndOstSG.Cells[col+StOstSG.FixedCols,1],0);
    Mov:=0;
    for row:=0 to high(self.MovSign) do
      if (self.MovSign[row]=mdFORREPEAR)or(self.MovSign[row]=mdFROMWIREHOUSE)then
        Mov:=Mov+StrToIntDef(OutSG.Cells[col+OutSG.FixedCols,row+OutSG.FixedRows],0)
          else Mov:=Mov-StrToIntDef(OutSG.Cells[col+OutSG.FixedCols,row+OutSG.FixedRows],0);
    Prod:=EndOst-StOst-Mov;
    if Prod<>StrToIntDef(ProdSG.Cells[col+ProdSG.FixedCols,1],0) then begin
      SetLength(self.Faults,high(self.Faults)+2);
      self.Faults[high(self.Faults)]:=col;
      if high(self.Faults)=0 then result:=Prod;
    end;
  end;
  if high(self.Faults)<0 then begin
    i:=0;
    while (i<=high(self.ModelsInd))and(Length(self.ProdSG.Cells[self.ProdSG.FixedCols+i,2])=0) do inc(i);
    if(i<=high(self.ModelsInd))and(Length(self.ProdSG.Cells[self.ProdSG.FixedCols+i,2])>0) then begin
      if MsgForm.ShowMessageForm('Результат производства с учетом предыдущего отчета уже'+
        ' посчтиан.'+chr(13)+'Пересчитать ?')=mrYes then self.CalckLotResult;
    end else self.CalckLotResult;
  end;
end;

procedure TDocForm.CalckLotResult;
var
  col : integer;
  CDS : TClientdataSet;
begin
  CDS:=TClientDataSet.Create(self);
  CDS.CloneCursor(DataMod.DataCDS,true,false);
  for col := 0 to high(self.ModelsInd) do begin
   // if StrToIntDef(self.ProdSG.Cells[self.ProdSG.FixedCols+col,1],0)>0 then begin
      CDS.Filter:='REPID='+IntToStr(PrevID)+' AND MODE='+IntToStr(mdLOTASSEMBL)+
        ' AND MODEL='+IntToStr(self.ModelsInd[col]);
      CDS.Filtered:=true;
      if (CDS.IsEmpty) then
        self.ProdSG.Cells[self.ProdSG.FixedCols+col,2]:=self.ProdSG.Cells[self.ProdSG.FixedCols+col,1]
      else self.ProdSG.Cells[self.ProdSG.FixedCols+col,2]:=IntToStr(CDS.FieldByName('COUNT').AsInteger+
        StrToIntDef(self.ProdSG.Cells[self.ProdSG.FixedCols+col,1],0));
      CDS.Filtered:=false;
    end;
  CDS.Free;
end;

//------------------------ события кнопок --------------------------------------

procedure TDocForm.EditBtnClick(Sender: TObject);
var
  i  : integer;
begin
  if StOstSg.RowCount=2 then begin
    StOstSG.RowCount:=3;
    StOstSG.Cells[0,2]:='Исправ ('+DataMod.PersonCDS.Lookup('ID',AutorID,'DESCR')+')';
    for I := 1 to StOstSG.ColCount - 1 do StOstSG.Cells[i,2]:='';
    self.SetGridSize(StOstSG);
    self.ShowStOstEditBtn(2);
  end else begin
    for I := 0 to StOstSG.ColCount - 1 do StOstSG.Cells[i,2]:='';
    STOstSG.RowCount:=2;
    self.SetGridSize(StOstSg);
    self.ShowStOstEditBtn(1);
  end;
end;

procedure TDocForm.GetOTKDataBtnClick(Sender: TObject);
var
  i,cnt  : integer;
  mypath : string;
begin
  if RepID=0 then mypath:=ScanGearPath+'\'+FormatDateTime('ddmmyy',now)+'.txt'
    else mypath:=ScanGearPath+'\'+FormatDateTime('ddmmyy',DataMod.ReportCDS.FieldByName('DATE').AsDateTime)+'.txt';
  if (FileExists(mypath))then begin
    if  MsgForm.ShowMessageForm('Получить данные о производстве с рабочего места ОТК ?')=mrYes then begin
      for I := 0 to high(self.ModelsInd) do
        if DataMod.ModelsCDS.Lookup('ID',self.ModelsInd[i],'IDFORCODE')<>null then begin
          cnt:=DataMod.GetLogCnt(mypath,DataMod.ModelsCDS.Lookup('ID',self.ModelsInd[i],'IDFORCODE'));
          if cnt=0 then ProdSG.Cells[ProdSG.FixedCols+i,1]:='' else ProdSG.Cells[ProdSG.FixedCols+i,1]:=IntToStr(cnt);
        end;
      GetOTKDataBtn.Visible:=false;
    end;
    self.CalckLotResult;
  end else self.MyShowMessage('Нет доступа к компьютеру ОТК !',pmtError,3);
end;

procedure TDocForm.DelMovBtnClick(Sender: TObject);
var
  row, col : integer;
begin
  for col := 0 to high(self.ModelsInd)+OutSG.FixedCols do begin
    for row := 0 to high(self.MovSign)-1 do
      OutSG.Cells[col,row+DelMovBtnPN.Tag]:=OutSG.Cells[col,row+DelMovBtnPN.Tag+1];
    OutSG.Cells[col,high(self.MovSign)+OutSG.FixedRows]:='';
  end;
  for row := 0 to high(self.MovSign)-1 do
    self.MovSign[DelMovBtnPN.Tag-1]:=self.MovSign[DelMovBtnPN.Tag];
  SetLength(self.MovSign,high(self.MovSign));
  DelMovBtnPN.Tag:=0;
  DelMovBtnPN.Visible:=false;
end;

procedure TDocForm.MailBtnClick(Sender: TObject);
begin
  self.SendMail(true);
end;

procedure TDocForm.SaveBtnClick(Sender: TObject);
begin
  if (RepID>0)and(DataMod.ReportCDS.FieldByName('SEND').AsBoolean) then begin
    self.MyShowMessage('Вы пытаетесь перезаписать уже разосланный документ.'+chr(13)+
      'Отчет будет отправлен снова !',pmtWarning,3);
    application.ProcessMessages;
    sleep(3000);
    self.SendMail(false);
  end;
  self.SaveReport(self);
  self.MyShowMessage('Отчет записан ! ',pmtInform,3);
  if not ShowResult then ShowResult:=true;
end;

procedure TDocForm.CloseBtnClick(Sender: TObject);
begin
  self.Close;
end;

procedure TDocForm.PrintBtnClick(Sender: TObject);
begin
  Report.ShowReport(true);
end;

procedure TDocForm.Timer1Timer(Sender: TObject);
begin
  //Скрытие кнопок в таблице
  if (not StOstSG.MouseInClient)and(not EditBtn.MouseInClient) then EditBtn.Visible:=false;
  if (not ProdSG.MouseInClient)and(not GetOTKDataBtn.MouseInClient) then GetOTKDataBtn.Visible:=false;
  if (not OutSG.MouseInClient)and(self.DelMovBtnPN.Visible) then self.DelMovBtnPN.Visible:=false;
end;

procedure TDocForm.VerBtnClick(Sender: TObject);
var
  fc, modid : integer;
  str  : string;
begin
  //Проверка расчетныйх ошибок
  fc:=(self.ClkRes);
  if high(self.Faults)>=0 then begin
    StOstSG.Repaint;
    OutSg.Repaint;
    EndOstSG.Repaint;
    ProdSg.Repaint;
    beep;
    str:='Остатки не верны!'+chr(13);
    modid:=self.ModelsInd[self.Faults[0]];
    if fc>=0 then begin
      modid:=self.ModelsInd[self.Faults[0]];
      str:=str+'Результат производства '+DataMod.ModelsCDS.Lookup('ID',modid,'DESCR') +
        ' должен быть равен '+inttostr(fc)+' шт.'+chr(13);
      str:=str+'Исправить данные о производстве?' ;
      if MsgForm.ShowMessageForm(str)=mrYes then begin
        ProdSG.Cells[self.Faults[0]+ProdSG.FixedCols,1]:=inttostr(fc);
        self.VerBtnClick(sender);
      end;
    end else begin
      str:=str+'Отрицательный результат производства '+DataMod.ModelsCDS.Lookup('ID',modid,'DESCR')+': '
        +inttostr(fc)+' шт';
      self.MyShowMessage(str,pmtError,3);
    end;
  end else begin
    StOstSG.Repaint;
    OutSg.Repaint;
    EndOstSG.Repaint;
    ProdSg.Repaint;
    if (Sender as TSpeedButton).Name='VerBtn' then
      self.MyShowMessage('Расчет произведен верно !',pmtInform,3);
  end;
end;

//----------------- подготовка печатной формы ----------------------------------

procedure TDocForm.ReportGetValue(const VarName: string; var Value: Variant);
var
  i,j : integer;
  str:string;
begin
  if CompareText(VarName,'DateLB')=0 then value:=DateLb.Caption;
  if CompareText(VarName,'AutorLB')=0 then value:=AutorLb.Caption;
  for j := 1 to 5 do
    for I := 0 to StOstSG.ColCount-1 do begin
        Str:='MI'+FormatFloat('00',i+1);
        if CompareText(VarName,str)=0 then Value:=(StOstSG.Cells[i+1,0]);
        Str:='StOst'+FormatFloat('0',i)+FormatFloat('0',j);
        if CompareText(VarName,str)=0 then Value:=(StOstSG.Cells[i,j]);
        Str:='Out'+FormatFloat('0',i)+FormatFloat('0',j);
        if CompareText(VarName,str)=0 then Value:=(OutSG.Cells[i,j]);
        Str:='EndOst'+FormatFloat('0',i)+FormatFloat('0',j);
        if CompareText(VarName,str)=0 then Value:=(EndOstSG.Cells[i,j]);
        Str:='Prod'+FormatFloat('0',i)+FormatFloat('0',j);
        if CompareText(VarName,str)=0 then Value:=(ProdSG.Cells[i,j]);
      end;
end;


end.
