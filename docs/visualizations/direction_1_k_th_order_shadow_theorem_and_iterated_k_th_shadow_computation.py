"""
algorithms.py — Core algorithms for iterated shadow geometry of polynomial supports.

Implements the kth-shadow operator, iterated mixed partial derivatives,
shadow profiles, and exchange family tests.
"""

from itertools import product as iterproduct
from collections import Counter
from math import comb, factorial, prod
from typing import List, Tuple, Set, Dict, FrozenSet
import functools


# ─────────────────────────────────────────────────────────────────────────
# Multi-index utilities
# ─────────────────────────────────────────────────────────────────────────

def multi_index_sum(tau: Tuple[int, ...]) -> int:
    """Total mass of a multi-index: sum of all entries."""
    return sum(tau)


def ascending_factorial(n: int, k: int) -> int:
    """Compute n * (n+1) * ... * (n+k-1). Returns 1 if k=0."""
    result = 1
    for j in range(k):
        result *= (n + j)
    return result


def multi_ascending_factorial(beta: Tuple[int, ...], tau: Tuple[int, ...]) -> int:
    """Product of ascending factorials: ∏_i ascFactorial(β_i + 1, τ_i)."""
    return prod(ascending_factorial(b + 1, t) for b, t in zip(beta, tau))


# ─────────────────────────────────────────────────────────────────────────
# Polynomial representation (sparse, multi-index keyed)
# ─────────────────────────────────────────────────────────────────────────

class MvPolynomial:
    """Sparse multivariate polynomial over rationals.

    Represented as a dict mapping multi-index tuples to coefficients.
    Zero coefficients are not stored.

    Example:
        p = MvPolynomial({(2,0): 3, (1,1): -1, (0,2): 5})
        represents 3*x^2 - xy + 5*y^2
    """

    def __init__(self, coeffs: Dict[Tuple[int, ...], float], n_vars: int = None):
        self.coeffs = {k: v for k, v in coeffs.items() if v != 0}
        if n_vars is not None:
            self.n_vars = n_vars
        elif self.coeffs:
            self.n_vars = len(next(iter(self.coeffs)))
        else:
            self.n_vars = 0

    @property
    def support(self) -> Set[Tuple[int, ...]]:
        """The Newton support: set of exponent vectors with nonzero coefficient."""
        return set(self.coeffs.keys())

    def coeff(self, alpha: Tuple[int, ...]) -> float:
        """Get the coefficient of the monomial x^alpha."""
        return self.coeffs.get(alpha, 0)

    def pderiv(self, i: int) -> 'MvPolynomial':
        """Partial derivative with respect to variable i."""
        new_coeffs = {}
        for alpha, c in self.coeffs.items():
            if alpha[i] > 0:
                new_alpha = list(alpha)
                new_alpha[i] -= 1
                new_alpha = tuple(new_alpha)
                new_coeffs[new_alpha] = new_coeffs.get(new_alpha, 0) + c * alpha[i]
        return MvPolynomial(new_coeffs, self.n_vars)

    def pderiv_pow(self, i: int, k: int) -> 'MvPolynomial':
        """Apply partial derivative w.r.t. variable i exactly k times."""
        result = self
        for _ in range(k):
            result = result.pderiv(i)
        return result

    def iterated_pderiv(self, tau: Tuple[int, ...]) -> 'MvPolynomial':
        """Mixed partial derivative: ∂^τ f = ∂_0^{τ_0} ... ∂_{n-1}^{τ_{n-1}} f."""
        result = self
        for i, k in enumerate(tau):
            result = result.pderiv_pow(i, k)
        return result

    def __repr__(self):
        if not self.coeffs:
            return "0"
        terms = []
        for alpha, c in sorted(self.coeffs.items(), key=lambda x: (-sum(x[0]), x[0])):
            terms.append(f"{c}*x^{alpha}")
        return " + ".join(terms)


# ─────────────────────────────────────────────────────────────────────────
# k-th Shadow computation
# ─────────────────────────────────────────────────────────────────────────

