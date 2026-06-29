#!/usr/bin/env python3
"""
Proof Expansion Constants: Core Algorithms

Implements the algorithmic pipeline for computing strengthening distances,
proof-cost ratios, and candidate lower-envelope expansion constants.

All algorithms include docstrings, type hints, and example usage.
"""

import math
from typing import Callable, Dict, List, Optional, Tuple


# ============================================================================
# Algorithm 1: Empirical Expansion Constant Estimation
# ============================================================================

def estimate_expansion_constant(
    cost: Callable[[int], int],
    lo: int = 1,
    hi: int = 20,
    *,
    exclude_edge: int = 0
) -> Dict[str, float]:
    """
    Estimate the binary expansion constant for a cost function.

    Given a cost function c : ℕ → ℕ, computes the expansion constant β
    defined as the largest value such that:
        β^(n-m) * c(m) ≤ c(n)  for all lo ≤ m < n ≤ hi.

    This is equivalent to:
        β = min_{m < n} (c(n)/c(m))^(1/(n-m))

    Args:
        cost: Cost function mapping natural numbers to natural numbers.
        lo: Lower bound of the index range (default 1 to avoid c(0) = 0 issues).
        hi: Upper bound of the index range.
        exclude_edge: Exclude pairs where m < exclude_edge (avoids edge effects).

    Returns:
        Dictionary with:
        - 'beta': The estimated expansion constant.
        - 'min_pair': The (m, n) pair achieving the minimum.
        - 'min_ratio': The ratio c(n)/c(m) at the minimum pair.
        - 'all_bases': List of per-unit bases for all pairs.

    Example:
        >>> result = estimate_expansion_constant(lambda n: 2**n, 0, 10)
        >>> abs(result['beta'] - 2.0) < 1e-10
        True
    """
    min_base = float('inf')
    min_pair = (lo, lo + 1)
    min_ratio = 1.0
    all_bases: List[Tuple[int, int, float]] = []

    for m in range(max(lo, exclude_edge), hi):
        cm = cost(m)
        if cm <= 0:
            continue
        for n in range(m + 1, hi + 1):
            cn = cost(n)
            if cn <= 0:
                continue
            ratio = cn / cm
            gap = n - m
            base = ratio ** (1.0 / gap)
            all_bases.append((m, n, base))
            if base < min_base:
                min_base = base
                min_pair = (m, n)
                min_ratio = ratio

    return {
        'beta': min_base,
        'min_pair': min_pair,
        'min_ratio': min_ratio,
        'all_bases': all_bases,
    }


# ============================================================================
# Algorithm 2: Model Shrinkage Distance
# ============================================================================

def model_shrinkage_distance(model_set_a: set, model_set_b: set) -> int:
    """
    Compute the model shrinkage distance between two model sets.

    If B ⊆ A (B represents a stronger statement), the shrinkage distance
    is |A| - |B|, measuring how many models are eliminated by strengthening.

    Args:
        model_set_a: The model set of the weaker statement.
        model_set_b: The model set of the stronger statement.

    Returns:
        The shrinkage distance max(0, |A| - |B|).

    Example:
        >>> model_shrinkage_distance({1,2,3,4,5}, {1,2,3})
        2
    """
    return max(0, len(model_set_a) - len(model_set_b))


def verify_shrinkage_additivity(
    chain: List[set]
) -> Tuple[bool, Optional[Tuple[int, int, int]]]:
    """
    Verify that model shrinkage distance is additive along a nested chain.

    For sets S_0 ⊇ S_1 ⊇ ... ⊇ S_k, checks that:
        d(S_i, S_k) = d(S_i, S_j) + d(S_j, S_k)
    for all i < j < k.

    Args:
        chain: A list of sets, each a subset of the previous.

    Returns:
        (True, None) if additive, or (False, (i, j, k)) for a counterexample.

    Example:
        >>> s0 = {1,2,3,4,5}
        >>> s1 = {1,2,3}
        >>> s2 = {1}
        >>> verify_shrinkage_additivity([s0, s1, s2])
        (True, None)
    """
    for i in range(len(chain)):
        for j in range(i + 1, len(chain)):
            for k in range(j + 1, len(chain)):
                d_ik = model_shrinkage_distance(chain[i], chain[k])
                d_ij = model_shrinkage_distance(chain[i], chain[j])
                d_jk = model_shrinkage_distance(chain[j], chain[k])
                if d_ik != d_ij + d_jk:
                    return False, (i, j, k)
    return True, None


# ============================================================================
# Algorithm 3: Lower Envelope Detection
# ============================================================================

