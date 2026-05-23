#!/usr/bin/env python3
"""
Algorithms for P-adic Orbital Period Valuation

Implements the core computational methods for computing and certifying
p-adic orbital invariants, as formalized in PadicOrbitalValuation.lean.

All algorithms have complete type hints, docstrings, and example usage.
"""

from fractions import Fraction
from typing import List, Tuple, NamedTuple, Optional
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════════
# Core p-adic Valuation
# ═══════════════════════════════════════════════════════════════════════

def padic_val_int(p: int, n: int) -> int:
    """
    Compute the p-adic valuation of an integer n.

    The p-adic valuation v_p(n) is the largest exponent k such that
    p^k divides n. By convention, v_p(0) = 0.

    Args:
        p: A prime number (≥ 2).
        n: An integer.

    Returns:
        The p-adic valuation of n.

    Complexity: O(log_p(|n|)) time, O(1) space.

    Examples:
        >>> padic_val_int(2, 24)
        3
        >>> padic_val_int(3, 81)
        4
        >>> padic_val_int(5, 7)
        0
    """
    if n == 0:
        return 0
    v = 0
    n = abs(n)
    while n % p == 0:
        v += 1
        n //= p
    return v


def padic_val_rat(p: int, q: Fraction) -> int:
    """
    Compute the p-adic valuation of a rational number q.

    For q = a/b in lowest terms, v_p(q) = v_p(a) - v_p(b).

    Args:
        p: A prime number (≥ 2).
        q: A rational number (Fraction).

    Returns:
        The p-adic valuation of q.

    Complexity: O(log_p(max(|num|, |den|))) time, O(1) space.

    Examples:
        >>> padic_val_rat(2, Fraction(3, 4))
        -2
        >>> padic_val_rat(3, Fraction(9, 2))
        2
    """
    if q == 0:
        return 0
    return padic_val_int(p, q.numerator) - padic_val_int(p, q.denominator)


# ═══════════════════════════════════════════════════════════════════════
# Orbital Arithmetic Invariants
# ═══════════════════════════════════════════════════════════════════════

def orbital_period_squared(a: Fraction, mu: Fraction) -> Fraction:
    """
    Compute the rationalized Kepler period invariant Θ(a,μ) = a³/μ.

    From Kepler's third law T = 2π·a^(3/2)·μ^(-1/2), we have
    (T/2π)² = a³/μ. This is always rational for rational inputs.

    Args:
        a: Semimajor axis (nonzero rational).
        mu: Gravitational parameter (nonzero rational).

    Returns:
        The rationalized period squared Θ = a³/μ.

    Examples:
        >>> orbital_period_squared(Fraction(2), Fraction(1))
        Fraction(8, 1)
    """
    return a ** 3 / mu


def kepler_valuation_charge(p: int, a: Fraction, mu: Fraction) -> int:
    """
    Compute the Kepler valuation charge Q_p(a,μ) = 3·v_p(a) - v_p(μ).

    This is the additive conserved quantity under multiplicative composition
    of orbital data: Q_p(a₁a₂, μ₁μ₂) = Q_p(a₁,μ₁) + Q_p(a₂,μ₂).

    Args:
        p: A prime number.
        a: Semimajor axis (nonzero rational).
        mu: Gravitational parameter (nonzero rational).

    Returns:
        The valuation charge Q_p(a,μ).

    Complexity: O(log_p(max(|a|, |μ|))) time, O(1) space.

    Examples:
        >>> kepler_valuation_charge(2, Fraction(4), Fraction(8))
        0
        >>> kepler_valuation_charge(3, Fraction(9), Fraction(3))
        5
    """
    return 3 * padic_val_rat(p, a) - padic_val_rat(p, mu)


