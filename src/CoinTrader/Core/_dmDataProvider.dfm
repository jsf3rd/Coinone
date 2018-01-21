object dmDataProvider: TdmDataProvider
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 404
  Width = 484
  object mtTicker: TFDMemTable
    OnCalcFields = mtTickerCalcFields
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
    object mtTickercoin: TWideStringField
      DisplayLabel = #53076#51064
      DisplayWidth = 10
      FieldName = 'coin'
      OnGetText = mtTickercoinGetText
      Size = 64
    end
    object mtTickerlast: TFloatField
      DisplayLabel = #54788#51116#44032
      DisplayWidth = 15
      FieldName = 'last'
      DisplayFormat = '#,##0'
    end
    object mtTickerprice_rate: TFloatField
      DisplayLabel = #51204#51068#45824#48708' '#44032#44201
      DisplayWidth = 15
      FieldKind = fkCalculated
      FieldName = 'price_rate'
      DisplayFormat = '#0.00'
      Calculated = True
    end
    object mtTickervolume_rate: TFloatField
      DisplayLabel = #51204#51068#45824#48708' '#44144#47000#47049
      DisplayWidth = 15
      FieldKind = fkCalculated
      FieldName = 'volume_rate'
      DisplayFormat = '#0.00'
      Calculated = True
    end
    object mtTickervolume: TFloatField
      DisplayLabel = #44144#47000#47049
      DisplayWidth = 13
      FieldName = 'volume'
      DisplayFormat = '#,##0'
    end
    object mtTickerhigh: TFloatField
      DisplayLabel = #51204#51068' '#52572#44256#44032
      DisplayWidth = 13
      FieldName = 'high_price'
      DisplayFormat = '#,##0'
    end
    object mtTickerlow_price: TFloatField
      DisplayLabel = #51204#51068' '#52572#51200#44032
      DisplayWidth = 13
      FieldName = 'low_price'
      DisplayFormat = '#,##0'
    end
    object mtTickeryesterday_volume: TFloatField
      DisplayLabel = #51204#51068#44144#47000#47049
      DisplayWidth = 13
      FieldName = 'yesterday_volume'
      Visible = False
      DisplayFormat = '#,##0'
    end
    object mtTickerfirst: TFloatField
      FieldName = 'first'
      Visible = False
    end
    object mtTickeryesterday_last: TFloatField
      FieldName = 'yesterday_last'
      Visible = False
    end
  end
  object dsTicker: TDataSource
    DataSet = mtTicker
    Left = 104
    Top = 112
  end
  object mtTickerPeriod: TFDMemTable
    OnCalcFields = mtTickerPeriodCalcFields
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
    object mtTickerPeriodyesterday_last: TFloatField
      FieldName = 'yesterday_last'
    end
    object mtTickerPeriodtick_stamp: TSQLTimeStampField
      FieldName = 'tick_stamp'
    end
    object mtTickerPeriodstoch: TFloatField
      FieldKind = fkCalculated
      FieldName = 'price_stoch'
      Calculated = True
    end
    object mtTickerPeriodvolume_avg: TFloatField
      FieldKind = fkCalculated
      FieldName = 'volume_stoch'
      LookupDataSet = mtTicker
      Calculated = True
    end
    object mtTickerPeriodhigh_price: TFloatField
      FieldName = 'high_price'
    end
    object mtTickerPeriodlow_price: TFloatField
      FieldName = 'low_price'
    end
    object mtTickerPeriodhigh_volume: TFloatField
      FieldName = 'high_volume'
    end
    object mtTickerPeriodlow_volume: TFloatField
      FieldName = 'low_volume'
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
    Top = 352
  end
  object mtBalance: TFDMemTable
    OnCalcFields = mtTickerCalcFields
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
      OnGetText = mtTickercoinGetText
      Size = 64
    end
    object FloatField8: TFloatField
      DisplayLabel = #49688#47049
      DisplayWidth = 15
      FieldName = 'amount'
      DisplayFormat = '#,##0.0000'
    end
    object mtBalanceavail: TFloatField
      DisplayLabel = #44032#50857
      DisplayWidth = 15
      FieldName = 'avail'
      DisplayFormat = '#,##0.0000'
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
    Left = 384
    Top = 112
  end
  object mtLimitOrders: TFDMemTable
    OnCalcFields = mtTickerCalcFields
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
      DisplayWidth = 5
      FieldName = 'coin'
      OnGetText = mtTickercoinGetText
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
      DisplayWidth = 10
      FieldName = 'price'
      DisplayFormat = '#,##0'
    end
    object FloatField10: TFloatField
      DisplayLabel = #49688#47049
      DisplayWidth = 9
      FieldName = 'amount'
      DisplayFormat = '#,##0.0000'
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
    OnCalcFields = mtTickerCalcFields
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
      DisplayWidth = 5
      FieldName = 'coin'
      OnGetText = mtTickercoinGetText
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
      DisplayWidth = 10
      FieldName = 'price'
      DisplayFormat = '#,##0'
    end
    object FloatField13: TFloatField
      DisplayLabel = #49688#47049
      DisplayWidth = 9
      FieldName = 'amount'
      DisplayFormat = '#,##0.0000'
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
    Left = 128
    Top = 192
    object SQLTimeStampField2: TSQLTimeStampField
      FieldName = 'tick_stamp'
    end
    object FloatField17: TFloatField
      FieldName = 'price_stoch'
    end
    object mtStochvolume_stoch: TFloatField
      FieldName = 'volume_stoch'
    end
  end
  object mtOrder: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 48
    Top = 280
    object mtOrderprice: TFloatField
      FieldName = 'price'
    end
    object mtOrderqty: TFloatField
      FieldName = 'qty'
    end
    object mtOrderorder_stamp: TSQLTimeStampField
      FieldName = 'order_stamp'
    end
    object mtOrderorder_type: TWideStringField
      FieldName = 'order_type'
      Size = 16
    end
  end
  object mtComplete: TFDMemTable
    OnCalcFields = mtTickerCalcFields
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
    Left = 128
    Top = 280
    object SQLTimeStampField3: TSQLTimeStampField
      Alignment = taCenter
      DisplayLabel = #49884#44036
      DisplayWidth = 18
      FieldName = 'order_stamp'
      DisplayFormat = 'YYYY-MM-DD hh:nn:ss'
    end
    object FloatField2: TFloatField
      DisplayLabel = #52404#44208#44032
      DisplayWidth = 9
      FieldName = 'price'
      DisplayFormat = '#,##0'
    end
    object FloatField3: TFloatField
      DisplayLabel = #49688#47049
      DisplayWidth = 7
      FieldName = 'amount'
      DisplayFormat = '#,##0.00'
    end
    object WideStringField7: TWideStringField
      Alignment = taCenter
      DisplayLabel = #44396#48516
      DisplayWidth = 6
      FieldName = 'order_type'
      OnGetText = mtLimitOrdersorder_typeGetText
      Size = 16
    end
  end
end
