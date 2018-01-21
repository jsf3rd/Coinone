object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'Templete Form'
  ClientHeight = 773
  ClientWidth = 884
  Color = clBtnFace
  Constraints.MinHeight = 700
  Constraints.MinWidth = 800
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #47569#51008' '#44256#46357
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 884
    Height = 754
    ActivePage = tsTrad
    Align = alClient
    TabOrder = 0
    OnChange = PageControlChange
    object tsMain: TTabSheet
      Caption = #49345#54889#54032
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 876
        Height = 312
        Align = alTop
        Caption = 'Panel2'
        TabOrder = 0
        object grdMain: TDBGrid
          Left = 1
          Top = 81
          Width = 874
          Height = 230
          Align = alClient
          Constraints.MinHeight = 230
          DataSource = dmDataProvider.dsTicker
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 0
          TitleFont.Charset = HANGEUL_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -13
          TitleFont.Name = #47569#51008' '#44256#46357
          TitleFont.Style = []
          OnDblClick = grdMainDblClick
        end
        object Panel1: TPanel
          Left = 1
          Top = 1
          Width = 874
          Height = 80
          Align = alTop
          TabOrder = 1
          object Button1: TButton
            Left = 15
            Top = 10
            Width = 75
            Height = 25
            Action = actTick
            TabOrder = 0
          end
          object GroupBox3: TGroupBox
            Left = 104
            Top = 7
            Width = 257
            Height = 67
            Caption = #52264#53944#49444#51221
            TabOrder = 1
            object edtChartDay: TLabeledEdit
              Left = 73
              Top = 30
              Width = 48
              Height = 25
              EditLabel.Width = 57
              EditLabel.Height = 17
              EditLabel.Caption = #52264#53944' '#44592#44036
              LabelPosition = lpLeft
              NumbersOnly = True
              TabOrder = 0
              Text = '2'
            end
            object edtStochHour: TLabeledEdit
              Left = 195
              Top = 30
              Width = 48
              Height = 25
              EditLabel.Width = 59
              EditLabel.Height = 17
              EditLabel.Caption = 'Stoch'#49884#44036
              LabelPosition = lpLeft
              NumbersOnly = True
              TabOrder = 1
              Text = '7'
            end
          end
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 312
        Width = 876
        Height = 410
        Align = alClient
        Caption = 'Panel3'
        TabOrder = 1
        OnResize = Panel3Resize
        object Splitter2: TSplitter
          Left = 1
          Top = 205
          Width = 874
          Height = 3
          Cursor = crVSplit
          Align = alBottom
          ExplicitTop = 1
          ExplicitWidth = 205
        end
        object chtMain: TDBChart
          Left = 1
          Top = 1
          Width = 874
          Height = 204
          Title.Font.Color = clBlack
          Title.Font.Height = -16
          Title.Font.Style = [fsBold]
          Title.Text.Strings = (
            'BTC')
          BottomAxis.DateTimeFormat = 'DD hh:nn'
          RightAxis.Grid.Visible = False
          View3D = False
          Align = alClient
          TabOrder = 0
          Constraints.MinHeight = 150
          DefaultCanvas = 'TGDIPlusCanvas'
          ColorPaletteIndex = 13
          object Series1: TLineSeries
            Marks.DrawEvery = 2
            DataSource = dmDataProvider.mtTickerPeriod
            Title = 'Price'
            Brush.BackColor = clDefault
            Pointer.InflateMargins = True
            Pointer.Style = psRectangle
            XValues.DateTime = True
            XValues.Name = 'X'
            XValues.Order = loAscending
            XValues.ValueSource = 'tick_stamp'
            YValues.Name = 'Y'
            YValues.Order = loNone
            YValues.ValueSource = 'price'
          end
          object Series2: TLineSeries
            Marks.DrawEvery = 7
            DataSource = dmDataProvider.mtTickerPeriod
            Title = 'Volume'
            VertAxis = aRightAxis
            Brush.BackColor = clDefault
            Pointer.InflateMargins = True
            Pointer.Style = psRectangle
            XValues.DateTime = True
            XValues.Name = 'X'
            XValues.Order = loAscending
            XValues.ValueSource = 'tick_stamp'
            YValues.Name = 'Y'
            YValues.Order = loNone
            YValues.ValueSource = 'volume'
          end
          object Series5: TLineSeries
            Active = False
            Marks.DrawEvery = 3
            DataSource = dmDataProvider.mtTickerPeriod
            Title = 'Stoch'
            VertAxis = aRightAxis
            Brush.BackColor = clDefault
            Pointer.InflateMargins = True
            Pointer.Style = psRectangle
            XValues.DateTime = True
            XValues.Name = 'X'
            XValues.Order = loAscending
            XValues.ValueSource = 'tick_stamp'
            YValues.Name = 'Y'
            YValues.Order = loNone
            YValues.ValueSource = 'price_stoch'
          end
          object Series7: TPointSeries
            DataSource = dmDataProvider.mtComplete
            Title = 'Complete'
            ClickableLine = False
            Pointer.Brush.Color = clRed
            Pointer.InflateMargins = True
            Pointer.Style = psCircle
            XValues.DateTime = True
            XValues.Name = 'X'
            XValues.Order = loAscending
            XValues.ValueSource = 'order_stamp'
            YValues.Name = 'Y'
            YValues.Order = loNone
            YValues.ValueSource = 'price'
          end
          object Series3: TPointSeries
            DataSource = dmDataProvider.mtOrder
            Title = 'Order'
            ClickableLine = False
            Pointer.Brush.Style = bsClear
            Pointer.HorizSize = 8
            Pointer.InflateMargins = True
            Pointer.Pen.Color = 8421440
            Pointer.Pen.Width = 2
            Pointer.Style = psCircle
            Pointer.VertSize = 8
            XValues.DateTime = True
            XValues.Name = 'X'
            XValues.Order = loAscending
            XValues.ValueSource = 'order_stamp'
            YValues.Name = 'Y'
            YValues.Order = loNone
            YValues.ValueSource = 'price'
          end
        end
        object chtStoch: TDBChart
          Left = 1
          Top = 208
          Width = 874
          Height = 201
          Title.Font.Color = clBlack
          Title.Font.Height = -16
          Title.Font.Style = [fsBold]
          Title.Text.Strings = (
            'BTC')
          Title.Visible = False
          BottomAxis.DateTimeFormat = 'DD hh:nn'
          BottomAxis.LabelStyle = talValue
          Legend.Symbol.Shadow.HorizSize = 3
          Legend.Symbol.Shadow.VertSize = 3
          RightAxis.Grid.Visible = False
          TopAxis.Visible = False
          View3D = False
          Align = alBottom
          TabOrder = 1
          Constraints.MinHeight = 150
          DefaultCanvas = 'TGDIPlusCanvas'
          ColorPaletteIndex = 13
          object Series4: TLineSeries
            DataSource = dmDataProvider.mtStoch
            Title = 'PriceStoch'
            VertAxis = aRightAxis
            Brush.BackColor = clDefault
            Pointer.InflateMargins = True
            Pointer.Style = psRectangle
            XValues.DateTime = True
            XValues.Name = 'X'
            XValues.Order = loAscending
            XValues.ValueSource = 'tick_stamp'
            YValues.Name = 'Y'
            YValues.Order = loNone
            YValues.ValueSource = 'price_stoch'
          end
          object Series10: TLineSeries
            DataSource = dmDataProvider.mtStoch
            Title = 'VolumeStoch'
            VertAxis = aRightAxis
            Brush.BackColor = clDefault
            Pointer.InflateMargins = True
            Pointer.Style = psRectangle
            XValues.DateTime = True
            XValues.Name = 'X'
            XValues.Order = loAscending
            XValues.ValueSource = 'tick_stamp'
            YValues.Name = 'Y'
            YValues.Order = loNone
            YValues.ValueSource = 'volume_stoch'
          end
          object Series8: TPointSeries
            Marks.Transparency = 20
            Marks.Visible = True
            Marks.Style = smsLabelValue
            Marks.Arrow.Color = 4079359
            Marks.Arrow.Visible = False
            Marks.Callout.Arrow.Color = 4079359
            Marks.Callout.Arrow.Visible = False
            Marks.Callout.Distance = 4
            Marks.Callout.Length = 18
            DataSource = dmDataProvider.mtComplete
            Title = 'Complete'
            XLabelsSource = 'order_type'
            ClickableLine = False
            Pointer.Brush.Color = clRed
            Pointer.InflateMargins = True
            Pointer.Style = psCircle
            XValues.DateTime = True
            XValues.Name = 'X'
            XValues.Order = loAscending
            XValues.ValueSource = 'order_stamp'
            YValues.Name = 'Y'
            YValues.Order = loNone
            YValues.ValueSource = 'price'
          end
          object Series6: TPointSeries
            Marks.Transparency = 26
            Marks.Callout.ArrowHead = ahLine
            Marks.Callout.Distance = 4
            Marks.Callout.Length = 4
            Marks.Symbol.Brush.Style = bsClear
            DataSource = dmDataProvider.mtOrder
            Title = 'Order'
            ClickableLine = False
            Pointer.Brush.Style = bsClear
            Pointer.HorizSize = 8
            Pointer.InflateMargins = True
            Pointer.Pen.Color = 8421440
            Pointer.Pen.Width = 2
            Pointer.Style = psCircle
            Pointer.VertSize = 8
            XValues.DateTime = True
            XValues.Name = 'X'
            XValues.Order = loAscending
            XValues.ValueSource = 'order_stamp'
            YValues.Name = 'Y'
            YValues.Order = loNone
            YValues.ValueSource = 'price'
          end
        end
      end
    end
    object tsTrad: TTabSheet
      Caption = #44144#47000
      ImageIndex = 1
      object Splitter1: TSplitter
        Left = 0
        Top = 380
        Width = 876
        Height = 3
        Cursor = crVSplit
        Align = alTop
        ExplicitLeft = 1
        ExplicitTop = 2
        ExplicitWidth = 854
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 876
        Height = 380
        Align = alTop
        TabOrder = 0
        object Button4: TButton
          Left = 15
          Top = 10
          Width = 75
          Height = 25
          Action = actBalance
          TabOrder = 0
        end
        object GroupBox1: TGroupBox
          Left = 104
          Top = 8
          Width = 241
          Height = 123
          Caption = #49884#51109#44032' '#44144#47000
          TabOrder = 1
          object Button2: TButton
            Left = 159
            Top = 22
            Width = 75
            Height = 25
            Action = actMarketBID
            TabOrder = 1
          end
          object Button3: TButton
            Left = 159
            Top = 53
            Width = 75
            Height = 25
            Action = actMarketASK
            TabOrder = 2
          end
          object edtKrwValue: TLabeledEdit
            Left = 64
            Top = 22
            Width = 73
            Height = 25
            EditLabel.Width = 52
            EditLabel.Height = 17
            EditLabel.Caption = #51452#47928#44552#50529
            LabelPosition = lpLeft
            NumbersOnly = True
            TabOrder = 0
            Text = '0'
          end
        end
        object GroupBox2: TGroupBox
          Left = 351
          Top = 8
          Width = 258
          Height = 123
          Caption = #51648#51221#44032' '#44144#47000
          TabOrder = 2
          object Button6: TButton
            Left = 169
            Top = 51
            Width = 75
            Height = 25
            Action = actLimitBID
            TabOrder = 2
          end
          object Button7: TButton
            Left = 169
            Top = 82
            Width = 75
            Height = 25
            Action = actLimitASK
            TabOrder = 3
          end
          object edtLimitCount: TLabeledEdit
            Left = 72
            Top = 53
            Width = 73
            Height = 25
            EditLabel.Width = 52
            EditLabel.Height = 17
            EditLabel.Caption = #51452#47928#49688#47049
            LabelPosition = lpLeft
            NumbersOnly = True
            TabOrder = 0
            Text = '0'
            OnChange = edtLimitCountChange
          end
          object edtLimitPrice: TLabeledEdit
            Left = 72
            Top = 84
            Width = 73
            Height = 25
            EditLabel.Width = 52
            EditLabel.Height = 17
            EditLabel.Caption = #51452#47928#44032#44201
            LabelPosition = lpLeft
            NumbersOnly = True
            TabOrder = 1
            Text = '10000'
            OnChange = edtLimitCountChange
          end
          object edtKrwView: TLabeledEdit
            Left = 72
            Top = 22
            Width = 73
            Height = 25
            Color = clSilver
            EditLabel.Width = 52
            EditLabel.Height = 17
            EditLabel.Caption = #51452#47928#44552#50529
            LabelPosition = lpLeft
            NumbersOnly = True
            ReadOnly = True
            TabOrder = 4
            Text = '0'
          end
        end
        object dbgBalance: TDBGrid
          Left = 1
          Top = 137
          Width = 874
          Height = 242
          Align = alBottom
          DataSource = dmDataProvider.dsBalance
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 3
          TitleFont.Charset = HANGEUL_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -13
          TitleFont.Name = #47569#51008' '#44256#46357
          TitleFont.Style = []
          OnDblClick = dbgBalanceDblClick
        end
      end
      object Panel5: TPanel
        Left = 0
        Top = 383
        Width = 876
        Height = 339
        Align = alClient
        TabOrder = 1
        OnResize = Panel5Resize
        object Splitter: TSplitter
          Left = 397
          Top = 42
          Height = 296
          Align = alRight
          ExplicitLeft = 535
          ExplicitTop = 44
          ExplicitHeight = 190
        end
        object pnlLimitOrderTitle: TPanel
          Left = 1
          Top = 1
          Width = 874
          Height = 41
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = #48120#52404#44208' '#45236#50669
          TabOrder = 0
          object lblRecentOrder: TLabel
            Left = 396
            Top = 15
            Width = 88
            Height = 17
            Caption = #52572#44540' '#44144#47000' '#45236#50669
          end
          object Button5: TButton
            Left = 84
            Top = 7
            Width = 75
            Height = 25
            Action = actCancelOrder
            TabOrder = 0
          end
        end
        object dbgLimitOrder: TJvDBGrid
          Left = 1
          Top = 42
          Width = 396
          Height = 296
          Align = alClient
          DataSource = dmDataProvider.dsLimitOrders
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 1
          TitleFont.Charset = HANGEUL_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -13
          TitleFont.Name = #47569#51008' '#44256#46357
          TitleFont.Style = []
          SelectColumnsDialogStrings.Caption = 'Select columns'
          SelectColumnsDialogStrings.OK = '&OK'
          SelectColumnsDialogStrings.NoSelectionWarning = 'At least one column must be visible!'
          EditControls = <>
          RowsHeight = 21
          TitleRowHeight = 21
        end
        object dbgRecentOrders: TJvDBGrid
          Left = 400
          Top = 42
          Width = 475
          Height = 296
          Align = alRight
          DataSource = dmDataProvider.dsCompleteOrders
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 2
          TitleFont.Charset = HANGEUL_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -13
          TitleFont.Name = #47569#51008' '#44256#46357
          TitleFont.Style = []
          SelectColumnsDialogStrings.Caption = 'Select columns'
          SelectColumnsDialogStrings.OK = '&OK'
          SelectColumnsDialogStrings.NoSelectionWarning = 'At least one column must be visible!'
          EditControls = <>
          RowsHeight = 21
          TitleRowHeight = 21
        end
      end
    end
    object tsPreference: TTabSheet
      Caption = #49444#51221
      ImageIndex = 2
      OnShow = tsPreferenceShow
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 876
        Height = 722
        Align = alClient
        TabOrder = 0
        object GroupBox4: TGroupBox
          Left = 8
          Top = 8
          Width = 585
          Height = 97
          Caption = 'Config'
          TabOrder = 0
          DesignSize = (
            585
            97)
          object edtHost: TLabeledEdit
            Left = 48
            Top = 33
            Width = 110
            Height = 25
            EditLabel.Width = 27
            EditLabel.Height = 17
            EditLabel.Caption = 'Host'
            LabelPosition = lpLeft
            TabOrder = 0
          end
          object edtPort: TLabeledEdit
            Left = 48
            Top = 64
            Width = 110
            Height = 25
            EditLabel.Width = 24
            EditLabel.Height = 17
            EditLabel.Caption = 'Port'
            LabelPosition = lpLeft
            NumbersOnly = True
            TabOrder = 1
          end
          object edtUserID: TLabeledEdit
            Left = 458
            Top = 33
            Width = 110
            Height = 25
            EditLabel.Width = 40
            EditLabel.Height = 17
            EditLabel.Caption = 'UserID'
            LabelPosition = lpLeft
            TabOrder = 2
          end
          object Button12: TButton
            Left = 483
            Top = 64
            Width = 85
            Height = 25
            Action = actSaveConfig
            Anchors = [akRight, akBottom]
            TabOrder = 3
          end
          object edtAccessToken: TLabeledEdit
            Left = 255
            Top = 33
            Width = 130
            Height = 25
            EditLabel.Width = 77
            EditLabel.Height = 17
            EditLabel.Caption = 'AccessToken'
            LabelPosition = lpLeft
            PasswordChar = '*'
            TabOrder = 4
          end
          object edtSecretKey: TLabeledEdit
            Left = 255
            Top = 64
            Width = 130
            Height = 25
            EditLabel.Width = 57
            EditLabel.Height = 17
            EditLabel.Caption = 'SecretKey'
            LabelPosition = lpLeft
            PasswordChar = '*'
            TabOrder = 5
          end
        end
        object GroupBox5: TGroupBox
          Left = 8
          Top = 111
          Width = 585
          Height = 98
          Align = alCustom
          Caption = 'Windows '#49436#48708#49828' '#44288#47532
          TabOrder = 1
          object Button8: TButton
            Left = 392
            Top = 25
            Width = 85
            Height = 25
            Action = actStartDataSvc
            TabOrder = 1
          end
          object Button9: TButton
            Left = 483
            Top = 25
            Width = 85
            Height = 25
            Action = actStopDataSvc
            TabOrder = 2
          end
          object edtDataStatus: TLabeledEdit
            Left = 118
            Top = 27
            Width = 248
            Height = 21
            EditLabel.Width = 100
            EditLabel.Height = 17
            EditLabel.Caption = 'CoinData Service'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            LabelPosition = lpLeft
            ParentFont = False
            TabOrder = 0
            Text = #49345#53468#54869#51064' '#51473'...'
          end
          object Button10: TButton
            Left = 392
            Top = 57
            Width = 85
            Height = 25
            Action = actStartCoreSvc
            TabOrder = 3
          end
          object Button11: TButton
            Left = 483
            Top = 56
            Width = 85
            Height = 25
            Action = actStopCoreSvc
            TabOrder = 4
          end
          object edtCoreStatus: TLabeledEdit
            Left = 118
            Top = 59
            Width = 248
            Height = 21
            EditLabel.Width = 101
            EditLabel.Height = 17
            EditLabel.Caption = 'CoinCore Service'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            LabelPosition = lpLeft
            ParentFont = False
            TabOrder = 5
            Text = #49345#53468#54869#51064' '#51473'...'
          end
        end
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 754
    Width = 884
    Height = 19
    Panels = <
      item
        Width = 180
      end
      item
        Width = 150
      end
      item
        Width = 80
      end>
  end
  object MainMenu: TMainMenu
    Left = 776
    Top = 232
    object File1: TMenuItem
      Caption = '&File'
      object Exit1: TMenuItem
        Action = actExit
      end
    end
    object ool1: TMenuItem
      Caption = '&Tool'
      object ShowLog1: TMenuItem
        Action = actShowLog
      end
      object ShowIniFile1: TMenuItem
        Action = actShowIni
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object About1: TMenuItem
        Caption = '&About'
        OnClick = actAboutExecute
      end
    end
    object MenuTest: TMenuItem
      Caption = 'T&est'
      Visible = False
    end
  end
  object ApplicationEvents: TApplicationEvents
    OnException = ApplicationEventsException
    Left = 688
    Top = 232
  end
  object ActionList: TActionList
    Left = 688
    Top = 176
    object actAbout: TAction
      Caption = '&About'
      OnExecute = actAboutExecute
    end
    object actExit: TAction
      Caption = '&Exit'
      ShortCut = 16465
      OnExecute = actExitExecute
    end
    object actShowIni: TAction
      Caption = 'Show &IniFile'
      OnExecute = actShowIniExecute
    end
    object actShowLog: TAction
      Caption = 'Show &Log'
      OnExecute = actShowLogExecute
    end
    object actTestMenu: TAction
      Caption = '&Test&Menu'
      ShortCut = 16456
      OnExecute = actTestMenuExecute
    end
    object actTick: TAction
      Caption = #44081#49888
      OnExecute = actTickExecute
    end
    object actMarketASK: TAction
      Caption = #47588#46020
      OnExecute = actMarketASKExecute
    end
    object actMarketBID: TAction
      Caption = #47588#49688
      OnExecute = actMarketBIDExecute
    end
    object actBalance: TAction
      Caption = #44081#49888
      OnExecute = actBalanceExecute
    end
    object actLimitASK: TAction
      Caption = #47588#46020
      OnExecute = actLimitASKExecute
    end
    object actLimitBID: TAction
      Caption = #47588#49688
      OnExecute = actLimitBIDExecute
    end
    object actCancelOrder: TAction
      Caption = #51452#47928#52712#49548
      OnExecute = actCancelOrderExecute
    end
    object actStartDataSvc: TAction
      Caption = #49436#48708#49828' '#49884#51089
      Enabled = False
      OnExecute = actStartDataSvcExecute
    end
    object actStopDataSvc: TAction
      Caption = #49436#48708#49828' '#51473#51648
      Enabled = False
      OnExecute = actStopDataSvcExecute
    end
    object actStartCoreSvc: TAction
      Caption = #49436#48708#49828' '#49884#51089
      Enabled = False
      OnExecute = actStartCoreSvcExecute
    end
    object actStopCoreSvc: TAction
      Caption = #49436#48708#49828' '#51473#51648
      Enabled = False
      OnExecute = actStopCoreSvcExecute
    end
    object actSaveConfig: TAction
      Caption = #51200#51109
      OnExecute = actSaveConfigExecute
    end
  end
  object ServiceStatusTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = ServiceStatusTimerTimer
    Left = 776
    Top = 176
  end
end
