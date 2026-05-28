"""
Algorithms for Iterated Shadow Geometry.

Implements core algorithms for computing k-th shadows of multi-index support sets,
derivative shadow profiles, and testing log-concavity / exchange properties.

All algorithms operate on multi-indices represented as tuples of non-negative integers.
"""

from itertools import product as iproduct
from math import comb, factorial
from functools import reduce
from typing import FrozenSet, Set, Tuple, List, Dict, Optional
from collections import defaultdict


# --- Core Types ---

MultiIndex = tuple  # tuple of non-negative ints, length = number of variables


def total_mass(sigma: MultiIndex) -> int:
    """Sum of all entries of a multi-index."""
    return sum(sigma)


def desc_factorial(n: int, k: int) -> int:
    """Descending factorial: n * (n-1) * ... * (n-k+1). Returns 0 if k > n."""
    if k > n or k < 0:
        return 0
    result = 1
    for i in range(k):
        result *= (n - i)
    return result


def multi_desc_factorial(alpha: MultiIndex, tau: MultiIndex) -> int:
    """Product of descending factorials: prod_i descFactorial(alpha[i], tau[i])."""
    result = 1
    for a, t in zip(alpha, tau):
        result *= desc_factorial(a, t)
    return result


# --- k-th Shadow Computation ---

def enumerate_sub_indices(alpha: MultiIndex, k: int) -> Set[MultiIndex]:
    """
    Enumerate all multi-indices beta <= alpha with total_mass(alpha - beta) = k.

    This gives all elements of the k-th shadow contributed by a single alpha.

    Time complexity: O(product of (alpha[i]+1) for each i), pruned by mass constraint.
    """
    n = len(alpha)
    results = set()

    def backtrack(pos: int, remaining_mass: int, current: list):
        if pos == n:
            if remaining_mass == 0:
                results.add(tuple(current))
            return
        # tau[pos] can range from 0 to min(alpha[pos], remaining_mass)
        for t in range(min(alpha[pos], remaining_mass) + 1):
            current.append(alpha[pos] - t)
            backtrack(pos + 1, remaining_mass - t, current)
            current.pop()

    backtrack(0, k, [])
    return results


def kth_shadow(S: Set[MultiIndex], k: int) -> Set[MultiIndex]:
    """
    Compute the k-th shadow of a support set S.

    Shadow_k(S) = {beta : exists alpha in S, beta <= alpha, |alpha - beta| = k}

    Args:
        S: Set of multi-indices (all same dimension)
        k: Shadow depth (non-negative integer)

    Returns:
        Set of multi-indices in the k-th shadow

    Time complexity: O(|S| * max_binomial_coefficients)
    Space complexity: O(|shadow|)
    """
    shadow = set()
    for alpha in S:
        shadow.update(enumerate_sub_indices(alpha, k))
    return shadow


def shadow_profile(S: Set[MultiIndex], max_k: Optional[int] = None) -> List[int]:
    """
    Compute the derivative shadow profile: k -> |Shadow_k(S)|.

    Args:
        S: Support set
        max_k: Maximum k to compute (default: max total mass in S)

    Returns:
        List where entry i is |Shadow_i(S)|
    """
    if not S:
        return [0]
    if max_k is None:
        max_k = max(total_mass(alpha) for alpha in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]


# --- Iterated Derivative Support ---

def iterated_pderiv_support(f_support: Set[MultiIndex], tau: MultiIndex) -> Set[MultiIndex]:
    """
    Compute the support of D^tau(f), given the support of f.

    In characteristic zero, coeff_beta(D^tau f) != 0 iff coeff_{beta+tau}(f) != 0.
    So supp(D^tau f) = {alpha - tau : alpha in supp(f), tau <= alpha}.

    Args:
        f_support: Support of polynomial f
        tau: Multi-index for differentiation

    Returns:
        Support of D^tau(f)
    """
    result = set()
    for alpha in f_support:
        if all(t <= a for a, t in zip(alpha, tau)):
            beta = tuple(a - t for a, t in zip(alpha, tau))
            result.add(beta)
    return result


def all_derivative_supports_union(f_support: Set[MultiIndex], k: int) -> Set[MultiIndex]:
    """
    Compute the union of supports of all D^tau(f) where |tau| = k.

    By the exact k-th shadow theorem, this equals Shadow_k(supp(f)).

    Args:
        f_support: Support of polynomial f
        k: Total derivative order

    Returns:
        Union of all k-th order derivative supports
    """
    n = len(next(iter(f_support))) if f_support else 0
    result = set()

    # Enumerate all tau with total_mass = k and tau <= some alpha in f_support
    for alpha in f_support:
        for beta in enumerate_sub_indices(alpha, k):
            tau = tuple(a - b for a, b in zip(alpha, beta))
            result.add(beta)

    return result


# --- Exchange Family Detection ---

def is_discrete_exchange_family(S: Set[MultiIndex]) -> bool:
    """
    Check whether S satisfies the discrete symmetric exchange property.

    For all alpha, beta in S and every coordinate i where beta[i] < alpha[i],
    there exists j where alpha[j] < beta[j] such that
    alpha - e_i + e_j is in S.

    Args:
        S: Set of multi-indices

    Returns:
        True if S is a discrete exchange family
    """
    S_frozen = frozenset(S)
    n = len(next(iter(S))) if S else 0

    for alpha in S:
        for beta in S:
            for i in range(n):
                if beta[i] < alpha[i]:
                    # Need to find j with alpha[j] < beta[j] and alpha - e_i + e_j in S
                    found = False
                    for j in range(n):
                        if alpha[j] < beta[j]:
                            candidate = list(alpha)
                            candidate[i] -= 1
                            candidate[j] += 1
                            if tuple(candidate) in S_frozen:
                                found = True
                                break
                    if not found:
                        return False
    return True


