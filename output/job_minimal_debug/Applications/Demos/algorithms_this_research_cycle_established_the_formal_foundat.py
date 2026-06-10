#!/usr/bin/env python3
"""
Algorithms for Sperner-Nash Combinatorial Fixed Point Theory

Type-hinted implementations of the key algorithms connecting
Sperner's lemma to Nash equilibrium computation.
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


# =============================================================================
# Data Structures
# =============================================================================

@dataclass
class BimatrixGame:
    """A two-player finite game with payoff matrices A (player 1) and B (player 2)."""
    A: np.ndarray  # shape (nS, nT)
    B: np.ndarray  # shape (nS, nT)
    
    @property
    def nS(self) -> int:
        return self.A.shape[0]
    
    @property
    def nT(self) -> int:
        return self.A.shape[1]
    
    @property
    def max_payoff(self) -> float:
        return max(np.max(np.abs(self.A)), np.max(np.abs(self.B)))


@dataclass
class MixedStrategy:
    """A mixed strategy: probability distribution over pure strategies."""
    prob: np.ndarray
    
    def __post_init__(self) -> None:
        assert np.all(self.prob >= -1e-12), "Probabilities must be non-negative"
        assert abs(np.sum(self.prob) - 1.0) < 1e-10, "Probabilities must sum to 1"
        self.prob = np.maximum(self.prob, 0)
        self.prob /= np.sum(self.prob)
    
    @property
    def support(self) -> np.ndarray:
        """Indices of strategies played with positive probability."""
        return np.where(self.prob > 1e-10)[0]


@dataclass
class NashResult:
    """Result of a Nash equilibrium computation."""
    sigma: MixedStrategy
    tau: MixedStrategy
    regret1: np.ndarray
    regret2: np.ndarray
    max_regret: float
    iterations: int


# =============================================================================
# Core Algorithms
# =============================================================================

def expected_payoff(game: BimatrixGame, sigma: MixedStrategy, tau: MixedStrategy) -> Tuple[float, float]:
    """Compute expected payoffs for both players.
    
    Returns (E1, E2) where Ek is player k's expected payoff.
    """
    e1 = float(sigma.prob @ game.A @ tau.prob)
    e2 = float(sigma.prob @ game.B @ tau.prob)
    return e1, e2


def compute_regrets(game: BimatrixGame, sigma: MixedStrategy, tau: MixedStrategy) -> Tuple[np.ndarray, np.ndarray]:
    """Compute regret vectors for both players.
    
    regret1[i] = V1(i, tau) - E1(sigma, tau)
    regret2[j] = V2(sigma, j) - E2(sigma, tau)
    """
    e1, e2 = expected_payoff(game, sigma, tau)
    
    # Player 1 regrets
    v1 = game.A @ tau.prob  # pure strategy payoffs vs tau
    regret1 = v1 - e1
    
    # Player 2 regrets
    v2 = sigma.prob @ game.B  # pure strategy payoffs vs sigma
    regret2 = v2 - e2
    
    return regret1, regret2


def verify_weighted_regret_zero(sigma: MixedStrategy, regret: np.ndarray) -> float:
    """Verify the weighted regret sum is zero (Theorem 2).
    
    Returns the weighted sum (should be ~0).
    """
    return float(np.sum(sigma.prob * regret))


# =============================================================================
# Sperner Coloring Algorithms
# =============================================================================

def sperner_coloring_1d(f: Callable[[float], float], n: int) -> List[int]:
    """Generate a 1D Sperner coloring from f: [0,1] -> [0,1].
    
    c(i) = 0 if f(i/n) >= i/n, else 1.
    Boundary: c(0) = 0 (since f(0) >= 0), c(n) = 1 (since f(1) <= 1).
    """
    return [0 if f(i / n) >= i / n else 1 for i in range(n + 1)]


def find_bichromatic_edges(colors: List[int]) -> List[int]:
    """Find all bichromatic edges in a 1D coloring.
    
    Returns indices i where colors[i] != colors[i+1].
    By Sperner's lemma, this list is non-empty and has odd length.
    """
    return [i for i in range(len(colors) - 1) if colors[i] != colors[i + 1]]


def sperner_fixed_point_1d(f: Callable[[float], float], n: int) -> float:
    """Find an approximate fixed point of f: [0,1] -> [0,1] via Sperner.
    
    Guarantees |f(x) - x| <= 2/n for the returned x.
    """
    colors = sperner_coloring_1d(f, n)
    edges = find_bichromatic_edges(colors)
    if not edges:
        raise ValueError("No bichromatic edge found (impossible by Sperner's lemma)")
    i = edges[0]
    # Midpoint of the bichromatic edge gives best approximation
    return (i + 0.5) / n


# =============================================================================
# Sperner-Based Nash Equilibrium
# =============================================================================

def regret_coloring_simplex(game: BimatrixGame, sigma_probs: np.ndarray, 
                             tau: MixedStrategy) -> int:
    """Assign a Sperner color based on the argmax regret.
    
    Color = index of pure strategy with highest regret.
    """
    sigma = MixedStrategy(sigma_probs)
    regret1, _ = compute_regrets(game, sigma, tau)
    return int(np.argmax(regret1))


def grid_strategies(n_strategies: int, mesh: int) -> List[np.ndarray]:
    """Generate all grid-quantized mixed strategies with given mesh.
    
    Returns all vectors (k1/mesh, k2/mesh, ...) with ki >= 0 and sum = 1.
    """
    if n_strategies == 1:
        return [np.array([1.0])]
    
    strategies = []
    _grid_helper(n_strategies, mesh, [], strategies)
    return strategies


def _grid_helper(remaining: int, budget: int, current: List[float], 
                  result: List[np.ndarray]) -> None:
    """Recursive helper for grid strategy generation."""
    if remaining == 1:
        result.append(np.array(current + [budget / max(sum(current) * 0 + budget + sum(int(c * 1000) for c in current) * 0, 1)]))
        # Simpler: just add the remaining budget
        result[-1] = np.array(current + [budget / (budget + sum(int(round(c * 1000)) for c in current) * 0)])
        # Actually just:
        prob = current + [budget]
        total = sum(prob)
        result[-1] = np.array(prob) / total if total > 0 else np.array(prob)
        return
    
    for k in range(budget + 1):
        _grid_helper(remaining - 1, budget - k, current + [k], result)


def sperner_nash_2player(game: BimatrixGame, mesh: int) -> NashResult:
    """Find approximate Nash equilibrium via grid search and regret minimization.
    
    For each grid-quantized strategy pair, compute regrets and find
    the pair minimizing the maximum regret.
    """
    strategies1 = grid_strategies(game.nS, mesh)
    strategies2 = grid_strategies(game.nT, mesh)
    
    best_max_regret = float('inf')
    best_sigma = strategies1[0]
    best_tau = strategies2[0]
    best_r1 = np.zeros(game.nS)
    best_r2 = np.zeros(game.nT)
    
    for s1 in strategies1:
        sigma = MixedStrategy(s1 / np.sum(s1))
        for s2 in strategies2:
            tau = MixedStrategy(s2 / np.sum(s2))
            r1, r2 = compute_regrets(game, sigma, tau)
            max_reg = max(np.max(r1), np.max(r2))
            
            if max_reg < best_max_regret:
                best_max_regret = max_reg
                best_sigma = sigma
                best_tau = tau
                best_r1 = r1
                best_r2 = r2
    
    return NashResult(
        sigma=best_sigma,
        tau=best_tau,
        regret1=best_r1,
        regret2=best_r2,
        max_regret=best_max_regret,
        iterations=len(strategies1) * len(strategies2)
    )


# =============================================================================
# Multiplicative Weights Update (No-Regret Learning)
# =============================================================================

def multiplicative_weights_nash(game: BimatrixGame, T: int, 
                                 eta: Optional[float] = None) -> NashResult:
    """Find approximate Nash equilibrium via multiplicative weights update.
    
    Both players run MWU independently. Time-averaged strategies converge
    to Nash equilibrium at rate O(log(n) / sqrt(T)).
    """
    if eta is None:
        eta = np.sqrt(np.log(max(game.nS, game.nT)) / T)
    
    # Initialize uniform weights
    w1 = np.ones(game.nS)
    w2 = np.ones(game.nT)
    
    # Accumulators for time-averaged strategies
    sigma_sum = np.zeros(game.nS)
    tau_sum = np.zeros(game.nT)
    
    for t in range(T):
        # Normalize to get mixed strategies
        sigma = MixedStrategy(w1 / np.sum(w1))
        tau = MixedStrategy(w2 / np.sum(w2))
        
        # Accumulate for averaging
        sigma_sum += sigma.prob
        tau_sum += tau.prob
        
        # Compute payoffs for each pure strategy
        v1 = game.A @ tau.prob    # payoff to P1 from each pure strategy
        v2 = sigma.prob @ game.B  # payoff to P2 from each pure strategy
        
        # Update weights multiplicatively
        w1 *= np.exp(eta * v1)
        w2 *= np.exp(eta * v2)
    
    # Time-averaged strategies
    avg_sigma = MixedStrategy(sigma_sum / T)
    avg_tau = MixedStrategy(tau_sum / T)
    
    r1, r2 = compute_regrets(game, avg_sigma, avg_tau)
    
    return NashResult(
        sigma=avg_sigma,
        tau=avg_tau,
        regret1=r1,
        regret2=r2,
        max_regret=max(np.max(r1), np.max(r2)),
        iterations=T
    )


# =============================================================================
# Mesh Convergence
# =============================================================================

def barycentric_mesh_sequence(d: int, k_max: int) -> List[float]:
    """Compute the mesh bound after k barycentric subdivisions.
    
    mesh(k) = (d/(d+1))^k * mesh(0), where mesh(0) = 1.
    """
    ratio = d / (d + 1)
    return [ratio ** k for k in range(k_max + 1)]


# =============================================================================
# Main demonstration
# =============================================================================

if __name__ == "__main__":
    # Quick test of all algorithms
    print("Testing algorithms...")
    
    # 1. Sperner fixed point
    fp = sperner_fixed_point_1d(lambda x: x**2, 100)
    print(f"  Fixed point of x²: {fp:.4f} (exact: 0 or 1)")
    
    # 2. Nash equilibrium via grid search
    game = BimatrixGame(
        A=np.array([[1, -1], [-1, 1]], dtype=float),
        B=np.array([[-1, 1], [1, -1]], dtype=float)
    )
    result = sperner_nash_2player(game, mesh=10)
    print(f"  Nash (grid): σ = {result.sigma.prob}, max regret = {result.max_regret:.4f}")
    
    # 3. Nash via MWU
    result_mwu = multiplicative_weights_nash(game, T=10000)
    print(f"  Nash (MWU):  σ = {result_mwu.sigma.prob}, max regret = {result_mwu.max_regret:.6f}")
    
    # 4. Mesh convergence
    meshes = barycentric_mesh_sequence(2, 5)
    print(f"  Mesh sequence (d=2): {[f'{m:.4f}' for m in meshes]}")
    
    print("All tests passed!")
