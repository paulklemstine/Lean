#!/usr/bin/env python3
"""
Applications of P-adic Orbital Period Valuation

Real-world and theoretical applications demonstrating how the
arithmetic tropical framework extends beyond toy examples.
"""

from fractions import Fraction
from typing import List, Dict, Tuple
from algorithms import (
    padic_val_rat, orbital_period_squared, kepler_valuation_charge,
    OrbitalDepthProfile, sieve_primes, valuation_spectrum,
    certify_cubic_law
)


# ═══════════════════════════════════════════════════════════════════════
# Application 1: Solar System Orbital Fingerprinting
# ═══════════════════════════════════════════════════════════════════════

def solar_system_fingerprint():
    """
    Compute p-adic orbital fingerprints for solar system bodies.

    We use rationalized orbital data (semimajor axes in AU, with μ
    normalized). The valuation spectrum provides a unique arithmetic
    signature for each orbit.
    """
    print("=" * 60)
    print("APPLICATION 1: Solar System Orbital Fingerprints")
    print("=" * 60)

    # Approximate semimajor axes as rationals (in AU)
    # μ_sun ≈ 1 in solar units (4π² AU³/yr²)
    bodies = {
        "Mercury": Fraction(387, 1000),
        "Venus": Fraction(723, 1000),
        "Earth": Fraction(1, 1),
        "Mars": Fraction(1524, 1000),
        "Jupiter": Fraction(5203, 1000),
        "Saturn": Fraction(9537, 1000),
    }
    mu_sun = Fraction(1, 1)

    primes = sieve_primes(50)

    for name, a in bodies.items():
        theta = orbital_period_squared(a, mu_sun)
        spectrum = [(p, kepler_valuation_charge(p, a, mu_sun))
                    for p in primes
                    if kepler_valuation_charge(p, a, mu_sun) != 0]
        print(f"\n  {name}: a = {a}")
        print(f"    Θ(a,μ) = {float(theta):.6f}")
        print(f"    Valuation spectrum: {spectrum[:8]}")


# ═══════════════════════════════════════════════════════════════════════
# Application 2: Orbital Resonance Detection via Charge Matching
# ═══════════════════════════════════════════════════════════════════════

def resonance_detection():
    """
    Detect mean-motion resonances by comparing valuation charges.

    Two orbits are in p:q resonance when their period ratio is p/q.
    The valuation charge difference encodes this arithmetically.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Resonance Detection via Charge Comparison")
    print("=" * 60)

    # Consider orbits with semimajor axes a₁ and a₂
    # If T₁/T₂ = p/q, then a₁³/a₂³ = p²/q² (from Kepler's law with same μ)
    pairs = [
        ("2:1 resonance", Fraction(4, 1), Fraction(1, 1)),
        ("3:2 resonance", Fraction(9, 4), Fraction(1, 1)),
        ("5:3 resonance", Fraction(25, 9), Fraction(1, 1)),
    ]
    mu = Fraction(1)

    primes = sieve_primes(30)

    for label, a1, a2 in pairs:
        print(f"\n  {label}: a₁={a1}, a₂={a2}")
        for p in primes[:8]:
            q1 = kepler_valuation_charge(p, a1, mu)
            q2 = kepler_valuation_charge(p, a2, mu)
            diff = q1 - q2
            if diff != 0:
                print(f"    p={p}: Q(a₁)={q1}, Q(a₂)={q2}, ΔQ={diff}")


# ═══════════════════════════════════════════════════════════════════════
# Application 3: Orbit Classification by Depth Profile
# ═══════════════════════════════════════════════════════════════════════

def orbit_classification():
    """
    Classify orbits by their tropical depth profiles.

    Two orbits with the same depth profile at all primes have the same
    period valuation at all primes — they are "arithmetically equivalent".
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Orbit Classification by Depth Profile")
    print("=" * 60)

    orbits = [
        ("Orbit A", Fraction(2, 3), Fraction(4, 9)),
        ("Orbit B", Fraction(8, 12), Fraction(16, 36)),
        ("Orbit C", Fraction(2, 3), Fraction(8, 27)),
        ("Orbit D", Fraction(4, 6), Fraction(4, 9)),
    ]

    primes = [2, 3, 5, 7]

    print("\n  Depth profiles at small primes:")
    for name, a, mu in orbits:
        profiles = {}
        for p in primes:
            dp = OrbitalDepthProfile.from_params(p, a, mu)
            profiles[p] = (dp.depth_a, dp.depth_mu)
        theta_val = {p: kepler_valuation_charge(p, a, mu) for p in primes}
        print(f"\n  {name}: a={a}, μ={mu}")
        print(f"    Profiles: {profiles}")
        print(f"    Charges:  {theta_val}")

    # Check arithmetic equivalence
    print("\n  Equivalence classes:")
    for i, (n1, a1, mu1) in enumerate(orbits):
        for j, (n2, a2, mu2) in enumerate(orbits):
            if j <= i:
                continue
            equiv = all(
                kepler_valuation_charge(p, a1, mu1) ==
                kepler_valuation_charge(p, a2, mu2)
                for p in sieve_primes(100)
            )
            if equiv:
                print(f"    {n1} ≡ {n2} (arithmetically equivalent)")


