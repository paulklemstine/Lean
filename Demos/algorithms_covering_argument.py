#!/usr/bin/env python3
"""
Agreement Geometry Algorithms

Implementations of key algorithms for polynomial agreement geometry and list decoding.

Algorithms:
1. Brute-force list decoder for univariate Reed-Solomon codes
2. Agreement set computation and overlap analysis
3. Bonferroni list-size bound computation
4. Optimal agreement threshold computation
"""

from typing import List, Tuple, Dict, Set, Optional
import math


# ─── Algorithm 1: Brute-Force List Decoder ────────────────────────────────────

def brute_force_list_decode(
    p: int,
    eval_points: List[int],
    received: List[int],
    max_degree: int,
    agreement_threshold: int
) -> List[List[int]]:
    """
    Brute-force list decoder for Reed-Solomon codes over Z/pZ.

    Given a received word (possibly corrupted), finds all polynomials of
    degree ≤ max_degree that agree with the received word on at least
    `agreement_threshold` evaluation points.

    Parameters
    ----------
    p : int
        Prime field size.
    eval_points : List[int]
        Evaluation points s_1, ..., s_n in Z/pZ.
    received : List[int]
        Received word r_1, ..., r_n in Z/pZ.
    max_degree : int
        Maximum polynomial degree d.
    agreement_threshold : int
        Minimum number of agreements t.

    Returns
    -------
    List[List[int]]
        List of coefficient vectors [a_0, a_1, ..., a_d] of polynomials
        that agree with the received word on ≥ t points.

    Complexity
    ----------
    Time: O(p^(d+1) * n) — exhaustive search over all polynomials.
    Space: O(p^(d+1)) for storing results.

    Example
    -------
    >>> # RS(7, 3) code: degree ≤ 2 polynomials over F_7, evaluated at 0,...,6
    >>> # Message polynomial: p(x) = x^2 + 2x + 3
    >>> eval_pts = list(range(7))
    >>> codeword = [(x**2 + 2*x + 3) % 7 for x in eval_pts]
    >>> # Corrupt 2 positions
    >>> received = codeword[:]
    >>> received[0] = (received[0] + 1) % 7
    >>> received[1] = (received[1] + 2) % 7
    >>> # Decode with agreement threshold 5 (= 7 - 2 errors)
    >>> results = brute_force_list_decode(7, eval_pts, received, 2, 5)
    >>> assert [3, 2, 1] in results  # Original polynomial recovered
    """
    n = len(eval_points)
    assert len(received) == n
    assert all(0 <= r < p for r in received)
    assert all(0 <= s < p for s in eval_points)

    results = []

    def eval_poly(coeffs: List[int], x: int) -> int:
        """Evaluate polynomial at x over Z/pZ."""
        result = 0
        power = 1
        for c in coeffs:
            result = (result + c * power) % p
            power = (power * x) % p
        return result

    def count_agreements(coeffs: List[int]) -> int:
        """Count number of evaluation points where poly agrees with received."""
        return sum(
            1 for i, s in enumerate(eval_points)
            if eval_poly(coeffs, s) == received[i]
        )

    # Enumerate all polynomials of degree ≤ max_degree
    total_coeffs = max_degree + 1
    for code in range(p ** total_coeffs):
        coeffs = []
        val = code
        for _ in range(total_coeffs):
            coeffs.append(val % p)
            val //= p

        agreements = count_agreements(coeffs)
        if agreements >= agreement_threshold:
            results.append(coeffs)

    return results


# ─── Algorithm 2: Agreement Analysis ──────────────────────────────────────────

