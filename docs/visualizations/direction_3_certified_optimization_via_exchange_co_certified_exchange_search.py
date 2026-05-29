#!/usr/bin/env python3
"""
Algorithms for Exchange-Certified Optimization

Implements the core algorithms from the exchange constant theory:
1. Exchange local search (greedy ascent)
2. Exchange constant computation
3. Certified gap bound verification
4. Exhaustive local optima enumeration

All algorithms operate on finite exchange families with weight functions.
"""

import itertools
from typing import List, Set, Dict, Tuple, Optional, Callable, FrozenSet
from dataclasses import dataclass


@dataclass
class CertifiedSolution:
    """A solution with a certified approximation guarantee.

    Attributes:
        basis: The exchange-local maximum found
        weight: w(basis)
        global_bound: Upper bound on w(Y) for any feasible Y
        exchange_constant: The exchange constant K used
        rank: Common cardinality of feasible sets
        is_exact: Whether K = 0 (exact optimality guaranteed)
    """
    basis: FrozenSet[int]
    weight: float
    global_bound: float
    exchange_constant: float
    rank: int
    is_exact: bool


class UniformMatroid:
    """Uniform matroid U(r, n): all r-subsets of {0, ..., n-1} are bases.

    Args:
        n: Size of ground set
        r: Rank (basis cardinality)
    """

    def __init__(self, n: int, r: int):
        if r > n or r < 0:
            raise ValueError(f"Invalid parameters: n={n}, r={r}")
        self.n = n
        self.r = r
        self.ground = frozenset(range(n))

    def bases(self) -> List[FrozenSet[int]]:
        """Enumerate all bases."""
        return [frozenset(s) for s in itertools.combinations(range(self.n), self.r)]

    def is_basis(self, B: FrozenSet[int]) -> bool:
        """Check if B is a basis."""
        return len(B) == self.r and B.issubset(self.ground)

    def exchange_neighbors(self, B: FrozenSet[int]) -> List[FrozenSet[int]]:
        """All single-swap neighbors of B that are also bases."""
        result = []
        for x in B:
            for y in self.ground - B:
                result.append((B - {x}) | {y})
        return result


def exchange_local_search(
    matroid: UniformMatroid,
    w: Callable[[FrozenSet[int]], float],
    start: FrozenSet[int],
    verbose: bool = False
) -> Tuple[FrozenSet[int], List[FrozenSet[int]]]:
    """Greedy exchange ascent algorithm.

    Starting from `start`, repeatedly performs the best-improving single swap
    until no improvement is possible (exchange-local maximum).

    Args:
        matroid: The uniform matroid
        w: Weight function to maximize
        start: Starting basis
        verbose: Print each step

    Returns:
        (local_max, trace): The local maximum and the sequence of bases visited

    Time complexity: O(|bases| * n * r) per step, at most |bases| steps
    Space complexity: O(n)
    """
    current = start
    trace = [current]

    while True:
        best_val = w(current)
        best_next = None

        for neighbor in matroid.exchange_neighbors(current):
            val = w(neighbor)
            if val > best_val:
                best_val = val
                best_next = neighbor

        if best_next is None:
            break

        if verbose:
            print(f"  {set(current)} -> {set(best_next)}, "
                  f"w: {w(current):.4f} -> {w(best_next):.4f}")
        current = best_next
        trace.append(current)

    return current, trace


def compute_exchange_constant(
    matroid: UniformMatroid,
    w: Callable[[FrozenSet[int]], float]
) -> float:
    """Compute the valuated exchange constant K.

    K is the maximum violation of the exact valuated exchange axiom:
        K = max_{B1, B2, x in B1\\B2} min_{y in B2\\B1}
            [w(B1) + w(B2) - w(swap(B1,x,y)) - w(swap(B2,y,x))]

    For additive weights, K = 0 exactly.

    Time complexity: O(|bases|^2 * n^2)
    """
    bases = matroid.bases()
    K = 0.0

    for B1 in bases:
        for B2 in bases:
            for x in B1 - B2:
                min_gap = float('inf')
                for y in B2 - B1:
                    B1_new = (B1 - {x}) | {y}
                    B2_new = (B2 - {y}) | {x}
                    gap = w(B1) + w(B2) - w(B1_new) - w(B2_new)
                    min_gap = min(min_gap, gap)
                if min_gap != float('inf'):
                    K = max(K, min_gap)

    return max(K, 0.0)


