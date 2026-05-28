"""
algorithms.py — Core algorithms for computing directional depth of functions
on lattice points, implementing the depth filtration theory for valuated matroids.

The central algorithm computes the directional depth of a function
f : (α → ℕ) → ℝ by iterating ratio transforms and checking log-concavity
at each level.
"""

from __future__ import annotations
import numpy as np
from typing import Callable, Dict, Tuple, List, Optional
from itertools import product as iter_product


# ─────────────────────────────────────────────────────────────────────────────
# Core data structures
# ─────────────────────────────────────────────────────────────────────────────

def make_multiindex_grid(n_vars: int, max_degree: int) -> List[Tuple[int, ...]]:
    """Generate all multi-indices m ∈ ℕ^n with |m| ≤ max_degree.

    Args:
        n_vars: Number of variables (dimension of α).
        max_degree: Maximum total degree.

    Returns:
        List of tuples representing multi-indices.

    Example:
        >>> grid = make_multiindex_grid(2, 2)
        >>> (1, 1) in grid
        True
    """
    return [m for m in iter_product(range(max_degree + 1), repeat=n_vars)
            if sum(m) <= max_degree]


def make_degree_slice(n_vars: int, degree: int) -> List[Tuple[int, ...]]:
    """Generate all multi-indices on a fixed degree slice.

    Args:
        n_vars: Number of variables.
        degree: The fixed total degree d.

    Returns:
        List of tuples m with sum(m) == degree.
    """
    return [m for m in iter_product(range(degree + 1), repeat=n_vars)
            if sum(m) == degree]


# ─────────────────────────────────────────────────────────────────────────────
# Ratio transform
# ─────────────────────────────────────────────────────────────────────────────

def shift_up(m: Tuple[int, ...], i: int) -> Tuple[int, ...]:
    """Shift multi-index m up by 1 at coordinate i: m + e_i."""
    return tuple(m[j] + (1 if j == i else 0) for j in range(len(m)))


def ratio_transform(f: Dict[Tuple[int, ...], float], i: int,
                    grid: List[Tuple[int, ...]]) -> Dict[Tuple[int, ...], float]:
    """Compute the ratio transform R_i f(m) = f(m + e_i) / f(m).

    Args:
        f: Function values as a dictionary from multi-index to float.
        i: Direction index.
        grid: Set of multi-indices to evaluate on.

    Returns:
        Dictionary of ratio transform values. Division by zero gives inf.

    Example:
        >>> f = {(0,): 1.0, (1,): 2.0, (2,): 3.0}
        >>> R = ratio_transform(f, 0, [(0,), (1,)])
        >>> R[(0,)]
        2.0
    """
    result = {}
    for m in grid:
        m_up = shift_up(m, i)
        fm = f.get(m, 0.0)
        fm_up = f.get(m_up, 0.0)
        if abs(fm) < 1e-15:
            result[m] = float('inf') if fm_up != 0 else 0.0
        else:
            result[m] = fm_up / fm
    return result


# ─────────────────────────────────────────────────────────────────────────────
# Log-concavity checks
# ─────────────────────────────────────────────────────────────────────────────

def check_directional_log_concavity(f: Dict[Tuple[int, ...], float],
                                      grid: List[Tuple[int, ...]],
                                      n_vars: int,
                                      tol: float = 1e-10) -> Tuple[bool, Optional[dict]]:
    """Check if f is directionally log-concave on the grid.

    For every direction i and point m, checks:
        f(m) * f(m + 2e_i) ≤ f(m + e_i)²

    Args:
        f: Function values.
        grid: Multi-indices to check.
        n_vars: Number of variables.
        tol: Numerical tolerance.

    Returns:
        (True, None) if log-concave, (False, witness) with a failure witness.

    Example:
        >>> f = {(k,): float(3-k) for k in range(4)}  # 3, 2, 1, 0
        >>> ok, _ = check_directional_log_concavity(f, [(k,) for k in range(4)], 1)
        >>> ok
        True
    """
    for i in range(n_vars):
        for m in grid:
            m1 = shift_up(m, i)
            m2 = shift_up(m1, i)
            fm = f.get(m, 0.0)
            fm1 = f.get(m1, 0.0)
            fm2 = f.get(m2, 0.0)
            lhs = fm * fm2
            rhs = fm1 * fm1
            if lhs > rhs + tol:
                return False, {"direction": i, "point": m,
                               "lhs": lhs, "rhs": rhs}
    return True, None