def enumerate_multi_indices_le(alpha: Tuple[int, ...], mass: int) -> List[Tuple[int, ...]]:
    """Enumerate all multi-indices τ with τ ≤ α (componentwise) and sum(τ) = mass.

    Uses recursive generation.
    """
    n = len(alpha)
    results = []

    def generate(pos, remaining, current):
        if pos == n:
            if remaining == 0:
                results.append(tuple(current))
            return
        max_val = min(alpha[pos], remaining)
        for v in range(max_val + 1):
            current.append(v)
            generate(pos + 1, remaining - v, current)
            current.pop()

    generate(0, mass, [])
    return results


def kth_shadow(S: Set[Tuple[int, ...]], k: int) -> Set[Tuple[int, ...]]:
    """Compute the k-th combinatorial shadow of a support set S.

    kthShadow(S, k) = {α - τ | α ∈ S, τ ≤ α, sum(τ) = k}
                     = {β | ∃ τ, sum(τ) = k, β + τ ∈ S}

    Args:
        S: Set of multi-index tuples (the support).
        k: Shadow depth (total mass to subtract).

    Returns:
        The k-th shadow as a set of multi-index tuples.

    Time complexity: O(|S| * max_degree^n) where max_degree is the maximum
    coordinate value and n is the number of variables.
    """
    shadow = set()
    for alpha in S:
        for tau in enumerate_multi_indices_le(alpha, k):
            beta = tuple(a - t for a, t in zip(alpha, tau))
            shadow.add(beta)
    return shadow


def shadow_profile(S: Set[Tuple[int, ...]], max_k: int = None) -> List[int]:
    """Compute the shadow profile: k ↦ |kthShadow(S, k)| for k = 0, 1, ..., max_k.

    Args:
        S: Support set.
        max_k: Maximum shadow depth (defaults to max total degree in S).

    Returns:
        List of shadow sizes [|Sh_0(S)|, |Sh_1(S)|, ...].
    """
    if not S:
        return [0]
    if max_k is None:
        max_k = max(sum(alpha) for alpha in S)
    return [len(kth_shadow(S, k)) for k in range(max_k + 1)]


# ─────────────────────────────────────────────────────────────────────────
# Derivative support computation (algebraic, for verification)
# ─────────────────────────────────────────────────────────────────────────

def all_multi_indices_of_mass(n: int, k: int) -> List[Tuple[int, ...]]:
    """Enumerate all n-tuples of non-negative integers summing to k.

    Uses stars-and-bars enumeration.
    """
    if n == 0:
        return [()] if k == 0 else []
    if n == 1:
        return [(k,)]
    results = []
    for first in range(k + 1):
        for rest in all_multi_indices_of_mass(n - 1, k - first):
            results.append((first,) + rest)
    return results


def derivative_support_union(f: MvPolynomial, k: int) -> Set[Tuple[int, ...]]:
    """Compute the union of supports of all k-th order mixed partial derivatives.

    Returns {β | ∃ τ with |τ|=k, β ∈ supp(∂^τ f)}.
    """
    n = f.n_vars
    union = set()
    for tau in all_multi_indices_of_mass(n, k):
        df = f.iterated_pderiv(tau)
        union |= df.support
    return union


def verify_shadow_theorem(f: MvPolynomial, k: int) -> bool:
    """Verify the exact k-th shadow theorem for a given polynomial and k.

    Checks: kthShadow(supp(f), k) == ⋃_{|τ|=k} supp(∂^τ f)

    Returns True if the theorem holds.
    """
    shadow = kth_shadow(f.support, k)
    deriv_supp = derivative_support_union(f, k)
    return shadow == deriv_supp


# ─────────────────────────────────────────────────────────────────────────
# Exchange family and log-concavity tests
# ─────────────────────────────────────────────────────────────────────────

def is_discrete_exchange_family(S: Set[Tuple[int, ...]]) -> bool:
    """Test whether S satisfies the discrete exchange property (M-convexity proxy).

    For all α, β ∈ S and all i with α_i > β_i,
    there exists j with β_j > α_j and α - e_i + e_j ∈ S.
    """
    S_list = list(S)
    n = len(S_list[0]) if S_list else 0
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
                            if tuple(candidate) in S:
                                found = True
                                break
                    if not found:
                        return False
    return True


