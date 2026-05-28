"""
algorithms.py — Core algorithms for computing directional depth of discrete functions.

Implements the depth filtration theory for valuated matroids: given a function
f : (α → ℕ) → ℝ on multisets, compute how many times the ratio transform
preserves directional log-concavity.

Key algorithms:
  - directional_log_concave: test 1-fold log-concavity
  - ratio_transform: compute R_i f
  - directional_depth_at_least: test depth ≥ k
  - compute_depth: compute exact depth (or detect infinite depth up to a bound)
  - exchange_closed_support: test exchange closure on a degree slice

All algorithms operate on finite degree slices of bounded total degree.
"""

from __future__ import annotations
import itertools
import math
from typing import Callable, Dict, List, Optional, Tuple
import numpy as np


# ─────────────────────────────────────────────────────────────────────────
# Type aliases
# ─────────────────────────────────────────────────────────────────────────
Multiset = Tuple[int, ...]
WeightFn = Dict[Multiset, float]


# ─────────────────────────────────────────────────────────────────────────
# Combinatorial helpers
# ─────────────────────────────────────────────────────────────────────────

def degree_slice(n: int, d: int) -> List[Multiset]:
    """Generate all multisets m ∈ ℕⁿ with ∑ m_i = d.
    
    Args:
        n: number of coordinates
        d: total degree
    Returns:
        List of tuples representing multisets in the degree-d slice.

    Complexity: O(C(n+d-1, d)) — the number of multisets.
    
    >>> len(degree_slice(3, 2))
    6
    """
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in degree_slice(n - 1, d - k):
            result.append((k,) + rest)
    return result


def unit_vector(n: int, i: int) -> Multiset:
    """Standard basis vector e_i in ℕⁿ.
    
    >>> unit_vector(3, 1)
    (0, 1, 0)
    """
    return tuple(1 if j == i else 0 for j in range(n))


def add_multisets(m: Multiset, e: Multiset) -> Multiset:
    """Pointwise addition of multisets.
    
    >>> add_multisets((1, 2, 3), (0, 1, 0))
    (1, 3, 3)
    """
    return tuple(a + b for a, b in zip(m, e))


def sub_multisets(m: Multiset, e: Multiset) -> Multiset:
    """Pointwise subtraction (truncating at 0).
    
    >>> sub_multisets((1, 2, 0), (0, 1, 1))
    (1, 1, 0)
    """
    return tuple(max(a - b, 0) for a, b in zip(m, e))


# ─────────────────────────────────────────────────────────────────────────
# Weight function utilities
# ─────────────────────────────────────────────────────────────────────────

def make_weight_fn(f: Callable[[Multiset], float], n: int, max_deg: int) -> WeightFn:
    """Tabulate f on all multisets up to a given total degree.
    
    Args:
        f: function from multisets to reals
        n: dimension
        max_deg: maximum total degree to tabulate
    
    Returns:
        Dictionary mapping multisets to weights.
    """
    wf: WeightFn = {}
    for d in range(max_deg + 1):
        for m in degree_slice(n, d):
            wf[m] = f(m)
    return wf


def lookup(wf: WeightFn, m: Multiset) -> float:
    """Look up weight, defaulting to 0 for missing keys."""
    return wf.get(m, 0.0)


# ─────────────────────────────────────────────────────────────────────────
# Core algorithms
# ─────────────────────────────────────────────────────────────────────────

def is_directional_log_concave(wf: WeightFn, n: int) -> bool:
    """Test whether f is directionally log-concave on its support.
    
    Checks: for all i and all m in support,
        f(m) * f(m + 2e_i) ≤ f(m + e_i)²
    
    Args:
        wf: weight function (dictionary)
        n: dimension
    
    Returns:
        True if directionally log-concave.
    
    Complexity: O(|support| * n)
    """
    for m, fm in wf.items():
        for i in range(n):
            ei = unit_vector(n, i)
            m1 = add_multisets(m, ei)
            m2 = add_multisets(m1, ei)
            f1 = lookup(wf, m1)
            f2 = lookup(wf, m2)
            if fm * f2 > f1 * f1 + 1e-12:
                return False
    return True


