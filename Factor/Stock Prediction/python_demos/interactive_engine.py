#!/usr/bin/env python3
"""
Interactive Online Portfolio Engine

Demonstrates the engine with a concrete example:
- Input: Historical prices + current portfolio
- Output: Buy/sell recommendations

Usage:
    python interactive_engine.py
"""

import numpy as np
from online_portfolio_engine import (
    OnlinePortfolioEngine, Portfolio, RiskParams
)
import json


def demo_with_sample_data():
    """Run engine with sample data showing input/output format."""
    
    # ================================================================
    # INPUT SPECIFICATION
    # ================================================================
    
    tickers = ["AAPL", "GOOGL", "MSFT", "AMZN", "NVDA"]
    n_assets = len(tickers)
    
    # Historical price data (last 30 days)
    # In practice, this would come from a market data API
    np.random.seed(42)
    historical_prices = []
    base_prices = np.array([175.0, 140.0, 380.0, 180.0, 800.0])
    
    # Simulate 30 days of realistic price movement
    prices = base_prices.copy()
    drifts = np.array([0.001, 0.0008, 0.0012, 0.0005, 0.002])
    vols = np.array([0.018, 0.02, 0.015, 0.022, 0.03])
    
    for day in range(30):
        noise = np.random.normal(0, 1, n_assets)
        prices = prices * np.exp(drifts - 0.5*vols**2 + vols*noise)
        historical_prices.append(prices.copy())
    
    # Current portfolio (what we're holding right now)
    current_holdings = {
        "AAPL": 0.25,   # 25% in Apple
        "GOOGL": 0.20,  # 20% in Google
        "MSFT": 0.20,   # 20% in Microsoft
        "AMZN": 0.15,   # 15% in Amazon
        "NVDA": 0.20,   # 20% in Nvidia
    }
    
    total_portfolio_value = 100000.0  # $100,000 portfolio
    
    # ================================================================
    # ENGINE SETUP
    # ================================================================
    
    risk_params = RiskParams(
        max_position=0.30,      # No more than 30% in any stock
        max_turnover=0.25,      # Trade at most 25% of portfolio
        min_weight=0.05,        # Minimum 5% position
        transaction_cost=0.001  # 10 bps per trade
    )
    
    engine = OnlinePortfolioEngine(
        n_assets=n_assets,
        tickers=tickers,
        risk_params=risk_params
    )
    
    # ================================================================
    # FEED HISTORICAL DATA TO ENGINE
    # ================================================================
    
    print("=" * 65)
    print("  ONLINE PORTFOLIO OPTIMIZATION ENGINE")
    print("  Input: 30 days of price history + current portfolio")
    print("=" * 65)
    
    print("\n📊 HISTORICAL PRICES (last 5 days):")
    print(f"  {'Day':>4s}  ", end="")
    for t in tickers:
        print(f"{t:>10s}", end="")
    print()
    
    for i, hp in enumerate(historical_prices):
        engine.process_prices(hp)
        if i >= 25:  # Show last 5 days
            print(f"  {i+1:4d}  ", end="")
            for p in hp:
                print(f"  ${p:7.2f}", end="")
            print()
    
    # ================================================================
    # SET CURRENT PORTFOLIO
    # ================================================================
    
    current_weights = np.array([current_holdings[t] for t in tickers])
    engine.current_portfolio = Portfolio(current_weights)
    
    print(f"\n💼 CURRENT PORTFOLIO (${total_portfolio_value:,.0f} total):")
    for ticker, weight in zip(tickers, current_weights):
        value = weight * total_portfolio_value
        print(f"  {ticker:6s}: {weight*100:5.1f}%  (${value:,.0f})")
    
    # ================================================================
    # GET RECOMMENDATION
    # ================================================================
    
    # Process today's prices (latest)
    today_prices = historical_prices[-1] * np.exp(
        np.random.normal(drifts - 0.5*vols**2, vols)
    )
    output = engine.process_prices(today_prices)
    
    print(f"\n{'='*65}")
    print("  📋 ENGINE RECOMMENDATION")
    print(f"{'='*65}")
    
    print(f"\n🎯 TARGET PORTFOLIO:")
    for ticker, weight in zip(tickers, output.target_portfolio.weights):
        value = weight * total_portfolio_value
        change = weight - current_holdings[ticker]
        arrow = "↑" if change > 0.005 else ("↓" if change < -0.005 else "→")
        print(f"  {ticker:6s}: {weight*100:5.1f}%  (${value:,.0f})  {arrow} {change*100:+.1f}%")
    
    print(f"\n🔄 TRADE ACTIONS:")
    if output.trades:
        for trade in output.trades:
            dollar_amount = trade.magnitude * total_portfolio_value
            print(f"  {trade.direction:4s} {trade.ticker:6s}: "
                  f"{trade.magnitude*100:5.2f}% = ${dollar_amount:,.0f}")
    else:
        print("  No trades recommended (within tolerance)")
    
    # Estimated transaction costs
    total_traded = sum(t.magnitude for t in output.trades)
    est_cost = total_traded * total_portfolio_value * risk_params.transaction_cost
    print(f"\n  Estimated transaction costs: ${est_cost:,.2f}")
    print(f"  Total turnover: {total_traded*100:.1f}%")
    
    # Metadata
    meta = output.metadata
    print(f"\n📈 ENGINE METRICS:")
    print(f"  Cumulative wealth factor: {meta.get('wealth', 'N/A')}")
    print(f"  Learning rate (η):        {meta.get('eta', 'N/A'):.6f}" if isinstance(meta.get('eta'), float) else "")
    print(f"  Total turnover:           {meta.get('turnover', 'N/A'):.4f}" if isinstance(meta.get('turnover'), float) else "")
    
    # ================================================================
    # OUTPUT AS JSON
    # ================================================================
    
    output_json = {
        "timestamp": "2025-01-15T16:00:00Z",
        "portfolio_value": total_portfolio_value,
        "current_portfolio": {t: float(w) for t, w in zip(tickers, current_weights)},
        "target_portfolio": {t: float(w) for t, w in zip(tickers, output.target_portfolio.weights)},
        "trades": [
            {
                "ticker": t.ticker,
                "action": t.direction,
                "fraction": float(t.magnitude),
                "dollar_amount": float(t.magnitude * total_portfolio_value)
            }
            for t in output.trades
        ],
        "risk_params": {
            "max_position": risk_params.max_position,
            "max_turnover": risk_params.max_turnover,
            "min_weight": risk_params.min_weight,
            "transaction_cost": risk_params.transaction_cost,
        },
        "engine_metrics": {
            k: float(v) if isinstance(v, (int, float)) else v
            for k, v in meta.items()
        }
    }
    
    json_path = "engine_output.json"
    with open(json_path, 'w') as f:
        json.dump(output_json, f, indent=2, default=str)
    
    print(f"\n💾 Full output saved to {json_path}")
    print("\n✅ Engine run complete!")
    
    return output_json


if __name__ == "__main__":
    result = demo_with_sample_data()