def check_mixed_log_concavity(f: Dict[Tuple[int, ...], float],
                                grid: List[Tuple[int, ...]],
                                n_vars: int,
                                tol: float = 1e-10) -> Tuple[bool, Optional[dict]]:
    """Check if f is mixed log-concave on the grid.

    For every pair of directions i, j and point m, checks:
        f(m) * f(m + e_i + e_j) ≤ f(m + e_i) * f(m + e_j)

    Args:
        f: Function values.
        grid: Multi-indices to check.
        n_vars: Number of variables.
        tol: Numerical tolerance.

    Returns:
        (True, None) if mixed log-concave, (False, witness) with failure witness.
    """
    for i in range(n_vars):
        for j in range(n_vars):
            for m in grid:
                m_i = shift_up(m, i)
                m_j = shift_up(m, j)
                m_ij = shift_up(m_i, j)
                fm = f.get(m, 0.0)
                fm_ij = f.get(m_ij, 0.0)
                fm_i = f.get(m_i, 0.0)
                fm_j = f.get(m_j, 0.0)
                if fm * fm_ij > fm_i * fm_j + tol:
                    return False, {"dirs": (i, j), "point": m,
                                   "lhs": fm * fm_ij, "rhs": fm_i * fm_j}
    return True, None


# ─────────────────────────────────────────────────────────────────────────────
# Directional depth computation
# ─────────────────────────────────────────────────────────────────────────────

def compute_directional_depth(f: Dict[Tuple[int, ...], float],
                               n_vars: int,
                               max_degree: int,
                               max_depth: int = 10,
                               tol: float = 1e-10) -> int:
    """Compute the directional depth of function f.

    The depth is the largest k such that f has directional depth ≥ k,
    defined recursively:
      - depth ≥ 0: always true
      - depth ≥ k+1: f is directionally log-concave AND every ratio
        transform R_i f has depth ≥ k.

    Args:
        f: Function values on multi-indices.
        n_vars: Number of variables.
        max_degree: Maximum degree for the grid.
        max_depth: Maximum depth to check (returns this if all levels pass).
        tol: Numerical tolerance.

    Returns:
        The computed depth (0 to max_depth).

    Complexity:
        Time: O(max_depth * n_vars * |grid| * n_vars) per level.
        Space: O(|grid|) per ratio transform.

    Example:
        >>> f = {(k,): float(k+1) for k in range(5)}  # 1, 2, 3, 4, 5
        >>> # This is NOT log-concave: 1*3 = 3 > 4 = 2*2? No: 3 ≤ 4. Check.
        >>> compute_directional_depth(f, 1, 4)  # Should be at least 1
        1
    """
    grid = make_multiindex_grid(n_vars, max_degree)
    return _depth_recursive(f, n_vars, grid, max_degree, max_depth, tol)


def _depth_recursive(f: Dict[Tuple[int, ...], float],
                     n_vars: int,
                     grid: List[Tuple[int, ...]],
                     max_degree: int,
                     remaining_depth: int,
                     tol: float) -> int:
    """Recursive helper for depth computation."""
    if remaining_depth <= 0:
        return 0

    # Check directional log-concavity at this level
    ok, witness = check_directional_log_concavity(f, grid, n_vars, tol)
    if not ok:
        return 0

    # Check all ratio transforms
    min_sub_depth = remaining_depth - 1
    for i in range(n_vars):
        Rf = ratio_transform(f, i, grid)
        # Filter out infinite values
        Rf_clean = {m: v for m, v in Rf.items() if np.isfinite(v)}
        sub_grid = [m for m in grid if m in Rf_clean]
        sub_depth = _depth_recursive(Rf_clean, n_vars, sub_grid,
                                     max_degree, remaining_depth - 1, tol)
        min_sub_depth = min(min_sub_depth, sub_depth)

    return 1 + min_sub_depth


# ─────────────────────────────────────────────────────────────────────────────
# Supermodularity check
# ─────────────────────────────────────────────────────────────────────────────