def ratio_transform(wf: WeightFn, n: int, i: int) -> WeightFn:
    """Compute the ratio transform R_i f.
    
    R_i f(m) = f(m + e_i) / f(m), defined as 0 when f(m) = 0.
    
    Args:
        wf: weight function
        n: dimension
        i: direction index
    
    Returns:
        New weight function representing R_i f.
    
    Complexity: O(|support|)
    """
    result: WeightFn = {}
    ei = unit_vector(n, i)
    for m, fm in wf.items():
        if abs(fm) > 1e-15:
            m1 = add_multisets(m, ei)
            f1 = lookup(wf, m1)
            result[m] = f1 / fm
    return result


def directional_depth_at_least(wf: WeightFn, n: int, k: int) -> bool:
    """Test whether f has directional depth ≥ k.
    
    Recursive definition:
      - depth ≥ 0: always true
      - depth ≥ k+1: f is dir. log-concave AND every R_i f has depth ≥ k
    
    Args:
        wf: weight function
        n: dimension
        k: depth level to test
    
    Returns:
        True if depth ≥ k.
    
    Complexity: O(n^k * |support|) — the ratio transform is applied k times.
    """
    if k == 0:
        return True
    if not is_directional_log_concave(wf, n):
        return False
    for i in range(n):
        ri = ratio_transform(wf, n, i)
        if not directional_depth_at_least(ri, n, k - 1):
            return False
    return True


def compute_depth(wf: WeightFn, n: int, max_k: int = 10) -> int:
    """Compute the exact directional depth of f, up to max_k.
    
    Returns the largest k such that depth ≥ k holds, or max_k if
    all levels up to max_k pass (suggesting infinite depth).
    
    Args:
        wf: weight function
        n: dimension
        max_k: maximum depth to test
    
    Returns:
        Exact depth (or max_k if possibly infinite).
    
    Complexity: O(max_k * n^max_k * |support|)
    """
    for k in range(max_k + 1):
        if not directional_depth_at_least(wf, n, k):
            return k - 1
    return max_k


def find_depth_failure_witness(wf: WeightFn, n: int, k: int) -> Optional[dict]:
    """Find a witness where depth fails at level k.
    
    If depth ≥ k fails, returns a dictionary describing where log-concavity
    breaks (the direction and multiset).
    
    Args:
        wf: weight function
        n: dimension
        k: depth level
    
    Returns:
        Dictionary with 'level', 'direction', 'multiset', 'values' or None.
    """
    if k == 0:
        return None
    for m, fm in wf.items():
        for i in range(n):
            ei = unit_vector(n, i)
            m1 = add_multisets(m, ei)
            m2 = add_multisets(m1, ei)
            f1 = lookup(wf, m1)
            f2 = lookup(wf, m2)
            if fm * f2 > f1 * f1 + 1e-12:
                return {
                    'level': 0,
                    'direction': i,
                    'multiset': m,
                    'values': (fm, f1, f2),
                    'violation': fm * f2 - f1 * f1
                }
    if k == 1:
        return None
    for i in range(n):
        ri = ratio_transform(wf, n, i)
        sub_witness = find_depth_failure_witness(ri, n, k - 1)
        if sub_witness is not None:
            sub_witness['level'] += 1
            sub_witness['outer_direction'] = i
            return sub_witness
    return None


# ─────────────────────────────────────────────────────────────────────────
# Exchange-closed support
# ─────────────────────────────────────────────────────────────────────────

