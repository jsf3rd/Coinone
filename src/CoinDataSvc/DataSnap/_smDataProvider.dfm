object smDataProvider: TsmDataProvider
  OldCreateOrder = False
  OnCreate = DSServerModuleCreate
  OnDestroy = DSServerModuleDestroy
  Height = 259
  Width = 405
  object qryDay: TFDQuery
    SQL.Strings = (
      'select * '
      'from day_tab'
      'where coin_code = :coin_code and'
      ':begin_time <= day_stamp and :end_time >= day_stamp'
      'order by day_stamp')
    Left = 48
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
  object qryTick: TFDQuery
    SQL.Strings = (
      'select t1.*,'
      
        '(select Max(t2.price) from ticker_tab t2 where t2.coin_code = t1' +
        '.coin_code and t2.tick_stamp > (t1.tick_stamp - interval '#39'7 hour' +
        #39') and t2.tick_stamp <= t1.tick_stamp ) high_price,'
      
        '(select Min(t2.price) from ticker_tab t2 where t2.coin_code = t1' +
        '.coin_code and t2.tick_stamp > (t1.tick_stamp - interval '#39'7 hour' +
        #39') and t2.tick_stamp <= t1.tick_stamp ) low_price,'
      
        '(select Avg(t2.price) from ticker_tab t2 where t2.coin_code = t1' +
        '.coin_code and t2.tick_stamp > (t1.tick_stamp - interval '#39'12 hou' +
        'r'#39') and t2.tick_stamp <= t1.tick_stamp ) ma'
      'from ticker_tab t1'
      'where t1.coin_code = :coin_code and'
      ':begin_time <= t1.tick_stamp and :end_time >= t1.tick_stamp'
      'order by t1.tick_stamp')
    Left = 112
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
  object FDStanStorageBinLink: TFDStanStorageBinLink
    Left = 56
    Top = 88
  end
  object qryHighLow: TFDQuery
    SQL.Strings = (
      'select Max(price) high_price, Min(price) low_price'
      'from ticker_tab'
      'where coin_code = :coin_code '
      'and tick_stamp > (now() - interval '#39'7 hour'#39') '
      'and tick_stamp <= now()')
    Left = 184
    Top = 16
    ParamData = <
      item
        Name = 'COIN_CODE'
        DataType = ftWideString
        ParamType = ptInput
      end>
  end
  object qryTotalValue: TFDQuery
    SQL.Strings = (
      'select day_stamp, sum(last_price * amount) krw'
      'from day_tab'
      'where day_stamp = :day_stamp'
      'group by day_stamp')
    Left = 184
    Top = 88
    ParamData = <
      item
        Name = 'DAY_STAMP'
        ParamType = ptInput
      end>
  end
end
