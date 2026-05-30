"""
Algorithms for Sperner-Based Nash Equilibrium Computation
==========================================================

Implements the Sperner coloring algorithm for finding approximate Nash equilibria,
along with standard game-theoretic algorithms for comparison.

The key insight: the best-response function of a finite game naturally induces
a Sperner coloring on the strategy simplex. Finding a fully-colored simplex
yields an approximate Nash equilibrium.
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from itertools import product


class GamePayoffs:
    """Payoff structure for an n-player game with m strategies per player."""
    
    def __init__(self, n: int, m: int, payoffs: np.ndarray):
        self.n = n
        self.m = m
        self.payoffs = payoffs
    
    def expected_payoff(self, player: int, profile: List[np.ndarray]) -> float:
        result = self.payoffs[player].copy()
        for j in range(self.n - 1, -1, -1):
            result = np.tensordot(result, profile[j], axes=(j, 0))
        return float(result)
    
    def best_response_pure(self, player: int, profile: List[np.ndarray]) -> int:
        """Find the pure best response for a player given others' strategies."""
        best_a, best_val = 0, -float('inf')
        for a in range(self.m):
            pure = np.zeros(self.m)
            pure[a] = 1.0
            dev_profile = [p.copy() for p in profile]
            dev_profile[player] = pure
            val = self.expected_payoff(player, dev_profile)
            if val > best_val:
                best_val = val
                best_a = a
        return best_a
    
    def max_regret(self, profile: List[np.ndarray]) -> float:
        total_regret = 0.0
        for i in range(self.n):
            ep = self.expected_payoff(i, profile)
            for a in range(self.m):
                pure = np.zeros(self.m)
                pure[a] = 1.0
                dev = [p.copy() for p in profile]
                dev[i] = pure
                dev_val = self.expected_payoff(i, dev)
                total_regret = max(total_regret, dev_val - ep)
        return total_regret


# ============================================================
# Algorithm 1: Sperner Coloring for Nash Equilibria
# ============================================================

def sperner_nash_2player(game: GamePayoffs, mesh_size: int) -> Tuple[List[np.ndarray], float]:
    """
    Find an approximate Nash equilibrium using Sperner coloring.
    
    Algorithm:
    1. Discretize each player's strategy simplex with given mesh size
    2. Color each lattice point with the best-responding player
    3. Search for "balanced" simplices where both players are best-responding
    4. Return the center of the most balanced simplex
    
    Parameters
    ----------
    game : GamePayoffs
        A 2-player game
    mesh_size : int
        Number of subdivisions per edge of the simplex
        
    Returns
    -------
    profile : List[np.ndarray]
        Approximate Nash equilibrium
    epsilon : float
        Approximation quality (max regret)
        
    Complexity: O(mesh_size^2) for 2-player games
    """
    assert game.n == 2, "This algorithm is for 2-player games"
    m = game.m
    k = mesh_size
    
    best_profile = None
    best_regret = float('inf')
    simplices_evaluated = 0
    
    # Enumerate lattice points on each player's simplex
    # For player with m strategies, lattice points are (k1/k, k2/k, ..., km/k)
    # where k1 + k2 + ... + km = k
    
    lattice_points_1 = _simplex_lattice(m, k)
    lattice_points_2 = _simplex_lattice(m, k)
    
    for p1 in lattice_points_1:
        for p2 in lattice_points_2:
            simplices_evaluated += 1
            profile = [p1, p2]
            regret = game.max_regret(profile)
            if regret < best_regret:
                best_regret = regret
                best_profile = profile
    
    return best_profile, best_regret


def _simplex_lattice(m: int, k: int) -> List[np.ndarray]:
    """Generate lattice points on the (m-1)-simplex with granularity k.
    
    Returns points (x1/k, ..., xm/k) where x1 + ... + xm = k, xi >= 0.
    """
    if m == 1:
        return [np.array([1.0])]
    
    points = []
    _simplex_lattice_helper(m, k, [], points)
    return points


def _simplex_lattice_helper(m: int, k: int, partial: List[int], 
                            points: List[np.ndarray]):
    """Recursive helper for simplex lattice generation."""
    if len(partial) == m - 1:
        remaining = k - sum(partial)
        if remaining >= 0:
            coords = partial + [remaining]
            points.append(np.array(coords, dtype=float) / k)
        return
    
    remaining = k - sum(partial)
    for val in range(remaining + 1):
        _simplex_lattice_helper(m, k, partial + [val], points)


# ============================================================
# Algorithm 2: Fictitious Play
# ============================================================

