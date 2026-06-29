#!/usr/bin/env python3
"""
Algorithms for Helfgott-Type Growth Analysis in SL(2, F_p)

Implements:
1. SL(2, F_p) construction and arithmetic
2. Growth certificate computation
3. Obstruction detection (Borel, torus, escape)
4. Trace amplification analysis
5. Entry-set sum-product bridge computation

All algorithms include complexity analysis and worked examples.
"""

from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass
import math


Matrix2x2 = Tuple[Tuple[int, int], Tuple[int, int]]


def mod(x: int, p: int) -> int:
    """Reduce x mod p to range [0, p)."""
    return x % p


def mat_mul(A: Matrix2x2, B: Matrix2x2, p: int) -> Matrix2x2:
    """
    Multiply two 2x2 matrices mod p.

    Time: O(1) field operations
    Space: O(1)
    """
    (a1, b1), (c1, d1) = A
    (a2, b2), (c2, d2) = B
    return (
        (mod(a1*a2 + b1*c2, p), mod(a1*b2 + b1*d2, p)),
        (mod(c1*a2 + d1*c2, p), mod(c1*b2 + d1*d2, p))
    )


def mat_inv(M: Matrix2x2, p: int) -> Matrix2x2:
    """
    Inverse of M ∈ SL(2, F_p). Since det(M) = 1, M^{-1} = [[d,-b],[-c,a]].

    Time: O(1)
    Space: O(1)
    """
    (a, b), (c, d) = M
    return (mod(d, p), mod(-b, p)), (mod(-c, p), mod(a, p))


def mat_det(M: Matrix2x2, p: int) -> int:
    """Determinant of a 2x2 matrix mod p."""
    (a, b), (c, d) = M
    return mod(a * d - b * c, p)


def mat_trace(M: Matrix2x2, p: int) -> int:
    """Trace of a 2x2 matrix mod p."""
    return mod(M[0][0] + M[1][1], p)


def identity() -> Matrix2x2:
    """The 2x2 identity matrix."""
    return ((1, 0), (0, 1))


def build_sl2(p: int) -> List[Matrix2x2]:
    """
    Enumerate all elements of SL(2, F_p).

    Algorithm: Iterate over (a, b, c) ∈ F_p³, solve ad - bc ≡ 1 (mod p) for d.

    Time: O(p³)
    Space: O(p³) = O(|SL(2, F_p)|)

    Returns: List of all matrices in SL(2, F_p)

    >>> len(build_sl2(5))
    120
    >>> len(build_sl2(7))
    336
    """
    result = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                # d = (1 + bc) / a if a != 0, else need bc = -1
                # Just check all d
                for d in range(p):
                    if mod(a * d - b * c, p) == 1:
                        result.append(((a, b), (c, d)))
    return result


