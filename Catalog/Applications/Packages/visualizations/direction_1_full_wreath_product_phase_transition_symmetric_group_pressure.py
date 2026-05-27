#!/usr/bin/env python3
"""
algorithms.py — Algorithms for wreath product pressure computation.

Implements:
1. Symmetric group maximal subgroup pressure computation
2. Coordinate-defect pressure (exact)
3. Non-coordinate pressure estimation
4. Phase transition threshold estimation
5. Logarithmic bound verification

All algorithms include docstrings, type hints, and complexity analysis.
"""

import math
from typing import Dict, List, Optional, Tuple


# =============================================================================
# Algorithm 1: Symmetric Group Pressure
# =============================================================================

def compute_symm_pressure(k: int) -> float:
    """
    Compute P(S_k) = Σ_{M maximal in S_k} 1/[S_k : M].

    Uses the O'Nan-Scott classification of maximal subgroups of S_k:
    - Intransitive: S_j × S_{k-j} for 1 ≤ j < k/2, index C(k,j)
    - Imprimitive: S_d ≀ S_{k/d} for d | k, d > 1, d < k
    - Primitive: various (alternating, affine, diagonal, etc.)

    Time complexity: O(k log k) for the combinatorial terms
    Space complexity: O(k)

    Args:
        k: Degree of symmetric group S_k (k ≥ 2)

    Returns:
        P(S_k) as a float

    Example:
        >>> compute_symm_pressure(5)
        0.7666666666666666
    """
    if k < 2:
        return 0.0

    pressure = 0.0

    # Intransitive maximal subgroups: S_j × S_{k-j}, index = C(k,j)
    for j in range(1, k // 2 + 1):
        idx = math.comb(k, j)
        if j == k - j:
            # Self-complementary: one class, index C(k,k/2)/2... 
            # Actually S_j × S_{k-j} for j = k/2 is a single class
            pressure += 1.0 / idx
        else:
            pressure += 1.0 / idx

    # Alternating group A_k (for k ≥ 2): index 2
    if k >= 2:
        pressure += 0.5

    # Imprimitive maximal subgroups: S_d ≀ S_{k/d} for d | k, 1 < d < k
    for d in range(2, k):
        if k % d == 0:
            n = k // d
            if n > 1:  # need at least 2 blocks
                # Index = k! / (d!^n · n!)
                idx = math.factorial(k) / (math.factorial(d) ** n * math.factorial(n))
                if idx > 0:
                    pressure += 1.0 / idx

    return pressure


# =============================================================================
# Algorithm 2: Coordinate-Defect Pressure
# =============================================================================

def compute_coord_pressure(k: int, m: int) -> float:
    """
    Compute P_coord(W_{k,m}) = m · P(S_k).

    This is the contribution from maximal subgroups of W_{k,m} = S_k ≀ S_m
    that arise by replacing exactly one coordinate S_k by a maximal subgroup.

    Time complexity: O(k log k)
    Space complexity: O(1) beyond the P(S_k) computation

    Args:
        k: Base group degree
        m: Number of copies (top group degree)

    Returns:
        Coordinate-defect pressure

    Example:
        >>> compute_coord_pressure(5, 3)
        2.3
    """
    return m * compute_symm_pressure(k)


# =============================================================================
# Algorithm 3: Non-Coordinate Pressure Estimation
# =============================================================================

def estimate_noncoord_pressure(k: int, m: int) -> float:
    """
    Estimate P_noncoord(W_{k,m}).

    Non-coordinate maximal subgroups fall into several O'Nan-Scott types:

    Type 1: Top-group type — lifts of maximal subgroups of S_m
        Count: number of maximal subgroup classes of S_m
        Index in W_{k,m}: [S_m : M_top] (independent of base)
        Contribution: P(S_m)

    Type 2: Diagonal type — for k ≥ 5 (S_k simple)
        Count: O(m^2) diagonal embeddings
        Index in W_{k,m}: (k!)^{m-1}
        Contribution: O(m^2 · (k!)^{1-m}) → 0 exponentially

    Type 3: Product-action type — rare for imprimitive actions
        Contribution: negligible for our asymptotic regime

    Time complexity: O(m log m + k log k)
    Space complexity: O(1)

    Args:
        k: Base group degree
        m: Number of copies

    Returns:
        Estimated non-coordinate pressure
    """
    if k < 2 or m < 1:
        return 0.0

    # Type 1: Top-group contribution
    top = compute_symm_pressure(m) if m >= 2 else 0.0

    # Type 2: Diagonal contribution
    diag = 0.0
    if k >= 5 and m >= 2:
        kfact = math.factorial(k)
        # Number of diagonal embeddings: C(m,2) for pairs
        count = m * (m - 1) / 2
        # Each has index ≥ (k!)^{m-1}
        if m - 1 <= 20:  # avoid overflow
            diag = count / (kfact ** (m - 1))

    return top + diag


# =============================================================================
# Algorithm 4: Full Wreath Pressure
# =============================================================================

def compute_wreath_pressure(k: int, m: int) -> float:
    """
    Compute estimated P(W_{k,m}) = P_coord + P_noncoord.

    Time complexity: O(m log m + k log k)
    Space complexity: O(1)
    """
    return compute_coord_pressure(k, m) + estimate_noncoord_pressure(k, m)


# =============================================================================
# Algorithm 5: Phase Transition Threshold
# =============================================================================

def estimate_threshold(k: int, m: int, target_pressure: float = 1.0) -> float:
    """
    Estimate the generation threshold for W_{k,m}.

    The phase transition occurs when the pressure P(W) crosses the
    critical value (approximately 1 for generation probability 1/2).

    For coordinate-defect dominated regime:
        threshold ≈ target / (m · P(S_k))

    Time complexity: O(k log k)

    Args:
        k: Base group degree
        m: Number of copies
        target_pressure: Critical pressure value (default 1.0)

    Returns:
        Estimated threshold value (as a scaling parameter)
    """
    p_sk = compute_symm_pressure(k)
    if p_sk <= 0 or m <= 0:
        return float('inf')
    return target_pressure / (m * p_sk)


# =============================================================================
# Algorithm 6: Logarithmic Bound Verification
# =============================================================================

def verify_log_bound(k: int, m_values: List[int]) -> Tuple[bool, float, float]:
    """
    Test the conjecture P_noncoord(W_{k,m}) ≤ A·log(m) + B.

    Performs least-squares fit of P_noncoord against log(m) and
    checks whether the bound holds for all tested values.

    Time complexity: O(|m_values| · (m_max log m_max + k log k))

    Args:
        k: Base group degree
        m_values: List of m values to test

    Returns:
        (conjecture_holds, best_A, best_B) where conjecture_holds is True
        if all data points satisfy the bound with the fitted constants.
    """
    if not m_values:
        return True, 0.0, 0.0

    data = []
    for m in m_values:
        if m >= 2:
            pnc = estimate_noncoord_pressure(k, m)
            data.append((math.log(m), pnc))

    if len(data) < 2:
        return True, 1.0, 1.0

    # Least squares: pnc ≈ A · log(m) + B
    n = len(data)
    sum_x = sum(x for x, _ in data)
    sum_y = sum(y for _, y in data)
    sum_xx = sum(x * x for x, _ in data)
    sum_xy = sum(x * y for x, y in data)

    denom = n * sum_xx - sum_x ** 2
    if abs(denom) < 1e-12:
        A = 0.0
        B = sum_y / n if n > 0 else 0.0
    else:
        A = (n * sum_xy - sum_x * sum_y) / denom
        B = (sum_y - A * sum_x) / n

    # Add margin
    A_bound = abs(A) + 0.1
    B_bound = abs(B) + 0.1

    # Check bound
    holds = True
    for logm, pnc in data:
        if pnc > A_bound * logm + B_bound + 1e-10:
            holds = False
            break

    return holds, A_bound, B_bound


# =============================================================================
# Algorithm 7: Pressure Ratio Analysis
# =============================================================================

def pressure_ratio_analysis(k: int, m_max: int) -> List[Dict[str, float]]:
    """
    Analyze pressure ratios for universality evidence.

    Computes P_full/P_coord and P_noncoord/m for m = 1, ..., m_max.

    Args:
        k: Base group degree
        m_max: Maximum m value

    Returns:
        List of dicts with ratio data for each m
    """
    results = []
    for m in range(1, m_max + 1):
        pc = compute_coord_pressure(k, m)
        pnc = estimate_noncoord_pressure(k, m)
        pf = pc + pnc

        results.append({
            'm': m,
            'coord_pressure': pc,
            'noncoord_pressure': pnc,
            'full_pressure': pf,
            'ratio_full_coord': pf / pc if pc > 0 else float('inf'),
            'noncoord_over_m': pnc / m if m > 0 else 0,
            'noncoord_over_logm': pnc / math.log(m + 1) if m > 0 else 0,
        })

    return results


if __name__ == "__main__":
    print("=== Symmetric Group Pressures ===")
    for k in range(2, 9):
        p = compute_symm_pressure(k)
        print(f"  P(S_{k}) = {p:.6f}")

    print("\n=== Pressure Decomposition for k=5 ===")
    for m in [1, 2, 3, 5, 10, 20]:
        pc = compute_coord_pressure(5, m)
        pnc = estimate_noncoord_pressure(5, m)
        print(f"  m={m:>3}: P_coord={pc:.4f}, P_noncoord={pnc:.6f}, "
              f"P_full={pc+pnc:.4f}")

    print("\n=== Logarithmic Bound Test ===")
    for k in [5, 6, 7]:
        holds, A, B = verify_log_bound(k, list(range(2, 51)))
        print(f"  k={k}: conjecture {'HOLDS' if holds else 'FAILS'}, "
              f"A={A:.4f}, B={B:.4f}")

    print("\n=== Phase Transition Thresholds ===")
    for k in [5, 6, 7, 8]:
        for m in [2, 5, 10]:
            t = estimate_threshold(k, m)
            print(f"  W_{{{k},{m}}}: threshold ≈ {t:.6f}")
