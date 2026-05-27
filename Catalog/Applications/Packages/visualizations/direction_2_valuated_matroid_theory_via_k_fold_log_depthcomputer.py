#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for directional depth computation

Implements:
1. DepthComputer: compute or lower-bound directional depth on finite degree slices
2. DepthFailureChecker: check for failure of depth at level k
3. ExactDepthSearcher: search for exact-depth examples among small valuations
4. MixedLogConcavityChecker: verify mixed log-concavity

All algorithms are tied to the formal definitions in the Lean development.
"""

from typing import Callable, Dict, List, Optional, Tuple
from itertools import product as iter_product
from math import log, exp
import time


def unit_vec(n: int, i: int) -> Tuple[int, ...]:
    """Standard basis vector e_i in Z^n."""
    return tuple(1 if j == i else 0 for j in range(n))


def add_tuples(*tuples: Tuple[int, ...]) -> Tuple[int, ...]:
    """Pointwise addition of tuples."""
    return tuple(sum(x) for x in zip(*tuples))


def multiindices(n: int, max_deg: int) -> List[Tuple[int, ...]]:
    """All multiindices m in {0,...,max_deg}^n."""
    return list(iter_product(range(max_deg + 1), repeat=n))


def degree_slice(n: int, d: int, max_coord: int = None) -> List[Tuple[int, ...]]:
    """All multiindices with total degree exactly d."""
    if max_coord is None:
        max_coord = d
    return [m for m in multiindices(n, max_coord) if sum(m) == d]


class DepthComputer:
    """
    Algorithm 1: Compute the directional depth of a function f : Z^n_≥0 → R.

    Time complexity: O(k · n · M^n) per level, where
      - k = target depth
      - n = number of variables
      - M = max_deg (truncation parameter)

    Space complexity: O(n^k · M^n) for storing ratio transforms.

    The algorithm works by iteratively computing ratio transforms and
    checking directional log-concavity at each level.
    """

    def __init__(self, f: Callable, n: int, max_deg: int = 10):
        self.f = f
        self.n = n
        self.max_deg = max_deg
        self._cache: Dict[Tuple, float] = {}

    def _eval(self, f: Callable, m: Tuple[int, ...]) -> float:
        """Evaluate f at m with caching."""
        key = (id(f), m)
        if key not in self._cache:
            self._cache[key] = f(m)
        return self._cache[key]

    def is_dir_log_concave(self, f: Callable) -> bool:
        """
        Check directional log-concavity:
        f(m + e_i)^2 >= f(m) * f(m + 2*e_i) for all m, i.

        Returns True if the condition holds on the truncated domain.
        """
        for m in multiindices(self.n, self.max_deg):
            for i in range(self.n):
                ei = unit_vec(self.n, i)
                fm = f(m)
                fm1 = f(add_tuples(m, ei))
                fm2 = f(add_tuples(m, ei, ei))
                if fm1 ** 2 < fm * fm2 - 1e-12:
                    return False
        return True

    def ratio_transform(self, f: Callable, i: int) -> Callable:
        """Compute R_i f(m) = f(m + e_i) / f(m)."""
        ei = unit_vec(self.n, i)
        def Rf(m: Tuple[int, ...]) -> float:
            fm = f(m)
            if abs(fm) < 1e-15:
                return 0.0
            return f(add_tuples(m, ei)) / fm
        return Rf

    def compute(self, max_depth: int = 10) -> int:
        """
        Compute the directional depth of self.f.

        Algorithm:
        1. Start with the set of functions S = {f}
        2. For each level k = 0, 1, 2, ...:
           a. Check all functions in S for directional log-concavity
           b. If any fails, return k
           c. Otherwise, compute S' = {R_i(g) : g in S, i in [n]}
           d. Replace S with S'
        3. Return max_depth if no failure found

        Returns: depth (integer), where depth >= return value.
        """
        current_level = [self.f]
        for k in range(max_depth):
            for fn in current_level:
                if not self.is_dir_log_concave(fn):
                    return k
            next_level = []
            for fn in current_level:
                for i in range(self.n):
                    next_level.append(self.ratio_transform(fn, i))
            current_level = next_level
        return max_depth


class DepthFailureChecker:
    """
    Algorithm 2: Find the exact point and direction where depth fails.

    Given f and target depth k, this finds the first (m, i, j) triple
    where the k-th iterated ratio transform fails log-concavity.

    Time complexity: O(k · n · M^n)
    """

    def __init__(self, f: Callable, n: int, max_deg: int = 8):
        self.f = f
        self.n = n
        self.max_deg = max_deg

    def check_at_level(self, level: int) -> Optional[Dict]:
        """
        Check for failure at a specific depth level.

        Returns None if no failure found, or a dict with failure details.
        """
        # Build the chain of ratio transforms up to this level
        transform_chains = self._build_chains(level)

        for chain, fn in transform_chains:
            for m in multiindices(self.n, self.max_deg):
                for j in range(self.n):
                    ej = unit_vec(self.n, j)
                    fm = fn(m)
                    fm1 = fn(add_tuples(m, ej))
                    fm2 = fn(add_tuples(m, ej, ej))
                    violation = fm1**2 - fm * fm2
                    if violation < -1e-12:
                        return {
                            "level": level,
                            "transform_chain": chain,
                            "direction": j,
                            "multiindex": m,
                            "values": (fm, fm1, fm2),
                            "violation": violation
                        }
        return None

    def _build_chains(self, level: int) -> List[Tuple[List[int], Callable]]:
        """Build all ratio transform chains up to given level."""
        if level == 0:
            return [([], self.f)]

        parent_chains = self._build_chains(level - 1)
        result = []
        for chain, fn in parent_chains:
            for i in range(self.n):
                ei = unit_vec(self.n, i)
                def make_ratio(f, e):
                    def Rf(m):
                        fm = f(m)
                        if abs(fm) < 1e-15:
                            return 0.0
                        return f(add_tuples(m, e)) / fm
                    return Rf
                result.append((chain + [i], make_ratio(fn, ei)))
        return result

    def find_first_failure(self, max_level: int = 5) -> Optional[Dict]:
        """Find the first level where depth fails."""
        for level in range(max_level + 1):
            result = self.check_at_level(level)
            if result is not None:
                return result
        return None


class MixedLogConcavityChecker:
    """
    Algorithm 3: Check mixed log-concavity.

    Verifies: f(m + e_i) * f(m + e_j) >= f(m) * f(m + e_i + e_j)
    for all m, i, j.

    This is the condition needed for -log f to be supermodular
    (the tropical bridge theorem).
    """

    def __init__(self, f: Callable, n: int, max_deg: int = 8):
        self.f = f
        self.n = n
        self.max_deg = max_deg

    def check(self) -> Tuple[bool, Optional[Dict]]:
        """
        Check mixed log-concavity.

        Returns (True, None) if satisfied, or (False, failure_details).
        """
        for m in multiindices(self.n, self.max_deg):
            for i in range(self.n):
                for j in range(self.n):
                    ei = unit_vec(self.n, i)
                    ej = unit_vec(self.n, j)
                    fi = self.f(add_tuples(m, ei))
                    fj = self.f(add_tuples(m, ej))
                    fm = self.f(m)
                    fij = self.f(add_tuples(m, ei, ej))

                    if fi * fj < fm * fij - 1e-12:
                        return False, {
                            "multiindex": m,
                            "directions": (i, j),
                            "values": {
                                "f(m+e_i)": fi,
                                "f(m+e_j)": fj,
                                "f(m)": fm,
                                "f(m+e_i+e_j)": fij
                            },
                            "violation": fi * fj - fm * fij
                        }
        return True, None


class ExactDepthSearcher:
    """
    Algorithm 4: Search for functions with exact depth k.

    Searches over polynomial coefficient vectors to find functions
    with a specific depth. Uses a grid search over coefficient space.

    This is the key tool for testing the Depth Dichotomy Conjecture.
    """

    def __init__(self, n: int = 1, max_deg: int = 6):
        self.n = n
        self.max_deg = max_deg

    def search_1d(self, target_depth: int, num_coeffs: int = 5,
                  grid_values: List[float] = None) -> List[Tuple[List[float], int]]:
        """
        Search for 1D functions with exact depth = target_depth.

        Args:
            target_depth: desired exact depth
            num_coeffs: number of coefficients in the polynomial
            grid_values: values to try for each coefficient

        Returns: list of (coefficient_vector, depth) pairs matching target.
        """
        if grid_values is None:
            grid_values = [0.5, 1.0, 2.0, 3.0, 4.0, 5.0]

        results = []

        def make_f(coeffs):
            def f(m):
                idx = m[0]
                if 0 <= idx < len(coeffs):
                    return coeffs[idx]
                return 0.0
            return f

        computer = DepthComputer(None, 1, self.max_deg)

        # Only search over first few coefficients to keep tractable
        count = 0
        for combo in iter_product(grid_values, repeat=min(num_coeffs, 4)):
            coeffs = list(combo) + [0.0] * max(0, num_coeffs - 4)
            f = make_f(coeffs)
            computer.f = f
            computer._cache.clear()

            d = computer.compute(max_depth=target_depth + 2)
            if d == target_depth:
                results.append((coeffs[:num_coeffs], d))
                count += 1
                if count >= 20:  # Limit results
                    break

        return results


# ============================================================
# Example usage and self-test
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHMS FOR DIRECTIONAL DEPTH COMPUTATION")
    print("=" * 60)
    print()

    # Example 1: Depth computation
    print("--- Algorithm 1: DepthComputer ---")
    f_geom = lambda m: 2.0 ** m[0]
    dc = DepthComputer(f_geom, 1, max_deg=8)
    depth = dc.compute(max_depth=8)
    print(f"  Geometric 2^n: depth >= {depth}")

    f_strict = lambda m: [1.0, 3.0, 2.0, 1.0, 0.0][min(m[0], 4)]
    dc2 = DepthComputer(f_strict, 1, max_deg=6)
    depth2 = dc2.compute(max_depth=6)
    print(f"  [1,3,2,1]: depth = {depth2}")
    print()

    # Example 2: Failure analysis
    print("--- Algorithm 2: DepthFailureChecker ---")
    dfc = DepthFailureChecker(f_strict, 1, max_deg=6)
    failure = dfc.find_first_failure(max_level=3)
    if failure:
        print(f"  Failure at level {failure['level']}")
        print(f"  Transform chain: {failure['transform_chain']}")
        print(f"  Direction: {failure['direction']}")
        print(f"  At m = {failure['multiindex']}")
        print(f"  Values: {failure['values']}")
        print(f"  Violation: {failure['violation']:.6e}")
    print()

    # Example 3: Mixed log-concavity
    print("--- Algorithm 3: MixedLogConcavityChecker ---")
    f_2d = lambda m: exp(-m[0]**2 - m[1]**2)
    mlc = MixedLogConcavityChecker(f_2d, 2, max_deg=5)
    ok, details = mlc.check()
    print(f"  Gaussian exp(-x^2-y^2): mixed LC = {ok}")

    f_2d_bad = lambda m: max(1.0, m[0]) * max(1.0, m[1])
    mlc2 = MixedLogConcavityChecker(f_2d_bad, 2, max_deg=4)
    ok2, details2 = mlc2.check()
    print(f"  max(1,x)*max(1,y): mixed LC = {ok2}")
    print()

    # Example 4: Exact depth search
    print("--- Algorithm 4: ExactDepthSearcher ---")
    searcher = ExactDepthSearcher(n=1, max_deg=6)
    print("  Searching for depth-exactly-1 functions...")
    t0 = time.time()
    results = searcher.search_1d(target_depth=1, num_coeffs=4,
                                  grid_values=[1.0, 2.0, 3.0, 4.0])
    t1 = time.time()
    print(f"  Found {len(results)} examples in {t1-t0:.2f}s")
    for coeffs, d in results[:5]:
        print(f"    coeffs={coeffs}, depth={d}")

    print()
    print("  Searching for depth-exactly-2 functions (testing dichotomy)...")
    t0 = time.time()
    results2 = searcher.search_1d(target_depth=2, num_coeffs=4,
                                   grid_values=[1.0, 2.0, 3.0, 4.0, 5.0])
    t1 = time.time()
    print(f"  Found {len(results2)} examples in {t1-t0:.2f}s")
    if results2:
        for coeffs, d in results2[:5]:
            print(f"    coeffs={coeffs}, depth={d}")
    else:
        print("  No depth-2 examples found — consistent with Dichotomy Conjecture!")