def check_neg_log_supermodular(f: Dict[Tuple[int, ...], float],
                                grid: List[Tuple[int, ...]],
                                n_vars: int,
                                tol: float = 1e-10) -> Tuple[bool, Optional[dict]]:
    """Check if -log(f) is supermodular on the grid.

    For i ≠ j and all m, checks:
        -log f(m+e_i) + (-log f(m+e_j)) ≤ -log f(m) + (-log f(m+e_i+e_j))

    This is equivalent to mixed log-concavity of f when f > 0.

    Args:
        f: Function values (must be positive on the grid).
        grid: Multi-indices to check.
        n_vars: Number of variables.
        tol: Tolerance.

    Returns:
        (True, None) if supermodular, (False, witness) with failure.
    """
    for i in range(n_vars):
        for j in range(n_vars):
            if i == j:
                continue
            for m in grid:
                m_i = shift_up(m, i)
                m_j = shift_up(m, j)
                m_ij = shift_up(m_i, j)
                vals = [f.get(m, 0.0), f.get(m_i, 0.0),
                        f.get(m_j, 0.0), f.get(m_ij, 0.0)]
                if any(v <= 0 for v in vals):
                    continue
                log_vals = [np.log(v) for v in vals]
                # Check: -log f(m_i) + (-log f(m_j)) ≤ -log f(m) + (-log f(m_ij))
                # i.e. log f(m) + log f(m_ij) ≤ log f(m_i) + log f(m_j)
                lhs = log_vals[0] + log_vals[3]
                rhs = log_vals[1] + log_vals[2]
                if lhs > rhs + tol:
                    return False, {"dirs": (i, j), "point": m,
                                   "lhs": lhs, "rhs": rhs}
    return True, None


# ─────────────────────────────────────────────────────────────────────────────
# Exchange property checker
# ─────────────────────────────────────────────────────────────────────────────

def check_exchange_closed_support(f: Dict[Tuple[int, ...], float],
                                   degree: int,
                                   n_vars: int,
                                   tol: float = 1e-10) -> bool:
    """Check if f has exchange-closed support on the degree-d slice.

    For any m, n with sum = d, f(m) > 0, f(n) > 0, and i with m[i] < n[i],
    there exists j with n[j] < m[j] such that f(exchange_move(m, i, j)) > 0.

    Args:
        f: Function values.
        degree: The degree d.
        n_vars: Number of variables.
        tol: Positivity tolerance.

    Returns:
        True if exchange-closed, False otherwise.
    """
    slice_pts = make_degree_slice(n_vars, degree)
    pos_pts = [m for m in slice_pts if f.get(m, 0.0) > tol]

    for m in pos_pts:
        for n in pos_pts:
            for i in range(n_vars):
                if m[i] >= n[i]:
                    continue
                # Need to find j with n[j] < m[j] and exchange move is positive
                found = False
                for j in range(n_vars):
                    if n[j] >= m[j] or m[j] == 0:
                        continue
                    # exchange_move: decrease m at j, increase at i
                    em = list(m)
                    em[j] -= 1
                    em[i] += 1
                    em_t = tuple(em)
                    if f.get(em_t, 0.0) > tol:
                        found = True
                        break
                if not found:
                    return False
    return True


# ─────────────────────────────────────────────────────────────────────────────
# Depth profile computation
# ─────────────────────────────────────────────────────────────────────────────

def compute_depth_profile(f: Dict[Tuple[int, ...], float],
                           n_vars: int,
                           max_degree: int,
                           max_depth: int = 10) -> Dict[str, object]:
    """Compute a comprehensive depth profile for function f.

    Returns a dictionary with:
        - 'depth': the computed directional depth
        - 'is_dir_log_concave': bool
        - 'is_mixed_log_concave': bool
        - 'neg_log_supermodular': bool
        - 'ratio_depths': depth of each R_i f

    Args:
        f: Function values.
        n_vars: Number of variables.
        max_degree: Maximum degree for grid.
        max_depth: Maximum depth to check.

    Returns:
        Dictionary with depth profile information.
    """
    grid = make_multiindex_grid(n_vars, max_degree)

    depth = compute_directional_depth(f, n_vars, max_degree, max_depth)
    dir_lc, dir_witness = check_directional_log_concavity(f, grid, n_vars)
    mix_lc, mix_witness = check_mixed_log_concavity(f, grid, n_vars)
    sup, sup_witness = check_neg_log_supermodular(f, grid, n_vars)

    ratio_depths = {}
    for i in range(n_vars):
        Rf = ratio_transform(f, i, grid)
        Rf_clean = {m: v for m, v in Rf.items() if np.isfinite(v)}
        rd = compute_directional_depth(Rf_clean, n_vars, max_degree, max_depth - 1)
        ratio_depths[i] = rd

    return {
        'depth': depth,
        'is_dir_log_concave': dir_lc,
        'is_mixed_log_concave': mix_lc,
        'neg_log_supermodular': sup,
        'ratio_depths': ratio_depths,
        'dir_failure': dir_witness,
        'mix_failure': mix_witness,
        'sup_failure': sup_witness,
    }


