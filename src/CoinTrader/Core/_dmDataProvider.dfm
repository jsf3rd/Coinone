object dmDataProvider: TdmDataProvider
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 404
  Width = 484
  object mtTick: TFDMemTable
    OnCalcFields = mtTickCalcFields
    FieldDefs = <>
    IndexDefs = <>
    IndexFieldNames = 'coin'
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 48
    Top = 112
    object mtTickcoin: TWideStringField
      DisplayLabel = #53076#51064
      DisplayWidth = 10
      FieldName = 'coin'
      OnGetText = mtTickcoinGetText
      Size = 64
    end
    object mtTicklast: TFloatField
      DisplayLabel = #54788#51116#44032
      DisplayWidth = 15
      FieldName = 'last'
      DisplayFormat = '#,##0'
    end
    object mtTickprice_rate: TFloatField
      DisplayLabel = #51204#51068#45824#48708' '#44032#44201
      DisplayWidth = 15
      FieldKind = fkCalculated
      FieldName = 'price_rate'
      DisplayFormat = '#0.00'
      Calculated = True
    end
    object mtTickvolume_rate: TFloatField
      DisplayLabel = #51204#51068#45824#48708' '#44144#47000#47049
      DisplayWidth = 15
      FieldKind = fkCalculated
      FieldName = 'volume_rate'
      DisplayFormat = '#0.00'
      Calculated = True
    end
    object mtTickvolume: TFloatField
      DisplayLabel = #44144#47000#47049
      DisplayWidth = 13
      FieldName = 'volume'
      DisplayFormat = '#,##0'
    end
    object mtTickhigh: TFloatField
      DisplayLabel = #51204#51068' '#52572#44256#44032
      DisplayWidth = 13
      FieldName = 'high_price'
      DisplayFormat = '#,##0'
    end
    object mtTicklow_price: TFloatField
      DisplayLabel = #51204#51068' '#52572#51200#44032
      DisplayWidth = 13
      FieldName = 'low_price'
      DisplayFormat = '#,##0'
    end
    object mtTickyesterday_volume: TFloatField
      DisplayLabel = #51204#51068#44144#47000#47049
      DisplayWidth = 13
      FieldName = 'yesterday_volume'
      Visible = False
      DisplayFormat = '#,##0'
    end
    object mtTickfirst: TFloatField
      FieldName = 'first'
      Visible = False
    end
    object mtTickyesterday_last: TFloatField
      FieldName = 'yesterday_last'
      Visible = False
    end
  end
  object dsTick: TDataSource
    DataSet = mtTick
    Left = 104
    Top = 112
  end
  object mtTickPeriod: TFDMemTable
    OnCalcFields = mtTickPeriodCalcFields
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 48
    Top = 192
    object WideStringField1: TWideStringField
      DisplayLabel = #53076#51064
      DisplayWidth = 10
      FieldName = 'coin_code'
      Size = 64
    end
    object FloatField1: TFloatField
      DisplayLabel = #54788#51116#44032
      DisplayWidth = 15
      FieldName = 'price'
      DisplayFormat = '#,##0'
    end
    object FloatField4: TFloatField
      FieldName = 'volume'
      Visible = False
    end
    object FloatField6: TFloatField
      FieldName = 'yesterday_volume'
      Visible = False
    end
    object mtTickPeriodyesterday_last: TFloatField
      FieldName = 'yesterday_last'
    end
    object mtTickPeriodtick_stamp: TSQLTimeStampField
      FieldName = 'tick_stamp'
    end
    object mtTickPeriodstoch: TFloatField
      FieldKind = fkCalculated
      FieldName = 'price_stoch'
      Calculated = True
    end
    object mtTickPeriodvolume_avg: TFloatField
      FieldKind = fkCalculated
      FieldName = 'volume_stoch'
      LookupDataSet = mtTick
      Calculated = True
    end
    object mtTickPeriodhigh_price: TFloatField
      FieldName = 'high_price'
    end
    object mtTickPeriodlow_price: TFloatField
      FieldName = 'low_price'
    end
  end
  object DSRestConnection: TDSRestConnection
    Port = 80
    LoginPrompt = False
    PreserveSessionID = False
    Left = 48
    Top = 32
    UniqueId = '{B2C5EBE4-1FE4-470A-B98B-E83CC07F9698}'
  end
  object FDStanStorageBinLink: TFDStanStorageBinLink
    Left = 48
    Top = 256
  end
  object mtHighLow: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 160
    Top = 192
    object mtHighLowhigh_price: TFloatField
      DisplayLabel = #52572#44256#44032
      DisplayWidth = 15
      FieldName = 'high_price'
      DisplayFormat = '#,##0'
    end
    object mtHighLowlow_price: TFloatField
      DisplayLabel = #52572#51200#44032
      FieldName = 'low_price'
      Visible = False
    end
    object FloatField2: TFloatField
      DisplayLabel = #52572#44256#44032
      DisplayWidth = 15
      FieldName = 'high_volume'
      DisplayFormat = '#,##0'
    end
    object FloatField7: TFloatField
      DisplayLabel = #52572#51200#44032
      FieldName = 'low_volume'
      Visible = False
    end
  end
  object mtBalance: TFDMemTable
    OnCalcFields = mtTickCalcFields
    IndexFieldNames = 'coin'
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 288
    Top = 112
    object WideStringField2: TWideStringField
      DisplayLabel = #53076#51064
      DisplayWidth = 10
      FieldName = 'coin'
      OnGetText = mtTickcoinGetText
      Size = 64
    end
    object FloatField8: TFloatField
      DisplayLabel = #49688#47049
      DisplayWidth = 15
      FieldName = 'amount'
      DisplayFormat = '#,##0.00'
    end
    object FloatField5: TFloatField
      DisplayLabel = #54788#51116#44032
      DisplayWidth = 15
      FieldName = 'last'
      DisplayFormat = '#,##0'
    end
    object FloatField9: TFloatField
      DisplayLabel = #54217#44032#50529
      DisplayWidth = 15
      FieldName = 'krw'
      DisplayFormat = '#,##0'
    end
  end
  object dsBalance: TDataSource
    DataSet = mtBalance
    Left = 360
    Top = 112
  end
  object mtLimitOrders: TFDMemTable
    OnCalcFields = mtTickCalcFields
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 288
    Top = 192
    object mtLimitOrderscoin: TWideStringField
      DisplayLabel = #53076#51064
      DisplayWidth = 6
      FieldName = 'coin'
      OnGetText = mtTickcoinGetText
      Size = 16
    end
    object mtLimitOrdersorder_stamp: TSQLTimeStampField
      Alignment = taCenter
      DisplayLabel = #49884#44036
      DisplayWidth = 18
      FieldName = 'order_stamp'
      DisplayFormat = 'YYYY-MM-DD hh:nn:ss'
    end
    object FloatField11: TFloatField
      DisplayLabel = #52404#44208#44032
      DisplayWidth = 9
      FieldName = 'price'
      DisplayFormat = '#,##0'
    end
    object FloatField10: TFloatField
      DisplayLabel = #49688#47049
      DisplayWidth = 7
      FieldName = 'amount'
      DisplayFormat = '#,##0.00'
    end
    object mtLimitOrdersorder_type: TWideStringField
      Alignment = taCenter
      DisplayLabel = #44396#48516
      DisplayWidth = 7
      FieldName = 'order_type'
      OnGetText = mtLimitOrdersorder_typeGetText
      Size = 16
    end
    object mtLimitOrdersorder_id: TWideStringField
      FieldName = 'order_id'
      Visible = False
      Size = 64
    end
  end
  object dsLimitOrders: TDataSource
    DataSet = mtLimitOrders
    Left = 384
    Top = 192
  end
  object mtCompleteOrders: TFDMemTable
    OnCalcFields = mtTickCalcFields
    FieldDefs = <>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 288
    Top = 264
    object WideStringField3: TWideStringField
      DisplayLabel = #53076#51064
      DisplayWidth = 6
      FieldName = 'coin'
      OnGetText = mtTickcoinGetText
      Size = 10
    end
    object SQLTimeStampField1: TSQLTimeStampField
      Alignment = taCenter
      DisplayLabel = #49884#44036
      DisplayWidth = 18
      FieldName = 'order_stamp'
      DisplayFormat = 'YYYY-MM-DD hh:nn:ss'
    end
    object FloatField12: TFloatField
      DisplayLabel = #52404#44208#44032
      DisplayWidth = 9
      FieldName = 'price'
      DisplayFormat = '#,##0'
    end
    object FloatField13: TFloatField
      DisplayLabel = #49688#47049
      DisplayWidth = 7
      FieldName = 'amount'
      DisplayFormat = '#,##0.00'
    end
    object WideStringField4: TWideStringField
      Alignment = taCenter
      DisplayLabel = #44396#48516
      DisplayWidth = 6
      FieldName = 'order_type'
      OnGetText = mtLimitOrdersorder_typeGetText
      Size = 16
    end
    object mtCompleteOrderslast: TFloatField
      DisplayLabel = #49688#49688#47308
      DisplayWidth = 7
      FieldName = 'fee'
      DisplayFormat = '#,##0.00'
    end
    object WideStringField5: TWideStringField
      FieldName = 'order_id'
      Visible = False
      Size = 64
    end
  end
  object dsCompleteOrders: TDataSource
    DataSet = mtCompleteOrders
    Left = 384
    Top = 264
  end
  object mtStoch: TFDMemTable
    Active = True
    FieldDefs = <
      item
        Name = 'tick_stamp'
        DataType = ftTimeStamp
      end
      item
        Name = 'price_stoch'
        DataType = ftFloat
      end>
    IndexDefs = <>
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    StoreDefs = True
    Left = 56
    Top = 328
    object SQLTimeStampField2: TSQLTimeStampField
      FieldName = 'tick_stamp'
    end
    object FloatField17: TFloatField
      FieldName = 'price_stoch'
    end
  end
end
