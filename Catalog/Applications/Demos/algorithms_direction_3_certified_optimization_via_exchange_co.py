"""
algorithms.py — Exchange-Based Optimization Algorithms with Certified Guarantees

Implements:
1. GreedyExchangeAlgorithm — Local search with exchange moves
2. CertifiedApproximation — Computes certified approximation bounds
3. ExchangeConstantComputer — Exact and approximate exchange constant computation
"""

from itertools import combinations
from typing import List, Set, FrozenSet, Callable, Tuple, Optional, Dict
import random


class BaseExchangeFamily:
    """A base exchange family (matroid-like structure).

    Stores feasible sets (bases) and supports exchange operations.
    """

    def __init__(self, ground_set: List[int], bases: List[FrozenSet[int]]):
        self.ground_set = ground_set
        self.bases = set(bases)
        self.rank = len(next(iter(bases))) if bases else 0

    def is_feasible(self, s: FrozenSet[int]) -> bool:
        return s in self.bases

    def exchange_neighbors(self, basis: FrozenSet[int]) -> List[FrozenSet[int]]:
        """All feasible sets reachable by a single exchange from basis."""
        neighbors = []
        for x in basis:
            for y in self.ground_set:
                if y not in basis:
                    new_basis = (basis - {x}) | {y}
                    if self.is_feasible(new_basis):
                        neighbors.append(new_basis)
        return neighbors

    @staticmethod
    def uniform_matroid(n: int, r: int) -> 'BaseExchangeFamily':
        """Construct the uniform matroid U(r, n)."""
        ground = list(range(n))
        bases = [frozenset(c) for c in combinations(ground, r)]
        return BaseExchangeFamily(ground, bases)

    @staticmethod
    def graphic_matroid(edges: List[Tuple[int, int]], n_vertices: int) -> 'BaseExchangeFamily':
        """Construct the graphic matroid from a graph."""
        n_edges = len(edges)
        r = n_vertices - 1
        bases = []
        for subset in combinations(range(n_edges), r):
            edge_set = [edges[i] for i in subset]
            parent = list(range(n_vertices))
            def find(x):
                while parent[x] != x:
                    parent[x] = parent[parent[x]]
                    x = parent[x]
                return x
            def union(x, y):
                px, py = find(x), find(y)
                if px == py:
                    return False
                parent[px] = py
                return True
            is_forest = True
            parent = list(range(n_vertices))
            for u, v in edge_set:
                if not union(u, v):
                    is_forest = False
                    break
            if is_forest and len(set(find(i) for i in range(n_vertices))) == 1:
                bases.append(frozenset(subset))
        return BaseExchangeFamily(list(range(n_edges)), bases)


class ExchangeConstantComputer:
    """Computes the exchange constant K for a weight function on an exchange family.

    The exchange constant K is the smallest non-negative real such that:
      w(B₁) + w(B₂) ≤ w(swap₁) + w(swap₂) + K
    for all feasible B₁, B₂ and all x ∈ B₁ \\ B₂.

    Time complexity: O(|bases|² · r²) where r is the rank.
    Space complexity: O(|bases|).
    """

    @staticmethod
    def compute(family: BaseExchangeFamily,
                w: Callable[[FrozenSet[int]], float]) -> float:
        """Compute the exact exchange constant.

        Args:
            family: The base exchange family
            w: Weight function on feasible sets

        Returns:
            The exchange constant K ≥ 0
        """
        K = 0.0
        bases_list = list(family.bases)
        for B1 in bases_list:
            for B2 in bases_list:
                for x in B1 - B2:
                    # Find the best exchange partner y
                    best_gap = float('inf')
                    for y in B2 - B1:
                        B1_new = (B1 - {x}) | {y}
                        B2_new = (B2 - {y}) | {x}
                        if family.is_feasible(B1_new) and family.is_feasible(B2_new):
                            gap = w(B1) + w(B2) - w(B1_new) - w(B2_new)
                            best_gap = min(best_gap, gap)
                    if best_gap != float('inf'):
                        K = max(K, best_gap)
        return max(K, 0.0)


