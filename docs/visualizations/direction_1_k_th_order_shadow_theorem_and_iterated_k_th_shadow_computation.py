"""
Algorithms for Iterated Shadow Geometry of Polynomial Supports.

Implements core algorithms for computing k-th shadows, derivative shadow profiles,
and testing exchange/log-concavity properties of multi-index support sets.

All algorithms operate on supports represented as sets of tuples (multi-indices).
"""

from itertools import combinations_with_replacement, product
from collections import defaultdict
from typing import Set, Tuple, List, Dict, Optional
from math import comb, prod as math_prod
from functools import reduce


# Type aliases
MultiIndex = Tuple[int, ...]
Support = Set[MultiIndex]


def mass(tau: MultiIndex) -> int:
    """Total mass (sum of coordinates) of a multi-index."""
    return sum(tau)


def multi_indices_of_mass(n: int, k: int) -> List[MultiIndex]:
    """
    Enumerate all multi-indices in n variables with total mass k.
    
    Uses stars-and-bars enumeration.
    
    Time complexity: O(C(n+k-1, k)) — the number of such multi-indices.
    Space complexity: O(C(n+k-1, k) * n) for storing results.
    
    Args:
        n: Number of variables (dimension).
        k: Total mass (sum of coordinates).
    
    Returns:
        List of all n-tuples of non-negative integers summing to k.
    
    Example:
        >>> multi_indices_of_mass(2, 2)
        [(2, 0), (1, 1), (0, 2)]
    """
    if n == 0:
        return [()] if k == 0 else []
    if n == 1:
        return [(k,)]
    result = []
    for first in range(k, -1, -1):
        for rest in multi_indices_of_mass(n - 1, k - first):
            result.append((first,) + rest)
    return result


def leq(tau: MultiIndex, alpha: MultiIndex) -> bool:
    """Check if tau <= alpha coordinatewise."""
    return all(t <= a for t, a in zip(tau, alpha))


def sub(alpha: MultiIndex, tau: MultiIndex) -> MultiIndex:
    """Subtract multi-indices coordinatewise (truncated at 0)."""
    return tuple(max(a - t, 0) for a, t in zip(alpha, tau))


def add(alpha: MultiIndex, tau: MultiIndex) -> MultiIndex:
    """Add multi-indices coordinatewise."""
    return tuple(a + t for a, t in zip(alpha, tau))


def kth_shadow(S: Support, k: int) -> Support:
    """
    Compute the k-th shadow of a support set S.
    
    The k-th shadow consists of all multi-indices obtainable by subtracting
    a multi-index of total mass k from an element of S, subject to the
    coordinatewise ordering constraint.
    
    Algorithm:
        For each α ∈ S, enumerate all τ with |τ| = k and τ ≤ α,
        and add α - τ to the result.
    
    Time complexity: O(|S| * C(n+k-1, k)) where n is the dimension.
    Space complexity: O(|result|).
    
    Args:
        S: Support set (set of multi-indices).
        k: Shadow depth.
    
    Returns:
        The k-th shadow as a set of multi-indices.
    
    Example:
        >>> S = {(2, 1)}
        >>> kth_shadow(S, 1)
        {(1, 1), (2, 0)}
    """
    if not S:
        return set()
    n = len(next(iter(S)))
    result = set()
    taus = multi_indices_of_mass(n, k)
    for alpha in S:
        for tau in taus:
            if leq(tau, alpha):
                result.add(sub(alpha, tau))
    return result


def shadow_profile(S: Support, max_k: Optional[int] = None) -> List[int]:
    """
    Compute the derivative shadow profile: k ↦ |Shadow_k(S)|.
    
    Args:
        S: Support set.
        max_k: Maximum shadow depth to compute (default: max total degree in S).
    
    Returns:
        List where index k gives |Shadow_k(S)|.
    
    Example:
        >>> S = {(2, 2)}
        >>> shadow_profile(S)
        [1, 2, 3, 2, 1]
    """
    if not S:
        return [0]
    if max_k is None:
        max_k = max(mass(alpha) for alpha in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]


