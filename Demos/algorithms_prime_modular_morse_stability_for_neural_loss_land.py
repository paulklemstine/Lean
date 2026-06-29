#!/usr/bin/env python3
"""
Prime-Modular Morse Stability: Core Algorithms

Implements the certified computational engine for computing critical profiles,
Morse indices, and arithmetic signatures of polynomial loss functions.
"""

from typing import List, Dict, Tuple, Optional
from collections import Counter
import math


# ============================================================
# Algorithm 1: Polynomial Arithmetic
# ============================================================

class IntPolynomial:
    """Integer polynomial represented as a list of coefficients [a0, a1, ..., ad]."""

    def __init__(self, coeffs: List[int]):
        # Strip trailing zeros
        while len(coeffs) > 1 and coeffs[-1] == 0:
            coeffs = coeffs[:-1]
        self.coeffs = coeffs

    @property
    def degree(self) -> int:
        return len(self.coeffs) - 1

    def eval(self, x) -> int:
        """Evaluate at x using Horner's method. O(deg f)."""
        result = 0
        for c in reversed(self.coeffs):
            result = result * x + c
        return result

    def eval_mod(self, x: int, p: int) -> int:
        """Evaluate at x modulo p. O(deg f · log p) via modular exponentiation."""
        result = 0
        for c in reversed(self.coeffs):
            result = (result * x + c) % p
        return result

    def derivative(self) -> 'IntPolynomial':
        """Compute formal derivative. O(deg f)."""
        if len(self.coeffs) <= 1:
            return IntPolynomial([0])
        return IntPolynomial([k * c for k, c in enumerate(self.coeffs) if k > 0])

    def map_mod(self, p: int) -> 'IntPolynomial':
        """Reduce coefficients modulo p."""
        return IntPolynomial([c % p for c in self.coeffs])

    def __repr__(self) -> str:
        terms = []
        for k, c in enumerate(self.coeffs):
            if c == 0:
                continue
            if k == 0:
                terms.append(str(c))
            elif k == 1:
                terms.append(f"{c}x" if c != 1 else "x")
            else:
                terms.append(f"{c}x^{k}" if c != 1 else f"x^{k}")
        return " + ".join(terms) if terms else "0"


# ============================================================
# Algorithm 2: One-Variable Critical Point Finder (mod p)
# ============================================================

def find_critical_points_mod_p(f: IntPolynomial, p: int) -> List[int]:
    """
    Find all critical points of f in F_p.

    Algorithm: Brute-force evaluation of f'(x) for all x in {0, ..., p-1}.
    Complexity: O(p · deg f)

    For large p, one could use polynomial GCD to find roots of f'
    more efficiently in O(deg² f · log p), but brute force suffices
    for the primes we consider.

    Args:
        f: Integer polynomial
        p: Prime number

    Returns:
        List of x in {0, ..., p-1} with f'(x) ≡ 0 (mod p)
    """
    df = f.derivative()
    return [x for x in range(p) if df.eval_mod(x, p) == 0]


def find_critical_fiber_mod_p(f: IntPolynomial, t: int, p: int) -> List[int]:
    """
    Find the critical fiber CritFiber(f, t; F_p).

    Returns all x in F_p with f'(x) ≡ 0 and f(x) ≡ t (mod p).

    Complexity: O(p · deg f)
    """
    df = f.derivative()
    return [x for x in range(p)
            if df.eval_mod(x, p) == 0 and f.eval_mod(x, p) == t % p]


# ============================================================
# Algorithm 3: Critical Profile Computation
# ============================================================

def critical_profile_mod_p(f: IntPolynomial, p: int) -> Dict[int, int]:
    """
    Compute the critical profile of f modulo p.

    critProfile_p(f, t) = #CritFiber(f, t; F_p) for each t in F_p.

    Returns: Dictionary mapping critical values t -> count of critical points.
    Only includes t with nonzero count.

    Complexity: O(p · deg f)
    """
    crits = find_critical_points_mod_p(f, p)
    values = [f.eval_mod(x, p) for x in crits]
    return dict(Counter(values))


def critical_profile_total(f: IntPolynomial, p: int) -> int:
    """
    Compute the total critical profile statistic:
    critProfileTotal_p(f) = Σ_t critProfile_p(f,t)²

    This is a collision statistic measuring critical-value clustering.
    It equals 1 when all critical values are distinct (generic Morse),
    and is larger when critical values collide.

    Complexity: O(p · deg f)
    """
    profile = critical_profile_mod_p(f, p)
    return sum(c * c for c in profile.values())


# ============================================================
# Algorithm 4: Separable Loss Critical Count via Convolution
# ============================================================

