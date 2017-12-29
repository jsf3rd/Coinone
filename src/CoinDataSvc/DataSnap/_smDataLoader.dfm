object smDataLoader: TsmDataLoader
  OldCreateOrder = False
  Height = 150
  Width = 215
  object qryUplaodTicker: TFDQuery
    SQL.Strings = (
      'INSERT INTO '
      '  public.ticker_tab'
      '('
      '  volume,'
      '  yesterday_volume,'
      '  now_price,'
      '  tick_time,'
      '  coin_code'
      ')'
      'VALUES ('
      '  :volume,'
      '  :yesterday_volume,'
      '  :now_price,'
      '  :tick_time,'
      '  :coin_code'
      ');')
    Left = 40
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
        Name = 'NOW_PRICE'
        DataType = ftFloat
        ParamType = ptInput
      end
      item
        Name = 'TICK_TIME'
        DataType = ftDateTime
        ParamType = ptInput
      end
      item
        Name = 'COIN_CODE'
        DataType = ftWideString
        ParamType = ptInput
      end>
  end
end
