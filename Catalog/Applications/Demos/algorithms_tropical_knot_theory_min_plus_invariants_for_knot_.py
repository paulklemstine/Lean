#!/usr/bin/env python3
"""
Tropical Knot Theory: Algorithms

Implements the core algorithms for tropical knot invariant computation:
1. Tropical Jones invariant via dynamic programming
2. Tropical span computation
3. Simplification with termination guarantee
4. State-profile comparison for separation detection
"""

from typing import Dict, List, Optional, Set, Tuple
from dataclasses import dataclass
from enum import Enum
import time

INF = float('inf')


class Resolution(Enum):
    A = "A"
    B = "B"


@dataclass
class TropLaurent:
    """A tropical Laurent polynomial: finite-support function ℤ → ℤ ∪ {∞}.

    Stored as a dict from degree to value. Missing keys have value ∞ (tropical zero).

    Time complexity:
        - Access: O(1) amortized
        - Tropical add (pointwise min): O(|supp(f)| + |supp(g)|)
        - Tropical span: O(|supp|)
    """
    coeffs: Dict[int, float]

    @staticmethod
    def zero() -> 'TropLaurent':
        """Tropical zero: ⊤ everywhere (empty support)."""
        return TropLaurent({})

    @staticmethod
    def monomial(degree: int, value: float = 0.0) -> 'TropLaurent':
        """Tropical monomial: value at given degree, ⊤ elsewhere."""
        return TropLaurent({degree: value})

    def __call__(self, n: int) -> float:
        """Evaluate at degree n."""
        return self.coeffs.get(n, INF)

    def trop_add(self, other: 'TropLaurent') -> 'TropLaurent':
        """Tropical addition: pointwise minimum.

        Time: O(|supp(self)| + |supp(other)|)
        """
        result = dict(self.coeffs)
        for k, v in other.coeffs.items():
            if k in result:
                result[k] = min(result[k], v)
            else:
                result[k] = v
        return TropLaurent(result)

    def scalar_add(self, c: float) -> 'TropLaurent':
        """Add scalar c to all coefficients (tropical scalar multiplication).

        Time: O(|supp|)
        """
        if c == INF:
            return TropLaurent.zero()
        return TropLaurent({k: v + c for k, v in self.coeffs.items()})

    def shift(self, d: int) -> 'TropLaurent':
        """Shift all degrees by d (multiply by tropical monomial t^d).

        Time: O(|supp|)
        """
        return TropLaurent({k + d: v for k, v in self.coeffs.items()})

    @property
    def support(self) -> Set[int]:
        """Degrees with finite value."""
        return set(self.coeffs.keys())

    @property
    def tropical_span(self) -> int:
        """Width of support: max(support) - min(support).

        Returns 0 for empty or singleton support.
        Time: O(|supp|)
        """
        if len(self.coeffs) <= 1:
            return 0
        return max(self.coeffs.keys()) - min(self.coeffs.keys())

    @property
    def min_value(self) -> float:
        """Minimum value across all degrees (tropical total cost)."""
        if not self.coeffs:
            return INF
        return min(self.coeffs.values())

    def __repr__(self):
        if not self.coeffs:
            return "⊤"
        terms = sorted(self.coeffs.items())
        parts = [f"t^{k}↦{v}" for k, v in terms]
        return "{" + ", ".join(parts) + "}"

    def __eq__(self, other):
        if not isinstance(other, TropLaurent):
            return False
        all_keys = self.support | other.support
        return all(self(k) == other(k) for k in all_keys)


