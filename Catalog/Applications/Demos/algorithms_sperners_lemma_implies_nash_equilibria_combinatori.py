#!/usr/bin/env python3
"""
Sperner-Nash Bridge: Core Algorithms

Type-hinted implementations of the key algorithms connecting Sperner's lemma
to Nash equilibrium computation.
"""

from typing import List, Tuple, Dict, Set, Optional, Callable
import numpy as np
from dataclasses import dataclass


@dataclass
class FiniteGame:
    """A finite normal-form game with n players."""
    num_players: int
    num_strats: List[int]
    payoff: Callable  # (player, strategy_profile) -> float

    @classmethod
    def two_player(cls, A: np.ndarray, B: np.ndarray) -> 'FiniteGame':
        """Create a 2-player game from payoff matrices."""
        m, n = A.shape
        def payoff(player: int, profile: Tuple[int, ...]) -> float:
            i, j = profile
            return A[i, j] if player == 0 else B[i, j]
        return cls(num_players=2, num_strats=[m, n], payoff=payoff)


@dataclass
class MixedProfile:
    """A mixed strategy profile."""
    strategies: List[np.ndarray]  # one distribution per player

    def expected_payoff(self, game: FiniteGame, player: int) -> float:
        """Compute expected payoff for a player."""
        from itertools import product as cart_product
        total = 0.0
        ranges = [range(s) for s in game.num_strats]
        for profile in cart_product(*ranges):
            prob = 1.0
            for j, s_j in enumerate(profile):
                prob *= self.strategies[j][s_j]
            total += prob * game.payoff(player, profile)
        return total

    def deviation_payoff(self, game: FiniteGame, player: int, pure_i: int) -> float:
        """Payoff when player deviates to pure strategy pure_i."""
        from itertools import product as cart_product
        total = 0.0
        ranges = [range(s) for s in game.num_strats]
        for profile in cart_product(*ranges):
            prob = 1.0
            for j, s_j in enumerate(profile):
                if j == player:
                    prob *= (1.0 if s_j == pure_i else 0.0)
                else:
                    prob *= self.strategies[j][s_j]
            total += prob * game.payoff(player, profile)
        return total

    def regret(self, game: FiniteGame, player: int, pure_i: int) -> float:
        """Regret of player from pure strategy pure_i."""
        return self.deviation_payoff(game, player, pure_i) - \
               self.expected_payoff(game, player)

    def max_regret(self, game: FiniteGame) -> float:
        """Maximum regret across all players and strategies."""
        return max(
            self.regret(game, i, si)
            for i in range(game.num_players)
            for si in range(game.num_strats[i])
        )

    def player_max_regret(self, game: FiniteGame, player: int) -> float:
        """Maximum regret for a specific player."""
        return max(
            self.regret(game, player, si)
            for si in range(game.num_strats[player])
        )

    def is_nash(self, game: FiniteGame, eps: float = 1e-10) -> bool:
        """Check if this is a (eps-approximate) Nash equilibrium."""
        return self.max_regret(game) <= eps

    def chromatic_player(self, game: FiniteGame) -> int:
        """Return the player with highest max regret (chromatic color)."""
        regrets = [self.player_max_regret(game, i) for i in range(game.num_players)]
        return int(np.argmax(regrets))


@dataclass
class SimplexVertex:
    """A vertex in a triangulated simplex."""
    coordinates: np.ndarray
    index: int


@dataclass
class Simplex:
    """A simplex in a triangulation."""
    vertices: List[int]  # indices into vertex array


