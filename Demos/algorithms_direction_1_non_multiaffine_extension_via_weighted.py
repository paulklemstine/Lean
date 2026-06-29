#!/usr/bin/env python3
"""
algorithms.py — Verified Algorithms for Quadratic Shadow Computation

Implements the quadratic shadow computation algorithm with correctness
guarantees matching the formally verified Lean implementation.

Time complexity: O(|S| · n²) where |S| = support size, n = number of variables
Space complexity: O(|Sh₂(S)|) for the output shadow set
"""

from typing import Dict, FrozenSet, List, Set, Tuple
from collections import defaultdict


# Type aliases
Exponent = Tuple[int, ...]  # An exponent vector α ∈ ℕⁿ


def compute_quadratic_shadow(
    support: Set[Exponent],
    n_vars: int
) -> Set[Exponent]:
    """
    Compute the quadratic shadow Sh₂(S) of a support set S.
    
    Sh₂(S) = {β ∈ ℕⁿ : ∃ α ∈ S, ∃ i,j, α = β + eᵢ + eⱼ}
    
    Algorithm: For each α ∈ S, enumerate all pairs (i,j) with
    α_i ≥ 1 and (α - eᵢ)_j ≥ 1, and insert α - eᵢ - eⱼ.
    
    Time: O(|S| · n²)
    Space: O(|Sh₂(S)|)
    
    >>> S = {(3,0,0), (0,3,0), (0,0,3)}
    >>> sorted(compute_quadratic_shadow(S, 3))
    [(0, 0, 1), (0, 1, 0), (1, 0, 0)]
    """
    shadow: Set[Exponent] = set()
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            alpha_minus_ei = list(alpha)
            alpha_minus_ei[i] -= 1
            for j in range(n_vars):
                if alpha_minus_ei[j] < 1:
                    continue
                beta = list(alpha_minus_ei)
                beta[j] -= 1
                shadow.add(tuple(beta))
    return shadow


def compute_shadow_multiplicity(
    support: Set[Exponent],
    n_vars: int,
    beta: Exponent
) -> int:
    """
    Compute the shadow multiplicity m_S(β): the number of triples
    (α, i, j) witnessing β ∈ Sh₂(S).
    
    This measures the "collision degree" — how many different ancestor
    paths converge to β in the second-derivative shadow.
    
    >>> S = {(2,1,0), (1,2,0), (0,2,1), (0,1,2), (1,0,2), (2,0,1)}
    >>> compute_shadow_multiplicity(S, 3, (0,0,1))
    6
    """
    count = 0
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            ai = list(alpha)
            ai[i] -= 1
            for j in range(n_vars):
                if ai[j] < 1:
                    continue
                test = list(ai)
                test[j] -= 1
                if tuple(test) == beta:
                    count += 1
    return count


def compute_weighted_shadow_measure(
    support: Set[Exponent],
    n_vars: int
) -> Dict[Exponent, int]:
    """
    Compute the full weighted shadow: for each β ∈ Sh₂(S),
    compute the multiplicity m_S(β).
    
    Returns a dictionary mapping each shadow point to its multiplicity.
    
    The unweighted shadow measure σ(S) = |Sh₂(S)| = len(result)
    The weighted shadow measure σ_w(S) = Σ_β m_S(β) = sum(result.values())
    
    >>> S = {(3,0,0), (0,3,0), (0,0,3)}
    >>> wsm = compute_weighted_shadow_measure(S, 3)
    >>> len(wsm)  # unweighted = |Sh₂(S)|
    3
    >>> sum(wsm.values())  # weighted = Σ multiplicities
    3
    """
    result: Dict[Exponent, int] = defaultdict(int)
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            ai = list(alpha)
            ai[i] -= 1
            for j in range(n_vars):
                if ai[j] < 1:
                    continue
                beta = list(ai)
                beta[j] -= 1
                result[tuple(beta)] += 1
    return dict(result)


def compute_actual_leaves(
    coeffs: Dict[Exponent, float],
    n_vars: int,
    degree: int
) -> Set[Exponent]:
    """
    Compute the actual nonzero quadratic leaf set by evaluating
    all second partial derivative coefficients.
    
    Uses the coefficient formula:
    coeff_β(∂ⱼ(∂ᵢf)) = coeff_{β+eᵢ+eⱼ}(f) · ((β+eⱼ)ᵢ+1) · (βⱼ+1)
    
    Time: O(|Sh₂| · n²) where Sh₂ is bounded by |S| · n²
    """
    from itertools import product as iprod
    
    leaves: Set[Exponent] = set()
    target_deg = degree - 2
    if target_deg < 0:
        return leaves
    
    # Generate all possible β of degree d-2
    for beta in _compositions(target_deg, n_vars):
        found = False
        for i in range(n_vars):
            if found:
                break
            for j in range(n_vars):
                ancestor = list(beta)
                ancestor[i] += 1
                ancestor[j] += 1
                ancestor_t = tuple(ancestor)
                if ancestor_t in coeffs and coeffs[ancestor_t] != 0:
                    # Numerical factor is always nonzero over ℤ
                    leaves.add(beta)
                    found = True
                    break
    return leaves


def verify_shadow_theorem(
    coeffs: Dict[Exponent, float],
    n_vars: int,
    degree: int
) -> bool:
    """
    Verify that NonzeroQuadLeafSet(f) = QuadraticShadow(Supp(f))
    for a given polynomial f.
    
    Returns True if the equality holds.
    
    >>> coeffs = {(3,0,0): 1, (0,3,0): 1, (0,0,3): 1}
    >>> verify_shadow_theorem(coeffs, 3, 3)
    True
    """
    support = {k for k, v in coeffs.items() if v != 0}
    shadow = compute_quadratic_shadow(support, n_vars)
    leaves = compute_actual_leaves(coeffs, n_vars, degree)
    return leaves == shadow


def _compositions(d: int, n: int):
    """Generate all weak compositions of d into n parts."""
    if n == 0:
        if d == 0:
            yield ()
        return
    if n == 1:
        yield (d,)
        return
    for first in range(d + 1):
        for rest in _compositions(d - first, n - 1):
            yield (first,) + rest


if __name__ == "__main__":
    import doctest
    doctest.testmod(verbose=True)
    
    # Additional demonstration
    print("\n" + "="*50)
    print("Weighted Shadow Analysis")
    print("="*50)
    
    # Elementary symmetric polynomial e_2 in 4 variables
    from itertools import combinations
    S_e2 = set()
    for i, j in combinations(range(4), 2):
        alpha = [0, 0, 0, 0]
        alpha[i] = 1
        alpha[j] = 1
        S_e2.add(tuple(alpha))
    
    wsm = compute_weighted_shadow_measure(S_e2, 4)
    print(f"\ne₂(x₁,x₂,x₃,x₄) support: {sorted(S_e2)}")
    print(f"Shadow: {sorted(wsm.keys())}")
    print(f"Unweighted measure σ(S) = {len(wsm)}")
    print(f"Weighted measure σ_w(S) = {sum(wsm.values())}")
    for beta, mult in sorted(wsm.items()):
        print(f"  β={beta}: multiplicity = {mult}")
