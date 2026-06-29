"""
algorithms.py — Core algorithms for iterated shadow geometry.

Implements the k-th shadow operator, iterated partial derivatives for
multivariate polynomials, derivative shadow profiles, and discrete
exchange family detection.
"""

from typing import Dict, Tuple, List, Set, FrozenSet
from collections import defaultdict
from itertools import combinations_with_replacement
from math import comb, factorial
from functools import reduce


# ─── Types ───────────────────────────────────────────────────────────
# A multi-index is a tuple of non-negative integers (one per variable).
# A polynomial is Dict[tuple[int,...], number] mapping exponent vector → coefficient.

MultiIndex = Tuple[int, ...]
Polynomial = Dict[MultiIndex, float]


def total_mass(tau: MultiIndex) -> int:
    """Sum of all entries in a multi-index."""
    return sum(tau)


def multi_indices_of_mass(n: int, k: int) -> List[MultiIndex]:
    """
    Enumerate all multi-indices in n variables with total mass k.

    Time: O(C(n+k-1, k)) — the number of weak compositions.
    Space: O(C(n+k-1, k) * n) for storing the result.
    """
    if k == 0:
        return [tuple([0] * n)]
    if n == 0:
        return []
    if n == 1:
        return [(k,)]
    result = []
    for first in range(k + 1):
        for rest in multi_indices_of_mass(n - 1, k - first):
            result.append((first,) + rest)
    return result


def kth_shadow(S: Set[MultiIndex], k: int) -> Set[MultiIndex]:
    """
    Compute the k-th shadow of a support set S.

    For each α ∈ S and each multi-index τ with |τ| = k and τ ≤ α,
    add α - τ to the shadow.

    Args:
        S: Finite set of multi-indices (the support).
        k: Shadow depth (total mass to subtract).

    Returns:
        The k-th shadow as a set of multi-indices.

    Time: O(|S| * C(n+k-1,k) * n) where n = dimension.
    Space: O(|shadow|) for the result set.
    """
    if not S:
        return set()
    n = len(next(iter(S)))
    shadow = set()
    for alpha in S:
        for tau in multi_indices_of_mass(n, k):
            if all(tau[i] <= alpha[i] for i in range(n)):
                beta = tuple(alpha[i] - tau[i] for i in range(n))
                shadow.add(beta)
    return shadow


def shadow_profile(S: Set[MultiIndex], max_k: int = None) -> List[int]:
    """
    Compute the shadow profile: a_k = |Sh_k(S)| for k = 0, 1, ..., max_k.

    If max_k is None, computes up to the maximum total degree in S.

    Args:
        S: Finite support set.
        max_k: Maximum shadow depth (default: max total degree in S).

    Returns:
        List [a_0, a_1, ..., a_{max_k}].
    """
    if not S:
        return [0]
    if max_k is None:
        max_k = max(total_mass(alpha) for alpha in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]


def ascending_factorial(m: int, k: int) -> int:
    """Compute ascFactorial(m, k) = m * (m+1) * ... * (m+k-1)."""
    result = 1
    for j in range(k):
        result *= (m + j)
    return result


def coeff_iterated_pderiv(poly: Polynomial, beta: MultiIndex,
                          tau: MultiIndex) -> float:
    """
    Coefficient of x^β in the τ-th iterated mixed partial derivative of poly.

    By the transport formula:
        coeff_β(∂^τ f) = (∏_i ascFact(β_i + 1, τ_i)) * coeff_{β+τ}(f)

    Args:
        poly: The polynomial as {exponent: coefficient}.
        beta: Target exponent vector.
        tau: Derivative multi-index.

    Returns:
        The coefficient value.
    """
    n = len(beta)
    alpha = tuple(beta[i] + tau[i] for i in range(n))
    scalar = 1
    for i in range(n):
        scalar *= ascending_factorial(beta[i] + 1, tau[i])
    return scalar * poly.get(alpha, 0.0)


def iterated_pderiv(poly: Polynomial, tau: MultiIndex) -> Polynomial:
    """
    Compute the τ-th iterated mixed partial derivative of poly.

    Args:
        poly: Input polynomial.
        tau: Multi-index specifying derivative orders.

    Returns:
        The resulting polynomial after differentiation.
    """
    n = len(tau)
    result = {}
    for alpha, coeff in poly.items():
        if all(alpha[i] >= tau[i] for i in range(n)):
            beta = tuple(alpha[i] - tau[i] for i in range(n))
            scalar = 1
            for i in range(n):
                scalar *= ascending_factorial(beta[i] + 1, tau[i])
            val = scalar * coeff
            if val != 0:
                result[beta] = result.get(beta, 0.0) + val
    # Remove zero coefficients
    return {k: v for k, v in result.items() if v != 0}


