#!/usr/bin/env python3
"""
Online Portfolio Optimization Engine — Python Demo

Implements the Exponential Gradient (EG) algorithm with Kelly criterion
position sizing for online stock portfolio selection.

This demo:
1. Generates synthetic stock data (geometric Brownian motion)
2. Runs the EG portfolio engine
3. Compares against benchmarks (equal weight, best stock, buy-and-hold)
4. Visualizes the results

Mathematical Foundation:
- Cover's Universal Portfolio (1991)
- Helmbold et al. Exponential Gradient (1998)
- Kelly Criterion for position sizing (1956)

Usage:
    python online_portfolio_engine.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend
import matplotlib.pyplot as plt
from dataclasses import dataclass, field
from typing import List, Tuple, Optional
import json
from pathlib import Path


# ============================================================================
# Core Data Structures
# ============================================================================

@dataclass
class Portfolio:
    """A portfolio: weights over n assets summing to 1."""
    weights: np.ndarray  # shape (n,), nonneg, sum = 1
    
    def __post_init__(self):
        assert np.all(self.weights >= -1e-10), f"Negative weights: {self.weights}"
        self.weights = np.maximum(self.weights, 0)
        s = self.weights.sum()
        if s > 0:
            self.weights /= s
    
    @property
    def n(self) -> int:
        return len(self.weights)
    
    @staticmethod
    def uniform(n: int) -> 'Portfolio':
        return Portfolio(np.ones(n) / n)


@dataclass
class PriceRelatives:
    """Price relatives: ratio of close to open price for each asset."""
    values: np.ndarray  # shape (n,), all positive
    
    def __post_init__(self):
        assert np.all(self.values > 0), "Price relatives must be positive"


@dataclass
class TradeAction:
    """A single trade recommendation."""
    asset: int
    direction: str  # 'BUY' or 'SELL'
    magnitude: float  # fraction of portfolio
    ticker: str = ""
    
    def __repr__(self):
        symbol = self.ticker or f"Asset_{self.asset}"
        return f"{self.direction} {symbol}: {self.magnitude:.4f} ({self.magnitude*100:.2f}%)"


@dataclass
class EngineOutput:
    """Output from the portfolio engine."""
    target_portfolio: Portfolio
    trades: List[TradeAction]
    metadata: dict = field(default_factory=dict)


@dataclass
class RiskParams:
    """Risk management parameters."""
    max_position: float = 0.25      # Max weight per asset
    max_turnover: float = 0.50      # Max total turnover per rebalance
    min_weight: float = 0.01        # Minimum nonzero weight
    transaction_cost: float = 0.001  # Cost per unit traded


# ============================================================================
# Portfolio Optimization Algorithms
# ============================================================================

class ExponentialGradient:
    """
    Exponential Gradient (EG) Online Portfolio Selection Algorithm.
    
    Update rule:
        b_{t+1}(i) = b_t(i) * exp(η * x_t(i) / <b_t, x_t>) / Z_t
    
    where Z_t is a normalization constant and η is the learning rate.
    
    Regret bound: O(√(T · log n))
    """
    
    def __init__(self, n_assets: int, eta: Optional[float] = None, 
                 risk_params: Optional[RiskParams] = None):
        self.n = n_assets
        self.eta = eta  # Will be set adaptively if None
        self.risk_params = risk_params or RiskParams()
        self.portfolio = Portfolio.uniform(n_assets)
        self.t = 0
        self.wealth = 1.0
        self.wealth_history = [1.0]
        self.portfolio_history = [self.portfolio.weights.copy()]
        
    def _compute_eta(self) -> float:
        """Optimal learning rate: η = √(8 ln(n) / T)"""
        if self.eta is not None:
            return self.eta
        T_est = max(self.t + 1, 100)  # Estimate horizon
        return np.sqrt(8 * np.log(self.n) / T_est)
    
    def update(self, price_relatives: PriceRelatives) -> Portfolio:
        """Process new price relatives and return updated portfolio."""
        x = price_relatives.values
        b = self.portfolio.weights
        
        # Portfolio return
        ret = np.dot(b, x)
        
        # Update wealth
        self.wealth *= ret
        self.wealth_history.append(self.wealth)
        
        # EG update
        eta = self._compute_eta()
        log_update = eta * x / ret
        new_weights = b * np.exp(log_update)
        
        # Project to constrained simplex
        new_weights = self._project_constrained(new_weights)
        
        self.portfolio = Portfolio(new_weights)
        self.portfolio_history.append(self.portfolio.weights.copy())
        self.t += 1
        
        return self.portfolio
    
    def _project_constrained(self, weights: np.ndarray) -> np.ndarray:
        """Project onto simplex with position limits."""
        rp = self.risk_params
        
        # Clamp to [0, max_position]
        weights = np.clip(weights, 0, rp.max_position)
        
        # Remove tiny weights
        weights[weights < rp.min_weight] = 0
        
        # Normalize
        s = weights.sum()
        if s > 0:
            weights /= s
        else:
            weights = np.ones(self.n) / self.n
        
        return weights
    
    def get_regret(self, price_history: List[PriceRelatives]) -> float:
        """Compute logarithmic regret vs best CRP."""
        if not price_history:
            return 0.0
        
        # Find best CRP by grid search over simplex
        best_log_wealth = -np.inf
        
        # For 2 assets, search over line; for more, use random sampling
        if self.n == 2:
            for w in np.linspace(0, 1, 1000):
                b = np.array([w, 1 - w])
                log_w = sum(np.log(np.dot(b, pr.values)) for pr in price_history)
                best_log_wealth = max(best_log_wealth, log_w)
        else:
            # Random sampling over simplex
            for _ in range(10000):
                b = np.random.dirichlet(np.ones(self.n))
                log_w = sum(np.log(np.dot(b, pr.values)) for pr in price_history)
                best_log_wealth = max(best_log_wealth, log_w)
        
        return best_log_wealth - np.log(self.wealth)


class KellyCriterion:
    """
    Kelly Criterion for optimal position sizing.
    
    For a bet with probability p of winning and odds b:1,
    optimal fraction f* = (p*b - (1-p)) / b
    
    Generalized to multi-asset: maximize E[log(return)]
    """
    
    @staticmethod
    def binary_kelly(p: float, b: float) -> float:
        """Kelly fraction for binary outcome."""
        if b <= 0 or p < 0 or p > 1:
            return 0
        f = (p * b - (1 - p)) / b
        return max(0, min(1, f))
    
    @staticmethod
    def growth_rate(p: float, b: float, f: float) -> float:
        """Expected log growth rate for fraction f."""
        if f <= 0 or f >= 1:
            return 0
        return p * np.log(1 + f * b) + (1 - p) * np.log(1 - f)
    
    @staticmethod
    def multi_asset_kelly(expected_returns: np.ndarray, 
                          covariance: np.ndarray) -> np.ndarray:
        """
        Approximate multi-asset Kelly: f* ≈ Σ⁻¹ μ
        where μ = expected excess returns, Σ = covariance matrix.
        """
        try:
            precision = np.linalg.inv(covariance)
            f = precision @ expected_returns
            # Clamp to valid portfolio
            f = np.maximum(f, 0)
            s = f.sum()
            if s > 0:
                f /= s
            return f
        except np.linalg.LinAlgError:
            n = len(expected_returns)
            return np.ones(n) / n


class MomentumEstimator:
    """Estimate momentum using exponential moving averages."""
    
    def __init__(self, n_assets: int, fast_alpha: float = 0.1, 
                 slow_alpha: float = 0.02):
        self.n = n_assets
        self.fast_alpha = fast_alpha
        self.slow_alpha = slow_alpha
        self.fast_ema = np.ones(n_assets)
        self.slow_ema = np.ones(n_assets)
        self.initialized = False
    
    def update(self, prices: np.ndarray):
        """Update EMAs with new prices."""
        if not self.initialized:
            self.fast_ema = prices.copy()
            self.slow_ema = prices.copy()
            self.initialized = True
        else:
            self.fast_ema = self.fast_alpha * prices + (1 - self.fast_alpha) * self.fast_ema
            self.slow_ema = self.slow_alpha * prices + (1 - self.slow_alpha) * self.slow_ema
    
    def get_momentum_signal(self) -> np.ndarray:
        """Momentum signal: fast EMA / slow EMA - 1."""
        return self.fast_ema / self.slow_ema - 1


# ============================================================================
# Main Engine
# ============================================================================

class OnlinePortfolioEngine:
    """
    Complete Online Portfolio Optimization Engine.
    
    Combines:
    - Exponential Gradient for online learning
    - Kelly Criterion for position sizing
    - Momentum signals for trend following
    - Risk management constraints
    
    Input: Historical prices + current portfolio
    Output: Trade recommendations
    """
    
    def __init__(self, n_assets: int, tickers: Optional[List[str]] = None,
                 risk_params: Optional[RiskParams] = None):
        self.n = n_assets
        self.tickers = tickers or [f"Stock_{i}" for i in range(n_assets)]
        self.risk_params = risk_params or RiskParams()
        
        # Sub-components
        self.eg = ExponentialGradient(n_assets, risk_params=self.risk_params)
        self.momentum = MomentumEstimator(n_assets)
        self.kelly = KellyCriterion()
        
        # State
        self.price_history: List[np.ndarray] = []
        self.current_portfolio = Portfolio.uniform(n_assets)
        
    def process_prices(self, prices: np.ndarray) -> EngineOutput:
        """
        Process new price data and generate trade recommendations.
        
        Args:
            prices: Current prices, shape (n,)
            
        Returns:
            EngineOutput with target portfolio and trade list
        """
        self.price_history.append(prices.copy())
        self.momentum.update(prices)
        
        if len(self.price_history) < 2:
            return EngineOutput(
                target_portfolio=self.current_portfolio,
                trades=[],
                metadata={"status": "warming_up"}
            )
        
        # Compute price relatives
        prev = self.price_history[-2]
        curr = self.price_history[-1]
        pr = PriceRelatives(curr / prev)
        
        # EG update
        eg_portfolio = self.eg.update(pr)
        
        # Momentum adjustment
        momentum = self.momentum.get_momentum_signal()
        momentum_weights = np.exp(momentum)
        momentum_weights /= momentum_weights.sum()
        
        # Kelly sizing (using recent returns)
        if len(self.price_history) >= 20:
            recent_rets = []
            for i in range(-20, -1):
                r = self.price_history[i+1] / self.price_history[i] - 1
                recent_rets.append(r)
            recent_rets = np.array(recent_rets)
            mu = recent_rets.mean(axis=0)
            cov = np.cov(recent_rets.T) + 1e-6 * np.eye(self.n)
            kelly_weights = self.kelly.multi_asset_kelly(mu, cov)
        else:
            kelly_weights = np.ones(self.n) / self.n
        
        # Blend: 50% EG + 25% momentum + 25% Kelly
        blended = (0.50 * eg_portfolio.weights + 
                   0.25 * momentum_weights + 
                   0.25 * kelly_weights)
        
        # Apply constraints
        blended = np.clip(blended, 0, self.risk_params.max_position)
        blended[blended < self.risk_params.min_weight] = 0
        if blended.sum() > 0:
            blended /= blended.sum()
        else:
            blended = np.ones(self.n) / self.n
        
        target = Portfolio(blended)
        
        # Compute trades
        trades = self._compute_trades(self.current_portfolio, target)
        
        # Apply turnover constraint
        total_turnover = sum(t.magnitude for t in trades)
        if total_turnover > self.risk_params.max_turnover:
            scale = self.risk_params.max_turnover / total_turnover
            for t in trades:
                t.magnitude *= scale
            # Adjust target portfolio to reflect limited trades
            adjusted = self.current_portfolio.weights.copy()
            for t in trades:
                if t.direction == 'BUY':
                    adjusted[t.asset] += t.magnitude
                else:
                    adjusted[t.asset] -= t.magnitude
            adjusted = np.maximum(adjusted, 0)
            if adjusted.sum() > 0:
                adjusted /= adjusted.sum()
            target = Portfolio(adjusted)
        
        self.current_portfolio = target
        
        return EngineOutput(
            target_portfolio=target,
            trades=trades,
            metadata={
                "wealth": self.eg.wealth,
                "eta": self.eg._compute_eta(),
                "momentum": momentum.tolist(),
                "turnover": total_turnover,
            }
        )
    
    def _compute_trades(self, current: Portfolio, target: Portfolio) -> List[TradeAction]:
        """Compute trade list from current to target portfolio."""
        trades = []
        for i in range(self.n):
            diff = target.weights[i] - current.weights[i]
            if abs(diff) > 0.001:
                trades.append(TradeAction(
                    asset=i,
                    direction='BUY' if diff > 0 else 'SELL',
                    magnitude=abs(diff),
                    ticker=self.tickers[i]
                ))
        # Sort by magnitude (largest trades first)
        trades.sort(key=lambda t: -t.magnitude)
        return trades


# ============================================================================
# Synthetic Data Generation
# ============================================================================

def generate_gbm_prices(n_assets: int, n_days: int, 
                         mu: Optional[np.ndarray] = None,
                         sigma: Optional[np.ndarray] = None,
                         seed: int = 42) -> np.ndarray:
    """
    Generate synthetic stock prices using Geometric Brownian Motion.
    
    dS = μS dt + σS dW
    
    Returns: prices array of shape (n_days, n_assets)
    """
    rng = np.random.default_rng(seed)
    
    if mu is None:
        # Random drift: some positive, some negative
        mu = rng.normal(0.0005, 0.001, n_assets)  # Daily drift
    if sigma is None:
        sigma = rng.uniform(0.01, 0.03, n_assets)  # Daily volatility
    
    dt = 1.0
    prices = np.zeros((n_days, n_assets))
    prices[0] = 100.0  # All start at $100
    
    for t in range(1, n_days):
        dW = rng.normal(0, np.sqrt(dt), n_assets)
        prices[t] = prices[t-1] * np.exp((mu - 0.5 * sigma**2) * dt + sigma * dW)
    
    return prices


# ============================================================================
# Benchmarks
# ============================================================================

def equal_weight_wealth(prices: np.ndarray) -> np.ndarray:
    """Buy-and-hold equal weight portfolio."""
    n_days, n_assets = prices.shape
    returns = prices[1:] / prices[:-1]
    portfolio_returns = returns.mean(axis=1)
    wealth = np.ones(n_days)
    for t in range(1, n_days):
        wealth[t] = wealth[t-1] * portfolio_returns[t-1]
    return wealth


def best_stock_wealth(prices: np.ndarray) -> np.ndarray:
    """Best individual stock in hindsight."""
    n_days, n_assets = prices.shape
    best_wealth = np.zeros(n_days)
    for i in range(n_assets):
        stock_wealth = prices[:, i] / prices[0, i]
        best_wealth = np.maximum(best_wealth, stock_wealth)
    return best_wealth


def best_crp_wealth(prices: np.ndarray, n_samples: int = 10000, seed: int = 0) -> np.ndarray:
    """Approximate best constant-rebalanced portfolio by random sampling."""
    rng = np.random.default_rng(seed)
    n_days, n_assets = prices.shape
    returns = prices[1:] / prices[:-1]
    
    best_log_wealth = -np.inf
    best_weights = np.ones(n_assets) / n_assets
    
    for _ in range(n_samples):
        w = rng.dirichlet(np.ones(n_assets))
        port_rets = returns @ w
        log_wealth = np.sum(np.log(port_rets))
        if log_wealth > best_log_wealth:
            best_log_wealth = log_wealth
            best_weights = w
    
    # Reconstruct wealth path for best CRP
    port_rets = returns @ best_weights
    wealth = np.ones(n_days)
    for t in range(1, n_days):
        wealth[t] = wealth[t-1] * port_rets[t-1]
    
    return wealth


# ============================================================================
# Visualization
# ============================================================================

def plot_results(prices: np.ndarray, engine: OnlinePortfolioEngine,
                 tickers: List[str], save_path: str = "portfolio_results.png"):
    """Create comprehensive visualization of engine performance."""
    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    fig.suptitle("Online Portfolio Optimization Engine — Results", fontsize=16, fontweight='bold')
    
    n_days, n_assets = prices.shape
    
    # Panel 1: Stock prices (normalized)
    ax1 = axes[0, 0]
    for i in range(n_assets):
        ax1.plot(prices[:, i] / prices[0, i], label=tickers[i], alpha=0.8)
    ax1.set_title("Normalized Stock Prices")
    ax1.set_xlabel("Day")
    ax1.set_ylabel("Price / Initial Price")
    ax1.legend(fontsize=8)
    ax1.grid(True, alpha=0.3)
    
    # Panel 2: Wealth comparison
    ax2 = axes[0, 1]
    engine_wealth = np.array(engine.eg.wealth_history)
    eq_wealth = equal_weight_wealth(prices)
    best_stock = best_stock_wealth(prices)
    crp_wealth = best_crp_wealth(prices)
    
    ax2.plot(engine_wealth, label="EG Engine", linewidth=2, color='blue')
    ax2.plot(eq_wealth, label="Equal Weight", linewidth=1, color='gray', linestyle='--')
    ax2.plot(best_stock, label="Best Stock", linewidth=1, color='red', linestyle=':')
    ax2.plot(crp_wealth, label="Best CRP", linewidth=1, color='green', linestyle='-.')
    ax2.set_title("Wealth Comparison")
    ax2.set_xlabel("Day")
    ax2.set_ylabel("Wealth (starting = 1)")
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    ax2.set_yscale('log')
    
    # Panel 3: Portfolio weights over time
    ax3 = axes[1, 0]
    weights_history = np.array(engine.eg.portfolio_history)
    ax3.stackplot(range(len(weights_history)), weights_history.T, 
                  labels=tickers, alpha=0.8)
    ax3.set_title("Portfolio Allocation Over Time")
    ax3.set_xlabel("Day")
    ax3.set_ylabel("Weight")
    ax3.legend(loc='upper left', fontsize=7)
    ax3.set_ylim(0, 1)
    ax3.grid(True, alpha=0.3)
    
    # Panel 4: Regret over time
    ax4 = axes[1, 1]
    # Compute running regret
    regret_history = []
    running_wealth = 1.0
    for t in range(1, n_days):
        running_wealth *= np.dot(
            engine.eg.portfolio_history[t-1] if t-1 < len(engine.eg.portfolio_history) 
            else np.ones(n_assets)/n_assets,
            prices[t] / prices[t-1]
        )
        # Best stock wealth up to t
        best_so_far = max(prices[t, i] / prices[0, i] for i in range(n_assets))
        regret = np.log(best_so_far) - np.log(running_wealth) if running_wealth > 0 else 0
        regret_history.append(max(0, regret))
    
    ax4.plot(regret_history, label="Log Regret vs Best Stock", color='purple')
    # Theoretical bound
    T_range = np.arange(1, n_days)
    bound = np.sqrt(T_range * np.log(n_assets) / 2)
    ax4.plot(T_range, bound, label=f"O(√(T·ln({n_assets})))", 
             color='orange', linestyle='--')
    ax4.set_title("Logarithmic Regret")
    ax4.set_xlabel("Day")
    ax4.set_ylabel("Regret")
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Results saved to {save_path}")


# ============================================================================
# Main Demo
# ============================================================================

def main():
    print("=" * 70)
    print("  ONLINE PORTFOLIO OPTIMIZATION ENGINE — DEMO")
    print("  Based on Cover's Universal Portfolio & Exponential Gradient")
    print("=" * 70)
    
    # Configuration
    n_assets = 8
    n_days = 500
    tickers = ["AAPL", "GOOGL", "MSFT", "AMZN", "META", "NVDA", "TSLA", "JPM"]
    
    # Generate synthetic data
    print("\n📊 Generating synthetic market data (GBM)...")
    mu = np.array([0.0008, 0.0006, 0.0007, 0.0004, 0.0003, 0.0012, -0.0002, 0.0005])
    sigma = np.array([0.02, 0.018, 0.015, 0.022, 0.025, 0.03, 0.035, 0.012])
    prices = generate_gbm_prices(n_assets, n_days, mu=mu, sigma=sigma)
    
    # Initialize engine
    risk_params = RiskParams(
        max_position=0.30,
        max_turnover=0.40,
        min_weight=0.02,
        transaction_cost=0.001
    )
    engine = OnlinePortfolioEngine(n_assets, tickers=tickers, risk_params=risk_params)
    
    # Run engine
    print("\n🚀 Running portfolio engine...")
    all_trades = []
    for t in range(n_days):
        output = engine.process_prices(prices[t])
        if output.trades:
            all_trades.append((t, output.trades))
    
    # Results
    print("\n📈 RESULTS:")
    print(f"  Final engine wealth:    {engine.eg.wealth:.4f}")
    
    eq_w = equal_weight_wealth(prices)[-1]
    best_s = best_stock_wealth(prices)[-1]
    crp_w = best_crp_wealth(prices)[-1]
    
    print(f"  Equal weight wealth:    {eq_w:.4f}")
    print(f"  Best stock wealth:      {best_s:.4f}")
    print(f"  Best CRP wealth:        {crp_w:.4f}")
    
    print(f"\n  Engine vs Equal Weight: {engine.eg.wealth/eq_w:.2f}x")
    print(f"  Engine vs Best CRP:     {engine.eg.wealth/crp_w:.2f}x")
    
    # Final portfolio
    print("\n📋 FINAL PORTFOLIO:")
    for i, (ticker, weight) in enumerate(zip(tickers, engine.current_portfolio.weights)):
        if weight > 0.01:
            print(f"  {ticker:6s}: {weight*100:6.2f}%")
    
    # Recent trades
    if all_trades:
        print(f"\n🔄 RECENT TRADES (last 5 rebalances):")
        for day, trades in all_trades[-5:]:
            print(f"  Day {day}:")
            for trade in trades[:3]:
                print(f"    {trade}")
    
    # Kelly criterion demo
    print("\n" + "=" * 70)
    print("  KELLY CRITERION DEMO")
    print("=" * 70)
    
    kelly = KellyCriterion()
    scenarios = [
        (0.6, 1.0, "Fair coin, 60% win rate"),
        (0.55, 2.0, "55% chance, 2:1 odds"),
        (0.7, 1.5, "70% chance, 1.5:1 odds"),
        (0.4, 3.0, "40% chance, 3:1 odds"),
    ]
    
    for p, b, desc in scenarios:
        f = kelly.binary_kelly(p, b)
        g = kelly.growth_rate(p, b, f)
        print(f"  {desc}:")
        print(f"    Kelly fraction: {f*100:.1f}%, Growth rate: {g:.4f}")
    
    # Regret analysis
    print("\n" + "=" * 70)
    print("  REGRET ANALYSIS")
    print("=" * 70)
    
    price_rels = []
    for t in range(1, n_days):
        price_rels.append(PriceRelatives(prices[t] / prices[t-1]))
    
    regret = engine.eg.get_regret(price_rels)
    theoretical_bound = np.sqrt(n_days * np.log(n_assets) / 2)
    
    print(f"  Empirical log-regret:     {regret:.4f}")
    print(f"  Theoretical bound:        {theoretical_bound:.4f}")
    print(f"  Regret / bound:           {regret/theoretical_bound:.4f}")
    print(f"  Average per-round regret: {regret/n_days:.6f} → 0 as T → ∞")
    
    # Generate plots
    print("\n📊 Generating visualization...")
    save_path = str(Path(__file__).parent / "portfolio_results.png")
    plot_results(prices, engine, tickers, save_path)
    
    # Save detailed results
    results = {
        "config": {
            "n_assets": n_assets,
            "n_days": n_days,
            "tickers": tickers,
        },
        "performance": {
            "engine_wealth": float(engine.eg.wealth),
            "equal_weight_wealth": float(eq_w),
            "best_stock_wealth": float(best_s),
            "best_crp_wealth": float(crp_w),
            "log_regret": float(regret),
            "theoretical_bound": float(theoretical_bound),
        },
        "final_portfolio": {
            tickers[i]: float(engine.current_portfolio.weights[i])
            for i in range(n_assets)
        },
    }
    
    results_path = str(Path(__file__).parent / "results.json")
    with open(results_path, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"  Detailed results saved to {results_path}")
    
    print("\n✅ Demo complete!")


if __name__ == "__main__":
    main()
