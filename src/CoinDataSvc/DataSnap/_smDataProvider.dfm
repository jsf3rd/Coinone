object smDataProvider: TsmDataProvider
  OldCreateOrder = False
  Height = 259
  Width = 405
  object qryTicker: TFDQuery
    SQL.Strings = (
      'select t1.*,'
      
        '(select Max(t2.price) from ticker_tab t2 where t2.coin_code = t1' +
        '.coin_code and t2.tick_stamp > (t1.tick_stamp - :high_period) an' +
        'd t2.tick_stamp <= t1.tick_stamp ) high_price,'
      
        '(select Min(t2.price) from ticker_tab t2 where t2.coin_code = t1' +
        '.coin_code and t2.tick_stamp > (t1.tick_stamp - :low_period) and' +
        ' t2.tick_stamp <= t1.tick_stamp ) low_price'
      'from ticker_tab t1'
      'where t1.coin_code = :coin_code and'
      ':begin_time <= t1.tick_stamp and :end_time >= t1.tick_stamp'
      'order by t1.tick_stamp')
    Left = 56
    Top = 16
    ParamData = <
      item
        Name = 'HIGH_PERIOD'
        DataType = ftTime
        ParamType = ptInput
      end
      item
        Name = 'LOW_PERIOD'
        DataType = ftTime
        ParamType = ptInput
      end
      item
        Name = 'COIN_CODE'
        DataType = ftWideString
        ParamType = ptInput
      end
      item
        Name = 'BEGIN_TIME'
        DataType = ftTimeStamp
        ParamType = ptInput
      end
      item
        Name = 'END_TIME'
        DataType = ftTimeStamp
        ParamType = ptInput
      end>
  end
  object FDStanStorageBinLink: TFDStanStorageBinLink
    Left = 56
    Top = 88
  end
  object qryHighLow: TFDQuery
    SQL.Strings = (
      'select Max(price) high_price, Min(price) low_price'
      'from ticker_tab'
      'where coin_code = :coin_code '
      'and tick_stamp > :begin_time'
      'and tick_stamp <= :end_time')
    Left = 128
    Top = 16
    ParamData = <
      item
        Name = 'COIN_CODE'
        DataType = ftWideString
        ParamType = ptInput
      end
      item
        Name = 'BEGIN_TIME'
        DataType = ftTimeStamp
        ParamType = ptInput
      end
      item
        Name = 'END_TIME'
        DataType = ftTimeStamp
        ParamType = ptInput
      end>
  end
  object qryOrder: TFDQuery
    SQL.Strings = (
      'select *'
      'from order_tab'
      'where coin_code = :coin_code'
      'and :begin_time <= order_stamp and :end_time >= order_stamp'
      'and user_id = :user_id'
      'order by order_stamp')
    Left = 192
    Top = 16
    ParamData = <
      item
        Name = 'COIN_CODE'
        DataType = ftWideString
        ParamType = ptInput
      end
      item
        Name = 'BEGIN_TIME'
        DataType = ftTimeStamp
        ParamType = ptInput
      end
      item
        Name = 'END_TIME'
        DataType = ftTimeStamp
        ParamType = ptInput
      end
      item
        Name = 'USER_ID'
        DataType = ftWideString
        ParamType = ptInput
      end>
  end
end
