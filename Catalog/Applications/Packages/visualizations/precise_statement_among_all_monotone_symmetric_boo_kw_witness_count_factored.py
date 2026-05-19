#!/usr/bin/env python3
"""
Algorithms for KW Witness Counting and Extremal Analysis.

Implements efficient computation of:
  - KW witness counts for threshold functions
  - Majority witness asymptotics
  - Transport cost (W1) comparison
  - Extremal profile analysis
"""

from math import comb, sqrt, pi, log2, log, factorial, lgamma
from typing import List, Tuple, Optional, Dict
import functools


# ============================================================================
# Algorithm 1: KW Witness Count (Direct)
# ============================================================================

def kw_witness_count_direct(n: int, t: int) -> int:
    """
    Compute the KW witness count for threshold function Thresh(n, t).

    Algorithm: Direct double sum over layer pairs.

    Time complexity: O(n^2) multiplications of large integers.
    Space complexity: O(1) beyond input.

    Args:
        n: Number of Boolean variables
        t: Threshold parameter (accept inputs with weight >= t)

    Returns:
        Total number of KW witnesses

    Examples:
        >>> kw_witness_count_direct(3, 2)
        27
        >>> kw_witness_count_direct(1, 1)
        1
        >>> kw_witness_count_direct(5, 3)
        605
    """
    if n == 0 or t <= 0 or t > n:
        return 0

    total = 0
    for k in range(t, n + 1):
        for l in range(0, t):
            total += comb(n - 1, k - 1) * comb(n - 1, l)
    return n * total


# ============================================================================
# Algorithm 2: KW Witness Count (Factored)
# ============================================================================

def kw_witness_count_factored(n: int, t: int) -> int:
    """
    Compute the KW witness count using the factored formula.

    The double sum factors because the two index sets are independent:
      W(n,t) = n * (sum_{j=t-1}^{n-1} C(n-1,j)) * (sum_{l=0}^{t-1} C(n-1,l))

    Time complexity: O(n) multiplications.
    Space complexity: O(1).

    Args:
        n: Number of Boolean variables
        t: Threshold parameter

    Returns:
        Total number of KW witnesses

    Examples:
        >>> kw_witness_count_factored(3, 2)
        27
        >>> kw_witness_count_factored(7, 4)
        12348
    """
    if n == 0 or t <= 0 or t > n:
        return 0

    upper_sum = sum(comb(n - 1, j) for j in range(t - 1, n))
    lower_sum = sum(comb(n - 1, l) for l in range(0, t))
    return n * upper_sum * lower_sum


# ============================================================================
# Algorithm 3: Majority Witness Count
# ============================================================================

def kw_majority(n: int) -> int:
    """
    Compute the KW witness count for the majority function.

    The majority function on n variables accepts inputs with weight >= ceil(n/2).

    Args:
        n: Number of variables (works for both odd and even n)

    Returns:
        Majority witness count

    Examples:
        >>> kw_majority(3)
        27
        >>> kw_majority(5)
        605
    """
    t = (n + 1) // 2
    return kw_witness_count_factored(n, t)


# ============================================================================
# Algorithm 4: Asymptotic Approximation
# ============================================================================

def kw_majority_asymptotic(n: int) -> float:
    """
    Asymptotic approximation of the majority witness count.

    Uses the formula: W(Maj_n) ~ n * 4^n / 16

    For odd n = 2m+1, the exact formula is:
      W = n * ((2^{2m} + C(2m,m)) / 2)^2

    The dominant term is n * 4^{n-2} = n * 4^n / 16, with a correction
    factor (1 + C(2m,m)/4^m)^2 that converges to 1.

    Time complexity: O(1).
    Space complexity: O(1).

    Args:
        n: Number of variables

    Returns:
        Approximate majority witness count as a float
    """
    if n <= 0:
        return 0.0
    return n * (4.0 ** n) / 16.0


def kw_majority_log2_asymptotic(n: int) -> float:
    """
    Asymptotic approximation of log2(W(Maj_n)).

    Result: log2(W(Maj_n)) = 2n + log2(n) - 4 + o(1)

    Args:
        n: Number of variables

    Returns:
        Approximate log2 of majority witness count
    """
    if n <= 1:
        return 0.0
    return 2 * n + log2(n) - 4


# ============================================================================
# Algorithm 5: W1 Transport Cost
# ============================================================================

def w1_transport_cost(n: int, t: int) -> int:
    """
    Compute the W1 (Wasserstein-1) transport cost for threshold t.

    W1(n,t) = sum_{k>=t, l<t} C(n,k) * C(n,l) * |k-l|

    This counts the "naive earthmover cost" between the true and false
    layer distributions across the threshold interface.

    Time complexity: O(n^2).
    Space complexity: O(1).

    Args:
        n: Number of variables
        t: Threshold parameter

    Returns:
        W1 transport cost
    """
    if t <= 0 or t > n:
        return 0

    total = 0
    for k in range(t, n + 1):
        for l in range(0, t):
            total += comb(n, k) * comb(n, l) * (k - l)
    return total


# ============================================================================
# Algorithm 6: KW/W1 Ratio Analysis
# ============================================================================