def derivative_support_at_order(poly: Polynomial, k: int) -> Set[MultiIndex]:
    """
    Union of supports of all k-th order mixed partial derivatives.

    Args:
        poly: Input polynomial.
        k: Derivative order.

    Returns:
        Set of all exponent vectors appearing in any k-th derivative.
    """
    if not poly:
        return set()
    n = len(next(iter(poly.keys())))
    result = set()
    for tau in multi_indices_of_mass(n, k):
        deriv = iterated_pderiv(poly, tau)
        result.update(deriv.keys())
    return result


def verify_shadow_theorem(poly: Polynomial, k: int) -> bool:
    """
    Verify the exact k-th shadow theorem for a given polynomial and k.

    Checks that derivative_support_at_order(poly, k) == kth_shadow(supp(poly), k).

    Returns:
        True if the theorem holds, False otherwise.
    """
    supp = set(alpha for alpha, c in poly.items() if c != 0)
    shadow = kth_shadow(supp, k)
    deriv_supp = derivative_support_at_order(poly, k)
    return shadow == deriv_supp


def is_discrete_exchange_family(S: Set[MultiIndex]) -> bool:
    """
    Check if S satisfies the discrete exchange property (M-convexity proxy).

    For all α, β ∈ S and all i with α_i > β_i, there exists j with
    β_j > α_j such that α - e_i + e_j ∈ S.

    Args:
        S: Finite support set.

    Returns:
        True if S is an exchange family.
    """
    S_list = list(S)
    if len(S_list) == 0:
        return True
    n = len(S_list[0])
    S_set = frozenset(S)
    for alpha in S_list:
        for beta in S_list:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if beta[j] > alpha[j]:
                            candidate = list(alpha)
                            candidate[i] -= 1
                            candidate[j] += 1
                            if tuple(candidate) in S_set:
                                found = True
                                break
                    if not found:
                        return False
    return True


def check_log_concavity(profile: List[int]) -> bool:
    """
    Check if a sequence is log-concave: a_k^2 >= a_{k-1} * a_{k+1}.

    Args:
        profile: The shadow profile [a_0, a_1, ...].

    Returns:
        True if log-concave.
    """
    for k in range(1, len(profile) - 1):
        if profile[k] ** 2 < profile[k - 1] * profile[k + 1]:
            return False
    return True


def check_ratio_monotonicity(profile: List[int]) -> bool:
    """
    Check ratio monotonicity: a_{k+1}/a_k <= a_k/a_{k-1} for all valid k.

    Args:
        profile: The shadow profile.

    Returns:
        True if ratio-monotone (denominators must be nonzero).
    """
    for k in range(1, len(profile) - 1):
        if profile[k - 1] == 0 or profile[k] == 0:
            continue
        lhs = profile[k + 1] * profile[k - 1]
        rhs = profile[k] * profile[k]
        if lhs > rhs:
            return False
    return True


def matroid_basis_support(n: int, r: int) -> Set[MultiIndex]:
    """
    Generate the support of the basis generating polynomial of the
    uniform matroid U_{r,n}: all 0/1 vectors with exactly r ones.

    Args:
        n: Number of elements.
        r: Rank.

    Returns:
        Set of indicator vectors of r-element subsets.
    """
    result = set()
    for combo in combinations_with_replacement(range(n), 0):
        pass  # placeholder
    from itertools import combinations
    for combo in combinations(range(n), r):
        vec = [0] * n
        for i in combo:
            vec[i] = 1
        result.add(tuple(vec))
    return result


def simplex_support(n: int, d: int) -> Set[MultiIndex]:
    """
    Generate the support of all monomials of total degree exactly d in n variables.

    Args:
        n: Number of variables.
        d: Total degree.

    Returns:
        Set of multi-indices with total mass d.
    """
    return set(multi_indices_of_mass(n, d))


# ─── Example Usage ──────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Iterated Shadow Geometry: Algorithm Demonstrations ===\n")

    # Example 1: Shadow profile of a simplex support
    n, d = 3, 4
    S = simplex_support(n, d)
    print(f"Simplex support (n={n}, d={d}): {len(S)} elements")
    prof = shadow_profile(S)
    print(f"Shadow profile: {prof}")
    print(f"Log-concave: {check_log_concavity(prof)}")
    print(f"Ratio-monotone: {check_ratio_monotonicity(prof)}")
    print()

    # Example 2: Matroid basis support
    n, r = 5, 3
    S = matroid_basis_support(n, r)
    print(f"Uniform matroid U({r},{n}) basis support: {len(S)} elements")
    prof = shadow_profile(S)
    print(f"Shadow profile: {prof}")
    print(f"Exchange family: {is_discrete_exchange_family(S)}")
    print(f"Log-concave: {check_log_concavity(prof)}")
    print()

    # Example 3: Verify shadow theorem
    poly = {(2, 1): 3.0, (0, 3): -1.0, (1, 0): 5.0}
    for k in range(4):
        ok = verify_shadow_theorem(poly, k)
        shadow = kth_shadow(set(poly.keys()), k)
        deriv = derivative_support_at_order(poly, k)
        print(f"k={k}: shadow={len(shadow)}, deriv_supp={len(deriv)}, match={ok}")
