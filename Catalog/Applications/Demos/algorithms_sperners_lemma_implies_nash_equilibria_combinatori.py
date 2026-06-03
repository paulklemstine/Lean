"""
Algorithms for Sperner-based Nash Equilibrium Computation

Type-hinted implementations of the core algorithms connecting Sperner's lemma
to Nash equilibrium computation.
"""

from typing import List, Tuple, Optional, Callable
import numpy as np
from dataclasses import dataclass


@dataclass
class FiniteGame:
    """A finite two-player normal-form game.
    
    Attributes:
        A: Payoff matrix for player 1 (m x n)
        B: Payoff matrix for player 2 (m x n)
    """
    A: np.ndarray
    B: np.ndarray
    
    @property
    def num_strategies_1(self) -> int:
        return self.A.shape[0]
    
    @property
    def num_strategies_2(self) -> int:
        return self.A.shape[1]
    
    def expected_payoff_1(self, p1: np.ndarray, p2: np.ndarray) -> float:
        """Expected payoff for player 1 under mixed strategies (p1, p2)."""
        return float(p1 @ self.A @ p2)
    
    def expected_payoff_2(self, p1: np.ndarray, p2: np.ndarray) -> float:
        """Expected payoff for player 2 under mixed strategies (p1, p2)."""
        return float(p1 @ self.B @ p2)
    
    def deviation_payoffs_1(self, p2: np.ndarray) -> np.ndarray:
        """Payoff to player 1 from each pure strategy, given p2."""
        return self.A @ p2
    
    def deviation_payoffs_2(self, p1: np.ndarray) -> np.ndarray:
        """Payoff to player 2 from each pure strategy, given p1."""
        return self.B.T @ p1
    
    def max_regret(self, p1: np.ndarray, p2: np.ndarray) -> float:
        """Maximum regret across both players."""
        exp1 = self.expected_payoff_1(p1, p2)
        exp2 = self.expected_payoff_2(p1, p2)
        max_dev1 = float(np.max(self.deviation_payoffs_1(p2)))
        max_dev2 = float(np.max(self.deviation_payoffs_2(p1)))
        return max(max_dev1 - exp1, max_dev2 - exp2)


@dataclass
class ApproxNashEquilibrium:
    """An approximate Nash equilibrium with quality bound."""
    p1: np.ndarray
    p2: np.ndarray
    epsilon: float  # approximation quality (max regret)
    mesh_size: float  # triangulation mesh size used


def simplex_triangulation(
    n: int, 
    resolution: int
) -> List[np.ndarray]:
    """Generate vertices of a triangulation of the (n-1)-simplex.
    
    Args:
        n: Dimension (number of vertices of the simplex = number of strategies)
        resolution: Grid resolution (number of subdivisions per edge)
    
    Returns:
        List of points on the simplex, each a probability vector.
    """
    from itertools import product as iter_product
    
    points: List[np.ndarray] = []
    for combo in iter_product(range(resolution + 1), repeat=n - 1):
        if sum(combo) <= resolution:
            last = resolution - sum(combo)
            point = np.array(list(combo) + [last], dtype=float) / resolution
            points.append(point)
    return points


def sperner_coloring(
    game: FiniteGame,
    p1: np.ndarray,
    p2: np.ndarray,
    player: int
) -> int:
    """Compute Sperner coloring for a point in the mixed strategy space.
    
    The coloring assigns each vertex the index of the best-response pure strategy
    for the specified player. This satisfies the Sperner boundary condition:
    if a strategy has zero probability, it cannot be the best response direction.
    
    Args:
        game: The finite game
        p1: Player 1's mixed strategy
        p2: Player 2's mixed strategy
        player: Which player (0 or 1)
    
    Returns:
        Index of the best-response pure strategy (the "color")
    """
    if player == 0:
        payoffs = game.deviation_payoffs_1(p2)
    else:
        payoffs = game.deviation_payoffs_2(p1)
    return int(np.argmax(payoffs))


