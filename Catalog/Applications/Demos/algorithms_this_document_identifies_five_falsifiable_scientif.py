#!/usr/bin/env python3
"""
algorithms.py — Efficient algorithms for KW witness counting on symmetric Boolean functions.

Implements the exact formulas proven in the formal verification, plus
asymptotic estimation and profile optimization routines.
"""

from math import comb, log2, factorial, sqrt, pi
from typing import Callable


# ─────────────────────────────────────────────────────────────
#  CORE: Exact Witness Counting
# ─────────────────────────────────────────────────────────────

def fiber_tf(n: int, k: int, l: int) -> int:
    """Per-fiber witness count: true→false orientation.
    
    Counts triples (x, y, i) where:
      - x has Hamming weight k
      - y has Hamming weight l
      - x_i = True and y_i = False
    
    Formula: n * C(n-1, k-1) * C(n-1, l) when k ≥ 1, else 0.
    
    Time: O(1) after precomputing binomial coefficients.
    Space: O(1).
    
    Args:
        n: Number of Boolean variables.
        k: Weight of x.
        l: Weight of y.
    
    Returns:
        Number of witness triples in this orientation.
    """
    if k == 0:
        return 0
    return n * comb(n - 1, k - 1) * comb(n - 1, l)


def fiber_ft(n: int, k: int, l: int) -> int:
    """Per-fiber witness count: false→true orientation.
    
    Counts triples (x, y, i) where:
      - x has Hamming weight k
      - y has Hamming weight l
      - x_i = False and y_i = True
    
    Formula: n * C(n-1, k) * C(n-1, l-1) when l ≥ 1, else 0.
    
    Time: O(1).
    Space: O(1).
    """
    if l == 0:
        return 0
    return n * comb(n - 1, k) * comb(n - 1, l - 1)


def fiber_total(n: int, k: int, l: int) -> int:
    """Total per-fiber witness count for weight pair (k, l).
    
    Time: O(1).
    Space: O(1).
    """
    return fiber_tf(n, k, l) + fiber_ft(n, k, l)


def kw_witness_count_symmetric(n: int, profile: list[bool]) -> int:
    """Exact KW witness count for a symmetric Boolean function.
    
    Given a profile p : {0, ..., n} → {True, False}, computes:
      |KWWitness(f)| = Σ_{k: p(k)=True} Σ_{l: p(l)=False} fiberTotal(n, k, l)
    
    This is the main theorem: card_KWWitness_eq_sum_correct.
    
    Time: O(n²).
    Space: O(1).
    
    Args:
        n: Number of variables.
        profile: List of length n+1; profile[k] is True iff f maps
                 weight-k vectors to True.
    
    Returns:
        Exact KW witness count.
    
    Example:
        >>> kw_witness_count_symmetric(3, [False, False, True, True])  # Thresh(3,2)
        30
    """
    assert len(profile) == n + 1, f"Profile length must be {n + 1}, got {len(profile)}"
    total = 0
    for k in range(n + 1):
        if not profile[k]:
            continue
        for l in range(n + 1):
            if profile[l]:
                continue
            total += fiber_total(n, k, l)
    return total


def kw_witness_count_threshold(n: int, t: int) -> int:
    """Exact KW witness count for the threshold function Thresh(n, t).
    
    f(x) = True iff hamming_weight(x) ≥ t.
    
    Specialization of the symmetric formula with profile p(k) = (k ≥ t).
    
    Time: O(n²).
    Space: O(1).
    
    Args:
        n: Number of variables.
        t: Threshold (1 ≤ t ≤ n for non-trivial results).
    
    Returns:
        Exact KW witness count.
    
    Example:
        >>> kw_witness_count_threshold(3, 2)
        30
    """
    profile = [k >= t for k in range(n + 1)]
    return kw_witness_count_symmetric(n, profile)


# ─────────────────────────────────────────────────────────────
#  DECOMPOSITION: Fiber Analysis
# ─────────────────────────────────────────────────────────────

def fiber_decomposition(n: int, profile: list[bool]) -> dict:
    """Full fiber decomposition of KW witness count.
    
    Returns a dictionary mapping (k, l) pairs to their fiber contributions,
    broken down by orientation (TF and FT).
    
    Time: O(n²).
    Space: O(n²).
    
    Args:
        n: Number of variables.
        profile: Boolean profile of length n+1.
    
    Returns:
        Dictionary with keys (k, l) and values {tf, ft, total}.
    """
    result = {}
    for k in range(n + 1):
        if not profile[k]:
            continue
        for l in range(n + 1):
            if profile[l]:
                continue
            tf = fiber_tf(n, k, l)
            ft = fiber_ft(n, k, l)
            result[(k, l)] = {"tf": tf, "ft": ft, "total": tf + ft}
    return result


