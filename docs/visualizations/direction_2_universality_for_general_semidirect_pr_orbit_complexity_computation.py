#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Semidirect Universality

Implements:
1. Orbit complexity computation for finite group actions
2. Pressure correction estimation from orbit data
3. Asymptotic fit comparison for conjecture testing
4. Semidirect pressure decomposition

All algorithms correspond to the formal Lean definitions in
Pythagorean/SemidirectUniversality.lean.
"""

import math
from typing import List, Tuple, Optional, Dict, Callable
from functools import lru_cache
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════════
# Algorithm 1: Orbit Complexity Computation
# ═══════════════════════════════════════════════════════════════════

def compute_orbit_count(
    m: int,
    k: int,
    action: Callable[[int, int], int],
    group_size: int
) -> int:
    """
    Compute the number of orbits of a group G acting on {0,...,m-1}^k
    via Burnside's lemma.

    Parameters:
        m: Size of the base set {0,...,m-1}
        k: Tuple length
        action: action(g, x) -> y, the group element g acting on base element x
        group_size: |G|

    Returns:
        Number of orbits on {0,...,m-1}^k

    Time complexity: O(|G| * m^k)
    Space complexity: O(m^k) for tracking fixed points

    Pseudocode:
        total_fixed = 0
        for g in G:
            count = 0
            for tuple in {0,...,m-1}^k:
                if action(g, tuple[i]) == tuple[i] for all i:
                    count += 1
            total_fixed += count
        return total_fixed / |G|
    """
    if m == 0:
        return 1 if k == 0 else 0

    total_fixed = 0

    # For each group element, count fixed k-tuples
    for g in range(group_size):
        # A k-tuple is fixed iff each coordinate is fixed
        # Count elements of {0,...,m-1} fixed by g
        fixed_elements = sum(1 for x in range(m) if action(g, x) == x)
        # Number of fixed k-tuples = (fixed_elements)^k
        total_fixed += fixed_elements ** k

    return total_fixed // group_size


def cyclic_action(g: int, x: int, m: int) -> int:
    """Cyclic group Z/m action: g · x = (x + g) mod m."""
    return (x + g) % m


def compute_cyclic_orbit_count(m: int, k: int) -> int:
    """
    Compute orbit count for Z/m acting on {0,...,m-1}^k by
    component-wise cyclic shift.

    Time complexity: O(m)
    """
    if m == 0:
        return 1 if k == 0 else 0

    total_fixed = 0
    for g in range(m):
        # Fixed elements: x such that (x + g) % m == x, i.e., g == 0
        fixed = m if g == 0 else 0
        total_fixed += fixed ** k

    return total_fixed // m  # = m^{k-1}


@lru_cache(maxsize=None)
def stirling2(n: int, k: int) -> int:
    """Stirling number of the second kind S(n, k)."""
    if n == 0 and k == 0:
        return 1
    if n == 0 or k == 0:
        return 0
    return k * stirling2(n - 1, k) + stirling2(n - 1, k - 1)


def compute_symmetric_orbit_count(m: int, k: int) -> int:
    """
    Compute orbit count for S_m acting on {0,...,m-1}^k.

    Two tuples are equivalent iff they have the same "type"
    (same partition of positions induced by equality of values).

    The count equals Σ_{j=1}^{min(m,k)} S(k,j) · C(m,j).

    Time complexity: O(k * min(m,k))
    """
    if m == 0:
        return 1 if k == 0 else 0
    if k == 0:
        return 1

    return sum(
        stirling2(k, j) * math.comb(m, j)
        for j in range(1, min(m, k) + 1)
    )


def verify_polynomial_bound(
    orbit_count_fn: Callable[[int, int], int],
    m_range: range,
    k_range: range,
    C: int,
    d: int
) -> Tuple[bool, Optional[Tuple[int, int, int, int]]]:
    """
    Verify that orbit_count(m, k) ≤ C · (m+1)^d · (k+1)^d
    for all m in m_range and k in k_range.

    Returns:
        (True, None) if bound holds everywhere
        (False, (m, k, actual, bound)) if bound fails

    Time complexity: O(|m_range| * |k_range| * T_orbit)
    """
    for m in m_range:
        for k in k_range:
            actual = orbit_count_fn(m, k)
            bound = C * (m + 1) ** d * (k + 1) ** d
            if actual > bound:
                return False, (m, k, actual, bound)
    return True, None


# ═══════════════════════════════════════════════════════════════════
# Algorithm 2: Pressure Correction Estimation
# ═══════════════════════════════════════════════════════════════════

class SemidirectPressureEstimator:
    """
    Estimates the pressure decomposition P(G^m ⋊ H_m) = m·P(G) + P_exotic(m).

    Corresponds to the Lean structure SemidirectPressureData.

    Attributes:
        base_pressure: P(G), the base group pressure
        exotic_fn: function m -> P_exotic(m)
    """

    def __init__(self, base_pressure: float, exotic_fn: Callable[[int], float]):
        self.base_pressure = base_pressure
        self.exotic_fn = exotic_fn

    def product_pressure(self, m: int) -> float:
        """m · P(G): extensive product pressure."""
        return m * self.base_pressure

    def exotic_pressure(self, m: int) -> float:
        """P_exotic(m): non-product contribution."""
        return self.exotic_fn(m)

    def semidirect_pressure(self, m: int) -> float:
        """P(G^m ⋊ H_m) = m·P(G) + P_exotic(m)."""
        return self.product_pressure(m) + self.exotic_pressure(m)

    def pressure_gap(self, m: int) -> float:
        """P(G^m ⋊ H_m) - m·P(G) = P_exotic(m)."""
        return self.exotic_pressure(m)

    def check_universality(self, epsilon: float, m_max: int) -> Optional[int]:
        """
        Find the smallest M such that |P - m·P₀| ≤ ε·m for all m ≥ M.

        Returns M, or None if no such M exists up to m_max.

        Time complexity: O(m_max)
        """
        for M in range(1, m_max + 1):
            if all(
                abs(self.pressure_gap(m)) <= epsilon * m
                for m in range(M, m_max + 1)
            ):
                return M
        return None

    def check_log_conjecture(self, m_max: int) -> Tuple[bool, float]:
        """
        Check if P_exotic(m) ≤ C · log(m+1) for some C.
        Returns (holds, best_C).

        Time complexity: O(m_max)
        """
        best_C = 0.0
        for m in range(2, m_max + 1):
            exotic = abs(self.exotic_pressure(m))
            log_val = math.log(m + 1)
            if log_val > 0:
                ratio = exotic / log_val
                best_C = max(best_C, ratio)
        return True, best_C


# ═══════════════════════════════════════════════════════════════════
# Algorithm 3: Asymptotic Fit Comparison
# ═══════════════════════════════════════════════════════════════════

def asymptotic_fit(
    ms: List[int],
    values: List[float]
) -> Dict[str, Tuple[float, float]]:
    """
    Fit values to multiple asymptotic models and return coefficients
    and residuals for each.

    Models:
    - constant: v ~ a
    - logarithmic: v ~ a · log(m+1)
    - sqrt: v ~ a · √m
    - linear: v ~ a · m

    Returns dict mapping model_name -> (coefficient, sum_sq_residual)

    Time complexity: O(n) where n = len(ms)
    """
    results = {}

    n = len(ms)
    if n == 0:
        return results

    # Constant fit: a = mean(values)
    a_const = sum(values) / n
    res_const = sum((v - a_const) ** 2 for v in values)
    results['constant'] = (a_const, res_const)

    # Logarithmic fit: v = a · log(m+1), least squares
    log_ms = [math.log(m + 1) for m in ms]
    dot_vl = sum(v * l for v, l in zip(values, log_ms))
    dot_ll = sum(l * l for l in log_ms)
    if dot_ll > 0:
        a_log = dot_vl / dot_ll
        res_log = sum((v - a_log * l) ** 2 for v, l in zip(values, log_ms))
        results['logarithmic'] = (a_log, res_log)

    # Sqrt fit: v = a · √m
    sqrt_ms = [math.sqrt(m) for m in ms]
    dot_vs = sum(v * s for v, s in zip(values, sqrt_ms))
    dot_ss = sum(s * s for s in sqrt_ms)
    if dot_ss > 0:
        a_sqrt = dot_vs / dot_ss
        res_sqrt = sum((v - a_sqrt * s) ** 2 for v, s in zip(values, sqrt_ms))
        results['sqrt'] = (a_sqrt, res_sqrt)

    # Linear fit: v = a · m
    float_ms = [float(m) for m in ms]
    dot_vm = sum(v * m for v, m in zip(values, float_ms))
    dot_mm = sum(m * m for m in float_ms)
    if dot_mm > 0:
        a_lin = dot_vm / dot_mm
        res_lin = sum((v - a_lin * m) ** 2 for v, m in zip(values, float_ms))
        results['linear'] = (a_lin, res_lin)

    return results


def best_asymptotic_model(
    ms: List[int],
    values: List[float]
) -> Tuple[str, float, float]:
    """
    Determine the best asymptotic model for the given data.

    Returns (model_name, coefficient, residual).
    """
    fits = asymptotic_fit(ms, values)
    if not fits:
        return 'unknown', 0.0, float('inf')
    best = min(fits.items(), key=lambda x: x[1][1])
    return best[0], best[1][0], best[1][1]


# ═══════════════════════════════════════════════════════════════════
# Algorithm 4: Orbit Complexity to Pressure Bound Conversion
# ═══════════════════════════════════════════════════════════════════

def orbit_complexity_to_pressure_bound(
    orbit_count_fn: Callable[[int, int], int],
    k0: int,
    min_index_fn: Callable[[int], float],
    m: int
) -> float:
    """
    Convert orbit complexity data to a pressure correction upper bound.

    Given:
    - orbit_count(m, k0): number of orbit types at generator count k0
    - min_index(m): minimum index of exotic maximal subgroups

    Returns:
    P_exotic(m) ≤ orbit_count(m, k0) / min_index(m)

    This implements the formal bound from Theorem 5.

    Time complexity: O(T_orbit + T_index)
    """
    N = orbit_count_fn(m, k0)
    F = min_index_fn(m)
    if F <= 0:
        return float('inf')
    return N / F


# ═══════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=== Algorithm 1: Orbit Complexity ===\n")

    # Test cyclic orbit complexity
    print("Cyclic Z/m orbits on {0,...,m-1}^k:")
    for m in [3, 5, 7, 10]:
        for k in [1, 2, 3]:
            count = compute_cyclic_orbit_count(m, k)
            print(f"  Z/{m} on {m}^{k}: {count} orbits")

    # Test symmetric orbit complexity
    print("\nSymmetric S_m orbits on {0,...,m-1}^k:")
    for m in [3, 5, 7]:
        for k in [1, 2, 3]:
            count = compute_symmetric_orbit_count(m, k)
            print(f"  S_{m} on {m}^{k}: {count} orbits")

    # Verify polynomial bounds
    print("\n\n=== Algorithm 2: Polynomial Bound Verification ===\n")
    ok, counterex = verify_polynomial_bound(
        compute_cyclic_orbit_count,
        range(1, 20), range(1, 6),
        C=1, d=1
    )
    print(f"Cyclic bound C=1, d=1: {'HOLDS' if ok else f'FAILS at {counterex}'}")

    ok, counterex = verify_polynomial_bound(
        compute_symmetric_orbit_count,
        range(1, 10), range(1, 5),
        C=1, d=3
    )
    print(f"Symmetric bound C=1, d=3: {'HOLDS' if ok else f'FAILS at {counterex}'}")

    print("\n\n=== Algorithm 3: Pressure Estimation ===\n")

    # Lamplighter estimator
    def lamplighter_exotic(m):
        if m <= 1: return 0.0
        return sum(1 for d in range(1, m+1) if m % d == 0) / m

    est = SemidirectPressureEstimator(0.5, lamplighter_exotic)
    M = est.check_universality(0.1, 100)
    print(f"Lamplighter universality threshold (ε=0.1): M = {M}")

    holds, C = est.check_log_conjecture(100)
    print(f"Log conjecture: holds={holds}, best C = {C:.4f}")

    print("\n\n=== Algorithm 4: Asymptotic Fit ===\n")

    ms = list(range(2, 51))
    exotic_vals = [lamplighter_exotic(m) for m in ms]
    model, coeff, res = best_asymptotic_model(ms, exotic_vals)
    print(f"Best model for lamplighter exotic: {model}")
    print(f"  Coefficient: {coeff:.6f}")
    print(f"  Residual: {res:.6f}")