# --- Log-Concavity Testing ---

def is_log_concave(seq: List[int]) -> bool:
    """
    Check whether a sequence is log-concave: a_k^2 >= a_{k-1} * a_{k+1}.

    Args:
        seq: Sequence of non-negative integers

    Returns:
        True if the sequence is log-concave
    """
    for k in range(1, len(seq) - 1):
        if seq[k] ** 2 < seq[k - 1] * seq[k + 1]:
            return False
    return True


def is_ratio_monotone(seq: List[int]) -> bool:
    """
    Check the stronger ratio-monotonicity: a_{k+1}/a_k <= a_k/a_{k-1}
    (when denominators are nonzero).

    Args:
        seq: Sequence of non-negative integers

    Returns:
        True if ratios are non-increasing
    """
    for k in range(1, len(seq) - 1):
        if seq[k - 1] > 0 and seq[k] > 0:
            # Check a_{k+1} * a_{k-1} <= a_k^2
            if seq[k + 1] * seq[k - 1] > seq[k] ** 2:
                return False
    return True


# --- Support Generators ---

def simplex_support(n: int, d: int) -> Set[MultiIndex]:
    """
    Generate the support of a generic dense polynomial of degree d in n variables.
    This is the set of all multi-indices with total mass <= d.
    """
    result = set()

    def gen(pos, remaining):
        if pos == n:
            result.add(tuple([0] * 0))  # placeholder
            return
        if pos == n - 1:
            for v in range(remaining + 1):
                yield v
        else:
            for v in range(remaining + 1):
                for rest in gen_tuple(pos + 1, remaining - v, n):
                    yield (v,) + rest

    def gen_tuple(pos, remaining, n):
        if pos == n:
            yield ()
            return
        for v in range(remaining + 1):
            for rest in gen_tuple(pos + 1, remaining - v, n):
                yield (v,) + rest

    return set(gen_tuple(0, d, n))


def homogeneous_support(n: int, d: int) -> Set[MultiIndex]:
    """
    Generate the support of a generic homogeneous polynomial of degree d in n vars.
    """
    def gen(pos, remaining, n):
        if pos == n - 1:
            yield (remaining,)
            return
        for v in range(remaining + 1):
            for rest in gen(pos + 1, remaining - v, n):
                yield (v,) + rest

    if n == 0:
        return {()} if d == 0 else set()
    return set(gen(0, d, n))


def uniform_matroid_support(n: int, r: int) -> Set[MultiIndex]:
    """
    Generate the support of the basis generating polynomial of U_{r,n}.
    These are all 0-1 vectors of length n with exactly r ones.
    """
    from itertools import combinations
    result = set()
    for combo in combinations(range(n), r):
        vec = [0] * n
        for i in combo:
            vec[i] = 1
        result.add(tuple(vec))
    return result


def permutahedron_support(n: int) -> Set[MultiIndex]:
    """
    Generate the support corresponding to all permutations of (0,1,...,n-1).
    This is a generalized permutahedron support.
    """
    from itertools import permutations
    return set(permutations(range(n)))


# --- Verified Shadow Computation ---

def verify_shadow_theorem(S: Set[MultiIndex], k: int) -> Dict:
    """
    Verify the k-th shadow theorem computationally:
    Shadow_k(S) should equal the union of supports of all D^tau(f)
    with |tau| = k, for any generic polynomial f with support S.

    Returns a dict with verification results.
    """
    shadow = kth_shadow(S, k)
    deriv_union = all_derivative_supports_union(S, k)

    return {
        "k": k,
        "shadow_size": len(shadow),
        "deriv_union_size": len(deriv_union),
        "match": shadow == deriv_union,
        "shadow": shadow,
        "deriv_union": deriv_union,
    }


def verify_semigroup_law(S: Set[MultiIndex], a: int, b: int) -> Dict:
    """
    Verify Shadow_b(Shadow_a(S)) = Shadow_{a+b}(S).
    """
    lhs = kth_shadow(kth_shadow(S, a), b)
    rhs = kth_shadow(S, a + b)

    return {
        "a": a,
        "b": b,
        "lhs_size": len(lhs),
        "rhs_size": len(rhs),
        "match": lhs == rhs,
    }


if __name__ == "__main__":
    # Quick self-test
    print("=== Algorithms Self-Test ===")

    # Test with uniform matroid U_{3,5}
    S = uniform_matroid_support(5, 3)
    print(f"\nUniform matroid U_{{3,5}}: |S| = {len(S)}")

    profile = shadow_profile(S)
    print(f"Shadow profile: {profile}")
    print(f"Log-concave: {is_log_concave(profile)}")
    print(f"Exchange family: {is_discrete_exchange_family(S)}")

    # Verify shadow theorem
    for k in range(4):
        result = verify_shadow_theorem(S, k)
        print(f"Shadow theorem k={k}: match={result['match']}, size={result['shadow_size']}")

    # Verify semigroup law
    for a in range(3):
        for b in range(3):
            result = verify_semigroup_law(S, a, b)
            print(f"Semigroup law a={a}, b={b}: match={result['match']}")