class KnotDiagram:
    """Combinatorial knot diagram with recursive crossing structure.

    Attributes:
        is_loop: True if this is an unknotted loop
        wA, wB: crossing weights for A and B resolutions
        left, right: sub-diagrams (D0, D1)
    """

    def __init__(self, wA=None, wB=None, left=None, right=None, name=""):
        self.is_loop = (wA is None)
        self.wA = wA
        self.wB = wB
        self.left = left
        self.right = right
        self.name = name
        self._cache: Dict[int, float] = {}

    @staticmethod
    def loop(name: str = "") -> 'KnotDiagram':
        return KnotDiagram(name=name or "○")

    @staticmethod
    def crossing(wA: int, wB: int, D0: 'KnotDiagram', D1: 'KnotDiagram',
                 name: str = "") -> 'KnotDiagram':
        return KnotDiagram(wA=wA, wB=wB, left=D0, right=D1, name=name)

    @property
    def num_crossings(self) -> int:
        if self.is_loop:
            return 0
        return 1 + self.left.num_crossings + self.right.num_crossings

    def tJones_value(self, n: int) -> float:
        """Compute tJones(D, n) with memoization.

        Time complexity: O(c) per query with memoization, O(2^c) worst case without.
        Space: O(c) for memoization cache.

        Algorithm: Dynamic programming on the skein tree.
        """
        if n in self._cache:
            return self._cache[n]

        if self.is_loop:
            result = 0.0 if n == 0 else INF
        else:
            val_A = self.wA + self.left.tJones_value(n - 1)
            val_B = self.wB + self.right.tJones_value(n + 1)
            result = min(val_A, val_B)

        self._cache[n] = result
        return result

    def tJones(self) -> TropLaurent:
        """Compute the full tropical Jones polynomial.

        Time: O(c · 2c) where c = num_crossings
        Space: O(c) for the result
        """
        c = self.num_crossings
        coeffs = {}
        for n in range(-c, c + 1):
            v = self.tJones_value(n)
            if v < INF:
                coeffs[n] = v
        return TropLaurent(coeffs)

    def clear_cache(self):
        """Clear memoization cache (call after structural modifications)."""
        self._cache.clear()
        if not self.is_loop:
            self.left.clear_cache()
            self.right.clear_cache()


def compute_tropical_jones(D: KnotDiagram) -> TropLaurent:
    """Compute the tropical Jones polynomial of a knot diagram.

    Algorithm: Bottom-up dynamic programming on the skein tree.

    Pseudocode:
        function TROPICAL_JONES(D):
            if D is a loop:
                return monomial(degree=0, value=0)
            else:
                fA ← TROPICAL_JONES(D.left)
                fB ← TROPICAL_JONES(D.right)
                // Shift and weight each resolution
                gA ← shift(fA, +1).scalar_add(D.wA)   // A-resolution shifts degree by +1
                gB ← shift(fB, -1).scalar_add(D.wB)   // B-resolution shifts degree by -1
                return trop_add(gA, gB)                  // Take pointwise min

    Time: O(c² · 2c) total, O(c) per level
    Space: O(c) for the polynomial at each level

    Args:
        D: A KnotDiagram

    Returns:
        The tropical Jones polynomial as a TropLaurent
    """
    if D.is_loop:
        return TropLaurent.monomial(0, 0.0)

    fA = compute_tropical_jones(D.left)
    fB = compute_tropical_jones(D.right)

    # A-resolution: shift by +1, add weight wA
    gA = fA.shift(1).scalar_add(D.wA)
    # B-resolution: shift by -1, add weight wB
    gB = fB.shift(-1).scalar_add(D.wB)

    return gA.trop_add(gB)


def simplify_diagram(D: KnotDiagram, strategy: str = "greedy") -> List[Tuple[str, KnotDiagram]]:
    """Simplify a knot diagram by resolving crossings.

    Guaranteed to terminate (number of crossings strictly decreases at each step).

    Strategies:
        - "greedy": always resolve the crossing that minimizes tropical cost
        - "A": always take A-resolution
        - "B": always take B-resolution

    Args:
        D: Initial diagram
        strategy: Resolution strategy

    Returns:
        List of (resolution_type, resulting_diagram) pairs
    """
    history = [("start", D)]

    current = D
    while not current.is_loop:
        if strategy == "A":
            current = current.left
            history.append(("A", current))
        elif strategy == "B":
            current = current.right
            history.append(("B", current))
        elif strategy == "greedy":
            fA = compute_tropical_jones(current.left)
            fB = compute_tropical_jones(current.right)
            # Choose resolution with lower minimum tropical cost
            if fA.min_value <= fB.min_value:
                current = current.left
                history.append(("A", current))
            else:
                current = current.right
                history.append(("B", current))

    return history


