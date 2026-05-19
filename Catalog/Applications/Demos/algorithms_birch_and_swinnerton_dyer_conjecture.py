#!/usr/bin/env python3
"""
BSD Conjecture — Algorithms

Implements the core computational algorithms for BSD data computation,
local Euler factor extraction, and BSD formula verification.
"""

from dataclasses import dataclass
from math import sqrt, gcd, isclose, log
from typing import List, Tuple, Optional


# ============================================================
# Algorithm 1: Frobenius Trace from Point Count
# ============================================================

def frobenius_trace(p: int, point_count: int) -> int:
    """Compute the Frobenius trace a_p from the point count #E(F_p).

    Given a prime p and the number of F_p-rational points on an
    elliptic curve E, compute the unique trace of Frobenius:
        a_p = p + 1 - #E(F_p)

    This is the computational counterpart of the formal theorem
    `frobenius_trace_unique_value`.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        p: A prime number (the characteristic).
        point_count: The number of F_p-rational points #E(F_p).

    Returns:
        The Frobenius trace a_p.

    Examples:
        >>> frobenius_trace(5, 5)
        1
        >>> frobenius_trace(7, 9)
        -1
        >>> frobenius_trace(11, 11)
        1
    """
    return p + 1 - point_count


def verify_hasse_bound(p: int, ap: int) -> bool:
    """Verify that a Frobenius trace satisfies the Hasse bound |a_p| <= 2*sqrt(p).

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        p: A prime number.
        ap: The Frobenius trace.

    Returns:
        True if |a_p| <= 2*sqrt(p).

    Examples:
        >>> verify_hasse_bound(5, 1)
        True
        >>> verify_hasse_bound(5, 10)
        False
    """
    return ap * ap <= 4 * p


# ============================================================
# Algorithm 2: Local Euler Factor Computation
# ============================================================

def euler_factor_polynomial(p: int, ap: int) -> Tuple[int, int, int]:
    """Compute the local Euler factor polynomial 1 - a_p T + p T^2.

    For a good prime p, the local Euler factor in the L-function is:
        L_p(s) = (1 - a_p p^{-s} + p^{1-2s})^{-1}

    Equivalently, with T = p^{-s}:
        L_p(T)^{-1} = 1 - a_p T + p T^2

    Returns the coefficients (1, -a_p, p) of the polynomial.

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        p: A prime number.
        ap: The Frobenius trace.

    Returns:
        Tuple (c0, c1, c2) where the polynomial is c0 + c1*T + c2*T^2.
    """
    return (1, -ap, p)


def euler_factor_at_one(p: int, ap: int) -> float:
    """Evaluate the local Euler factor at s=1 (i.e., T = 1/p).

    L_p(1)^{-1} = 1 - a_p/p + 1/p = (p + 1 - a_p) / p = #E(F_p) / p

    Time complexity: O(1)

    Args:
        p: A prime number.
        ap: The Frobenius trace.

    Returns:
        The value of the local Euler factor at s=1.
    """
    return p / (p + 1 - ap)


# ============================================================
# Algorithm 3: BSD Quotient Computation
# ============================================================

@dataclass
class BSDInvariants:
    """Complete BSD invariant package for numerical verification."""
    rank: int
    regulator: float
    sha_order: int
    tamagawa_product: int
    torsion_order: int
    real_period: float
    leading_coeff: float

    def algebraic_side(self) -> float:
        """Compute Omega * R * |Sha| * prod(c_p) / |E(Q)_tors|^2.

        Time complexity: O(1)
        Space complexity: O(1)
        """
        numerator = (self.real_period * self.regulator *
                     self.sha_order * self.tamagawa_product)
        denominator = self.torsion_order ** 2
        return numerator / denominator

    def verify_bsd(self, tolerance: float = 1e-10) -> Tuple[bool, float]:
        """Verify the BSD formula numerically.

        Returns (passes, ratio) where ratio should be ~1.0 if BSD holds.

        Time complexity: O(1)
        Space complexity: O(1)

        Args:
            tolerance: Relative tolerance for the comparison.

        Returns:
            Tuple of (whether BSD holds within tolerance, the ratio L*/algebraic_side).
        """
        alg = self.algebraic_side()
        if abs(alg) < 1e-300:
            return (abs(self.leading_coeff) < 1e-300, float('inf'))
        ratio = self.leading_coeff / alg
        return (isclose(ratio, 1.0, rel_tol=tolerance), ratio)


# ============================================================
# Algorithm 4: Partial L-series from Point Counts
# ============================================================

