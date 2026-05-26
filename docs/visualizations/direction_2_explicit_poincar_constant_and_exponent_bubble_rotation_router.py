#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for the Bubble-Rotation Walk

Implements the recursive symbol-placement routing algorithm and
spectral gap estimation for the bubble-rotation walk on S_n.

Algorithms:
1. BubbleRotationRouter: constructs canonical paths using rotation + bubble
2. SpectralGapEstimator: computes/bounds the spectral gap
3. CongestionAnalyzer: measures edge congestion of the routing scheme
"""

import numpy as np
from itertools import permutations
from math import factorial
from typing import List, Tuple, Dict, Optional
from collections import defaultdict


class Permutation:
    """Represents a permutation of {0, 1, ..., n-1}."""

    def __init__(self, values: Tuple[int, ...]):
        self.values = tuple(values)
        self.n = len(values)

    def __call__(self, i: int) -> int:
        return self.values[i]

    def __mul__(self, other: 'Permutation') -> 'Permutation':
        """Composition: (self * other)(i) = self(other(i))."""
        return Permutation(tuple(self.values[other.values[i]]
                                 for i in range(self.n)))

    def inverse(self) -> 'Permutation':
        inv = [0] * self.n
        for i, v in enumerate(self.values):
            inv[v] = i
        return Permutation(tuple(inv))

    def __eq__(self, other):
        return self.values == other.values

    def __hash__(self):
        return hash(self.values)

    def __repr__(self):
        return f"Perm({list(self.values)})"

    @staticmethod
    def identity(n: int) -> 'Permutation':
        return Permutation(tuple(range(n)))

    @staticmethod
    def adjacent_swap(n: int, i: int) -> 'Permutation':
        """Swap positions i and i+1."""
        vals = list(range(n))
        vals[i], vals[i + 1] = vals[i + 1], vals[i]
        return Permutation(tuple(vals))

    @staticmethod
    def long_cycle(n: int) -> 'Permutation':
        """The long cycle (0 1 2 ... n-1)."""
        return Permutation(tuple((i + 1) % n for i in range(n)))


class BubbleRotationRouter:
    """
    Implements the recursive symbol-placement routing algorithm.

    Algorithm (Strategy A):
    For each pair (sigma, tau), construct a canonical path from sigma to tau:
    1. Compute pi = sigma^{-1} * tau (the "correction" permutation).
    2. Process symbols from n-1 down to 1:
       a. Find where symbol k currently sits: position pi^{-1}(k).
       b. Use powers of the long cycle rho to rotate it to position k+1
          (or nearby).
       c. Use adjacent transpositions to bubble it into position k.
    3. After processing all symbols, pi is resolved.

    Complexity:
    - Path length: O(n) per symbol × n symbols = O(n²)
    - Total congestion: O(n² · n!)
    """

    def __init__(self, n: int):
        self.n = n
        self.identity = Permutation.identity(n)
        self.rho = Permutation.long_cycle(n)
        self.rho_inv = self.rho.inverse()
        self.generators = self._build_generators()

    def _build_generators(self) -> List[Permutation]:
        """Build the bubble-rotation generating set."""
        gens = []
        for i in range(self.n - 1):
            gens.append(Permutation.adjacent_swap(self.n, i))
        gens.append(self.rho)
        gens.append(self.rho_inv)
        return gens

    def route(self, sigma: Permutation, tau: Permutation) -> List[Permutation]:
        """
        Construct a canonical path from sigma to tau.

        Returns a list of generators [g_1, g_2, ..., g_m] such that
        g_m * ... * g_2 * g_1 * sigma = tau.

        The algorithm processes each symbol position from the top down,
        using the long cycle for global transport and adjacent swaps
        for local placement.
        """
        n = self.n
        if n <= 1:
            return []

        # Current state of the permutation we're building
        pi = sigma.inverse() * tau  # Correction permutation
        path = []

        # Process symbols from n-1 down to 0
        current = Permutation.identity(n)
        for target_pos in range(n - 1, 0, -1):
            # Find which value should go to position target_pos
            target_val = pi(target_pos)

            # Find where target_val currently sits
            current_pos = None
            composed = current * pi
            for j in range(n):
                if composed(j) == target_pos:
                    # After applying current, position j maps to target_pos
                    # We need to find where target_val is in the current arrangement
                    pass

            # Simpler: directly find position of target_val in the residual perm
            residual = current * pi
            source_pos = residual.inverse()(target_pos)

            if source_pos == target_pos:
                continue  # Already in place

            # Step 1: Use long cycle powers to bring source_pos close
            # Rotate by (target_pos - source_pos) mod n positions
            shift = (target_pos - source_pos) % n
            if shift > 0 and shift <= n // 2:
                # Use rho^shift
                for _ in range(shift):
                    path.append(self.rho)
                    current = self.rho * current
            elif shift > n // 2:
                # Use rho_inv^(n-shift)
                for _ in range(n - shift):
                    path.append(self.rho_inv)
                    current = self.rho_inv * current
            # Now use adjacent swaps to fine-tune
            residual = current * pi
            new_pos = residual.inverse()(target_pos)

            # Bubble the element into position using adjacent swaps
            if new_pos < target_pos:
                for j in range(new_pos, target_pos):
                    swap = Permutation.adjacent_swap(n, j)
                    path.append(swap)
                    current = swap * current
            elif new_pos > target_pos:
                for j in range(new_pos - 1, target_pos - 1, -1):
                    swap = Permutation.adjacent_swap(n, j)
                    path.append(swap)
                    current = swap * current

        return path

    def verify_route(self, sigma: Permutation, tau: Permutation,
                     path: List[Permutation]) -> bool:
        """Verify that the path connects sigma to tau."""
        result = sigma
        for g in path:
            result = g * result
        return result == tau

    def max_path_length(self, sample_size: Optional[int] = None) -> int:
        """Compute or estimate the maximum path length over all pairs."""
        perms = list(permutations(range(self.n)))
        if sample_size and len(perms) ** 2 > sample_size:
            # Sample random pairs
            max_len = 0
            for _ in range(sample_size):
                i, j = np.random.randint(len(perms), size=2)
                sigma = Permutation(perms[i])
                tau = Permutation(perms[j])
                path = self.route(sigma, tau)
                max_len = max(max_len, len(path))
            return max_len

        max_len = 0
        for p in perms:
            sigma = Permutation(p)
            for q in perms:
                tau = Permutation(q)
                path = self.route(sigma, tau)
                max_len = max(max_len, len(path))
        return max_len


class SpectralGapEstimator:
    """
    Estimates the spectral gap of the bubble-rotation walk.

    Methods:
    1. Exact computation via eigenvalue decomposition (small n)
    2. Power iteration for the second eigenvalue (medium n)
    3. Theoretical lower bound from canonical paths (any n)
    """

    def __init__(self, n: int):
        self.n = n

    def exact_gap(self) -> Tuple[float, np.ndarray]:
        """
        Compute the exact spectral gap by full eigenvalue decomposition.
        Only feasible for n ≤ 8.

        Returns:
            (gap, eigenvalues) where gap = 1 - max|λ_i| for i ≥ 2
        """
        N = factorial(self.n)
        perms = list(permutations(range(self.n)))
        perm_idx = {p: i for i, p in enumerate(perms)}

        gens = self._generators()
        k = len(gens)

        P = np.zeros((N, N))
        for i, sigma in enumerate(perms):
            for g in gens:
                tau = tuple(g[sigma[j]] for j in range(self.n))
                j = perm_idx[tau]
                P[i, j] += 1.0 / k

        eigenvalues = np.sort(np.abs(np.linalg.eigvals(P)))[::-1]
        gap = 1.0 - eigenvalues[1]
        return gap, eigenvalues

    def theoretical_lower_bound(self) -> float:
        """
        Compute the theoretical lower bound on the spectral gap
        from the canonical path analysis.

        gap ≥ |S| / (4 * n^4)
        """
        k = len(self._generators())
        return k / (4.0 * self.n ** 4)

    def _generators(self) -> List[Tuple[int, ...]]:
        gens = set()
        n = self.n
        for i in range(n - 1):
            p = list(range(n))
            p[i], p[i + 1] = p[i + 1], p[i]
            gens.add(tuple(p))
        rho = tuple((i + 1) % n for i in range(n))
        rho_inv = tuple((i - 1) % n for i in range(n))
        gens.add(rho)
        gens.add(rho_inv)
        return list(gens)


class CongestionAnalyzer:
    """
    Analyzes the edge congestion of a routing scheme on the Cayley graph.

    For each directed edge (sigma, g*sigma) in Cay(S_n, S^br),
    counts how many canonical paths pass through that edge,
    weighted by path length.
    """

    def __init__(self, n: int, router: BubbleRotationRouter):
        self.n = n
        self.router = router

    def compute_congestion(self) -> Dict:
        """
        Compute exact edge congestion for small n.

        Returns dict with:
        - max_load: maximum number of paths through any edge
        - max_weighted_load: max of sum of path lengths through any edge
        - total_path_length: sum of all path lengths
        - avg_path_length: average path length
        """
        perms = [Permutation(p) for p in permutations(range(self.n))]
        edge_load = defaultdict(int)
        edge_weighted_load = defaultdict(int)
        total_length = 0
        count = 0

        for sigma in perms:
            for tau in perms:
                path = self.router.route(sigma, tau)
                length = len(path)
                total_length += length
                count += 1

                # Track which edges the path uses
                current = sigma
                for g in path:
                    edge = (current, g)
                    edge_load[edge] += 1
                    edge_weighted_load[edge] += length
                    current = g * current

        max_load = max(edge_load.values()) if edge_load else 0
        max_weighted = max(edge_weighted_load.values()) if edge_weighted_load else 0

        return {
            'max_load': max_load,
            'max_weighted_load': max_weighted,
            'total_path_length': total_length,
            'avg_path_length': total_length / count if count > 0 else 0,
            'num_edges_used': len(edge_load),
            'num_pairs': count,
        }


def demonstrate():
    """Run a complete demonstration of all algorithms."""
    print("=" * 70)
    print("  BUBBLE-ROTATION WALK: ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    for n in range(3, 6):
        print(f"\n{'=' * 70}")
        print(f"  n = {n}, |S_{n}| = {factorial(n)}")
        print(f"{'=' * 70}")

        # Spectral gap
        estimator = SpectralGapEstimator(n)
        gap, eigs = estimator.exact_gap()
        bound = estimator.theoretical_lower_bound()

        print(f"\nSpectral gap: {gap:.8f}")
        print(f"Theoretical lower bound: {bound:.8f}")
        print(f"Ratio (actual/bound): {gap/bound:.2f}×")
        print(f"n² · gap = {n**2 * gap:.6f}")

        # Routing
        router = BubbleRotationRouter(n)
        print(f"\nRouting analysis:")
        print(f"  Number of generators: {len(router.generators)}")

        # Test a few routes
        id_perm = Permutation.identity(n)
        rho = Permutation.long_cycle(n)
        path = router.route(id_perm, rho)
        valid = router.verify_route(id_perm, rho, path)
        print(f"  Route id → ρ: length {len(path)}, valid: {valid}")

        if n <= 5:
            # Congestion analysis (only for small n)
            analyzer = CongestionAnalyzer(n, router)
            stats = analyzer.compute_congestion()
            print(f"\nCongestion analysis:")
            print(f"  Max edge load: {stats['max_load']}")
            print(f"  Max weighted load: {stats['max_weighted_load']}")
            print(f"  Avg path length: {stats['avg_path_length']:.2f}")
            print(f"  Theoretical bound: 2·n² = {2 * n**2}")
            print(f"  Congestion bound: 2·n²·n! = {2 * n**2 * factorial(n)}")


if __name__ == "__main__":
    demonstrate()
