object DataMod: TDataMod
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 211
  Width = 401
  object ModelsCDS: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'ID'
        DataType = ftAutoInc
      end
      item
        Name = 'DESCR'
        DataType = ftString
        Size = 255
      end
      item
        Name = 'CODE'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'IDFORCODE'
        DataType = ftString
        Size = 4
      end
      item
        Name = 'COUNTFORPERSON'
        DataType = ftFloat
      end
      item
        Name = 'MARK'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'MODEL'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'NOTE'
        DataType = ftString
        Size = 255
      end
      item
        Name = 'SHORTDESCR'
        DataType = ftString
        Size = 6
      end>
    IndexDefs = <>
    IndexFieldNames = 'DESCR'
    Params = <>
    StoreDefs = True
    Left = 48
    Top = 32
  end
  object PersonCDS: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'ID'
        DataType = ftAutoInc
      end
      item
        Name = 'DESCR'
        DataType = ftString
        Size = 255
      end
      item
        Name = 'ACSLEVEL'
        DataType = ftString
        Size = 50
      end
      item
        Name = 'PASSWORD'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'NOTE'
        DataType = ftString
        Size = 255
      end>
    IndexDefs = <>
    IndexFieldNames = 'DESCR'
    Params = <>
    StoreDefs = True
    Left = 136
    Top = 32
  end
  object ReportCDS: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'ID'
        DataType = ftAutoInc
      end
      item
        Name = 'DATE'
        DataType = ftDate
      end
      item
        Name = 'AUTOR'
        DataType = ftInteger
      end
      item
        Name = 'SEND'
        DataType = ftBoolean
      end
      item
        Name = 'PARENT'
        DataType = ftInteger
      end>
    IndexDefs = <>
    IndexFieldNames = 'DATE'
    Params = <>
    StoreDefs = True
    Left = 48
    Top = 104
  end
  object DataCDS: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'ID'
        DataType = ftAutoInc
      end
      item
        Name = 'REPID'
        DataType = ftInteger
      end
      item
        Name = 'MODEL'
        DataType = ftInteger
      end
      item
        Name = 'MODE'
        DataType = ftInteger
      end
      item
        Name = 'COUNT'
        DataType = ftInteger
      end
      item
        Name = 'LOTNUMBER'
        DataType = ftInteger
      end
      item
        Name = 'TITLE'
        DataType = ftString
        Size = 255
      end
      item
        Name = 'NOTE'
        DataType = ftString
        Size = 255
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 136
    Top = 104
  end
end
