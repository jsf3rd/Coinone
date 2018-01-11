unit CoinState;

interface

uses System.Classes, System.SysUtils, TradeContext;

type
  TState = class
  private
    FContext: TTradeContext;
  public
    procedure Tick; override;
    constructor Create(AContext: TTradeContext);
  end;

  TStateNormal = class(TState)
  public
    procedure Tick; override;

  end;

  TStateOverBought = class(TState)
  public
    procedure Tick; override;

  end;

  TStateOverSold = class(TState)
  public
    procedure Tick; override;

  end;

implementation

{ TState }

constructor TState.Create(AContext: TTradeContext);
begin
  FContext := AContext;
end;

procedure TState.Tick;
begin
  //
end;

end.