def analyze_agreement_structure(
    p: int,
    S: List[int],
    target: Dict[int, int],
    max_degree: int
) -> Dict:
    """
    Analyze the agreement structure of degree-≤d polynomials with a target function.

    Parameters
    ----------
    p : int
        Prime field size.
    S : List[int]
        Finite subset of Z/pZ.
    target : Dict[int, int]
        Target function f : S → Z/pZ.
    max_degree : int
        Maximum polynomial degree d.

    Returns
    -------
    Dict with keys:
        'agreement_sizes': Dict mapping agreement size to count of polys
        'max_agreement': Maximum agreement size
        'pairwise_overlaps': Distribution of pairwise overlap sizes
        'max_overlap': Maximum pairwise overlap
        'bonferroni_check': Whether the Bonferroni bound holds for each threshold
    """
    def eval_poly(coeffs: List[int], x: int) -> int:
        result = 0
        power = 1
        for c in coeffs:
            result = (result + c * power) % p
            power = (power * x) % p
        return result

    # Enumerate all polynomials and compute agreement sets
    n_coeffs = max_degree + 1
    poly_agree: List[Tuple[List[int], Set[int]]] = []

    for code in range(p ** n_coeffs):
        coeffs = []
        val = code
        for _ in range(n_coeffs):
            coeffs.append(val % p)
            val //= p

        agree = {x for x in S if eval_poly(coeffs, x) == target[x]}
        poly_agree.append((coeffs, agree))

    # Agreement size distribution
    agree_sizes: Dict[int, int] = {}
    for _, agree in poly_agree:
        sz = len(agree)
        agree_sizes[sz] = agree_sizes.get(sz, 0) + 1

    max_agree = max(agree_sizes.keys()) if agree_sizes else 0

    # Pairwise overlap analysis (sample if too many pairs)
    overlap_sizes: Dict[int, int] = {}
    max_overlap = 0
    n_polys = len(poly_agree)
    sample_limit = 10000

    if n_polys * (n_polys - 1) // 2 <= sample_limit:
        for i in range(n_polys):
            for j in range(i + 1, n_polys):
                if poly_agree[i][0] == poly_agree[j][0]:
                    continue
                overlap = len(poly_agree[i][1] & poly_agree[j][1])
                overlap_sizes[overlap] = overlap_sizes.get(overlap, 0) + 1
                max_overlap = max(max_overlap, overlap)

    # Bonferroni check for each threshold
    n = len(S)
    d = max_degree
    bonferroni_results = {}

    for t in range(1, n + 1):
        agreeing = [(c, a) for c, a in poly_agree if len(a) >= t]
        L = len(agreeing)
        if L == 0:
            continue
        lhs = 2 * L * t
        rhs = 2 * n + L * (L - 1) * d
        bonferroni_results[t] = {
            'L': L,
            'lhs': lhs,
            'rhs': rhs,
            'holds': lhs <= rhs
        }

    return {
        'agreement_sizes': agree_sizes,
        'max_agreement': max_agree,
        'pairwise_overlaps': overlap_sizes,
        'max_overlap': max_overlap,
        'bonferroni_check': bonferroni_results,
        'total_polys': n_polys,
    }


# ─── Algorithm 3: Bonferroni Bound Computation ───────────────────────────────

def bonferroni_max_list_size(n: int, d: int, t: int) -> int:
    """
    Compute the maximum list size L from the Bonferroni bound:
    2*L*t ≤ 2*n + L*(L-1)*d

    Rearranging: d*L^2 - (2t - d)*L - 2n ≥ 0... wait, let me derive correctly:
    2Lt ≤ 2n + L(L-1)d
    2Lt ≤ 2n + L²d - Ld
    L²d - L(2t - d) - 2n ≥ 0... no:
    2Lt - L²d + Ld ≤ 2n
    -dL² + (2t+d)L ≤ 2n
    dL² - (2t+d)L + 2n ≥ 0

    Quadratic in L: aL² + bL + c ≥ 0 where a = d, b = -(2t+d), c = 2n.
    Discriminant: (2t+d)² - 8dn.
    If discriminant < 0, the quadratic is always positive (no constraint on L).
    If discriminant ≥ 0, L must be outside the roots:
    L ≤ ((2t+d) - sqrt(disc)) / (2d) or L ≥ ((2t+d) + sqrt(disc)) / (2d).

    We want the maximum L satisfying 2Lt ≤ 2n + L(L-1)d.

    Parameters
    ----------
    n : int
        Size of the evaluation set |S|.
    d : int
        Maximum polynomial degree.
    t : int
        Agreement threshold.

    Returns
    -------
    int
        Maximum list size L satisfying the Bonferroni bound.
    """
    if d == 0:
        # Pairwise disjoint: L*t ≤ n
        return n // t if t > 0 else float('inf')

    # Binary search for max L satisfying 2*L*t ≤ 2*n + L*(L-1)*d
    lo, hi = 0, 2 * n + 1
    while lo < hi:
        mid = (lo + hi + 1) // 2
        lhs = 2 * mid * t
        rhs = 2 * n + mid * (mid - 1) * d
        if lhs <= rhs:
            lo = mid
        else:
            hi = mid - 1
    return lo