# ─────────────────────────────────────────────────────────────────────────────
# Example families
# ─────────────────────────────────────────────────────────────────────────────

def gaussian_function(n_vars: int, max_degree: int,
                       sigma: float = 1.0) -> Dict[Tuple[int, ...], float]:
    """Gaussian-type function f(m) = exp(-|m|²/(2σ²)).

    Expected to have infinite depth (all levels log-concave).
    """
    grid = make_multiindex_grid(n_vars, max_degree)
    return {m: np.exp(-sum(x**2 for x in m) / (2 * sigma**2)) for m in grid}


def binomial_function(n_vars: int, degree: int) -> Dict[Tuple[int, ...], float]:
    """Multinomial coefficient function f(m) = d! / (m₁! ... mₙ!).

    Only nonzero on the degree-d slice. Expected to have high depth.
    """
    from math import factorial
    grid = make_degree_slice(n_vars, degree)
    result = {}
    for m in grid:
        result[m] = factorial(degree) / np.prod([factorial(mi) for mi in m])
    return result


def power_function(n_vars: int, max_degree: int,
                    base: float = 2.0) -> Dict[Tuple[int, ...], float]:
    """Power function f(m) = base^(-|m|).

    Expected to have infinite depth.
    """
    grid = make_multiindex_grid(n_vars, max_degree)
    return {m: base ** (-sum(m)) for m in grid}


def depth_one_witness() -> Tuple[Dict[Tuple[int, ...], float], int, int]:
    """Construct the explicit witness with depth exactly 1.

    This matches the Lean proof: a function on Fin 2 → ℕ that is
    directionally log-concave but whose ratio transform fails.

    Returns:
        (function_dict, n_vars, max_degree)
    """
    # f(m) defined on single variable effectively
    # f(0) = 1, f(1) = 3, f(2) = 2, f(3) = 1, f(k) = 0 for k ≥ 4
    # Ratio: R(0) = 3, R(1) = 2/3, R(2) = 1/2
    # R(0)*R(2) = 3/2 > 4/9 = R(1)^2 → NOT log-concave
    f = {}
    for m in make_multiindex_grid(1, 6):
        k = m[0]
        if k == 0:
            f[m] = 1.0
        elif k == 1:
            f[m] = 3.0
        elif k == 2:
            f[m] = 2.0
        elif k == 3:
            f[m] = 1.0
        else:
            f[m] = 0.0
    return f, 1, 6


if __name__ == "__main__":
    print("=== Depth Computation Algorithms ===\n")

    # Test the explicit witness
    f, nv, md = depth_one_witness()
    depth = compute_directional_depth(f, nv, md, max_depth=5)
    print(f"Depth-1 witness: depth = {depth}")

    # Gaussian
    f_gauss = gaussian_function(2, 5)
    depth_gauss = compute_directional_depth(f_gauss, 2, 5, max_depth=5)
    print(f"Gaussian (2 vars, σ=1): depth = {depth_gauss}")

    # Binomial
    f_binom = binomial_function(3, 4)
    depth_binom = compute_directional_depth(f_binom, 3, 4, max_depth=5)
    print(f"Multinomial (3 vars, d=4): depth = {depth_binom}")

    # Power
    f_pow = power_function(2, 5, base=2.0)
    depth_pow = compute_directional_depth(f_pow, 2, 5, max_depth=5)
    print(f"Power base 2 (2 vars): depth = {depth_pow}")
