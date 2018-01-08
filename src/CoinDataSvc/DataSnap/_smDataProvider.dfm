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
    Left = 32
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
      'select * '
      'from ticker_tab'
      'where coin_code = :coin_code and'
      ':begin_time <= tick_stamp and :end_time >= tick_stamp'
      'order by tick_stamp')
    Left = 96
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
      'select max(volume) high_volume, min(volume) low_volume,'
      ' max(high_price) high_price, min(low_price) low_price'
      'from day_tab'
      'where coin_code = :coin_code and'
      ':begin_time <= day_stamp and :end_time >= day_stamp')
    Left = 168
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
  object qryTotalValue: TFDQuery
    SQL.Strings = (
      'select day_stamp, sum(last_price * amount) krw'
      'from day_tab'
      'where day_stamp = :day_stamp'
      'group by day_stamp')
    Left = 168
    Top = 88
    ParamData = <
      item
        Name = 'DAY_STAMP'
        ParamType = ptInput
      end>
  end
end