def johnson_max_list_size(n: int, d: int, t: int) -> Optional[int]:
    """
    Compute the Johnson bound on list size (when applicable).

    If t > sqrt(n*d), then L ≤ n / (t - sqrt(n*d)).

    Parameters
    ----------
    n : int
        Size of the evaluation set |S|.
    d : int
        Maximum polynomial degree.
    t : int
        Agreement threshold.

    Returns
    -------
    Optional[int]
        Johnson bound on L, or None if t ≤ sqrt(n*d).
    """
    threshold = math.sqrt(n * d)
    if t <= threshold:
        return None
    return int(n / (t - threshold))


# ─── Algorithm 4: Optimal Threshold Computation ──────────────────────────────

def compute_list_size_table(n: int, d: int) -> List[Tuple[int, int, Optional[int]]]:
    """
    Compute a table of (t, bonferroni_bound, johnson_bound) for all thresholds.

    Parameters
    ----------
    n : int
        Size of the evaluation set |S|.
    d : int
        Maximum polynomial degree.

    Returns
    -------
    List[Tuple[int, int, Optional[int]]]
        Table of (threshold, bonferroni_max_L, johnson_max_L).
    """
    results = []
    for t in range(1, n + 1):
        bonf = bonferroni_max_list_size(n, d, t)
        john = johnson_max_list_size(n, d, t)
        results.append((t, bonf, john))
    return results


# ─── Main ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    import random
    random.seed(42)

    print("=" * 70)
    print("Agreement Geometry Algorithms — Demonstration")
    print("=" * 70)

    # Demo: Brute-force list decoding
    print("\n--- Brute-force List Decoder ---")
    p = 7
    eval_pts = list(range(7))
    # Encode polynomial p(x) = x^2 + 2x + 3
    true_coeffs = [3, 2, 1]
    codeword = [sum(c * (x ** i) for i, c in enumerate(true_coeffs)) % p for x in eval_pts]
    print(f"True polynomial: 3 + 2x + x^2")
    print(f"Codeword: {codeword}")

    # Corrupt 2 positions
    received = codeword[:]
    received[0] = (received[0] + 1) % p
    received[3] = (received[3] + 3) % p
    print(f"Received (2 errors): {received}")

    results = brute_force_list_decode(p, eval_pts, received, 2, 5)
    print(f"List decode (t=5): {len(results)} polynomial(s) found")
    for coeffs in results:
        print(f"  coeffs = {coeffs}")

    # Demo: Agreement analysis
    print("\n--- Agreement Structure Analysis ---")
    S = list(range(7))
    target = {x: random.randint(0, 6) for x in S}
    print(f"Target function: {target}")

    analysis = analyze_agreement_structure(7, S, target, 2)
    print(f"Total degree-≤2 polynomials: {analysis['total_polys']}")
    print(f"Agreement size distribution: {dict(sorted(analysis['agreement_sizes'].items()))}")
    print(f"Max agreement: {analysis['max_agreement']}")
    print(f"Max pairwise overlap: {analysis['max_overlap']} (bound = 2)")

    print("\nBonferroni check:")
    for t, info in sorted(analysis['bonferroni_check'].items()):
        if info['L'] > 0:
            status = "✓" if info['holds'] else "✗"
            print(f"  t={t}: L={info['L']}, 2Lt={info['lhs']}, "
                  f"bound={info['rhs']} {status}")

    # Demo: List-size bounds comparison
    print("\n--- List-Size Bounds Comparison ---")
    print(f"{'n':>5} {'d':>5} {'t':>5} {'Bonf':>8} {'Johnson':>8}")
    print(f"{'-'*5} {'-'*5} {'-'*5} {'-'*8} {'-'*8}")
    for n_val in [50, 100, 200]:
        for d_val in [5, 10]:
            for t_val in [15, 20, 30, 40]:
                bonf = bonferroni_max_list_size(n_val, d_val, t_val)
                john = johnson_max_list_size(n_val, d_val, t_val)
                john_str = str(john) if john is not None else "N/A"
                print(f"{n_val:>5} {d_val:>5} {t_val:>5} {bonf:>8} {john_str:>8}")

    print("\nAll algorithm demos completed.")