def exchange_closed_support(wf: WeightFn, n: int, d: int) -> bool:
    """Test whether f has exchange-closed support on the degree-d slice.
    
    For all m, n in support ∩ slice(d) with m_i < n_i, there exists j
    with n_j < m_j and f(exchange(m, i, j)) > 0.
    
    Args:
        wf: weight function
        n: dimension
        d: degree
    
    Returns:
        True if exchange-closed.
    
    Complexity: O(|slice|² * n²)
    """
    slc = degree_slice(n, d)
    support = [m for m in slc if lookup(wf, m) > 1e-15]
    
    for m in support:
        for nn in support:
            for i in range(n):
                if m[i] < nn[i]:
                    found = False
                    for j in range(n):
                        if nn[j] < m[j] and m[j] > 0:
                            # exchange move: m + e_i - e_j
                            ex = list(m)
                            ex[i] += 1
                            ex[j] -= 1
                            ex_t = tuple(ex)
                            if lookup(wf, ex_t) > 1e-15:
                                found = True
                                break
                    if not found:
                        return False
    return True


# ─────────────────────────────────────────────────────────────────────────
# Model families
# ─────────────────────────────────────────────────────────────────────────

def uniform_matroid_valuation(n: int, r: int, max_deg: int = None) -> WeightFn:
    """Weight function for the uniform matroid U(r, n): f(m) = 1 if
    m is a 0-1 vector with exactly r ones, else 0.
    
    For depth analysis, we extend: f(m) = ∏ C(n_i, m_i) style, but
    the simplest version is the indicator.
    
    >>> wf = uniform_matroid_valuation(3, 2)
    >>> lookup(wf, (1, 1, 0))
    1.0
    """
    if max_deg is None:
        max_deg = r
    wf: WeightFn = {}
    for d in range(max_deg + 1):
        for m in degree_slice(n, d):
            if all(mi <= 1 for mi in m) and sum(m) == r:
                wf[m] = 1.0
            else:
                wf[m] = 0.0
    return wf


def weighted_graphical_matroid(n: int, edges: List[Tuple[int, int]],
                                weights: List[float],
                                max_deg: int = None) -> WeightFn:
    """Weight function from a weighted graph.
    
    For a graph G = (V, E) with edge weights w_e, the graphical matroid
    weight of a set S ⊆ E is ∏_{e ∈ S} w_e if S is a forest, else 0.
    
    Here we use a simplified version on ℕⁿ for n = |E|.
    
    Args:
        n: number of edges
        edges: list of (u, v) pairs
        weights: edge weights (positive reals)
        max_deg: max total degree
    
    Returns:
        Weight function.
    """
    if max_deg is None:
        max_deg = n
    num_vertices = max(max(u, v) for u, v in edges) + 1
    
    def is_forest(subset_indices):
        """Check if selected edges form a forest using union-find."""
        parent = list(range(num_vertices))
        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        for idx in subset_indices:
            u, v = edges[idx]
            ru, rv = find(u), find(v)
            if ru == rv:
                return False
            parent[ru] = rv
        return True
    
    wf: WeightFn = {}
    for d in range(max_deg + 1):
        for m in degree_slice(n, d):
            # Only consider 0-1 vectors (simple matroid)
            if all(mi <= 1 for mi in m):
                selected = [i for i, mi in enumerate(m) if mi == 1]
                if is_forest(selected):
                    wf[m] = math.prod(weights[i] for i in selected) if selected else 1.0
                else:
                    wf[m] = 0.0
            else:
                wf[m] = 0.0
    return wf


def gaussian_weight(sigma: float = 1.0) -> Callable[[Multiset], float]:
    """Gaussian weight function f(m) = exp(-||m||² / (2σ²)).
    
    This family has infinite directional depth for all σ > 0.
    
    >>> f = gaussian_weight(1.0)
    >>> f((0, 0, 0))
    1.0
    """
    def f(m: Multiset) -> float:
        norm_sq = sum(x**2 for x in m)
        return math.exp(-norm_sq / (2 * sigma**2))
    return f


