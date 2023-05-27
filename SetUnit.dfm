object SetForm: TSetForm
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = #1053#1072#1089#1088#1086#1081#1082#1080
  ClientHeight = 339
  ClientWidth = 741
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Pages: TPageControl
    Left = 0
    Top = 0
    Width = 741
    Height = 339
    ActivePage = MainPage
    Align = alClient
    TabOrder = 0
    ExplicitHeight = 322
    object MainPage: TTabSheet
      Caption = #1054#1073#1097#1080#1077
      ImageIndex = 2
      ExplicitHeight = 294
      object GroupBox1: TGroupBox
        AlignWithMargins = True
        Left = 10
        Top = 10
        Width = 713
        Height = 183
        Margins.Left = 10
        Margins.Top = 10
        Margins.Right = 10
        Margins.Bottom = 10
        Align = alTop
        Caption = #1054#1090#1087#1088#1072#1082#1072' '#1087#1086#1095#1090#1099':: '
        TabOrder = 0
        object Label1: TLabel
          Left = 16
          Top = 32
          Width = 104
          Height = 13
          Caption = #1040#1076#1088#1077#1089' '#1086#1090#1087#1088#1072#1074#1080#1090#1077#1083#1103':'
        end
        object Label2: TLabel
          Left = 16
          Top = 59
          Width = 96
          Height = 13
          Caption = #1057#1077#1088#1074#1077#1088' '#1080#1089#1093' '#1087#1086#1095#1090#1099':'
        end
        object Label3: TLabel
          Left = 16
          Top = 86
          Width = 29
          Height = 13
          Caption = #1055#1086#1088#1090':'
        end
        object Label4: TLabel
          Left = 16
          Top = 113
          Width = 34
          Height = 13
          Caption = #1051#1086#1075#1080#1085':'
        end
        object Label5: TLabel
          Left = 16
          Top = 140
          Width = 41
          Height = 13
          Caption = #1055#1072#1088#1086#1083#1100':'
        end
        object Label6: TLabel
          Left = 408
          Top = 32
          Width = 110
          Height = 13
          Caption = #1040#1076#1088#1077#1089#1072' '#1087#1086#1083#1091#1095#1072#1090#1077#1083#1077#1081':'
        end
        object FromED: TEdit
          Left = 136
          Top = 29
          Width = 241
          Height = 21
          TabOrder = 0
          Text = 'FromED'
        end
        object HostED: TEdit
          Left = 136
          Top = 56
          Width = 241
          Height = 21
          TabOrder = 1
          Text = 'HostED'
        end
        object PortED: TEdit
          Left = 136
          Top = 83
          Width = 65
          Height = 21
          TabOrder = 2
          Text = 'PortED'
        end
        object LoginED: TEdit
          Left = 136
          Top = 110
          Width = 121
          Height = 21
          TabOrder = 3
          Text = 'LoginED'
        end
        object PasswordED: TEdit
          Left = 136
          Top = 137
          Width = 121
          Height = 21
          TabOrder = 4
          Text = 'PasswordED'
        end
        object RecipMemo: TMemo
          Left = 408
          Top = 51
          Width = 289
          Height = 110
          TabOrder = 5
        end
      end
      object GroupBox2: TGroupBox
        AlignWithMargins = True
        Left = 10
        Top = 203
        Width = 713
        Height = 86
        Margins.Left = 10
        Margins.Top = 0
        Margins.Right = 10
        Margins.Bottom = 10
        Align = alTop
        Caption = #1055#1091#1090#1100' '#1082' '#1076#1072#1085#1085#1099#1084' '#1089#1082#1072#1085#1077#1088#1072':'
        TabOrder = 1
        object ScanGearPathBtn: TSpeedButton
          Left = 674
          Top = 23
          Width = 23
          Height = 21
          Caption = '...'
        end
        object ScanGearPathED: TEdit
          Left = 16
          Top = 24
          Width = 652
          Height = 21
          TabOrder = 0
          Text = 'ScanGearPathED'
        end
        object CheckOTKCB: TCheckBox
          Left = 16
          Top = 51
          Width = 425
          Height = 17
          Caption = '- '#1087#1088#1086#1074#1077#1088#1103#1090#1100' '#1089#1086#1086#1090#1074#1077#1090#1089#1090#1074#1080#1077' '#1087#1088#1086#1080#1079#1074#1086#1076#1089#1090#1074#1072' '#1076#1072#1085#1085#1099#1084' '#1054#1058#1050
          TabOrder = 1
        end
      end
    end
    object ModelsPage: TTabSheet
      BorderWidth = 5
      Caption = #1052#1086#1076#1077#1083#1080
      ExplicitHeight = 294
      object ToolBar2: TToolBar
        Left = 0
        Top = 0
        Width = 723
        Height = 29
        Caption = 'ToolBar2'
        TabOrder = 0
        object ModelsNav: TDBNavigator
          Left = 0
          Top = 0
          Width = 240
          Height = 22
          DataSource = ModelsDS
          Flat = True
          TabOrder = 0
        end
      end
      object ModelsGrid: TDBGrid
        Left = 0
        Top = 29
        Width = 723
        Height = 272
        Align = alClient
        DataSource = ModelsDS
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'DESCR'
            Title.Caption = #1053#1072#1080#1084#1077#1085#1086#1074#1072#1085#1080#1077
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'SHORTDESCR'
            Title.Caption = #1050#1088#1072#1090#1082#1086
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'CODE'
            Title.Caption = #1050#1086#1076' '#1087#1086' 1'#1057
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'MODEL'
            PickList.Strings = (
              '')
            Title.Caption = #1052#1086#1076#1077#1083#1100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'MARK'
            Title.Caption = #1052#1072#1088#1082#1072
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'IDFORCODE'
            Title.Alignment = taCenter
            Title.Caption = 'ID '#1074' '#1082#1086#1076#1077
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COUNTFORPERSON'
            Title.Alignment = taCenter
            Title.Caption = #1045#1076'/'#1095#1077#1083
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'NOTE'
            Title.Caption = #1055#1088#1080#1084#1077#1095#1072#1085#1080#1077
            Visible = True
          end>
      end
    end
    object PersonPage: TTabSheet
      BorderWidth = 5
      Caption = #1055#1086#1083#1100#1079#1086#1074#1072#1090#1077#1083#1080
      ImageIndex = 1
      ExplicitHeight = 294
      object PersonTB: TToolBar
        Left = 0
        Top = 0
        Width = 723
        Height = 29
        Caption = 'PersonTB'
        TabOrder = 0
        object PersonNav: TDBNavigator
          Left = 0
          Top = 0
          Width = 240
          Height = 22
          DataSource = PersonDS
          Flat = True
          TabOrder = 0
        end
      end
      object PersonGrid: TDBGrid
        Left = 0
        Top = 29
        Width = 723
        Height = 272
        Align = alClient
        DataSource = PersonDS
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'DESCR'
            Title.Caption = #1057#1086#1090#1088#1091#1076#1085#1080#1082
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'ACSLEVEL'
            Title.Caption = #1059#1088#1086#1074#1077#1085#1100' '#1076#1086#1089#1090#1091#1087#1072
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PASSWORD'
            Title.Caption = #1055#1072#1088#1086#1083#1100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'NOTE'
            Title.Caption = #1055#1088#1080#1084#1077#1095#1072#1085#1080#1077
            Visible = True
          end>
      end
    end
    object RepTablePage: TTabSheet
      Caption = #1058#1072#1073#1083#1080#1094#1072' REPORT'
      ImageIndex = 3
      ExplicitHeight = 294
      object ToolBar1: TToolBar
        Left = 0
        Top = 0
        Width = 733
        Height = 29
        Caption = 'PersonTB'
        TabOrder = 0
        object DBNavigator1: TDBNavigator
          Left = 0
          Top = 0
          Width = 240
          Height = 22
          DataSource = ReportDS
          Flat = True
          TabOrder = 0
        end
      end
      object DBGrid1: TDBGrid
        Left = 0
        Top = 29
        Width = 733
        Height = 282
        Align = alClient
        DataSource = ReportDS
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'ID'
            ReadOnly = True
            Width = 50
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'DATE'
            Title.Caption = #1044#1072#1090#1072' (DATE)'
            Width = 150
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'AUTOR'
            Title.Caption = #1040#1074#1090#1086#1088' (AUTOR)'
            Width = 150
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'SEND'
            Title.Caption = #1054#1090#1087#1088#1072#1074'-'#1085#1086' (SEND)'
            Width = 150
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'PARENT'
            Title.Caption = #1055#1088#1077#1076#1086#1082' (PARENT)'
            Width = 150
            Visible = True
          end>
      end
    end
    object DataTablePage: TTabSheet
      Caption = #1058#1072#1073#1083#1080#1094#1072' DATA'
      ImageIndex = 4
      ExplicitHeight = 294
      object ToolBar3: TToolBar
        Left = 0
        Top = 0
        Width = 733
        Height = 29
        Caption = 'PersonTB'
        TabOrder = 0
        object DBNavigator2: TDBNavigator
          Left = 0
          Top = 0
          Width = 240
          Height = 22
          DataSource = DataDS
          Flat = True
          TabOrder = 0
        end
      end
      object DBGrid2: TDBGrid
        Left = 0
        Top = 29
        Width = 733
        Height = 282
        Align = alClient
        DataSource = DataDS
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'ID'
            ReadOnly = True
            Width = 50
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'REPID'
            Title.Caption = #1054#1090#1095#1077#1090' (REPID)'
            Width = 100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'MODEL'
            Title.Caption = #1052#1086#1076#1077#1083#1100' (MODEL)'
            Width = 100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'MODE'
            Title.Caption = #1056#1077#1078#1080#1084' (MODE)'
            Width = 100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'COUNT'
            Title.Caption = #1050#1086#1083'-'#1074#1086' (COUNT)'
            Width = 100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'LOTNUMBER'
            Title.Caption = #1051#1086#1090' (LOTNUMBER)'
            Width = 100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'TITLE'
            Title.Caption = #1047#1072#1075'-'#1074#1086#1082' (TITLE)'
            Width = 100
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'NOTE'
            Title.Caption = #1055#1088#1080#1084#1077#1095' (NOTE)'
            Width = 200
            Visible = True
          end>
      end
    end
  end
  object ModelsDS: TDataSource
    DataSet = DataMod.ModelsCDS
    Left = 368
    Top = 8
  end
  object PersonDS: TDataSource
    DataSet = DataMod.PersonCDS
    Left = 424
    Top = 8
  end
  object ReportDS: TDataSource
    DataSet = DataMod.ReportCDS
    Left = 480
    Top = 8
  end
  object DataDS: TDataSource
    DataSet = DataMod.DataCDS
    Left = 536
    Top = 8
  end
end
