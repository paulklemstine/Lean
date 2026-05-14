#!/usr/bin/env python3
"""
Tropical BSD Prototype — Algorithms

Implements the core algorithms from the research paper with full type hints,
docstrings, and complexity analysis.
"""

from typing import Dict, List, Optional, Set, Tuple
import math


def tropical_analytic_rank(S: List[int], w: Dict[int, float]) -> int:
    """
    Compute the tropical analytic rank (order of vanishing at s=1).

    Algorithm: Find the minimum weight, count elements achieving it, subtract 1.

    Time complexity: O(|S|)
    Space complexity: O(1) additional

    Args:
        S: Support set (nonempty list of natural numbers)
        w: Weight function mapping each n in S to a real number

    Returns:
        Tropical order of vanishing at s=1

    Examples:
        >>> tropical_analytic_rank([2, 3, 5], {2: 0.3, 3: 0.3, 5: 0.7})
        1
        >>> tropical_analytic_rank([2, 3, 5], {2: 0.3, 3: 0.5, 5: 0.7})
        0
    """
    if not S:
        raise ValueError("Support set S must be nonempty")
    m = min(w[n] for n in S)
    count = sum(1 for n in S if w[n] == m)
    return count - 1


def tropical_residue(S: List[int], w: Dict[int, float]) -> float:
    """
    Compute the tropical residue at s=1.

    This is simply the minimum weight over the support.

    Time complexity: O(|S|)
    Space complexity: O(1)

    Args:
        S: Support set (nonempty)
        w: Weight function

    Returns:
        min_{n in S} w(n)
    """
    return min(w[n] for n in S)


def active_set(S: List[int], w: Dict[int, float]) -> List[int]:
    """
    Compute the active set (ground states / minimizers).

    Time complexity: O(|S|)
    Space complexity: O(|S|)

    Args:
        S: Support set
        w: Weight function

    Returns:
        List of elements in S achieving the minimum weight
    """
    m = min(w[n] for n in S)
    return [n for n in S if w[n] == m]


def pointwise_min_profiles(
    I: List[int], S: List[int], v: Dict[int, Dict[int, float]]
) -> Dict[int, float]:
    """
    Compute the combined weight function w(n) = min_{i in I} v(i, n).

    Time complexity: O(|I| * |S|)
    Space complexity: O(|S|)

    Args:
        I: Generator index set
        S: Support set
        v: Valuation profiles v[i][n]

    Returns:
        Combined weight dictionary
    """
    return {n: min(v[i][n] for i in I) for n in S}


def verify_tropical_independence(
    I: List[int], S: List[int], v: Dict[int, Dict[int, float]]
) -> bool:
    """
    Check tropical independence: distinct generators have distinct profiles.

    Time complexity: O(|I|^2 * |S|)
    Space complexity: O(1)

    Args:
        I: Generator index set
        S: Support set
        v: Valuation profiles

    Returns:
        True if all pairs of generators have distinguishing support elements
    """
    for idx_a, i in enumerate(I):
        for j in I[idx_a + 1 :]:
            if all(v[i][n] == v[j][n] for n in S):
                return False
    return True


def verify_genericity(
    I: List[int], S: List[int], v: Dict[int, Dict[int, float]]
) -> bool:
    """
    Check the genericity condition: |active_set| = |I| + 1.

    Time complexity: O(|I| * |S|)

    Args:
        I: Generator index set
        S: Support set
        v: Valuation profiles

    Returns:
        True if genericity holds
    """
    w = pointwise_min_profiles(I, S, v)
    A = active_set(S, w)
    return len(A) == len(I) + 1


def verify_tropical_bsd(
    I: List[int], S: List[int], v: Dict[int, Dict[int, float]]
) -> Tuple[bool, dict]:
    """
    Full verification of the tropical BSD identity.

    Checks:
    1. Tropical independence of profiles
    2. Genericity condition
    3. Equality of tropical analytic rank and algebraic rank

    Time complexity: O(|I|^2 * |S|)

    Args:
        I: Generator index set
        S: Support set
        v: Valuation profiles

    Returns:
        Tuple of (bsd_holds, diagnostics_dict)
    """
    w = pointwise_min_profiles(I, S, v)
    A = active_set(S, w)
    tord = len(A) - 1
    rank = len(I)

    diagnostics = {
        "combined_weights": w,
        "active_set": A,
        "active_count": len(A),
        "tropical_analytic_rank": tord,
        "tropical_algebraic_rank": rank,
        "independence": verify_tropical_independence(I, S, v),
        "genericity": len(A) == rank + 1,
        "bsd_holds": tord == rank,
        "residue": tropical_residue(S, w),
    }

    return diagnostics["bsd_holds"], diagnostics


def tropical_l_series_eval(
    S: List[int], w: Dict[int, float], s: float
) -> Tuple[float, List[int]]:
    """
    Evaluate the tropical L-series at parameter s and return active branches.

    T_w(s) = min_{n in S} (w(n) + (s-1) * log(n))

    Time complexity: O(|S|)

    Args:
        S: Support set
        w: Weight function
        s: Real parameter

    Returns:
        Tuple of (T_w(s), list of active branches at s)
    """
    values = {n: w[n] + (s - 1) * math.log(n) for n in S}
    t = min(values.values())
    active = [n for n, val in values.items() if abs(val - t) < 1e-12]
    return t, active