def separable_critical_count_mod_p(
    components: List[IntPolynomial], p: int
) -> int:
    """
    Compute total critical point count of separable loss Σ fᵢ(θᵢ) mod p.

    By the product decomposition theorem (Theorem 1), this equals
    the product of individual critical counts.

    Complexity: O(n · p · max_deg)
    """
    count = 1
    for f in components:
        count *= len(find_critical_points_mod_p(f, p))
    return count


def separable_critical_profile_convolution(
    components: List[IntPolynomial], p: int
) -> Dict[int, int]:
    """
    Compute critical profile of separable loss via additive convolution.

    For L = Σ fᵢ(θᵢ), the critical profile at value t is:
    critProfile_p(L, t) = Σ_{τ: Σ τᵢ = t} Π_i critProfile_p(fᵢ, τᵢ)

    This is the additive convolution of individual profiles over F_p.

    Complexity: O(n · p² · max_deg)
    """
    # Start with the profile of the first component
    profiles = []
    for f in components:
        prof = {}
        for t in range(p):
            count = len(find_critical_fiber_mod_p(f, t, p))
            if count > 0:
                prof[t] = count
        profiles.append(prof)

    # Convolve profiles one by one
    result = profiles[0] if profiles else {}
    for i in range(1, len(profiles)):
        new_result = {}
        for t1, c1 in result.items():
            for t2, c2 in profiles[i].items():
                t = (t1 + t2) % p
                new_result[t] = new_result.get(t, 0) + c1 * c2
        result = new_result

    return result


# ============================================================
# Algorithm 5: Exceptional Prime Set Computation
# ============================================================

def prime_factors(n: int) -> List[int]:
    """Compute prime factorization of |n|. O(sqrt(n))."""
    n = abs(n)
    if n <= 1:
        return []
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            factors.append(d)
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def exceptional_primes_for_critical_point(
    f: IntPolynomial, a: int
) -> List[int]:
    """
    Compute the exceptional prime set for a nondegenerate integer critical point.

    Given f with f'(a) = 0 and f''(a) ≠ 0, returns the set of primes p
    such that f''(a) ≡ 0 (mod p), i.e., the prime factors of |f''(a)|.

    For all primes NOT in this set, the critical point remains nondegenerate mod p.

    Complexity: O(sqrt(|f''(a)|))
    """
    ddf = f.derivative().derivative()
    second_deriv_val = ddf.eval(a)
    return prime_factors(second_deriv_val)


def exceptional_primes_separable(
    components: List[IntPolynomial],
    critical_points: List[List[int]]
) -> List[int]:
    """
    Compute the exceptional prime set for a separable loss with known
    integer critical points.

    The exceptional set is the union of:
    1. Primes dividing any f''_i(a_j) for critical points a_j of f_i
    2. Primes dividing differences of distinct critical points (for injectivity)
    3. Primes dividing differences of distinct critical values (for value separation)

    Complexity: O(n · k² · sqrt(M)) where k = max critical points per component,
    M = max absolute value of relevant integers.
    """
    all_primes = set()

    for i, (f, crits) in enumerate(zip(components, critical_points)):
        for a in crits:
            # Nondegeneracy primes
            all_primes.update(exceptional_primes_for_critical_point(f, a))

        # Injectivity primes
        for j in range(len(crits)):
            for k in range(j + 1, len(crits)):
                diff = crits[j] - crits[k]
                if diff != 0:
                    all_primes.update(prime_factors(diff))

        # Value separation primes
        values = [f.eval(a) for a in crits]
        for j in range(len(values)):
            for k in range(j + 1, len(values)):
                diff = values[j] - values[k]
                if diff != 0:
                    all_primes.update(prime_factors(diff))

    return sorted(all_primes)


# ============================================================
# Algorithm 6: Diagonal Quadratic Morse Analysis
# ============================================================

def diagonal_morse_index(epsilon: List[int]) -> int:
    """
    Compute Morse index of diagonal quadratic Q(θ) = Σ εᵢθᵢ² + cᵢθᵢ + d.
    Equals the number of negative εᵢ.

    Complexity: O(n)
    """
    return sum(1 for e in epsilon if e < 0)


def diagonal_sign_product(epsilon: List[int]) -> int:
    """
    Compute sign product ∏ εᵢ.
    For ±1 entries, equals (-1)^(Morse index).

    Complexity: O(n)
    """
    prod = 1
    for e in epsilon:
        prod *= e
    return prod


def diagonal_hessian_det(epsilon: List[int]) -> int:
    """
    Compute Hessian determinant ∏(2εᵢ) = 2^n · ∏εᵢ.

    Complexity: O(n)
    """
    prod = 1
    for e in epsilon:
        prod *= 2 * e
    return prod