@dataclass
class OrbitalDepthProfile:
    """
    The tropical depth profile of an orbital system at a fixed prime p.

    Records the p-adic depths (valuations) of the semimajor axis and
    gravitational parameter. The period invariant is recoverable from
    this combinatorial datum alone.
    """
    depth_a: int
    depth_mu: int

    def period_depth_invariant(self) -> int:
        """Compute 3·depth(a) - depth(μ), the tropical read-off formula."""
        return 3 * self.depth_a - self.depth_mu

    @classmethod
    def from_params(cls, p: int, a: Fraction, mu: Fraction) -> 'OrbitalDepthProfile':
        """Construct from orbital parameters at prime p."""
        return cls(
            depth_a=padic_val_rat(p, a),
            depth_mu=padic_val_rat(p, mu)
        )


class OrbitalValuationReport(NamedTuple):
    """Complete orbital valuation report at a fixed prime."""
    prime: int
    a: Fraction
    mu: Fraction
    val_a: int
    val_mu: int
    val_theta: int
    predicted: int
    match: bool
    even_pair: bool
    half_val: Optional[int]


# ═══════════════════════════════════════════════════════════════════════
# Certification Algorithm
# ═══════════════════════════════════════════════════════════════════════

def certify_cubic_law(p: int, a: Fraction, mu: Fraction) -> OrbitalValuationReport:
    """
    Certify the cubic valuation law for given parameters.

    Computes v_p(a³/μ) directly and via the formula 3·v_p(a) - v_p(μ),
    checking equality. Also tests half-valuation admissibility.

    Algorithm:
        1. Compute v_p(a) and v_p(μ) using integer factorization.
        2. Compute Θ = a³/μ as an exact rational.
        3. Compute v_p(Θ) directly.
        4. Compute the prediction 3·v_p(a) - v_p(μ).
        5. Compare and report.
        6. Check even parity and compute half-valuation if admissible.

    Complexity: O(log_p(max(|a|, |μ|))) time, O(1) space.

    Args:
        p: A prime number.
        a: Nonzero rational semimajor axis.
        mu: Nonzero rational gravitational parameter.

    Returns:
        An OrbitalValuationReport with all computed values.

    Examples:
        >>> r = certify_cubic_law(2, Fraction(3, 4), Fraction(5, 8))
        >>> r.match
        True
    """
    va = padic_val_rat(p, a)
    vmu = padic_val_rat(p, mu)
    theta = orbital_period_squared(a, mu)
    vtheta = padic_val_rat(p, theta)
    predicted = 3 * va - vmu
    even_pair = (va % 2 == 0) and (vmu % 2 == 0)
    half_val = predicted // 2 if even_pair and predicted % 2 == 0 else None

    return OrbitalValuationReport(
        prime=p,
        a=a,
        mu=mu,
        val_a=va,
        val_mu=vmu,
        val_theta=vtheta,
        predicted=predicted,
        match=(vtheta == predicted),
        even_pair=even_pair,
        half_val=half_val
    )


def certify_scaling_covariance(
    p: int, a: Fraction, mu: Fraction, lam: Fraction
) -> Tuple[bool, int, int, int]:
    """
    Certify the scaling covariance theorem:
    v_p(Θ(λa,μ)) = v_p(Θ(a,μ)) + 3·v_p(λ).

    Returns:
        (match, v_original, v_scaled, v_predicted)
    """
    v_orig = padic_val_rat(p, orbital_period_squared(a, mu))
    v_scaled = padic_val_rat(p, orbital_period_squared(lam * a, mu))
    v_pred = v_orig + 3 * padic_val_rat(p, lam)
    return (v_scaled == v_pred, v_orig, v_scaled, v_pred)


def certify_charge_additivity(
    p: int,
    a1: Fraction, mu1: Fraction,
    a2: Fraction, mu2: Fraction
) -> Tuple[bool, int, int, int]:
    """
    Certify the additive charge law:
    Q_p(a₁a₂, μ₁μ₂) = Q_p(a₁,μ₁) + Q_p(a₂,μ₂).

    Returns:
        (match, q_composite, q_sum, q1, q2)
    """
    q1 = kepler_valuation_charge(p, a1, mu1)
    q2 = kepler_valuation_charge(p, a2, mu2)
    q_comp = kepler_valuation_charge(p, a1 * a2, mu1 * mu2)
    return (q_comp == q1 + q2, q_comp, q1 + q2, q1)