# ═══════════════════════════════════════════════════════════════════════
# Application 4: Exceptional Prime Search
# ═══════════════════════════════════════════════════════════════════════

def exceptional_prime_search():
    """
    Search for primes where the valuation charge vanishes for many orbits.

    These "exceptional primes" might reveal hidden structure in
    orbital arithmetic.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Exceptional Prime Search")
    print("=" * 60)

    primes = sieve_primes(200)
    test_orbits = [
        (Fraction(m, n), Fraction(r, s))
        for m in range(1, 8) for n in range(1, 8)
        for r in range(1, 8) for s in range(1, 8)
        if m != 0 and n != 0 and r != 0 and s != 0
    ]

    print(f"\n  Testing {len(primes)} primes against "
          f"{len(test_orbits)} orbital pairs")

    prime_scores: Dict[int, int] = {}
    for p in primes:
        zero_count = sum(
            1 for a, mu in test_orbits
            if kepler_valuation_charge(p, a, mu) == 0
        )
        prime_scores[p] = zero_count

    # Find primes with most zero charges
    sorted_primes = sorted(prime_scores.items(), key=lambda x: -x[1])

    print("\n  Top 10 primes with most vanishing charges:")
    print(f"  {'Prime':>6} {'Zero charges':>14} {'Fraction':>10}")
    print("  " + "-" * 35)
    for p, count in sorted_primes[:10]:
        frac = count / len(test_orbits)
        print(f"  {p:>6} {count:>14} {frac:>10.4f}")

    # Large primes are "generic" — almost all charges vanish
    print("\n  Primes > 7 have trivially vanishing charges for small")
    print("  numerators/denominators (no factors of p in the data).")
    print("  The interesting structure is at small primes.")


# ═══════════════════════════════════════════════════════════════════════
# Application 5: Composite System Analysis
# ═══════════════════════════════════════════════════════════════════════

def composite_system():
    """
    Demonstrate charge additivity for composite orbital systems.

    In a hierarchical triple system, the total charge decomposes
    as the sum of individual charges.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 5: Composite Orbital System Charge Decomposition")
    print("=" * 60)

    # Inner binary: a₁ = 2/3, μ₁ = 4/9
    # Outer orbit: a₂ = 5/2, μ₂ = 25/8
    a1, mu1 = Fraction(2, 3), Fraction(4, 9)
    a2, mu2 = Fraction(5, 2), Fraction(25, 8)

    primes = [2, 3, 5, 7, 11, 13]

    print(f"\n  Inner: a₁={a1}, μ₁={mu1}")
    print(f"  Outer: a₂={a2}, μ₂={mu2}")
    print(f"  Composite: a₁a₂={a1*a2}, μ₁μ₂={mu1*mu2}")

    print(f"\n  {'p':>3} {'Q₁':>5} {'Q₂':>5} {'Q₁+Q₂':>7} "
          f"{'Q(comp)':>8} {'match':>6}")
    print("  " + "-" * 40)
    for p in primes:
        q1 = kepler_valuation_charge(p, a1, mu1)
        q2 = kepler_valuation_charge(p, a2, mu2)
        q_comp = kepler_valuation_charge(p, a1 * a2, mu1 * mu2)
        ok = "✓" if q_comp == q1 + q2 else "✗"
        print(f"  {p:>3} {q1:>5} {q2:>5} {q1+q2:>7} {q_comp:>8} {ok:>6}")