def legendre_symbol(a: int, p: int) -> int:
    """
    Compute Legendre symbol (a/p) via Euler's criterion: a^((p-1)/2) mod p.

    Returns: 1 if a is a QR mod p, -1 if NR, 0 if p | a.

    Complexity: O(log p)
    """
    if p == 2:
        return a % 2
    a = a % p
    if a == 0:
        return 0
    val = pow(a, (p - 1) // 2, p)
    return 1 if val == 1 else -1


def quad_signature(epsilon: List[int], p: int) -> int:
    """
    Compute the quadratic character signature χ_p(det Hess(Q)).

    For diagonal quadratic Q with sign pattern ε and odd prime p:
    quadSignature_p(Q) = χ_p(2^n · ∏εᵢ) = χ_p(2)^n · χ_p((-1)^index)

    This arithmetic statistic detects Morse index parity.

    Complexity: O(n + log p)
    """
    det = diagonal_hessian_det(epsilon)
    return legendre_symbol(det, p)


# ============================================================
# Algorithm 7: Verified Separable Assembly
# ============================================================

def verified_separable_assembly(
    components: List[IntPolynomial], p: int
) -> Tuple[int, Dict[int, int], bool]:
    """
    Verified computation of separable loss critical data.

    1. Computes per-component critical sets
    2. Verifies product formula for total count
    3. Computes full profile via convolution
    4. Returns (total_count, profile, verification_passed)

    This implements the certified computational engine justified by Theorem 1.

    Complexity: O(n · p² · max_deg)
    """
    # Step 1: Per-component critical counts
    per_component_counts = []
    for f in components:
        crits = find_critical_points_mod_p(f, p)
        per_component_counts.append(len(crits))

    # Step 2: Product formula
    product_count = 1
    for c in per_component_counts:
        product_count *= c

    # Step 3: Convolution profile
    profile = separable_critical_profile_convolution(components, p)
    total_from_profile = sum(profile.values())

    # Step 4: Verification
    verified = (product_count == total_from_profile)

    return product_count, profile, verified


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Prime-Modular Morse Stability: Algorithm Examples")
    print("=" * 60)

    # Example 1: One-variable critical analysis
    f = IntPolynomial([0, 0, -2, 0, 1])  # x^4 - 2x^2
    print(f"\nPolynomial: {f}")
    print(f"Derivative: {f.derivative()}")
    print(f"Second derivative: {f.derivative().derivative()}")

    for a in [-1, 0, 1]:
        df_val = f.derivative().eval(a)
        ddf_val = f.derivative().derivative().eval(a)
        exc = exceptional_primes_for_critical_point(f, a)
        print(f"\n  a = {a}: f'(a) = {df_val}, f''(a) = {ddf_val}")
        print(f"  Exceptional primes: {exc}")

        for p in [3, 5, 7, 11]:
            crits = find_critical_points_mod_p(f, p)
            profile = critical_profile_mod_p(f, p)
            print(f"    p = {p}: crits = {crits}, profile = {profile}")

    # Example 2: Separable loss
    print("\n" + "=" * 60)
    f1 = IntPolynomial([0, 0, -2, 0, 1])  # x^4 - 2x^2
    f2 = IntPolynomial([0, 0, 1])          # y^2
    components = [f1, f2]

    for p in [3, 5, 7, 11, 13]:
        count, profile, verified = verified_separable_assembly(components, p)
        print(f"  p = {p}: count = {count}, profile = {profile}, verified = {verified}")

    # Example 3: Diagonal quadratic
    print("\n" + "=" * 60)
    epsilon = [1, -1, 1, -1]
    idx = diagonal_morse_index(epsilon)
    sig_prod = diagonal_sign_product(epsilon)
    hess = diagonal_hessian_det(epsilon)
    print(f"\n  ε = {epsilon}")
    print(f"  Morse index = {idx}")
    print(f"  Sign product = {sig_prod}")
    print(f"  (-1)^index = {(-1)**idx}")
    print(f"  Match: {sig_prod == (-1)**idx}")
    print(f"  Hessian det = {hess} = 2^{len(epsilon)} × {sig_prod}")

    for p in [3, 5, 7, 11, 13, 17, 19, 23]:
        sig = quad_signature(epsilon, p)
        chi2n = legendre_symbol(2, p) ** len(epsilon)
        chi_neg1_idx = legendre_symbol((-1)**idx, p)
        print(f"    p = {p}: χ_p(det) = {sig}, χ_p(2)^n·χ_p((-1)^idx) = {chi2n * chi_neg1_idx}")