def lower_envelope_breakpoints(
    S: List[int], w: Dict[int, float], s_min: float = -2.0, s_max: float = 4.0
) -> List[Tuple[float, int, int]]:
    """
    Find breakpoints of the lower envelope T_w(s).

    At a breakpoint, the minimizing branch changes. Each breakpoint corresponds
    to a "tropical zero" of the L-series.

    The breakpoint between branches n1 and n2 occurs at:
        s* = 1 + (w(n2) - w(n1)) / (log(n1) - log(n2))  when log(n1) != log(n2)

    Time complexity: O(|S|^2 log |S|)

    Args:
        S: Support set (must have distinct elements > 0)
        w: Weight function
        s_min, s_max: Range to search for breakpoints

    Returns:
        List of (s_breakpoint, left_branch, right_branch) tuples, sorted by s
    """
    breakpoints = []
    for i, n1 in enumerate(S):
        for n2 in S[i + 1 :]:
            log_n1 = math.log(n1)
            log_n2 = math.log(n2)
            if abs(log_n1 - log_n2) < 1e-15:
                continue
            # w(n1) + (s-1)*log(n1) = w(n2) + (s-1)*log(n2)
            # s - 1 = (w(n2) - w(n1)) / (log(n1) - log(n2))
            s_star = 1.0 + (w[n2] - w[n1]) / (log_n1 - log_n2)
            if s_min <= s_star <= s_max:
                breakpoints.append((s_star, n1, n2))

    breakpoints.sort()
    return breakpoints


def construct_generic_profiles(
    rank: int, support_size: int
) -> Tuple[List[int], List[int], Dict[int, Dict[int, float]]]:
    """
    Construct valuation profiles satisfying the genericity condition.

    Strategy: For rank r and support size s >= r+1, construct profiles where
    generator i has weight 0 at support elements {i, r+1} and weight 1 elsewhere.
    This ensures exactly r+1 elements achieve the minimum combined weight 0.

    Time complexity: O(rank * support_size)

    Args:
        rank: Desired tropical rank (number of generators)
        support_size: Size of support set (must be >= rank + 1)

    Returns:
        Tuple of (I, S, v) satisfying genericity

    Raises:
        ValueError: If support_size < rank + 1
    """
    if support_size < rank + 1:
        raise ValueError(f"Need support_size >= rank + 1, got {support_size} < {rank + 1}")

    S = list(range(2, 2 + support_size))  # primes starting from 2
    I = list(range(1, 1 + rank))

    v: Dict[int, Dict[int, float]] = {}
    for i in I:
        profile: Dict[int, float] = {}
        for idx, n in enumerate(S):
            # Generator i has weight 0 at position i-1 and at position rank
            if idx == i - 1 or idx == rank:
                profile[n] = 0.0
            else:
                profile[n] = 1.0
        v[i] = profile

    return I, S, v


def residue_decomposition_check(
    S: List[int], profiles: List[Dict[int, float]]
) -> Tuple[float, float, bool]:
    """
    Verify the residue decomposition theorem for multiple profiles.

    Checks that res(min(w1, w2, ...)) = min(res(w1), res(w2), ...)

    Args:
        S: Support set
        profiles: List of weight functions

    Returns:
        Tuple of (lhs, rhs, match)
    """
    # LHS: residue of pointwise min
    combined = {n: min(p[n] for p in profiles) for n in S}
    lhs = tropical_residue(S, combined)

    # RHS: min of individual residues
    rhs = min(tropical_residue(S, p) for p in profiles)

    return lhs, rhs, abs(lhs - rhs) < 1e-15


# ─── Example usage ───

if __name__ == "__main__":
    print("=== Tropical BSD Algorithms ===\n")

    # Example 1: Basic tropical analytic rank
    S = [2, 3, 5, 7]
    w = {2: 0.3, 3: 0.3, 5: 0.3, 7: 0.8}
    print(f"Support: {S}")
    print(f"Weights: {w}")
    print(f"Tropical analytic rank: {tropical_analytic_rank(S, w)}")
    print(f"Active set: {active_set(S, w)}")
    print(f"Residue: {tropical_residue(S, w)}")

    # Example 2: Construct generic profiles for rank 3
    print(f"\n--- Constructing generic rank-3 profiles ---")
    I, S, v = construct_generic_profiles(rank=3, support_size=6)
    bsd_holds, diag = verify_tropical_bsd(I, S, v)
    print(f"Generators: {I}")
    print(f"Support: {S}")
    print(f"Independence: {diag['independence']}")
    print(f"Genericity: {diag['genericity']}")
    print(f"Active set: {diag['active_set']}")
    print(f"Tropical analytic rank: {diag['tropical_analytic_rank']}")
    print(f"Tropical algebraic rank: {diag['tropical_algebraic_rank']}")
    print(f"BSD holds: {bsd_holds}")

    # Example 3: Breakpoints
    print(f"\n--- Lower envelope breakpoints ---")
    S = [2, 3, 5]
    w = {2: 0.5, 3: 0.2, 5: 0.8}
    bps = lower_envelope_breakpoints(S, w)
    print(f"Breakpoints: {[(f'{s:.3f}', n1, n2) for s, n1, n2 in bps]}")

    # Example 4: Residue decomposition
    print(f"\n--- Residue decomposition ---")
    S = [2, 3, 5, 7]
    profiles = [
        {2: 1.0, 3: 0.5, 5: 0.8, 7: 0.6},
        {2: 0.3, 3: 0.9, 5: 0.7, 7: 0.4},
        {2: 0.8, 3: 0.6, 5: 0.2, 7: 0.9},
    ]
    lhs, rhs, match = residue_decomposition_check(S, profiles)
    print(f"LHS (res of min): {lhs}")
    print(f"RHS (min of res): {rhs}")
    print(f"Match: {match}")