def geometric_weight(rates: List[float]) -> Callable[[Multiset], float]:
    """Product-geometric weight: f(m) = ∏ r_i^{m_i}.
    
    Has infinite directional depth (ratio transforms are constant).
    
    >>> f = geometric_weight([2.0, 3.0])
    >>> f((1, 2))
    18.0
    """
    def f(m: Multiset) -> float:
        return math.prod(r**mi for r, mi in zip(rates, m))
    return f


def polynomial_coefficients(coeffs: List[float], n: int, max_deg: int) -> WeightFn:
    """Weight function from polynomial coefficients.
    
    For a univariate polynomial with coefficients coeffs[0], coeffs[1], ...,
    extended to n variables as the product polynomial.
    """
    wf: WeightFn = {}
    for d in range(max_deg + 1):
        for m in degree_slice(n, d):
            val = 1.0
            for mi in m:
                if mi < len(coeffs):
                    val *= coeffs[mi]
                else:
                    val *= 0.0
            wf[m] = val
    return wf


# ─────────────────────────────────────────────────────────────────────────
# Tropical valuation
# ─────────────────────────────────────────────────────────────────────────

def tropical_valuation(wf: WeightFn) -> Dict[Multiset, float]:
    """Compute the tropical valuation v = -log f on the support.
    
    Returns -log(f(m)) for positive f(m), infinity for f(m) ≤ 0.
    
    >>> wf = {(0,): 1.0, (1,): math.e}
    >>> v = tropical_valuation(wf)
    >>> round(v[(1,)], 5)
    -1.0
    """
    result = {}
    for m, fm in wf.items():
        if fm > 1e-15:
            result[m] = -math.log(fm)
        else:
            result[m] = float('inf')
    return result


def is_supermodular(val: Dict[Multiset, float], n: int) -> bool:
    """Test supermodularity of a valuation on ℕⁿ.
    
    Checks: for all i ≠ j and all m,
        v(m + eᵢ) + v(m + eⱼ) ≤ v(m) + v(m + eᵢ + eⱼ)
    
    Only checks on the support (finite entries).
    """
    for m in val:
        for i in range(n):
            for j in range(i + 1, n):
                ei, ej = unit_vector(n, i), unit_vector(n, j)
                mi = add_multisets(m, ei)
                mj = add_multisets(m, ej)
                mij = add_multisets(mi, ej)
                vi = val.get(mi, float('inf'))
                vj = val.get(mj, float('inf'))
                vij = val.get(mij, float('inf'))
                vm = val.get(m, float('inf'))
                if vi + vj > vm + vij + 1e-10:
                    return False
    return True


if __name__ == "__main__":
    # Example: Gaussian weight on ℕ³
    print("=== Gaussian Weight (σ=1) on ℕ³ ===")
    gw = gaussian_weight(1.0)
    wf = make_weight_fn(gw, 3, 6)
    depth = compute_depth(wf, 3, max_k=5)
    print(f"  Depth ≥ {depth} (expected: high, suggesting infinite)")
    
    # Example: Geometric weight
    print("\n=== Geometric Weight [2, 3, 5] on ℕ³ ===")
    geo = geometric_weight([2.0, 3.0, 5.0])
    wf_geo = make_weight_fn(geo, 3, 6)
    depth_geo = compute_depth(wf_geo, 3, max_k=5)
    print(f"  Depth ≥ {depth_geo} (expected: high, suggesting infinite)")
    
    # Example: Weight with depth exactly 1
    print("\n=== Custom depth-1 weight on ℕ² ===")
    # f(m) = (m₁ + 1) * exp(-m₁²) * (m₂ + 1) — has log-concavity but
    # ratio transform may fail
    def custom_f(m):
        return (m[0] + 1) * math.exp(-m[0]**2) * (m[1] + 1)
    wf_custom = make_weight_fn(custom_f, 2, 8)
    depth_custom = compute_depth(wf_custom, 2, max_k=5)
    print(f"  Depth = {depth_custom}")
    witness = find_depth_failure_witness(wf_custom, 2, depth_custom + 1)
    if witness:
        print(f"  Failure witness: {witness}")
