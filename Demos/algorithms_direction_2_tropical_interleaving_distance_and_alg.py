"""
Algorithms for Tropical Persistence Interleaving Distance

This module implements the core algorithms for computing tropical persistence
interleaving distances, barcode distances, and related quantities.

All algorithms operate on tropical persistence modules represented as
monotone integer-valued step functions on ℤ, stored as finite lists of
(position, value) pairs.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple, Optional
import itertools


@dataclass
class TropPersistMod:
    """A finite-type tropical persistence module.

    Represented by a monotone step function ℤ → ℤ that is constant
    outside [lo, hi]. The function equals val_lo for i ≤ lo and
    val_hi for i ≥ hi.

    Attributes:
        steps: Sorted list of (position, value) pairs defining the step function.
               The function equals steps[0][1] for i ≤ steps[0][0] and
               steps[-1][1] for i ≥ steps[-1][0].
    """
    steps: List[Tuple[int, int]]

    def __post_init__(self):
        self.steps = sorted(self.steps, key=lambda x: x[0])
        # Validate monotonicity
        for i in range(len(self.steps) - 1):
            assert self.steps[i][1] <= self.steps[i + 1][1], \
                f"Not monotone at positions {self.steps[i]} -> {self.steps[i+1]}"

    def val(self, i: int) -> int:
        """Evaluate the module at position i."""
        if not self.steps:
            return 0
        if i <= self.steps[0][0]:
            return self.steps[0][1]
        if i >= self.steps[-1][0]:
            return self.steps[-1][1]
        # Binary search for the right interval
        lo, hi = 0, len(self.steps) - 1
        while lo < hi:
            mid = (lo + hi + 1) // 2
            if self.steps[mid][0] <= i:
                lo = mid
            else:
                hi = mid - 1
        return self.steps[lo][1]

    @property
    def support_lo(self) -> int:
        return self.steps[0][0] if self.steps else 0

    @property
    def support_hi(self) -> int:
        return self.steps[-1][0] if self.steps else 0

    def total_variation(self) -> int:
        """Total variation = val(hi) - val(lo)."""
        if not self.steps:
            return 0
        return self.steps[-1][1] - self.steps[0][1]

    def local_variation_bound(self) -> int:
        """Maximum single-step variation."""
        if len(self.steps) <= 1:
            return 0
        max_var = 0
        for i in range(len(self.steps) - 1):
            gap = self.steps[i + 1][0] - self.steps[i][0]
            val_diff = self.steps[i + 1][1] - self.steps[i][1]
            if gap > 0:
                # Per-unit variation
                max_var = max(max_var, val_diff)  # conservative: total jump
            else:
                max_var = max(max_var, val_diff)
        return max_var


def step_module(k: int) -> TropPersistMod:
    """Create a step module: 0 for i ≤ k, 1 for i > k.

    This is the tropical analogue of an interval module.
    """
    return TropPersistMod([(k, 0), (k + 1, 1)])


def is_delta_interleaved(delta: int, M: TropPersistMod, N: TropPersistMod,
                          lo: Optional[int] = None, hi: Optional[int] = None) -> bool:
    """Check if M and N are δ-interleaved on [lo, hi].

    For finite-type modules, it suffices to check on a bounded range.
    Default range: [min(supports) - delta, max(supports) + delta].

    Time complexity: O((hi - lo) * log(n)) where n = max step count.
    Space complexity: O(1) beyond input.

    Args:
        delta: The interleaving parameter (non-negative integer).
        M, N: Tropical persistence modules.
        lo, hi: Range to check (auto-computed if None).

    Returns:
        True if M and N are δ-interleaved on the given range.
    """
    if lo is None:
        lo = min(M.support_lo, N.support_lo) - delta - 1
    if hi is None:
        hi = max(M.support_hi, N.support_hi) + delta + 1

    for i in range(lo, hi + 1):
        if M.val(i) > N.val(i + delta):
            return False
        if N.val(i) > M.val(i + delta):
            return False
    return True


def compute_interleaving_distance(M: TropPersistMod, N: TropPersistMod,
                                   max_delta: Optional[int] = None) -> int:
    """Compute the exact interleaving distance between M and N.

    Uses binary search over δ values. For finite-type modules, the
    distance is at most max(support ranges).

    Time complexity: O(log(D) * R) where D = max distance, R = support range.
    Space complexity: O(1) beyond input.

    Args:
        M, N: Tropical persistence modules.
        max_delta: Upper bound on search (auto-computed if None).

    Returns:
        The exact interleaving distance (smallest δ with δ-interleaving).
        Returns -1 if no interleaving exists up to max_delta.
    """
    if max_delta is None:
        max_delta = max(M.support_hi, N.support_hi) - min(M.support_lo, N.support_lo) + 2

    # Binary search for smallest δ
    lo, hi = 0, max_delta
    if not is_delta_interleaved(hi, M, N):
        return -1  # No finite interleaving found

    while lo < hi:
        mid = (lo + hi) // 2
        if is_delta_interleaved(mid, M, N):
            hi = mid
        else:
            lo = mid + 1
    return lo


def pointwise_distance(M: TropPersistMod, N: TropPersistMod,
                        lo: Optional[int] = None, hi: Optional[int] = None) -> int:
    """Compute the pointwise sup distance: max_i |M(i) - N(i)|.

    Time complexity: O(R * log(n)) where R = range, n = max step count.

    Args:
        M, N: Tropical persistence modules.
        lo, hi: Range to check.

    Returns:
        The maximum pointwise absolute difference.
    """
    if lo is None:
        lo = min(M.support_lo, N.support_lo) - 1
    if hi is None:
        hi = max(M.support_hi, N.support_hi) + 1

    max_diff = 0
    for i in range(lo, hi + 1):
        diff = abs(M.val(i) - N.val(i))
        max_diff = max(max_diff, diff)
    return max_diff


def compute_barcode_distance(M: TropPersistMod, N: TropPersistMod) -> int:
    """Compute the tropical barcode distance (pointwise sup distance).

    This is the sup-norm distance between the rank functions,
    which serves as a natural barcode distance analogue.
    """
    return pointwise_distance(M, N)


# --- Graph-based tropical persistence ---

@dataclass
class SimpleGraph:
    """A simple undirected graph with integer vertex labels."""
    n: int  # number of vertices (labeled 0..n-1)
    edges: List[Tuple[int, int]]

    def degree(self, v: int) -> int:
        """Degree of vertex v."""
        return sum(1 for u, w in self.edges if u == v or w == v)

    def neighbors(self, v: int) -> List[int]:
        """List of neighbors of v."""
        nbrs = []
        for u, w in self.edges:
            if u == v:
                nbrs.append(w)
            elif w == v:
                nbrs.append(u)
        return nbrs


def graph_tpm(G: SimpleGraph, f: List[int]) -> TropPersistMod:
    """Construct a tropical persistence module from a graph filtration.

    The module value at index t is the cumulative sum of (degree(v) + 1)
    for all vertices v with f[v] ≤ t.

    Args:
        G: A simple graph.
        f: Integer filtration values for each vertex.

    Returns:
        The associated tropical persistence module.
    """
    events = sorted(range(G.n), key=lambda v: f[v])
    steps = []
    cumulative = 0

    # Group vertices by filtration value
    i = 0
    while i < len(events):
        t = f[events[i]]
        while i < len(events) and f[events[i]] == t:
            v = events[i]
            cumulative += G.degree(v) + 1
            i += 1
        steps.append((t, cumulative))

    # Add a base step before the first event
    if steps:
        steps = [(steps[0][0] - 1, 0)] + steps

    return TropPersistMod(steps)


def verify_graph_stability(G: SimpleGraph, f: List[int], g: List[int]) -> dict:
    """Verify the graph perturbation stability theorem computationally.

    Args:
        G: A simple graph.
        f, g: Two integer filtration functions.

    Returns:
        Dictionary with perturbation bound δ, actual interleaving distance,
        and verification status.
    """
    delta = max(abs(f[v] - g[v]) for v in range(G.n))
    M = graph_tpm(G, f)
    N = graph_tpm(G, g)
    d_I = compute_interleaving_distance(M, N)

    return {
        'perturbation_bound': delta,
        'interleaving_distance': d_I,
        'stable': d_I <= delta,
        'module_M': M,
        'module_N': N,
    }


if __name__ == "__main__":
    # Quick verification
    M = step_module(0)
    N = step_module(2)
    d_I = compute_interleaving_distance(M, N)
    d_B = compute_barcode_distance(M, N)
    print(f"Step modules at 0 and 2:")
    print(f"  Interleaving distance: {d_I}")
    print(f"  Barcode distance: {d_B}")
    print(f"  Strict gap: {d_B} < {d_I} = {d_B < d_I}")