# ═══════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    solar_system_fingerprint()
    resonance_detection()
    orbit_classification()
    exceptional_prime_search()
    composite_system()

    print("\n" + "=" * 60)
    print("ALL APPLICATIONS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
P-adic Orbital Period Valuation — Demonstration Script

Demonstrates the formally verified theorems:
1. Cubic valuation law: v_p(a³/μ) = 3·v_p(a) - v_p(μ)
2. Scaling covariance under rational dilation
3. Additive charge law for composite orbits
4. Half-valuation integrality under even parity
5. Tropical depth recovery

Enumerates primes p < 1000 and rational pairs (a, μ) with bounded
numerators/denominators, verifying all predictions.
"""

from fractions import Fraction
from math import gcd
from typing import List, Tuple
import itertools


def padic_val(p: int, n: int) -> int:
    """Compute the p-adic valuation of integer n.
    Returns 0 for n=0 by convention."""
    if n == 0:
        return 0
    v = 0
    n = abs(n)
    while n % p == 0:
        v += 1
        n //= p
    return v


def padic_val_rat(p: int, q: Fraction) -> int:
    """Compute the p-adic valuation of rational q = num/den."""
    if q == 0:
        return 0
    return padic_val(p, q.numerator) - padic_val(p, q.denominator)


def orbital_period_squared(a: Fraction, mu: Fraction) -> Fraction:
    """Θ(a,μ) = a³/μ — the rationalized Kepler period invariant."""
    return a ** 3 / mu


def kepler_valuation_charge(p: int, a: Fraction, mu: Fraction) -> int:
    """Q_p(a,μ) = 3·v_p(a) - v_p(μ) — the additive orbital charge."""
    return 3 * padic_val_rat(p, a) - padic_val_rat(p, mu)


def orbital_half_valuation(p: int, a: Fraction, mu: Fraction) -> int:
    """The half-valuation k such that 2k = 3·v_p(a) - v_p(μ),
    defined when the even parity condition holds."""
    return (3 * padic_val_rat(p, a) - padic_val_rat(p, mu)) // 2


def is_even_valuation_pair(p: int, a: Fraction, mu: Fraction) -> bool:
    """Check if both v_p(a) and v_p(μ) are even."""
    return padic_val_rat(p, a) % 2 == 0 and padic_val_rat(p, mu) % 2 == 0


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes up to n."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def generate_rationals(max_val: int) -> List[Fraction]:
    """Generate nonzero rationals m/n with 1 ≤ m,n ≤ max_val."""
    rats = set()
    for m in range(1, max_val + 1):
        for n in range(1, max_val + 1):
            rats.add(Fraction(m, n))
            rats.add(Fraction(-m, n))
    return sorted(rats, key=lambda x: (abs(x.denominator), abs(x.numerator)))


def main():
    primes = sieve_primes(1000)
    print("=" * 72)
    print("P-ADIC ORBITAL PERIOD VALUATION — DEMONSTRATION")
    print("=" * 72)

    # ── Theorem 1: Cubic Valuation Law ──
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  THEOREM 1: Cubic Valuation Law                    │")
    print("│  v_p(a³/μ) = 3·v_p(a) - v_p(μ)                    │")
    print("└─────────────────────────────────────────────────────┘")

    # Exhaustive test over small rationals and primes
    test_primes = primes[:50]  # first 50 primes
    max_coeff = 20
    rationals = generate_rationals(max_coeff)
    # Filter to positive for cleaner output
    pos_rationals = [r for r in rationals if r > 0][:50]

    total_tests = 0
    failures = 0
    for p in test_primes:
        for a in pos_rationals[:20]:
            for mu in pos_rationals[:20]:
                theta = orbital_period_squared(a, mu)
                v_theta = padic_val_rat(p, theta)
                predicted = 3 * padic_val_rat(p, a) - padic_val_rat(p, mu)
                total_tests += 1
                if v_theta != predicted:
                    failures += 1
                    print(f"  FAILURE: p={p}, a={a}, μ={mu}: "
                          f"v_p(Θ)={v_theta} ≠ {predicted}")

    print(f"\n  Tested {total_tests} cases over {len(test_primes)} primes")
    print(f"  Failures: {failures}")
    if failures == 0:
        print("  ✓ ALL TESTS PASSED")

    # Show interesting examples
    print("\n  Sample computations:")
    examples = [
        (2, Fraction(3, 4), Fraction(5, 8)),
        (3, Fraction(9, 2), Fraction(27, 4)),
        (5, Fraction(25, 7), Fraction(125, 49)),
        (7, Fraction(49, 3), Fraction(7, 9)),
        (2, Fraction(1, 16), Fraction(1, 32)),
    ]
    print(f"  {'p':>3} {'a':>8} {'μ':>8} {'v_p(a)':>7} {'v_p(μ)':>7} "
          f"{'v_p(Θ)':>7} {'3v-v':>5} {'match':>5}")
    print("  " + "-" * 60)
    for p, a, mu in examples:
        va = padic_val_rat(p, a)
        vmu = padic_val_rat(p, mu)
        theta = orbital_period_squared(a, mu)
        vtheta = padic_val_rat(p, theta)
        predicted = 3 * va - vmu
        ok = "✓" if vtheta == predicted else "✗"
        print(f"  {p:>3} {str(a):>8} {str(mu):>8} {va:>7} {vmu:>7} "
              f"{vtheta:>7} {predicted:>5} {ok:>5}")

    # ── Theorem 4: Scaling Covariance ──
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  THEOREM 4: Scaling Covariance                     │")
    print("│  v_p(Θ(λa,μ)) = v_p(Θ(a,μ)) + 3·v_p(λ)           │")
    print("└─────────────────────────────────────────────────────┘")

    scale_tests = 0
    scale_failures = 0
    for p in test_primes[:10]:
        for a in pos_rationals[:10]:
            for mu in pos_rationals[:10]:
                for lam in pos_rationals[:10]:
                    v_orig = padic_val_rat(p, orbital_period_squared(a, mu))
                    v_scaled = padic_val_rat(p, orbital_period_squared(lam * a, mu))
                    predicted = v_orig + 3 * padic_val_rat(p, lam)
                    scale_tests += 1
                    if v_scaled != predicted:
                        scale_failures += 1

    print(f"\n  Tested {scale_tests} scaling cases")
    print(f"  Failures: {scale_failures}")
    if scale_failures == 0:
        print("  ✓ ALL SCALING TESTS PASSED")

    # ── Theorem 5: Additive Charge Law ──
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  THEOREM 5: Additive Charge Law                    │")
    print("│  Q_p(a₁a₂,μ₁μ₂) = Q_p(a₁,μ₁) + Q_p(a₂,μ₂)      │")
    print("└─────────────────────────────────────────────────────┘")

    charge_tests = 0
    charge_failures = 0
    for p in test_primes[:10]:
        for a1 in pos_rationals[:8]:
            for a2 in pos_rationals[:8]:
                for mu1 in pos_rationals[:8]:
                    for mu2 in pos_rationals[:8]:
                        q_comp = kepler_valuation_charge(p, a1 * a2, mu1 * mu2)
                        q_sum = (kepler_valuation_charge(p, a1, mu1) +
                                 kepler_valuation_charge(p, a2, mu2))
                        charge_tests += 1
                        if q_comp != q_sum:
                            charge_failures += 1

    print(f"\n  Tested {charge_tests} charge additivity cases")
    print(f"  Failures: {charge_failures}")
    if charge_failures == 0:
        print("  ✓ ALL CHARGE TESTS PASSED")

    # ── Theorem 2: Half-Valuation Integrality ──
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  THEOREM 2: Half-Valuation Integrality              │")
    print("│  Even parity ⟹ 2k = 3·v_p(a) - v_p(μ)             │")
    print("└─────────────────────────────────────────────────────┘")

    even_cases = 0
    half_failures = 0
    for p in test_primes[:20]:
        for a in pos_rationals[:30]:
            for mu in pos_rationals[:30]:
                if is_even_valuation_pair(p, a, mu):
                    even_cases += 1
                    k = orbital_half_valuation(p, a, mu)
                    charge = 3 * padic_val_rat(p, a) - padic_val_rat(p, mu)
                    if 2 * k != charge:
                        half_failures += 1
                        print(f"  FAILURE: p={p}, a={a}, μ={mu}")

    print(f"\n  Found {even_cases} even-parity cases")
    print(f"  Half-valuation failures: {half_failures}")
    if half_failures == 0:
        print("  ✓ ALL HALF-VALUATION TESTS PASSED")

    # ── Extremal Cases ──
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  EXTREMAL & INTERESTING CASES                      │")
    print("└─────────────────────────────────────────────────────┘")

    print("\n  Cases with large |Q_p(a,μ)|:")
    extremals = []
    for p in primes[:30]:
        for a in pos_rationals[:30]:
            for mu in pos_rationals[:30]:
                q = kepler_valuation_charge(p, a, mu)
                if abs(q) >= 6:
                    extremals.append((abs(q), p, a, mu, q))

    extremals.sort(reverse=True)
    print(f"  {'p':>3} {'a':>8} {'μ':>8} {'Q_p':>5} {'even?':>6}")
    print("  " + "-" * 40)
    for _, p, a, mu, q in extremals[:15]:
        even = is_even_valuation_pair(p, a, mu)
        print(f"  {p:>3} {str(a):>8} {str(mu):>8} {q:>5} {'yes' if even else 'no':>6}")

    # ── Conjecture E: Exceptional Prime Rigidity ──
    print("\n┌─────────────────────────────────────────────────────┐")
    print("│  CONJECTURE E: Exceptional Prime Rigidity           │")
    print("│  Q_p=0 for many p ⟹ a³/μ = ±1 ?                   │")
    print("└─────────────────────────────────────────────────────┘")

    print("\n  Searching for a,μ with many vanishing charges but a³/μ ≠ ±1...")
    candidates = []
    for a in pos_rationals[:25]:
        for mu in pos_rationals[:25]:
            theta = orbital_period_squared(a, mu)
            if theta == 1 or theta == -1:
                continue
            zero_count = sum(1 for p in primes if kepler_valuation_charge(p, a, mu) == 0)
            if zero_count > len(primes) * 0.9:
                candidates.append((zero_count, a, mu, theta))

    if candidates:
        candidates.sort(reverse=True)
        print("  Found candidates (potential counterexamples):")
        for zc, a, mu, theta in candidates[:5]:
            print(f"    a={a}, μ={mu}, Θ={theta}, "
                  f"zero-charge primes: {zc}/{len(primes)}")
    else:
        print("  No counterexamples found — conjecture holds in tested range.")
        print("  (All cases with Q_p=0 for >90% of primes have a³/μ = ±1)")

    print("\n" + "=" * 72)
    print("DEMONSTRATION COMPLETE")
    print("=" * 72)


if __name__ == "__main__":
    main()
