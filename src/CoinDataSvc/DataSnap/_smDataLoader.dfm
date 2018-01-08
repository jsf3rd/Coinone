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
  object qryUploadDay: TFDQuery
    SQL.Strings = (
      'INSERT INTO '
      '  public.day_tab'
      '('
      '  volume,'
      '  last_price,'
      '  first_price,'
      '  high_price,'
      '  low_price,'
      '  day_stamp,'
      '  coin_code,'
      '  amount'
      ')'
      'VALUES ('
      '  :volume,'
      '  :last_price,'
      '  :first_price,'
      '  :high_price,'
      '  :low_price,'
      '  :day_stamp,'
      '  :coin_code,'
      '  :amount'
      ');')
    Left = 168
    Top = 24
    ParamData = <
      item
        Name = 'VOLUME'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'LAST_PRICE'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'FIRST_PRICE'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'HIGH_PRICE'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'LOW_PRICE'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'DAY_STAMP'
        DataType = ftTimeStamp
        ParamType = ptInput
      end
      item
        Name = 'COIN_CODE'
        DataType = ftWideString
        ParamType = ptInput
      end
      item
        Name = 'AMOUNT'
        DataType = ftFloat
        ParamType = ptInput
      end>
  end
end