def boundary_contribution(n: int, t: int) -> int:
    """Contribution of the boundary layer pair (t, t-1) alone.
    
    This equals C(n,t) * C(n,t-1), which is a lower bound on |KWWitness(Thresh(n,t))|.
    
    Proven formally as choose_mul_choose_le_card_KWWitness_threshold.
    """
    return comb(n, t) * comb(n, t - 1)


# ─────────────────────────────────────────────────────────────
#  ASYMPTOTICS: Central Limit Approximations
# ─────────────────────────────────────────────────────────────

def stirling_approx(n: int) -> float:
    """Stirling approximation to n!."""
    if n == 0:
        return 1.0
    return sqrt(2 * pi * n) * (n / 2.718281828) ** n


def central_binomial_approx(n: int) -> float:
    """Asymptotic approximation to C(n, n/2) ≈ 2^n / sqrt(πn/2)."""
    if n == 0:
        return 1.0
    return 2 ** n / sqrt(pi * n / 2)


def majority_witness_approx(n: int) -> float:
    """Asymptotic approximation of |KWWitness(Maj_n)|.
    
    For the majority function, the dominant contribution comes from
    weight pairs near n/2. The leading term is approximately:
      2^(2n) / (πn/2) * correction_factor
    
    This gives log₂|KW(Maj_n)| ≈ 2n - log₂(πn/2).
    """
    t = (n + 1) // 2
    return float(kw_witness_count_threshold(n, t))


def witness_entropy(n: int, profile: list[bool]) -> float:
    """log₂ of the KW witness count (witness entropy).
    
    This quantity appears in communication complexity lower bounds:
    any protocol computing f on the KW relation must use at least
    log₂|KWWitness(f)| bits in some worst case.
    """
    count = kw_witness_count_symmetric(n, profile)
    return log2(count) if count > 0 else 0.0


# ─────────────────────────────────────────────────────────────
#  PROFILE OPTIMIZATION
# ─────────────────────────────────────────────────────────────

def maximize_witness_count(n: int, num_true_layers: int) -> tuple[list[bool], int]:
    """Find the monotone profile with exactly `num_true_layers` true layers
    that maximizes the KW witness count.
    
    For monotone profiles, the true layers form a contiguous block at the top.
    The threshold t = n + 1 - num_true_layers gives profile p(k) = (k ≥ t).
    Among all monotone profiles with fixed number of true layers, the threshold
    profile is unique, so this just evaluates it.
    
    Time: O(n²).
    
    Args:
        n: Number of variables.
        num_true_layers: Number of weight layers mapped to True.
    
    Returns:
        (optimal_profile, witness_count).
    """
    t = n + 1 - num_true_layers
    profile = [k >= t for k in range(n + 1)]
    count = kw_witness_count_symmetric(n, profile)
    return profile, count


def compare_all_symmetric_profiles(n: int) -> list[tuple[list[bool], int]]:
    """Enumerate all symmetric Boolean profiles on n variables and compute
    their KW witness counts.
    
    Time: O(2^n * n²). Only feasible for small n.
    
    Args:
        n: Number of variables.
    
    Returns:
        List of (profile, witness_count) sorted by witness count descending.
    """
    results = []
    for mask in range(2 ** (n + 1)):
        profile = [(mask >> k) & 1 == 1 for k in range(n + 1)]
        # Skip trivially empty (all true or all false)
        if all(profile) or not any(profile):
            continue
        count = kw_witness_count_symmetric(n, profile)
        results.append((profile, count))
    results.sort(key=lambda x: -x[1])
    return results


# ─────────────────────────────────────────────────────────────
#  EXAMPLE USAGE
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Threshold examples
    print("Threshold function witness counts:")
    for n in [5, 10, 20, 50, 100]:
        for t_frac in [0.25, 0.5, 0.75]:
            t = max(1, int(n * t_frac))
            count = kw_witness_count_threshold(n, t)
            entropy = log2(count) if count > 0 else 0
            lb = boundary_contribution(n, t)
            print(f"  Thresh({n},{t}): |KW| = {count}, log₂ = {entropy:.1f}, "
                  f"boundary_lb = {lb}, ratio = {count/lb:.3f}")
    
    # Profile comparison for small n
    print("\nAll profiles for n=4 (top 5 by witness count):")
    for profile, count in compare_all_symmetric_profiles(4)[:5]:
        label = "".join("1" if p else "0" for p in profile)
        print(f"  p = [{label}]: |KW| = {count}")
    
    # Fiber decomposition
    print("\nFiber decomposition for Thresh(5, 3):")
    fibers = fiber_decomposition(5, [k >= 3 for k in range(6)])
    for (k, l), data in sorted(fibers.items()):
        print(f"  (k={k}, l={l}): TF={data['tf']}, FT={data['ft']}, total={data['total']}")