def test_log_concavity(profile: List[int]) -> Tuple[bool, List[int]]:
    """Test whether a shadow profile is log-concave.

    A sequence a_0, a_1, ..., a_m is log-concave if a_k^2 ≥ a_{k-1} * a_{k+1}
    for all 1 ≤ k ≤ m-1.

    Returns:
        (is_log_concave, list of indices where log-concavity fails)
    """
    violations = []
    for k in range(1, len(profile) - 1):
        if profile[k] ** 2 < profile[k - 1] * profile[k + 1]:
            violations.append(k)
    return len(violations) == 0, violations


def test_ratio_monotonicity(profile: List[int]) -> Tuple[bool, List[int]]:
    """Test whether shadow profile ratios are monotonically decreasing.

    Tests: a_{k+1}/a_k ≤ a_k/a_{k-1} for all valid k
    (i.e., a_{k+1} * a_{k-1} ≤ a_k^2, which is log-concavity).

    Returns (is_monotone, violation_indices).
    """
    return test_log_concavity(profile)


# ─────────────────────────────────────────────────────────────────────────
# Shadow composition verification
# ─────────────────────────────────────────────────────────────────────────

def verify_shadow_composition(S: Set[Tuple[int, ...]], a: int, b: int) -> bool:
    """Verify: kthShadow(kthShadow(S, a), b) == kthShadow(S, a + b)."""
    lhs = kth_shadow(kth_shadow(S, a), b)
    rhs = kth_shadow(S, a + b)
    return lhs == rhs


# ─────────────────────────────────────────────────────────────────────────
# Example generators
# ─────────────────────────────────────────────────────────────────────────

def simplex_support(n: int, d: int) -> Set[Tuple[int, ...]]:
    """Support of a 'full' homogeneous polynomial of degree d in n variables.

    Returns all n-tuples of non-negative integers summing to d.
    """
    return set(all_multi_indices_of_mass(n, d))


def matroid_basis_support(n: int, r: int) -> Set[Tuple[int, ...]]:
    """Support of the basis generating polynomial of the uniform matroid U_{r,n}.

    Each basis is an r-element subset of {0,...,n-1}; the support consists
    of the indicator multi-indices (0/1 entries, exactly r ones).
    """
    from itertools import combinations
    support = set()
    for basis in combinations(range(n), r):
        alpha = [0] * n
        for i in basis:
            alpha[i] = 1
        support.add(tuple(alpha))
    return support


def product_of_simplices_support(dims: List[int]) -> Set[Tuple[int, ...]]:
    """Support of a product of univariate polynomials of given degrees.

    E.g., dims=[2,3] gives all (a,b) with 0≤a≤2, 0≤b≤3.
    """
    ranges = [range(d + 1) for d in dims]
    return set(iterproduct(*ranges))


def random_exchange_support(n: int, d: int, count: int, seed: int = 42) -> Set[Tuple[int, ...]]:
    """Generate a random M-convex-like support set by starting from a simplex
    and randomly removing elements while maintaining the exchange property."""
    import random
    rng = random.Random(seed)
    full = simplex_support(n, d)
    S = set(full)
    candidates = list(S)
    rng.shuffle(candidates)
    removed = 0
    for alpha in candidates:
        if removed >= len(full) - count:
            break
        trial = S - {alpha}
        if len(trial) >= 2 and is_discrete_exchange_family(trial):
            S = trial
            removed += 1
    return S


if __name__ == "__main__":
    # Quick demo
    print("=== Shadow Profile of Simplex Support ===")
    S = simplex_support(3, 3)
    print(f"Support size: {len(S)}")
    prof = shadow_profile(S)
    print(f"Shadow profile: {prof}")
    lc, violations = test_log_concavity(prof)
    print(f"Log-concave: {lc}")

    print("\n=== Matroid Basis Support (U_3,5) ===")
    S = matroid_basis_support(5, 3)
    print(f"Support size: {len(S)}")
    prof = shadow_profile(S)
    print(f"Shadow profile: {prof}")
    lc, _ = test_log_concavity(prof)
    print(f"Log-concave: {lc}")
    print(f"Exchange family: {is_discrete_exchange_family(S)}")

    print("\n=== Shadow Composition Verification ===")
    S = simplex_support(3, 4)
    for a in range(5):
        for b in range(5 - a):
            ok = verify_shadow_composition(S, a, b)
            if not ok:
                print(f"FAILED: a={a}, b={b}")
    print("All shadow composition checks passed!")