def kw_w1_ratio(n: int, t: int) -> Optional[float]:
    """
    Compute the ratio KW(n,t) / W1(n,t).

    The conjecture is that this ratio converges to a constant rho(alpha)
    as n -> infinity with t = floor(alpha * n).

    Args:
        n: Number of variables
        t: Threshold parameter

    Returns:
        The ratio, or None if W1 = 0
    """
    kw = kw_witness_count_factored(n, t)
    w1 = w1_transport_cost(n, t)
    if w1 == 0:
        return None
    return kw / w1


def kw_w1_ratio_sequence(alpha: float, n_values: List[int]) -> List[Tuple[int, float]]:
    """
    Compute the KW/W1 ratio along the sequence t = floor(alpha * n).

    Args:
        alpha: Density parameter in (0, 1)
        n_values: List of n values to compute for

    Returns:
        List of (n, ratio) pairs
    """
    results = []
    for n in n_values:
        t = max(1, min(n, int(alpha * n)))
        ratio = kw_w1_ratio(n, t)
        if ratio is not None:
            results.append((n, ratio))
    return results


# ============================================================================
# Algorithm 7: Extremal Analysis
# ============================================================================

def find_extremal_threshold(n: int) -> Tuple[int, int]:
    """
    Find the threshold that maximizes the KW witness count for given n.

    By the symmetry W(n,t) = W(n, n+1-t) and unimodality,
    the maximum is at or near the center.

    Time complexity: O(n^2) to compute all witness counts.
    Space complexity: O(n).

    Args:
        n: Number of variables

    Returns:
        Tuple of (optimal threshold t, maximum witness count)
    """
    best_t = 0
    best_w = 0
    for t in range(0, n + 2):
        w = kw_witness_count_factored(n, t)
        if w > best_w:
            best_w = w
            best_t = t
    return best_t, best_w


def monotone_profile_classification(n: int) -> List[Tuple[int, List[bool]]]:
    """
    Enumerate all monotone profiles on n+1 layers, confirming each is a threshold.

    A monotone profile p: {0,...,n} -> Bool with p(i) <= p(j) for i <= j
    is exactly a threshold profile. There are n+2 such profiles.

    Time complexity: O(n).
    Space complexity: O(n).

    Args:
        n: Number of variables

    Returns:
        List of (threshold t, profile) pairs, sorted by t
    """
    profiles = []
    for t in range(0, n + 2):
        profile = [i >= t for i in range(n + 1)]
        profiles.append((t, profile))
    return profiles


# ============================================================================
# Algorithm 8: Witness Entropy
# ============================================================================

def witness_entropy(n: int, t: int) -> float:
    """
    Compute the normalized witness entropy: log2(W(n,t)) / n.

    This quantity measures the "information content per variable" of the
    witness set. For majority, it approaches 2 - (1/2n) log2(n).

    Args:
        n: Number of variables
        t: Threshold parameter

    Returns:
        Normalized witness entropy
    """
    w = kw_witness_count_factored(n, t)
    if w <= 0 or n <= 0:
        return 0.0
    return log2(w) / n


# ============================================================================
# Main: Run all algorithms with examples
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("  ALGORITHMS FOR KW WITNESS COUNTING")
    print("=" * 70)

    # Verify factored formula matches direct computation
    print("\n--- Factorization Verification ---")
    for n in range(1, 15):
        for t in range(1, n + 1):
            d = kw_witness_count_direct(n, t)
            f = kw_witness_count_factored(n, t)
            assert d == f, f"Mismatch at n={n}, t={t}: {d} vs {f}"
    print("Direct and factored formulas agree for n=1..14 ✓")

    # Majority witness counts
    print("\n--- Majority Witness Counts ---")
    print(f"{'n':>5} | {'Exact':>18} | {'Asymptotic':>18} | {'Rel Error':>12}")
    print("-" * 60)
    for n in range(3, 30, 2):
        exact = kw_majority(n)
        approx = kw_majority_asymptotic(n)
        err = abs(exact - approx) / exact if exact > 0 else 0
        print(f"{n:>5} | {exact:>18} | {approx:>18.2f} | {err:>12.6f}")

    # KW/W1 ratio convergence
    print("\n--- KW/W1 Ratio at alpha=0.5 ---")
    n_vals = list(range(3, 50, 2))
    ratios = kw_w1_ratio_sequence(0.5, n_vals)
    for n, r in ratios:
        print(f"  n={n:>3}: KW/W1 = {r:.8f}")

    # Extremal thresholds
    print("\n--- Extremal Thresholds ---")
    for n in range(2, 20):
        opt_t, opt_w = find_extremal_threshold(n)
        maj_t = (n + 1) // 2
        print(f"  n={n:>2}: optimal t={opt_t}, majority t={maj_t}, "
              f"W_max={opt_w}, {'✓ match' if opt_t == maj_t else '! differ'}")

    # Witness entropy
    print("\n--- Witness Entropy for Majority ---")
    for n in range(3, 40, 2):
        ent = witness_entropy(n, (n + 1) // 2)
        print(f"  n={n:>3}: H(Maj)/n = {ent:.6f}, limit = {2 - 0.5*log2(n)/n:.6f}")