def partial_l_product(point_counts: dict, s: float = 1.0) -> float:
    """Compute a partial Euler product for L(E,s) from point count data.

    L(E,s) = prod_{p good} (1 - a_p p^{-s} + p^{1-2s})^{-1}

    This computes the product over the given good primes.

    Time complexity: O(n) where n = len(point_counts)
    Space complexity: O(1)

    Args:
        point_counts: Dict mapping prime p -> #E(F_p).
        s: The value at which to evaluate (default: s=1).

    Returns:
        The partial Euler product.

    Example:
        >>> primes_data = {2: 5, 3: 5, 5: 5, 7: 9}
        >>> partial_l_product(primes_data)  # Partial L(E,1)
        1.44...
    """
    product = 1.0
    for p, N in point_counts.items():
        ap = frobenius_trace(p, N)
        # L_p(s)^{-1} = 1 - a_p * p^{-s} + p^{1-2s}
        T = p ** (-s)
        inv_factor = 1 - ap * T + p * T * T
        if abs(inv_factor) > 1e-15:
            product /= inv_factor
    return product


# ============================================================
# Algorithm 5: Isogeny Invariance Verification
# ============================================================

def verify_isogeny_bsd_relation(
    B1: BSDInvariants, B2: BSDInvariants,
    tolerance: float = 1e-10
) -> dict:
    """Verify the isogeny BSD relation between two curves.

    Checks all four conditions of IsogenyBSDRel:
    1. rank equality
    2. analytic rank equality (via leading coeff comparison)
    3. leading coefficient equality
    4. BSD quotient equality

    Time complexity: O(1)
    Space complexity: O(1)

    Args:
        B1, B2: BSD invariant packages for two isogenous curves.
        tolerance: Relative tolerance for float comparisons.

    Returns:
        Dictionary with verification results.
    """
    alg1 = B1.algebraic_side()
    alg2 = B2.algebraic_side()

    return {
        "rank_equal": B1.rank == B2.rank,
        "leading_coeff_equal": isclose(B1.leading_coeff, B2.leading_coeff,
                                        rel_tol=tolerance),
        "quotient_equal": isclose(alg1, alg2, rel_tol=tolerance),
        "both_satisfy_bsd": B1.verify_bsd(tolerance)[0] and B2.verify_bsd(tolerance)[0],
    }


# ============================================================
# Algorithm 6: Sieve for Good Primes
# ============================================================

def sieve_primes(limit: int) -> List[int]:
    """Sieve of Eratosthenes up to limit.

    Time complexity: O(n log log n) where n = limit
    Space complexity: O(n)
    """
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def good_primes(conductor: int, limit: int) -> List[int]:
    """Return primes up to limit that don't divide the conductor (good primes).

    Time complexity: O(limit * log log limit)
    Space complexity: O(limit)
    """
    return [p for p in sieve_primes(limit) if conductor % p != 0]


# ============================================================
# Main: Run all algorithm examples
# ============================================================

if __name__ == "__main__":
    print("BSD Algorithms — Example Usage")
    print("=" * 50)

    # Frobenius traces
    print("\n1. Frobenius traces for 11a1:")
    for p, N in [(2, 5), (3, 5), (5, 5), (7, 9), (13, 10)]:
        ap = frobenius_trace(p, N)
        hasse_ok = verify_hasse_bound(p, ap)
        print(f"   p={p:3d}, #E(F_p)={N:3d}, a_p={ap:4d}, "
              f"Hasse: {hasse_ok}")

    # Euler factors
    print("\n2. Local Euler factors at s=1:")
    for p, N in [(2, 5), (3, 5), (5, 5), (7, 9)]:
        ap = frobenius_trace(p, N)
        lp = euler_factor_at_one(p, ap)
        print(f"   L_{p}(1) = {lp:.6f}")

    # BSD verification for 11a1
    print("\n3. BSD verification (11a1):")
    B = BSDInvariants(
        rank=0, regulator=1.0, sha_order=1,
        tamagawa_product=5, torsion_order=5,
        real_period=1.26920930427955,
        leading_coeff=0.253841860855911
    )
    ok, ratio = B.verify_bsd()
    print(f"   BSD holds: {ok}, ratio = {ratio:.15f}")

    # Partial L-product
    print("\n4. Partial L-product convergence:")
    primes_11a1 = {
        2: 5, 3: 5, 5: 5, 7: 9, 13: 10, 17: 20, 19: 20, 23: 25,
        29: 30, 31: 25, 37: 30, 41: 50, 43: 45, 47: 40, 53: 60,
    }
    for n in [3, 5, 8, 10, 15]:
        subset = dict(list(primes_11a1.items())[:n])
        val = partial_l_product(subset)
        print(f"   {n:2d} primes: L(E,1) ≈ {val:.6f}")

    print("\n5. Good primes for conductor 11:")
    gp = good_primes(11, 50)
    print(f"   {gp}")