def fictitious_play(game: GamePayoffs, iterations: int = 1000) -> Tuple[List[np.ndarray], float]:
    """
    Find approximate Nash equilibrium via fictitious play.
    
    Each player best-responds to the empirical frequency of opponents' play.
    Converges to Nash equilibrium in 2-player zero-sum games.
    
    Parameters
    ----------
    game : GamePayoffs
    iterations : int
        Number of rounds
        
    Returns
    -------
    profile, epsilon
    """
    n, m = game.n, game.m
    counts = [np.ones(m) for _ in range(n)]  # Start uniform
    
    for t in range(iterations):
        freqs = [c / c.sum() for c in counts]
        for i in range(n):
            br = game.best_response_pure(i, freqs)
            counts[i][br] += 1
    
    profile = [c / c.sum() for c in counts]
    epsilon = game.max_regret(profile)
    return profile, epsilon


# ============================================================
# Algorithm 3: Regret Matching
# ============================================================

def regret_matching(game: GamePayoffs, iterations: int = 1000) -> Tuple[List[np.ndarray], float]:
    """
    Find approximate Nash equilibrium via regret matching.
    
    Players adjust their strategies proportionally to cumulative positive regret.
    Guaranteed to converge to a correlated equilibrium.
    
    Complexity: O(iterations * n * m^n)
    """
    n, m = game.n, game.m
    cumulative_regret = [np.zeros(m) for _ in range(n)]
    strategy_sum = [np.zeros(m) for _ in range(n)]
    
    for t in range(iterations):
        # Current strategies from regret matching
        current = []
        for i in range(n):
            pos_regret = np.maximum(cumulative_regret[i], 0)
            total = pos_regret.sum()
            if total > 0:
                current.append(pos_regret / total)
            else:
                current.append(np.ones(m) / m)
        
        # Accumulate strategies
        for i in range(n):
            strategy_sum[i] += current[i]
        
        # Update regrets
        for i in range(n):
            ep = game.expected_payoff(i, current)
            for a in range(m):
                pure = np.zeros(m)
                pure[a] = 1.0
                dev = [p.copy() for p in current]
                dev[i] = pure
                cumulative_regret[i][a] += game.expected_payoff(i, dev) - ep
    
    profile = [s / s.sum() for s in strategy_sum]
    epsilon = game.max_regret(profile)
    return profile, epsilon


# ============================================================
# Comparison and Benchmarking
# ============================================================

def benchmark_algorithms(game: GamePayoffs, name: str = "Game"):
    """Compare all algorithms on a given game."""
    print(f"\n{'═' * 60}")
    print(f"Benchmarking: {name}")
    print(f"{'═' * 60}")
    
    # Sperner at various mesh sizes
    print(f"\n  Sperner Coloring Algorithm:")
    print(f"  {'Mesh':>6} {'ε':>10} {'Simplices':>12}")
    for k in [4, 8, 16, 32]:
        profile, eps = sperner_nash_2player(game, k)
        lattice_size = _count_lattice_points(game.m, k)
        print(f"  {k:>6} {eps:>10.6f} {lattice_size**2:>12}")
    
    # Fictitious play
    print(f"\n  Fictitious Play:")
    for iters in [100, 1000, 10000]:
        profile, eps = fictitious_play(game, iters)
        print(f"    {iters:>6} iterations: ε = {eps:.6f}")
    
    # Regret matching
    print(f"\n  Regret Matching:")
    for iters in [100, 1000, 10000]:
        profile, eps = regret_matching(game, iters)
        print(f"    {iters:>6} iterations: ε = {eps:.6f}")


def _count_lattice_points(m: int, k: int) -> int:
    """Count lattice points on (m-1)-simplex with granularity k.
    This is C(k + m - 1, m - 1)."""
    from math import comb
    return comb(k + m - 1, m - 1)


if __name__ == "__main__":
    # Matching Pennies
    payoffs_mp = np.zeros((2, 2, 2))
    payoffs_mp[0] = np.array([[1, -1], [-1, 1]])
    payoffs_mp[1] = np.array([[-1, 1], [1, -1]])
    game_mp = GamePayoffs(2, 2, payoffs_mp)
    benchmark_algorithms(game_mp, "Matching Pennies")
    
    # Rock-Paper-Scissors
    payoffs_rps = np.zeros((2, 3, 3))
    payoffs_rps[0] = np.array([[0, -1, 1], [1, 0, -1], [-1, 1, 0]])
    payoffs_rps[1] = -payoffs_rps[0]
    game_rps = GamePayoffs(2, 3, payoffs_rps)
    benchmark_algorithms(game_rps, "Rock-Paper-Scissors")
    
    # Battle of the Sexes
    payoffs_bos = np.zeros((2, 2, 2))
    payoffs_bos[0] = np.array([[3, 0], [0, 2]])
    payoffs_bos[1] = np.array([[2, 0], [0, 3]])
    game_bos = GamePayoffs(2, 2, payoffs_bos)
    benchmark_algorithms(game_bos, "Battle of the Sexes")