class GreedyExchangeAlgorithm:
    """Greedy exchange algorithm with certified approximation guarantees.

    Starting from any feasible set, repeatedly performs the exchange that
    most improves the weight function, until no improving exchange exists.

    The algorithm terminates at an exchange-local maximum, which is guaranteed
    to be within K * r of the global optimum (additive bound) or within a
    multiplicative factor of 1 + K * r / w_min.

    Time complexity: O(|bases| · r² · iterations)
    Convergence: Terminates in at most |bases| iterations.
    """

    def __init__(self, family: BaseExchangeFamily,
                 w: Callable[[FrozenSet[int]], float]):
        self.family = family
        self.w = w
        self.history: List[FrozenSet[int]] = []

    def run(self, start: Optional[FrozenSet[int]] = None) -> FrozenSet[int]:
        """Run the greedy exchange algorithm.

        Args:
            start: Starting feasible set. If None, uses an arbitrary basis.

        Returns:
            An exchange-local maximum.
        """
        if start is None:
            start = next(iter(self.family.bases))

        current = start
        self.history = [current]

        while True:
            best_neighbor = None
            best_weight = self.w(current)

            for neighbor in self.family.exchange_neighbors(current):
                nw = self.w(neighbor)
                if nw > best_weight:
                    best_weight = nw
                    best_neighbor = neighbor

            if best_neighbor is None:
                break

            current = best_neighbor
            self.history.append(current)

        return current

    def is_local_max(self, basis: FrozenSet[int]) -> bool:
        """Check if basis is an exchange-local maximum."""
        for neighbor in self.family.exchange_neighbors(basis):
            if self.w(neighbor) > self.w(basis):
                return False
        return True


class CertifiedApproximation:
    """Computes certified approximation bounds from exchange constants.

    Given:
    - Exchange family F with rank r
    - Weight function w
    - Exchange constant K

    Provides:
    - Additive bound: w(Y) ≤ w(B) + K * r for any local max B and feasible Y
    - Multiplicative bound: w(Y)/w(B) ≤ 1 + K * r / w(B) when w(B) > 0
    """

    def __init__(self, family: BaseExchangeFamily,
                 w: Callable[[FrozenSet[int]], float],
                 K: float):
        self.family = family
        self.w = w
        self.K = K
        self.rank = family.rank

    def additive_bound(self, local_max: FrozenSet[int]) -> float:
        """Certified additive approximation gap."""
        return self.K * self.rank

    def multiplicative_ratio(self, local_max: FrozenSet[int]) -> float:
        """Certified multiplicative approximation ratio."""
        w_B = self.w(local_max)
        if w_B <= 0:
            return float('inf')
        return 1 + self.K * self.rank / w_B

    def verify_bound(self, local_max: FrozenSet[int]) -> Dict:
        """Verify the certified bound against all feasible sets."""
        w_B = self.w(local_max)
        additive_gap = self.additive_bound(local_max)
        max_actual_gap = 0.0
        worst_Y = local_max

        for Y in self.family.bases:
            gap = self.w(Y) - w_B
            if gap > max_actual_gap:
                max_actual_gap = gap
                worst_Y = Y

        return {
            'local_max': set(local_max),
            'local_max_weight': w_B,
            'worst_feasible': set(worst_Y),
            'worst_weight': self.w(worst_Y),
            'actual_gap': max_actual_gap,
            'certified_gap': additive_gap,
            'gap_ratio': max_actual_gap / additive_gap if additive_gap > 0 else 0.0,
            'bound_holds': max_actual_gap <= additive_gap + 1e-10,
        }


# === Example usage ===
if __name__ == "__main__":
    print("Exchange-Based Optimization Algorithm Demo")
    print("=" * 50)

    # Create uniform matroid U(3, 7)
    family = BaseExchangeFamily.uniform_matroid(7, 3)
    print(f"Created U(3,7) with {len(family.bases)} bases")

    # Additive weight
    weights = {0: 10, 1: 8, 2: 6, 3: 4, 4: 3, 5: 2, 6: 1}
    w = lambda B: sum(weights[x] for x in B)

    # Compute exchange constant
    K = ExchangeConstantComputer.compute(family, w)
    print(f"Exchange constant K = {K}")

    # Run greedy algorithm
    algo = GreedyExchangeAlgorithm(family, w)
    result = algo.run()
    print(f"Greedy result: {set(result)}, w = {w(result)}")
    print(f"Steps: {len(algo.history) - 1}")

    # Verify certified bound
    cert = CertifiedApproximation(family, w, K)
    verification = cert.verify_bound(result)
    print(f"Verification: {verification}")