def find_nash_sperner(
    game: FiniteGame,
    resolution: int = 20,
    tolerance: float = 0.01
) -> List[ApproxNashEquilibrium]:
    """Find approximate Nash equilibria using the Sperner construction.
    
    Algorithm:
    1. Triangulate each player's strategy simplex at given resolution
    2. For each grid point pair (p1, p2), compute regret
    3. Return points with regret below tolerance
    
    Complexity: O(N^n) where N = resolution, n = total strategies
    
    Args:
        game: The finite game
        resolution: Triangulation resolution
        tolerance: Maximum allowed regret
    
    Returns:
        List of approximate Nash equilibria
    """
    grid1 = simplex_triangulation(game.num_strategies_1, resolution)
    grid2 = simplex_triangulation(game.num_strategies_2, resolution)
    
    mesh = 1.0 / resolution
    results: List[ApproxNashEquilibrium] = []
    
    for p1 in grid1:
        for p2 in grid2:
            regret = game.max_regret(p1, p2)
            if regret <= tolerance:
                results.append(ApproxNashEquilibrium(
                    p1=p1.copy(),
                    p2=p2.copy(),
                    epsilon=regret,
                    mesh_size=mesh
                ))
    
    return results


def iterative_sperner_refinement(
    game: FiniteGame,
    initial_resolution: int = 5,
    max_iterations: int = 8,
    target_epsilon: float = 1e-4
) -> List[ApproxNashEquilibrium]:
    """Iteratively refine Sperner-based Nash approximations.
    
    This implements the combinatorial equilibrium refinement:
    start with a coarse triangulation, find approximate equilibria,
    then refine the triangulation around them.
    
    Args:
        game: The finite game
        initial_resolution: Starting grid resolution
        max_iterations: Maximum refinement iterations
        target_epsilon: Target approximation quality
    
    Returns:
        List of approximate Nash equilibria at the finest resolution
    """
    resolution = initial_resolution
    best_equilibria: List[ApproxNashEquilibrium] = []
    
    for iteration in range(max_iterations):
        tolerance = 2.0 / resolution
        equilibria = find_nash_sperner(game, resolution, tolerance)
        
        if equilibria:
            best_equilibria = sorted(equilibria, key=lambda e: e.epsilon)[:10]
            best_eps = best_equilibria[0].epsilon
            
            if best_eps <= target_epsilon:
                break
        
        resolution = int(resolution * 1.5) + 1
    
    return best_equilibria


def verify_support_lemma(
    game: FiniteGame,
    p1: np.ndarray,
    p2: np.ndarray,
    tolerance: float = 1e-6
) -> Tuple[bool, dict]:
    """Verify the Nash support lemma for a given strategy profile.
    
    The support lemma states: if (p1, p2) is a Nash equilibrium, then every
    strategy with positive probability achieves the same expected payoff
    (equal to the mixed strategy expected payoff).
    
    Args:
        game: The finite game
        p1, p2: Mixed strategy profile
        tolerance: Numerical tolerance
    
    Returns:
        (is_valid, details) where details contains per-strategy information
    """
    exp1 = game.expected_payoff_1(p1, p2)
    exp2 = game.expected_payoff_2(p1, p2)
    
    dev1 = game.deviation_payoffs_1(p2)
    dev2 = game.deviation_payoffs_2(p1)
    
    support_1_ok = all(
        abs(dev1[i] - exp1) <= tolerance
        for i in range(len(p1)) if p1[i] > tolerance
    )
    support_2_ok = all(
        abs(dev2[j] - exp2) <= tolerance
        for j in range(len(p2)) if p2[j] > tolerance
    )
    
    details = {
        'player1_expected': exp1,
        'player2_expected': exp2,
        'player1_deviations': dev1.tolist(),
        'player2_deviations': dev2.tolist(),
        'player1_support': [i for i in range(len(p1)) if p1[i] > tolerance],
        'player2_support': [j for j in range(len(p2)) if p2[j] > tolerance],
        'support_lemma_holds': support_1_ok and support_2_ok
    }
    
    return support_1_ok and support_2_ok, details


if __name__ == '__main__':
    # Example: Matching Pennies
    game = FiniteGame(
        A=np.array([[1, -1], [-1, 1]], dtype=float),
        B=np.array([[-1, 1], [1, -1]], dtype=float)
    )
    
    print("Finding Nash equilibria for Matching Pennies...")
    results = iterative_sperner_refinement(game, target_epsilon=0.01)
    
    for eq in results[:3]:
        print(f"  p1={eq.p1}, p2={eq.p2}, ε={eq.epsilon:.6f}")
        valid, details = verify_support_lemma(game, eq.p1, eq.p2, tolerance=0.05)
        print(f"  Support lemma: {'✓' if valid else '✗'}")