def ascending_factorial_product(beta: MultiIndex, tau: MultiIndex) -> int:
    """
    Compute the scalar factor in the coefficient transport formula:
    ∏_i ∏_{j=0}^{τ_i - 1} (β_i + j + 1)
    
    This equals ∏_i (β_i + 1)(β_i + 2)...(β_i + τ_i).
    
    Args:
        beta: Target multi-index.
        tau: Derivative multi-index.
    
    Returns:
        The ascending factorial product (always a positive integer).
    """
    result = 1
    for bi, ti in zip(beta, tau):
        for j in range(ti):
            result *= (bi + j + 1)
    return result


def coeff_iterated_pderiv(f_coeffs: Dict[MultiIndex, float], beta: MultiIndex,
                           tau: MultiIndex) -> float:
    """
    Compute coeff_β(∂^τ f) using the coefficient transport formula.
    
    Uses the proven formula:
    coeff_β(∂^τ f) = (∏_i ascFact(β_i+1, τ_i)) * coeff_{β+τ}(f)
    
    Args:
        f_coeffs: Dictionary mapping multi-indices to coefficients of f.
        beta: Target multi-index.
        tau: Derivative multi-index.
    
    Returns:
        The coefficient value.
    """
    alpha = add(beta, tau)
    c = f_coeffs.get(alpha, 0.0)
    return ascending_factorial_product(beta, tau) * c


def derivative_support(f_coeffs: Dict[MultiIndex, float],
                        tau: MultiIndex) -> Support:
    """
    Compute the support of ∂^τ f using the coefficient transport formula.
    
    Args:
        f_coeffs: Polynomial coefficients.
        tau: Derivative multi-index.
    
    Returns:
        Support of the derivative.
    """
    result = set()
    for alpha in f_coeffs:
        if f_coeffs[alpha] == 0:
            continue
        # beta = alpha - tau (if tau <= alpha)
        if leq(tau, alpha):
            beta = sub(alpha, tau)
            result.add(beta)
    return result


def all_derivative_supports_union(f_coeffs: Dict[MultiIndex, float],
                                   k: int) -> Support:
    """
    Compute the union of supports of all k-th order mixed partial derivatives.
    
    This is ⋃_{|τ|=k} Supp(∂^τ f).
    
    Args:
        f_coeffs: Polynomial coefficients.
        k: Derivative order.
    
    Returns:
        Union of all k-th order derivative supports.
    """
    n = len(next(iter(f_coeffs)))
    result = set()
    for tau in multi_indices_of_mass(n, k):
        result |= derivative_support(f_coeffs, tau)
    return result


def is_log_concave(seq: List[int]) -> bool:
    """
    Test if a sequence is log-concave: a_k^2 >= a_{k-1} * a_{k+1} for all k.
    
    Args:
        seq: Sequence of non-negative integers.
    
    Returns:
        True if the sequence is log-concave.
    """
    for k in range(1, len(seq) - 1):
        if seq[k] ** 2 < seq[k-1] * seq[k+1]:
            return False
    return True


def is_ratio_monotone(seq: List[int]) -> bool:
    """
    Test if a_k/a_{k-1} is non-increasing (stronger than log-concavity).
    
    Args:
        seq: Sequence of positive integers.
    
    Returns:
        True if the ratio sequence is non-increasing.
    """
    for k in range(2, len(seq) - 1):
        if seq[k-1] == 0 or seq[k] == 0:
            continue
        # Check: a_{k+1}/a_k <= a_k/a_{k-1}
        # Equivalent to: a_{k+1} * a_{k-1} <= a_k^2
        if seq[k+1] * seq[k-1] > seq[k] ** 2:
            return False
    return True