def detect_lower_envelope(
    cost: Callable[[int], int],
    lo: int = 0,
    hi: int = 20,
    candidate_bases: Optional[List[float]] = None,
    tolerance: float = 1e-6
) -> Dict[str, object]:
    """
    Detect and classify the lower envelope of a cost function.

    Tests whether the cost function admits exponential expansion with
    various candidate bases. Returns the largest base that passes.

    Args:
        cost: Cost function mapping natural numbers to natural numbers.
        lo: Lower bound of the index range.
        hi: Upper bound of the index range.
        candidate_bases: List of bases to test (default: 1.1 to 10.0).
        tolerance: Multiplicative tolerance for the test.

    Returns:
        Dictionary with:
        - 'max_valid_base': Largest base passing the expansion test.
        - 'classification': 'none', 'subexponential', 'exponential', or 'superexponential'.
        - 'base_results': Dict mapping base to pass/fail.

    Example:
        >>> result = detect_lower_envelope(lambda n: 2**n, 0, 10)
        >>> result['classification']
        'exponential'
    """
    if candidate_bases is None:
        candidate_bases = [1.0 + 0.1 * i for i in range(1, 100)]

    base_results = {}
    max_valid = 1.0

    for b in candidate_bases:
        passes = True
        for m in range(lo, hi):
            cm = cost(m)
            for n in range(m + 1, hi + 1):
                cn = cost(n)
                if b ** (n - m) * cm > cn * (1 + tolerance):
                    passes = False
                    break
            if not passes:
                break
        base_results[b] = passes
        if passes:
            max_valid = max(max_valid, b)

    # Classify
    if max_valid <= 1.05:
        classification = 'none'
    elif max_valid < 1.5:
        classification = 'subexponential'
    elif max_valid <= 10.0:
        classification = 'exponential'
    else:
        classification = 'superexponential'

    return {
        'max_valid_base': max_valid,
        'classification': classification,
        'base_results': base_results,
    }


# ============================================================================
# Algorithm 4: Expansion Slope Computation
# ============================================================================

def expansion_slope(c1: int, c2: int, d: int) -> float:
    """
    Compute the normalized expansion slope.

    σ(c₁, c₂, d) = c₂ / (c₁ * d)

    This measures the average proof-cost growth per unit of strengthening.

    Args:
        c1: Proof cost of the weaker statement.
        c2: Proof cost of the stronger statement.
        d: Semantic distance between the statements.

    Returns:
        The expansion slope as a float.

    Raises:
        ValueError: If c1 or d is zero.

    Example:
        >>> expansion_slope(1, 1024, 10)
        102.4
    """
    if c1 == 0 or d == 0:
        raise ValueError("c1 and d must be positive")
    return c2 / (c1 * d)


def expansion_slope_matrix(
    cost: Callable[[int], int],
    lo: int = 0,
    hi: int = 10
) -> List[List[Optional[float]]]:
    """
    Compute the expansion slope matrix for all pairs (m, n).

    Returns a matrix M where M[m-lo][n-lo] = σ(cost(m), cost(n), n-m).

    Args:
        cost: Cost function.
        lo: Lower bound of range.
        hi: Upper bound of range.

    Returns:
        Matrix of expansion slopes (None on diagonal and below).

    Example:
        >>> M = expansion_slope_matrix(lambda n: 2**n, 0, 5)
        >>> M[0][5]  # σ(1, 32, 5) = 6.4
        6.4
    """
    size = hi - lo + 1
    matrix = [[None] * size for _ in range(size)]
    for i in range(size):
        for j in range(i + 1, size):
            m = lo + i
            n = lo + j
            cm = cost(m)
            cn = cost(n)
            d = n - m
            if cm > 0 and d > 0:
                matrix[i][j] = cn / (cm * d)
    return matrix


# ============================================================================
# Algorithm 5: Hierarchy Transfer
# ============================================================================

def verify_expansion_transfer(
    cost_a: Callable[[int], int],
    cost_b: Callable[[int], int],
    f: Callable[[int], int],
    base: float,
    lo: int = 0,
    hi: int = 10
) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """
    Verify the expansion transfer principle.

    Checks that if cost_B satisfies base-expansion under embedding f,
    and cost_A ≤ cost_B ∘ f, then the bound transfers.

    Specifically, checks:
        base^(f(n)-f(m)) * cost_A(m) ≤ cost_B(f(n))
    for all lo ≤ m ≤ n ≤ hi.

    Args:
        cost_a: Source cost function.
        cost_b: Target cost function.
        f: Monotone embedding.
        base: Expansion base.
        lo: Lower bound.
        hi: Upper bound.

    Returns:
        (True, None) if transfer holds, or (False, (m, n)) for a counterexample.

    Example:
        >>> verify_expansion_transfer(
        ...     lambda n: 2**n, lambda n: 3**n, lambda n: n, 2.0, 0, 10
        ... )
        (True, None)
    """
    for m in range(lo, hi + 1):
        for n in range(m, hi + 1):
            fm = f(m)
            fn = f(n)
            lhs = base ** (fn - fm) * cost_a(m)
            rhs = cost_b(fn)
            if lhs > rhs * 1.0001:
                return False, (m, n)
    return True, None