# ═══════════════════════════════════════════════════════════════════════
# Batch Verification
# ═══════════════════════════════════════════════════════════════════════

def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes returning all primes ≤ n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def batch_verify(
    primes: List[int],
    rationals: List[Fraction],
    verbose: bool = False
) -> Tuple[int, int]:
    """
    Batch-verify the cubic valuation law over all combinations.

    Args:
        primes: List of primes to test.
        rationals: List of nonzero rationals to test.
        verbose: Print failures if True.

    Returns:
        (total_tests, failures)

    Complexity: O(|primes| × |rationals|² × log(max_val)) time.
    """
    total = 0
    failures = 0
    for p in primes:
        for a in rationals:
            for mu in rationals:
                if a == 0 or mu == 0:
                    continue
                r = certify_cubic_law(p, a, mu)
                total += 1
                if not r.match:
                    failures += 1
                    if verbose:
                        print(f"FAILURE: p={p}, a={a}, μ={mu}")
    return total, failures


# ═══════════════════════════════════════════════════════════════════════
# Valuation Spectrum Analysis
# ═══════════════════════════════════════════════════════════════════════

def valuation_spectrum(
    a: Fraction, mu: Fraction, max_prime: int = 100
) -> List[Tuple[int, int]]:
    """
    Compute the valuation spectrum of Θ(a,μ) across all primes ≤ max_prime.

    The spectrum is the function p ↦ v_p(Θ(a,μ)). Most entries are zero;
    this returns only the nonzero values.

    Args:
        a: Semimajor axis.
        mu: Gravitational parameter.
        max_prime: Upper bound for primes.

    Returns:
        List of (prime, valuation) pairs with nonzero valuation.

    Examples:
        >>> valuation_spectrum(Fraction(12), Fraction(18))
        [(2, 5), (3, 1)]
    """
    primes = sieve_primes(max_prime)
    return [(p, kepler_valuation_charge(p, a, mu))
            for p in primes
            if kepler_valuation_charge(p, a, mu) != 0]


# ═══════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=== Orbital Valuation Algorithm Examples ===\n")

    # Example 1: Basic certification
    r = certify_cubic_law(2, Fraction(3, 4), Fraction(5, 8))
    print(f"Example 1: p=2, a=3/4, μ=5/8")
    print(f"  v_2(a)={r.val_a}, v_2(μ)={r.val_mu}")
    print(f"  v_2(Θ)={r.val_theta}, predicted={r.predicted}, match={r.match}")
    print(f"  Even pair: {r.even_pair}, Half-val: {r.half_val}")

    # Example 2: Valuation spectrum
    print(f"\nExample 2: Valuation spectrum of Θ(12, 18)")
    spec = valuation_spectrum(Fraction(12), Fraction(18))
    for p, v in spec:
        print(f"  v_{p}(Θ) = {v}")

    # Example 3: Depth profile
    print(f"\nExample 3: Depth profile at p=2")
    dp = OrbitalDepthProfile.from_params(2, Fraction(8), Fraction(4))
    print(f"  depth(a) = {dp.depth_a}")
    print(f"  depth(μ) = {dp.depth_mu}")
    print(f"  Period invariant = {dp.period_depth_invariant()}")

    # Example 4: Scaling covariance
    print(f"\nExample 4: Scaling covariance")
    ok, v0, vs, vp = certify_scaling_covariance(
        3, Fraction(1, 3), Fraction(9), Fraction(27))
    print(f"  p=3, a=1/3, μ=9, λ=27")
    print(f"  v_original={v0}, v_scaled={vs}, predicted={vp}, match={ok}")

    # Example 5: Batch verification
    print(f"\nExample 5: Batch verification")
    small_primes = sieve_primes(20)
    small_rats = [Fraction(m, n)
                  for m in range(1, 6) for n in range(1, 6)]
    total, fails = batch_verify(small_primes, small_rats)
    print(f"  Tested {total} cases, {fails} failures")