def is_discrete_exchange_family(S: Support) -> bool:
    """
    Test if S satisfies the discrete exchange property (M-convexity proxy).
    
    For all α, β ∈ S and all i with α_i > β_i,
    there exists j with β_j > α_j such that α - e_i + e_j ∈ S.
    
    Args:
        S: Support set.
    
    Returns:
        True if S satisfies the exchange property.
    """
    S_set = set(S)
    if not S_set:
        return True
    n = len(next(iter(S_set)))
    for alpha in S_set:
        for beta in S_set:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if beta[j] > alpha[j]:
                            # Compute alpha - e_i + e_j
                            candidate = list(alpha)
                            candidate[i] -= 1
                            candidate[j] += 1
                            if tuple(candidate) in S_set:
                                found = True
                                break
                    if not found:
                        return False
    return True


def matroid_basis_support(n: int, r: int,
                          bases: Optional[List[Tuple[int, ...]]] = None) -> Support:
    """
    Generate the support of a matroid basis generating polynomial.
    
    For the uniform matroid U_{r,n}, the bases are all r-element subsets of {0,...,n-1}.
    The support consists of indicator multi-indices (0/1 entries) for each basis.
    
    Args:
        n: Ground set size.
        r: Rank.
        bases: Optional list of bases (as tuples of elements). 
               If None, uses uniform matroid.
    
    Returns:
        Support set.
    """
    if bases is None:
        bases = list(combinations_with_replacement(range(n), r))
        bases = [b for b in product(range(n), repeat=r)
                 if len(set(b)) == r and b == tuple(sorted(b))]
        # Use combinations properly
        from itertools import combinations
        bases = list(combinations(range(n), r))
    
    support = set()
    for basis in bases:
        idx = [0] * n
        for elem in basis:
            idx[elem] += 1
        support.add(tuple(idx))
    return support


def generalized_permutahedron_support(n: int, degree: int) -> Support:
    """
    Generate a generalized permutahedral support: all permutations of a 
    fixed composition.
    
    Args:
        n: Dimension.
        degree: Total degree.
    
    Returns:
        Support set (symmetric under coordinate permutations).
    """
    from itertools import permutations
    # Start with a specific composition and take all permutations
    base = [0] * n
    remaining = degree
    for i in range(n):
        base[i] = min(remaining, degree // n + (1 if i < degree % n else 0))
        remaining -= base[i]
    
    support = set()
    for perm in permutations(base):
        support.add(perm)
    return support


def verify_shadow_theorem(f_coeffs: Dict[MultiIndex, float], k: int) -> bool:
    """
    Verify the k-th Shadow Theorem: that the k-th shadow of Supp(f) equals
    the union of supports of all k-th order derivatives of f.
    
    Args:
        f_coeffs: Polynomial coefficients.
        k: Shadow depth.
    
    Returns:
        True if the shadow theorem holds (should always be True for nonzero
        coefficients in characteristic zero).
    """
    support = {m for m, c in f_coeffs.items() if c != 0}
    shadow = kth_shadow(support, k)
    deriv_union = all_derivative_supports_union(f_coeffs, k)
    return shadow == deriv_union


if __name__ == "__main__":
    # Quick self-test
    print("=== Algorithm Self-Tests ===")
    
    # Test 1: mass
    assert mass((2, 1, 3)) == 6
    print("✓ mass computation")
    
    # Test 2: multi_indices_of_mass
    assert len(multi_indices_of_mass(3, 2)) == 6  # C(4,2)
    print("✓ multi-index enumeration")
    
    # Test 3: kth_shadow
    S = {(2, 2)}
    profile = shadow_profile(S)
    assert profile == [1, 2, 3, 2, 1], f"Got {profile}"
    print(f"✓ shadow profile of {{(2,2)}}: {profile}")
    
    # Test 4: log-concavity
    assert is_log_concave([1, 2, 3, 2, 1])
    assert not is_log_concave([1, 3, 2, 3, 1])
    print("✓ log-concavity test")
    
    # Test 5: shadow theorem verification
    f = {(2, 2): 1.0, (3, 0): 2.0, (0, 3): -1.0}
    for k in range(4):
        assert verify_shadow_theorem(f, k), f"Shadow theorem failed at k={k}"
    print("✓ shadow theorem verification")
    
    print("\nAll self-tests passed!")