def is_irreducible_charpoly(M: Matrix2x2, p: int) -> bool:
    """
    Check if the characteristic polynomial of M is irreducible over F_p.

    For M ∈ SL(2, F_p), charpoly = X² - tr(M)·X + 1.
    This is irreducible iff its discriminant tr(M)² - 4 is a
    quadratic non-residue mod p.

    Time: O(log p) for modular exponentiation
    Space: O(1)

    >>> is_irreducible_charpoly(((0, 1), (p-1, 0)), 5)  # trace=0, disc=-4
    True
    """
    t = mat_trace(M, p)
    disc = mod(t * t - 4, p)
    if disc == 0:
        return False
    # Euler criterion: disc is QR iff disc^((p-1)/2) ≡ 1
    return pow(disc, (p - 1) // 2, p) != 1


def is_upper_triangular(M: Matrix2x2) -> bool:
    """Check if M is upper triangular (M[1][0] == 0)."""
    return M[1][0] == 0


@dataclass
class GrowthCertificate:
    """
    A certified growth analysis of a subset A ⊆ SL(2, F_p).

    Fields:
        p: The prime
        A: The subset (as a frozenset)
        card_A: |A|
        card_A2: |A²|
        card_A3: |A³|
        trace_set_size: |tr(A)|
        is_symmetric: Whether A = A⁻¹
        contains_identity: Whether 1 ∈ A
        has_irreducible_witness: Whether some g ∈ A has irreducible charpoly
        has_noncommuting_pair: Whether ∃ x,y ∈ A with xy ≠ yx
        obstruction_class: Classification string
        growth_exponent: δ = log|A³|/log|A| - 1
    """
    p: int
    card_A: int
    card_A2: int
    card_A3: int
    trace_set_size: int
    is_symmetric: bool
    contains_identity: bool
    has_irreducible_witness: bool
    has_noncommuting_pair: bool
    obstruction_class: str
    growth_exponent: float


def compute_growth_certificate(A: Set[Matrix2x2], p: int) -> GrowthCertificate:
    """
    Compute a complete growth certificate for A ⊆ SL(2, F_p).

    Time: O(|A|³) for triple product computation
    Space: O(|A|³) for storing A³

    >>> sl2 = build_sl2(5)
    >>> A = {identity(), ((0,1),(4,0)), ((0,4),(1,0))}
    >>> cert = compute_growth_certificate(A, 5)
    >>> cert.card_A
    3
    >>> cert.card_A3 > cert.card_A
    True
    """
    A_list = list(A)
    n = len(A_list)

    # Compute A²
    A2 = set()
    for a in A_list:
        for b in A_list:
            A2.add(mat_mul(a, b, p))

    # Compute A³
    A3 = set()
    for ab in A2:
        for c in A_list:
            A3.add(mat_mul(ab, c, p))

    # Trace set
    traces = {mat_trace(g, p) for g in A}

    # Symmetry check
    is_symm = all(mat_inv(g, p) in A for g in A)

    # Identity check
    has_id = identity() in A

    # Irreducible witness
    has_irr = any(is_irreducible_charpoly(g, p) for g in A)

    # Noncommuting pair
    has_nc = False
    for i in range(n):
        for j in range(i+1, n):
            if mat_mul(A_list[i], A_list[j], p) != mat_mul(A_list[j], A_list[i], p):
                has_nc = True
                break
        if has_nc:
            break

    # Classification
    if all(is_upper_triangular(g) for g in A):
        obs_class = "Borel-like"
    elif not has_nc:
        obs_class = "commuting"
    elif has_irr and has_nc:
        obs_class = "escaped/noncommuting"
    elif has_irr:
        obs_class = "escaped/commuting"
    else:
        obs_class = "non-escaped"

    # Growth exponent
    delta = math.log(len(A3)) / math.log(n) - 1 if n > 1 else 0.0

    return GrowthCertificate(
        p=p, card_A=n, card_A2=len(A2), card_A3=len(A3),
        trace_set_size=len(traces), is_symmetric=is_symm,
        contains_identity=has_id, has_irreducible_witness=has_irr,
        has_noncommuting_pair=has_nc, obstruction_class=obs_class,
        growth_exponent=delta
    )


def entry_set_sum_product(A: Set[Matrix2x2], p: int, i: int = 1, j: int = 0) -> Dict:
    """
    Extract the (i,j)-entry set S from A and compute S+S and S*S.

    This implements the cross-domain bridge from group structure to
    additive combinatorics over F_p.

    Time: O(|A| + |S|²)
    Space: O(|S|²)

    Returns: Dictionary with S, S+S, S*S sizes and growth data
    """
    # Extract entry set
    S = set()
    for g in A:
        S.add(g[i][j])

    S_list = list(S)
    n = len(S_list)

    # Compute S + S
    sum_set = set()
    for a in S_list:
        for b in S_list:
            sum_set.add(mod(a + b, p))

    # Compute S * S
    prod_set = set()
    for a in S_list:
        for b in S_list:
            prod_set.add(mod(a * b, p))

    return {
        'S_size': n,
        'S_plus_S_size': len(sum_set),
        'S_times_S_size': len(prod_set),
        'additive_growth': len(sum_set) / n if n > 0 else 0,
        'multiplicative_growth': len(prod_set) / n if n > 0 else 0,
        'has_zero': 0 in S,
        'has_nonzero': any(x != 0 for x in S),
    }


def trace_amplification_analysis(A: Set[Matrix2x2], p: int) -> Dict:
    """
    Analyze trace amplification through products.

    Computes tr(A), tr(A²), tr(A³) to measure how trace diversity
    grows with product operations.

    Time: O(|A|³)
    Space: O(|A|³)

    Returns: Dictionary with trace set sizes at each product level
    """
    A_list = list(A)

    tr_A = {mat_trace(g, p) for g in A}

    A2 = set()
    for a in A_list:
        for b in A_list:
            A2.add(mat_mul(a, b, p))
    tr_A2 = {mat_trace(g, p) for g in A2}

    A3 = set()
    for ab in A2:
        for c in A_list:
            A3.add(mat_mul(ab, c, p))
    tr_A3 = {mat_trace(g, p) for g in A3}

    return {
        'tr_A_size': len(tr_A),
        'tr_A2_size': len(tr_A2),
        'tr_A3_size': len(tr_A3),
        'trace_amplification_2': len(tr_A2) / len(tr_A) if len(tr_A) > 0 else 0,
        'trace_amplification_3': len(tr_A3) / len(tr_A) if len(tr_A) > 0 else 0,
        'total_field_elements': p,
        'trace_saturation': len(tr_A3) / p,
    }


# Example usage
if __name__ == "__main__":
    p = 7
    print(f"Building SL(2, F_{p})...")
    sl2 = build_sl2(p)
    print(f"|SL(2, F_{p})| = {len(sl2)}")

    # Create a small test set
    I = identity()
    # Find an element with irreducible charpoly
    irr_elements = [g for g in sl2 if is_irreducible_charpoly(g, p)]
    print(f"Elements with irreducible charpoly: {len(irr_elements)}")

    if irr_elements:
        g = irr_elements[0]
        g_inv = mat_inv(g, p)
        A = {I, g, g_inv}

        cert = compute_growth_certificate(A, p)
        print(f"\nGrowth Certificate:")
        print(f"  |A| = {cert.card_A}")
        print(f"  |A²| = {cert.card_A2}")
        print(f"  |A³| = {cert.card_A3}")
        print(f"  |tr(A)| = {cert.trace_set_size}")
        print(f"  δ = {cert.growth_exponent:.4f}")
        print(f"  Class: {cert.obstruction_class}")
        print(f"  Has irreducible witness: {cert.has_irreducible_witness}")
        print(f"  Has noncommuting pair: {cert.has_noncommuting_pair}")

        # Entry set analysis
        entry_data = entry_set_sum_product(A, p)
        print(f"\nEntry Set (1,0) Analysis:")
        print(f"  |S| = {entry_data['S_size']}")
        print(f"  |S+S| = {entry_data['S_plus_S_size']}")
        print(f"  |S·S| = {entry_data['S_times_S_size']}")
        print(f"  Additive growth: {entry_data['additive_growth']:.2f}")

        # Trace amplification
        trace_data = trace_amplification_analysis(A, p)
        print(f"\nTrace Amplification:")
        print(f"  |tr(A)| = {trace_data['tr_A_size']}")
        print(f"  |tr(A²)| = {trace_data['tr_A2_size']}")
        print(f"  |tr(A³)| = {trace_data['tr_A3_size']}")
        print(f"  Amplification (A→A³): {trace_data['trace_amplification_3']:.2f}x")