def detect_separation(D1: KnotDiagram, D2: KnotDiagram) -> Optional[List[int]]:
    """Detect tropical separation between two diagrams.

    If the tropical Jones polynomials differ, returns the separating degrees.
    Otherwise returns None.

    This implements the separation schema theorem:
    if tropicalStateProfile(D1) ≠ tropicalStateProfile(D2),
    then differentTropicalJones(D1, D2).

    Time: O(max(c1, c2)²) where c1, c2 are crossing numbers
    Space: O(max(c1, c2))

    Args:
        D1, D2: Knot diagrams to compare

    Returns:
        List of separating degrees, or None if profiles match
    """
    f1 = compute_tropical_jones(D1)
    f2 = compute_tropical_jones(D2)

    all_degrees = f1.support | f2.support
    separating = [n for n in sorted(all_degrees) if f1(n) != f2(n)]

    return separating if separating else None


def state_dag_analysis(D: KnotDiagram) -> Dict:
    """Analyze the state-sum DAG structure of a knot diagram.

    Returns statistics about the computation DAG:
    - Number of states (complete resolutions)
    - DAG depth
    - Tropical span
    - Optimal paths for each degree

    Time: O(2^c) for complete enumeration
    Space: O(c) for path storage
    """
    states = []

    def enumerate_states(d: KnotDiagram, weight: int, shift: int, path: str):
        if d.is_loop:
            states.append({
                "weight": weight,
                "degree": shift,
                "path": path,
            })
            return
        enumerate_states(d.left, weight + d.wA, shift - 1, path + "A")
        enumerate_states(d.right, weight + d.wB, shift + 1, path + "B")

    enumerate_states(D, 0, 0, "")

    # Group by degree, find minimum weight for each
    degree_costs: Dict[int, List] = {}
    for s in states:
        deg = s["degree"]
        if deg not in degree_costs:
            degree_costs[deg] = []
        degree_costs[deg].append(s)

    optimal_paths = {}
    for deg, state_list in sorted(degree_costs.items()):
        best = min(state_list, key=lambda s: s["weight"])
        optimal_paths[deg] = best

    f = compute_tropical_jones(D)

    return {
        "num_crossings": D.num_crossings,
        "num_states": len(states),
        "dag_depth": D.num_crossings,
        "tropical_span": f.tropical_span,
        "optimal_paths": optimal_paths,
        "tropical_jones": f,
    }


def benchmark_computation(max_crossings: int = 15) -> List[Dict]:
    """Benchmark tropical Jones computation for increasing diagram sizes.

    Builds chain diagrams with 1 to max_crossings crossings and measures
    computation time and tropical span.
    """
    results = []
    for k in range(1, max_crossings + 1):
        D = KnotDiagram.loop()
        for _ in range(k):
            D = KnotDiagram.crossing(1, 1, D, KnotDiagram.loop())

        t0 = time.time()
        f = compute_tropical_jones(D)
        elapsed = time.time() - t0

        results.append({
            "crossings": k,
            "support_size": len(f.support),
            "tropical_span": f.tropical_span,
            "min_value": f.min_value,
            "computation_time_ms": elapsed * 1000,
        })

    return results


if __name__ == "__main__":
    print("Tropical Jones Computation Benchmark")
    print("=" * 60)
    results = benchmark_computation(15)
    print(f"{'c':>4s} | {'|supp|':>6s} | {'span':>5s} | {'min_val':>8s} | {'time(ms)':>10s}")
    print("-" * 45)
    for r in results:
        print(f"{r['crossings']:4d} | {r['support_size']:6d} | {r['tropical_span']:5d} | "
              f"{r['min_value']:8.1f} | {r['computation_time_ms']:10.3f}")

    print("\n\nState DAG Analysis (4-crossing chain)")
    print("=" * 60)
    D = KnotDiagram.loop()
    for _ in range(4):
        D = KnotDiagram.crossing(1, 1, D, KnotDiagram.loop())
    analysis = state_dag_analysis(D)
    print(f"Crossings: {analysis['num_crossings']}")
    print(f"Total states: {analysis['num_states']}")
    print(f"DAG depth: {analysis['dag_depth']}")
    print(f"Tropical span: {analysis['tropical_span']}")
    print(f"Tropical Jones: {analysis['tropical_jones']}")
    print("\nOptimal paths:")
    for deg, info in sorted(analysis['optimal_paths'].items()):
        print(f"  degree {deg:+d}: weight={info['weight']}, path={info['path']}")