# ============================================================================
# Algorithm 6: Gap Distribution Analysis
# ============================================================================

def gap_distribution(
    cost: Callable[[int], int],
    lo: int = 0,
    hi: int = 20
) -> Dict[int, Dict[str, float]]:
    """
    Analyze the distribution of expansion ratios by gap size.

    For each gap d = 1, 2, ..., hi-lo, computes statistics of the
    expansion ratio c(n)/c(m) over all pairs with n - m = d.

    Args:
        cost: Cost function.
        lo: Lower bound.
        hi: Upper bound.

    Returns:
        Dictionary mapping gap size to statistics:
        - 'min': Minimum ratio for this gap.
        - 'max': Maximum ratio for this gap.
        - 'mean': Mean ratio for this gap.
        - 'min_base': Minimum per-unit base.

    Example:
        >>> stats = gap_distribution(lambda n: 2**n, 0, 10)
        >>> abs(stats[1]['min'] - 2.0) < 1e-10
        True
    """
    result = {}
    for d in range(1, hi - lo + 1):
        ratios = []
        for m in range(lo, hi - d + 1):
            n = m + d
            cm = cost(m)
            cn = cost(n)
            if cm > 0:
                ratios.append(cn / cm)
        if ratios:
            result[d] = {
                'min': min(ratios),
                'max': max(ratios),
                'mean': sum(ratios) / len(ratios),
                'min_base': min(ratios) ** (1.0 / d),
            }
    return result


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    # Example 1: Expansion constant estimation
    print("1. Expansion constant for doubling hierarchy (2^n):")
    result = estimate_expansion_constant(lambda n: 2**n, 0, 15)
    print(f"   β = {result['beta']:.6f}")
    print(f"   Achieved at pair {result['min_pair']}")
    print()

    # Example 2: Model shrinkage
    print("2. Model shrinkage distance:")
    A = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    B = {1, 2, 3, 4, 5}
    C = {1, 2}
    print(f"   d(A, B) = {model_shrinkage_distance(A, B)}")
    print(f"   d(B, C) = {model_shrinkage_distance(B, C)}")
    print(f"   d(A, C) = {model_shrinkage_distance(A, C)}")
    print(f"   Additivity: d(A,C) = d(A,B) + d(B,C) ? "
          f"{model_shrinkage_distance(A,C) == model_shrinkage_distance(A,B) + model_shrinkage_distance(B,C)}")
    valid, cex = verify_shrinkage_additivity([A, B, C])
    print(f"   Chain additivity verified: {valid}")
    print()

    # Example 3: Lower envelope detection
    print("3. Lower envelope detection:")
    for name, cost in [("2^n", lambda n: 2**n),
                       ("n^2+1", lambda n: n**2+1),
                       ("n!", math.factorial)]:
        result = detect_lower_envelope(cost, 1, 12)
        print(f"   {name}: max_base={result['max_valid_base']:.2f}, "
              f"class={result['classification']}")
    print()

    # Example 4: Expansion slope
    print("4. Expansion slope matrix (2^n, indices 0-5):")
    M = expansion_slope_matrix(lambda n: 2**n, 0, 5)
    print("   m\\n |", end="")
    for j in range(6):
        print(f"   {j:5d}", end="")
    print()
    for i in range(6):
        print(f"   {i:3d} |", end="")
        for j in range(6):
            if M[i][j] is not None:
                print(f"  {M[i][j]:5.1f}", end="")
            else:
                print(f"  {'---':>5}", end="")
        print()
    print()

    # Example 5: Transfer verification
    print("5. Transfer principle verification:")
    valid, cex = verify_expansion_transfer(
        lambda n: 2**n, lambda n: 3**n, lambda n: n, 2.0, 0, 10
    )
    print(f"   2^n → 3^n with identity embedding, base 2: {'PASS' if valid else f'FAIL at {cex}'}")
    print()

    # Example 6: Gap distribution
    print("6. Gap distribution for doubling hierarchy:")
    stats = gap_distribution(lambda n: 2**n, 0, 10)
    for d in [1, 2, 5, 10]:
        if d in stats:
            s = stats[d]
            print(f"   gap={d}: min_ratio={s['min']:.1f}, "
                  f"min_base={s['min_base']:.4f}")
