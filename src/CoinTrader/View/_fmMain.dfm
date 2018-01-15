object fmMain: TfmMain
  Left = 0
  Top = 0
  Caption = 'Templete Form'
  ClientHeight = 773
  ClientWidth = 864
  Color = clBtnFace
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
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 864
    Height = 754
    ActivePage = tsMain
    Align = alClient
    TabOrder = 0
    OnChange = PageControlChange
    object tsMain: TTabSheet
      Caption = #49345#54889#54032
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 856
        Height = 312
        Align = alTop
        Caption = 'Panel2'
        TabOrder = 0
        object grdMain: TDBGrid
          Left = 1
          Top = 81
          Width = 854
          Height = 230
          Align = alClient
          Constraints.MinHeight = 230
          DataSource = dmDataProvider.dsTick
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
          Width = 854
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
        Width = 856
        Height = 410
        Align = alClient
        Caption = 'Panel3'
        TabOrder = 1
        object Splitter2: TSplitter
          Left = 1
          Top = 205
          Width = 854
          Height = 3
          Cursor = crVSplit
          Align = alBottom
          ExplicitTop = 1
          ExplicitWidth = 205
        end
        object chtMain: TDBChart
          Left = 1
          Top = 1
          Width = 854
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
            DataSource = dmDataProvider.mtTickPeriod
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
            DataSource = dmDataProvider.mtTickPeriod
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
            DataSource = dmDataProvider.mtTickPeriod
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
          Width = 854
          Height = 201
          Title.Font.Color = clBlack
          Title.Font.Height = -16
          Title.Font.Style = [fsBold]
          Title.Text.Strings = (
            'BTC')
          Title.Visible = False
          BottomAxis.DateTimeFormat = 'DD hh:nn'
          RightAxis.Grid.Visible = False
          View3D = False
          Align = alBottom
          TabOrder = 1
          Constraints.MinHeight = 150
          DefaultCanvas = 'TGDIPlusCanvas'
          ColorPaletteIndex = 13
          object Series4: TLineSeries
            DataSource = dmDataProvider.mtStoch
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
          object Series8: TPointSeries
            Marks.Transparency = 20
            Marks.Visible = True
            Marks.Arrow.Color = 4079359
            Marks.Arrow.Visible = False
            Marks.Callout.Arrow.Color = 4079359
            Marks.Callout.Arrow.Visible = False
            Marks.Callout.Distance = 4
            Marks.Callout.Length = 18
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
        Top = 373
        Width = 856
        Height = 3
        Cursor = crVSplit
        Align = alBottom
        ExplicitLeft = 1
        ExplicitTop = 2
        ExplicitWidth = 854
      end
      object dbgBalance: TDBGrid
        Left = 0
        Top = 137
        Width = 856
        Height = 236
        Align = alClient
        DataSource = dmDataProvider.dsBalance
        Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
        TabOrder = 0
        TitleFont.Charset = HANGEUL_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -13
        TitleFont.Name = #47569#51008' '#44256#46357
        TitleFont.Style = []
        OnDblClick = dbgBalanceDblClick
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 856
        Height = 137
        Align = alTop
        TabOrder = 1
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
      end
      object Panel5: TPanel
        Left = 0
        Top = 376
        Width = 856
        Height = 346
        Align = alBottom
        TabOrder = 2
        object Splitter: TSplitter
          Left = 397
          Top = 42
          Height = 303
          Align = alRight
          OnMoved = SplitterMoved
          ExplicitLeft = 535
          ExplicitTop = 44
          ExplicitHeight = 190
        end
        object pnlLimitOrderTitle: TPanel
          Left = 1
          Top = 1
          Width = 854
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
        object dbgLimitOrder: TDBGrid
          Left = 1
          Top = 42
          Width = 396
          Height = 303
          Align = alClient
          DataSource = dmDataProvider.dsLimitOrders
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 1
          TitleFont.Charset = HANGEUL_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -13
          TitleFont.Name = #47569#51008' '#44256#46357
          TitleFont.Style = []
        end
        object dbgRecentOrders: TDBGrid
          Left = 400
          Top = 42
          Width = 455
          Height = 303
          Align = alRight
          Constraints.MinWidth = 200
          DataSource = dmDataProvider.dsCompleteOrders
          Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
          TabOrder = 2
          TitleFont.Charset = HANGEUL_CHARSET
          TitleFont.Color = clWindowText
          TitleFont.Height = -13
          TitleFont.Name = #47569#51008' '#44256#46357
          TitleFont.Style = []
        end
      end
    end
    object tsPreference: TTabSheet
      Caption = #49444#51221
      ImageIndex = 2
      object Button8: TButton
        Left = 48
        Top = 48
        Width = 75
        Height = 25
        Caption = 'Button8'
        TabOrder = 0
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 754
    Width = 864
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
    Left = 656
    Top = 304
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
    Left = 568
    Top = 304
  end
  object ActionList: TActionList
    Left = 464
    Top = 304
    object actAbout: TAction
      Caption = '&About'
      OnExecute = actAboutExecute
    end
    object actClearLog: TAction
      Caption = '&Clear Log'
      ShortCut = 16472
      OnExecute = actClearLogExecute
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
  end
end