class SpernerNashSolver:
    """
    Sperner-Nash Algorithm: Find approximate Nash equilibria using
    Sperner-type colorings of the mixed strategy space.

    Algorithm:
    1. Triangulate the product of strategy simplices
    2. Color each vertex by the player with highest max regret
    3. Find fully-colored simplices (all players represented)
    4. Barycenters of such simplices are approximate Nash equilibria
    5. Refine the triangulation to improve approximation

    Complexity: O(N^n) where N = grid points per dimension, n = num players
    """

    def __init__(self, game: FiniteGame, initial_divisions: int = 10):
        self.game = game
        self.divisions = initial_divisions

    def _grid_to_mixed_profile(self, grid_point: np.ndarray) -> MixedProfile:
        """Convert a grid point to a mixed strategy profile.
        For 2 players with strategies [m, n], grid_point has dim m+n-2."""
        strategies = []
        idx = 0
        for player in range(self.game.num_players):
            k = self.game.num_strats[player]
            if k == 2:
                t = grid_point[idx]
                strategies.append(np.array([1 - t, t]))
                idx += 1
            else:
                # General simplex: use first k-1 coordinates
                coords = grid_point[idx:idx + k - 1]
                last = 1.0 - sum(coords)
                strategies.append(np.append(coords, last))
                idx += k - 1
        return MixedProfile(strategies)

    def _triangulate_2d(self, n: int) -> Tuple[List[np.ndarray], List[Tuple[int, ...]]]:
        """Triangulate [0,1]^2 into small triangles."""
        vertices = []
        vertex_map: Dict[Tuple[int, int], int] = {}

        for i in range(n + 1):
            for j in range(n + 1):
                v = np.array([i / n, j / n])
                vertex_map[(i, j)] = len(vertices)
                vertices.append(v)

        triangles = []
        for i in range(n):
            for j in range(n):
                v00 = vertex_map[(i, j)]
                v10 = vertex_map[(i + 1, j)]
                v01 = vertex_map[(i, j + 1)]
                v11 = vertex_map[(i + 1, j + 1)]
                triangles.append((v00, v10, v01))
                triangles.append((v10, v11, v01))

        return vertices, triangles

    def solve(self, divisions: Optional[int] = None) -> List[Tuple[MixedProfile, float]]:
        """
        Find approximate Nash equilibria.
        
        Returns list of (mixed_profile, max_regret) sorted by quality.
        """
        n = divisions or self.divisions

        if self.game.num_players != 2:
            raise NotImplementedError("Currently supports 2-player games only")

        vertices, triangles = self._triangulate_2d(n)

        # Color each vertex
        profiles = [self._grid_to_mixed_profile(v) for v in vertices]
        colors = [p.chromatic_player(self.game) for p in profiles]

        # Find fully-colored simplices
        results = []
        for tri in triangles:
            tri_colors = {colors[v] for v in tri}
            if len(tri_colors) == self.game.num_players:
                # Fully colored! Barycenter is approximate Nash
                barycenter = np.mean([vertices[v] for v in tri], axis=0)
                profile = self._grid_to_mixed_profile(barycenter)
                mr = profile.max_regret(self.game)
                results.append((profile, mr))

        results.sort(key=lambda x: x[1])
        return results

    def solve_adaptive(self, target_eps: float = 0.01,
                       max_divisions: int = 500) -> Tuple[MixedProfile, float]:
        """
        Adaptively refine until target approximation quality is reached.

        Pseudocode:
            n ← initial_divisions
            while n ≤ max_divisions:
                equilibria ← solve(n)
                if best_regret ≤ target_eps:
                    return best
                n ← 2n
        """
        n = self.divisions
        while n <= max_divisions:
            results = self.solve(n)
            if results and results[0][1] <= target_eps:
                return results[0]
            n *= 2
        # Return best found
        results = self.solve(n // 2)
        if results:
            return results[0]
        raise RuntimeError("No approximate equilibrium found")


class EquilibriumFiltration:
    """
    The Equilibrium Filtration: nested family of ε-approximate Nash sets.
    
    F_ε = {σ : max_regret(σ) ≤ ε}
    
    Properties:
    - F_0 = exact Nash equilibria
    - ε₁ ≤ ε₂ → F_{ε₁} ⊆ F_{ε₂}
    - Non-empty for ε ≥ 2M (M = payoff bound)
    """

    def __init__(self, game: FiniteGame):
        self.game = game

    def level_set_membership(self, profile: MixedProfile, eps: float) -> bool:
        """Check if profile is in the ε-level set."""
        return profile.max_regret(self.game) <= eps

    def sample_level_set(self, eps: float, n_samples: int = 1000) -> List[MixedProfile]:
        """Sample the ε-level set by random sampling."""
        members = []
        for _ in range(n_samples):
            strategies = []
            for player in range(self.game.num_players):
                k = self.game.num_strats[player]
                # Sample from Dirichlet distribution (uniform on simplex)
                s = np.random.dirichlet(np.ones(k))
                strategies.append(s)
            profile = MixedProfile(strategies)
            if self.level_set_membership(profile, eps):
                members.append(profile)
        return members

    def critical_regret(self, n_samples: int = 10000) -> float:
        """Estimate the critical regret (smallest ε with non-empty F_ε)."""
        min_regret = float('inf')
        for _ in range(n_samples):
            strategies = []
            for player in range(self.game.num_players):
                k = self.game.num_strats[player]
                s = np.random.dirichlet(np.ones(k))
                strategies.append(s)
            profile = MixedProfile(strategies)
            mr = profile.max_regret(self.game)
            min_regret = min(min_regret, mr)
        return min_regret


def sperner_nash_number(num_players: int, eps: float) -> int:
    """
    Compute the Sperner-Nash number: minimum grid resolution for ε-approximation.
    
    Formula: ⌈1/ε⌉^n where n = number of players.
    
    This gives the computational complexity of the Sperner-based algorithm.
    """
    import math
    return math.ceil(1 / eps) ** num_players


if __name__ == "__main__":
    # Demo: Matching Pennies
    A = np.array([[1, -1], [-1, 1]])
    B = np.array([[-1, 1], [1, -1]])
    game = FiniteGame.two_player(A, B)

    solver = SpernerNashSolver(game, initial_divisions=10)
    profile, quality = solver.solve_adaptive(target_eps=0.01)

    print("Matching Pennies Nash Equilibrium (Sperner-Nash Algorithm):")
    print(f"  Player 1: {profile.strategies[0]}")
    print(f"  Player 2: {profile.strategies[1]}")
    print(f"  Max regret: {quality:.6f}")

    # Equilibrium filtration
    filt = EquilibriumFiltration(game)
    print(f"\nEstimated critical regret: {filt.critical_regret():.4f}")
    print(f"Sperner-Nash number at ε=0.01: {sperner_nash_number(2, 0.01)}")
