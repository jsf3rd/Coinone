object smDataLoader: TsmDataLoader
  OldCreateOrder = False
  Height = 260
  Width = 338
  object qryUploadTicker: TFDQuery
    SQL.Strings = (
      'INSERT INTO '
      '  public.ticker_tab'
      '('
      '  volume,'
      '  yesterday_volume,'
      '  price,'
      '  yesterday_last,'
      '  tick_stamp,'
      '  coin_code'
      ')'
      'VALUES ('
      '  :volume,'
      '  :yesterday_volume,'
      '  :price,'
      '  :yesterday_last,'
      '  :tick_stamp,'
      '  :coin_code'
      ');')
    Left = 64
    Top = 24
    ParamData = <
      item
        Name = 'VOLUME'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'YESTERDAY_VOLUME'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'PRICE'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'YESTERDAY_LAST'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'TICK_STAMP'
        DataType = ftTimeStamp
        ParamType = ptInput
      end
      item
        Name = 'COIN_CODE'
        DataType = ftWideString
        ParamType = ptInput
      end>
  end
  object qryUploadOrder: TFDQuery
    SQL.Strings = (
      'INSERT INTO '
      '  public.order_tab'
      '('
      '  order_id,'
      '  coin_code,'
      '  price,'
      '  qty,'
      '  order_stamp,'
      '  user_id,'
      '  order_type'
      ')'
      'VALUES ('
      '  :order_id,'
      '  :coin_code,'
      '  :price,'
      '  :qty,'
      '  :order_stamp,'
      '  :user_id,'
      '  :order_type'
      ');')
    Left = 168
    Top = 24
    ParamData = <
      item
        Name = 'ORDER_ID'
        DataType = ftGuid
        ParamType = ptInput
      end
      item
        Name = 'COIN_CODE'
        DataType = ftWideString
        ParamType = ptInput
      end
      item
        Name = 'PRICE'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'QTY'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'ORDER_STAMP'
        DataType = ftTimeStamp
        ParamType = ptInput
      end
      item
        Name = 'USER_ID'
        DataType = ftWideString
        ParamType = ptInput
      end
      item
        Name = 'ORDER_TYPE'
        DataType = ftWideString
        ParamType = ptInput
      end>
  end
  object qryDeleteOrder: TFDQuery
    SQL.Strings = (
      'delete from order_tab'
      'where order_id = :order_id')
    Left = 64
    Top = 96
    ParamData = <
      item
        Name = 'ORDER_ID'
        DataType = ftGuid
        ParamType = ptInput
      end>
  end
end