def verify_certified_bound(
    matroid: UniformMatroid,
    w: Callable[[FrozenSet[int]], float],
    K: float
) -> Tuple[bool, Optional[Dict]]:
    """Verify the certified approximation bound on all local maxima.

    For every exchange-local max B and every basis Y, checks:
        w(Y) <= w(B) + K * |Y \\ B|

    Returns (True, None) if verified, or (False, counterexample) if not.
    """
    bases = matroid.bases()

    for B in bases:
        if not all(w(nb) <= w(B) + 1e-12 for nb in matroid.exchange_neighbors(B)):
            continue  # Not a local max

        for Y in bases:
            d = len(Y - B)
            bound = w(B) + K * d
            if w(Y) > bound + 1e-10:
                return False, {
                    'B': set(B), 'Y': set(Y),
                    'w_B': w(B), 'w_Y': w(Y),
                    'distance': d, 'bound': bound,
                    'violation': w(Y) - bound
                }

    return True, None


def certified_optimization(
    matroid: UniformMatroid,
    w: Callable[[FrozenSet[int]], float],
    start: Optional[FrozenSet[int]] = None
) -> CertifiedSolution:
    """Complete certified optimization pipeline.

    1. Compute exchange constant K
    2. Run exchange local search
    3. Return solution with certified bound

    Args:
        matroid: The uniform matroid
        w: Weight function to maximize
        start: Starting basis (random if None)

    Returns:
        CertifiedSolution with guaranteed approximation quality
    """
    import random

    if start is None:
        start = frozenset(random.sample(range(matroid.n), matroid.r))

    K = compute_exchange_constant(matroid, w)
    local_max, trace = exchange_local_search(matroid, w, start)
    w_max = w(local_max)

    # Global bound: w(Y) <= w(B) + K * rank for all feasible Y
    global_bound = w_max + K * matroid.r

    return CertifiedSolution(
        basis=local_max,
        weight=w_max,
        global_bound=global_bound,
        exchange_constant=K,
        rank=matroid.r,
        is_exact=(K < 1e-12)
    )


def enumerate_local_maxima(
    matroid: UniformMatroid,
    w: Callable[[FrozenSet[int]], float]
) -> List[FrozenSet[int]]:
    """Find all exchange-local maxima by exhaustive enumeration.

    Time complexity: O(|bases| * n * r)
    """
    results = []
    for B in matroid.bases():
        is_max = True
        w_B = w(B)
        for nb in matroid.exchange_neighbors(B):
            if w(nb) > w_B + 1e-12:
                is_max = False
                break
        if is_max:
            results.append(B)
    return results


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    import random
    random.seed(42)

    # Create a uniform matroid U(3, 6)
    M = UniformMatroid(6, 3)
    wt = {i: random.uniform(1, 10) for i in range(6)}

    # Additive weight (K = 0)
    def w_add(B):
        return sum(wt[x] for x in B)

    print("=== Additive Weight (K = 0) ===")
    result = certified_optimization(M, w_add)
    print(f"Solution: {set(result.basis)}")
    print(f"Weight: {result.weight:.4f}")
    print(f"Exchange constant: {result.exchange_constant:.6f}")
    print(f"Exact: {result.is_exact}")
    print()

    # Quadratic weight (K > 0)
    def w_quad(B):
        return sum(wt[x] for x in B) ** 2

    print("=== Quadratic Weight (K > 0) ===")
    result = certified_optimization(M, w_quad)
    print(f"Solution: {set(result.basis)}")
    print(f"Weight: {result.weight:.4f}")
    print(f"Exchange constant: {result.exchange_constant:.4f}")
    print(f"Global bound: {result.global_bound:.4f}")
    print(f"Exact: {result.is_exact}")

    # Verify bound
    K = result.exchange_constant
    ok, cex = verify_certified_bound(M, w_quad, K)
    print(f"Bound verification: {'PASSED' if ok else 'FAILED'}")
