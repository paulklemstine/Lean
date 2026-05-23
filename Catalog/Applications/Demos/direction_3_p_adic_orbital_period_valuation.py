#!/usr/bin/env python3
"""
Applications of P-adic Orbital Period Valuation

Real-world applications demonstrating the p-adic arithmetic fingerprint
of Kepler orbits:

1. Solar System orbital fingerprints (rationalized parameters)
2. Resonance detection via valuation alignment
3. Orbit classification by arithmetic type
4. Bohr model quantum orbit fingerprints
"""

from fractions import Fraction
from collections import defaultdict
import math

# ──────────────────────────────────────────────────────────────
# Core p-adic tools (self-contained)
# ──────────────────────────────────────────────────────────────

def padic_val(n: int, p: int) -> int:
    if n == 0:
        return 10**9
    n = abs(n)
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def padic_val_rat(r: Fraction, p: int) -> int:
    if r == 0:
        return 10**9
    return padic_val(r.numerator, p) - padic_val(r.denominator, p)


def kepler_val(a: Fraction, mu: Fraction, p: int):
    diff = 3 * padic_val_rat(a, p) - padic_val_rat(mu, p)
    if diff % 2 != 0:
        return None
    return diff // 2


def is_rational_period(a: Fraction, mu: Fraction) -> bool:
    ratio = a ** 3 / mu
    for n in [abs(ratio.numerator), ratio.denominator]:
        temp = n
        p = 2
        while p * p <= temp:
            if temp % p == 0:
                diff = 3 * padic_val_rat(a, p) - padic_val_rat(mu, p)
                if diff % 2 != 0:
                    return False
                while temp % p == 0:
                    temp //= p
            p += 1
        if temp > 1:
            diff = 3 * padic_val_rat(a, temp) - padic_val_rat(mu, temp)
            if diff % 2 != 0:
                return False
    return True


def period_ratio(a: Fraction, mu: Fraction):
    ratio = a ** 3 / mu
    n, d = ratio.numerator, ratio.denominator
    sn, sd = int(math.isqrt(n)), int(math.isqrt(d))
    if sn * sn == n and sd * sd == d:
        return Fraction(sn, sd)
    return None


# ──────────────────────────────────────────────────────────────
# Application 1: Solar System Orbital Fingerprints
# ──────────────────────────────────────────────────────────────

def solar_system_fingerprints():
    """Compute p-adic fingerprints for rationalized solar system orbits.
    
    We use the Titius-Bode-inspired rational approximations of semi-major 
    axes (in AU) and set μ = 4π² (normalized). Since μ is irrational,
    we work with the period relation T² = a³ (in natural units where μ=1).
    
    For the pure Kepler relation T² = a³ (μ=1), q = T and q² = a³.
    The period is rational iff a³ is a perfect square, i.e., a is itself
    a perfect square times a perfect cube (a = r² for some rational r,
    giving q = r³).
    """
    print("=" * 70)
    print("  APPLICATION 1: Solar System Orbital Fingerprints")
    print("=" * 70)
    print()
    print("  Using rationalized semi-major axes (in AU) with μ = 1:")
    print("  Kepler's law: T² = a³ (natural units)")
    print()
    
    # Rational approximations of semi-major axes in AU
    planets = [
        ("Mercury", Fraction(387, 1000)),
        ("Venus", Fraction(723, 1000)),
        ("Earth", Fraction(1, 1)),
        ("Mars", Fraction(1524, 1000)),
        ("Jupiter", Fraction(5203, 1000)),
        ("Saturn", Fraction(9537, 1000)),
    ]
    
    mu = Fraction(1)
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 127]
    
    print(f"  {'Planet':<10} {'a (AU)':>10} {'a³ sq?':>8} {'Non-zero v_p':>30}")
    print("  " + "─" * 62)
    
    for name, a in planets:
        rational = is_rational_period(a, mu)
        
        # Compute nonzero valuations
        nonzero = {}
        for p in primes:
            v = kepler_val(a, mu, p)
            if v is not None and v != 0:
                nonzero[p] = v
        
        status = "Yes" if rational else "No"
        nz_str = str(nonzero) if nonzero else "{}"
        print(f"  {name:<10} {str(a):>10} {status:>8} {nz_str:>30}")
    
    print()
    print("  Note: Most real planetary semi-major axes give irrational periods")
    print("  when expressed as exact fractions. The p-adic obstruction reveals")
    print("  which primes prevent rationality.")
    print()


# ──────────────────────────────────────────────────────────────
# Application 2: Orbital Resonance Detection
# ──────────────────────────────────────────────────────────────

def resonance_detection():
    """Detect mean-motion resonances via valuation alignment.
    
    Two orbits are in p:q mean-motion resonance when their period ratio
    T₁/T₂ = p/q. In our framework, this means the difference of their
    valuation profiles is constrained.
    
    If T₁²·μ = a₁³ and T₂²·μ = a₂³ (same μ), then
    T₁/T₂ = (a₁/a₂)^(3/2), and the resonance condition T₁/T₂ = m/n gives
    v_p(m/n) = v_p(T₁) - v_p(T₂) = (3/2)(v_p(a₁) - v_p(a₂)).
    """
    print("=" * 70)
    print("  APPLICATION 2: Orbital Resonance Detection")
    print("=" * 70)
    print()
    print("  Resonance orbits share valuation structure.")
    print("  For two orbits with same μ, the period ratio T₁/T₂ = (a₁/a₂)^(3/2)")
    print()
    
    # Example: Jupiter-Saturn near 5:2 resonance
    # Use exact rational a values that give rational periods
    resonance_pairs = [
        ("2:1", Fraction(1), Fraction(4, 1)),   # a₂/a₁ = 4^(1/3)... 
        ("3:2", Fraction(4), Fraction(9)),       # T ratio = 27/8 if a ratio = 9/4
        ("1:1", Fraction(1), Fraction(1)),       # Same orbit
    ]
    
    mu = Fraction(1)
    primes = [2, 3, 5, 7]
    
    # Generate pairs of orbits in exact resonance
    print("  Orbits with rational period ratios (μ = 1):")
    print()
    
    examples = [
        (Fraction(1), Fraction(4), "a₁=1, a₂=4: T₁=1, T₂=8, ratio=1:8"),
        (Fraction(4), Fraction(9), "a₁=4, a₂=9: T₁=8, T₂=27, ratio=8:27"),
        (Fraction(1), Fraction(1), "a₁=1, a₂=1: same orbit, ratio=1:1"),
        (Fraction(9), Fraction(16), "a₁=9, a₂=16: T₁=27, T₂=64, ratio=27:64"),
    ]
    
    for a1, a2, desc in examples:
        q1 = period_ratio(a1, mu)
        q2 = period_ratio(a2, mu)
        
        print(f"  {desc}")
        if q1 and q2:
            ratio = q1 / q2
            print(f"    T₁={q1}, T₂={q2}, ratio={ratio}")
            
            # Valuation profiles
            for p in primes:
                v1 = kepler_val(a1, mu, p)
                v2 = kepler_val(a2, mu, p)
                if v1 is not None and v2 is not None and (v1 != 0 or v2 != 0):
                    print(f"    v_{p}(T₁)={v1}, v_{p}(T₂)={v2}, "
                          f"diff={v1-v2} = v_{p}({ratio})")
        print()


# ──────────────────────────────────────────────────────────────
# Application 3: Orbit Classification
# ──────────────────────────────────────────────────────────────

def orbit_classification():
    """Classify orbits by their arithmetic type.
    
    The arithmetic type of an orbit is determined by the sign pattern
    of its p-adic valuations:
    - All v_p ≥ 0: "integer type" (period ratio is an integer)
    - Some v_p < 0: "fractional type" (period ratio has denominator)
    - All v_p = 0: "unit type" (period ratio is ±1)
    """
    print("=" * 70)
    print("  APPLICATION 3: Orbit Classification by Arithmetic Type")
    print("=" * 70)
    print()
    
    mu = Fraction(1)
    primes = [2, 3, 5, 7]
    
    types = {"integer": [], "fractional": [], "unit": []}
    
    for an in range(1, 20):
        for ad in range(1, 10):
            a = Fraction(an, ad)
            if not is_rational_period(a, mu):
                continue
            
            q = period_ratio(a, mu)
            if q is None:
                continue
            
            profile = {}
            for p in primes:
                v = kepler_val(a, mu, p)
                if v is not None:
                    profile[p] = v
            
            all_nonneg = all(v >= 0 for v in profile.values())
            all_zero = all(v == 0 for v in profile.values())
            
            if all_zero:
                types["unit"].append((a, q, profile))
            elif all_nonneg:
                types["integer"].append((a, q, profile))
            else:
                types["fractional"].append((a, q, profile))
    
    for typ, orbits in types.items():
        print(f"  {typ.upper()} TYPE: {len(orbits)} orbits")
        for a, q, profile in orbits[:5]:
            nz = {p: v for p, v in profile.items() if v != 0}
            print(f"    a={str(a):>6}, q={str(q):>8}, nonzero vals: {nz}")
        if len(orbits) > 5:
            print(f"    ... and {len(orbits) - 5} more")
        print()


# ──────────────────────────────────────────────────────────────
# Application 4: Bohr Model Quantum Fingerprints
# ──────────────────────────────────────────────────────────────

def bohr_model_fingerprints():
    """P-adic fingerprints of Bohr model energy levels.
    
    In the Bohr model, the orbital radius is a_n = n² · a₀ where a₀
    is the Bohr radius. If we set a₀ = 1 and μ = 1 (natural units),
    then a_n = n² and the "Kepler period" satisfies T² = n⁶, so T = n³.
    
    The p-adic valuation is v_p(T_n) = 3·v_p(n).
    """
    print("=" * 70)
    print("  APPLICATION 4: Bohr Model Quantum Orbit Fingerprints")
    print("=" * 70)
    print()
    print("  Bohr orbits: a_n = n², μ = 1, T_n = n³")
    print("  v_p(T_n) = 3·v_p(n)")
    print()
    
    mu = Fraction(1)
    primes = [2, 3, 5, 7]
    
    print(f"  {'n':>3} {'a_n':>6} {'T_n':>8}", end="")
    for p in primes:
        print(f"  v_{p}(T)", end="")
    print()
    print("  " + "─" * 50)
    
    for n in range(1, 16):
        a = Fraction(n * n)
        q = period_ratio(a, mu)
        
        print(f"  {n:>3} {n*n:>6} {n**3:>8}", end="")
        for p in primes:
            v = kepler_val(a, mu, p)
            print(f"  {v:>6}", end="")
        print()
    
    print()
    print("  Observation: The p-adic fingerprint of quantum level n")
    print("  is completely determined by the prime factorization of n.")
    print("  Levels with the same squarefree part have proportional fingerprints.")
    print()


# ──────────────────────────────────────────────────────────────
# Application 5: Density of Rational Kepler Periods
# ──────────────────────────────────────────────────────────────

def rational_density():
    """Compute the density of rational Kepler periods.
    
    Among all orbits (a, μ) with bounded height, what fraction have
    rational period ratios?
    """
    print("=" * 70)
    print("  APPLICATION 5: Density of Rational Kepler Periods")
    print("=" * 70)
    print()
    
    for N in [5, 10, 15, 20]:
        total = 0
        rational_count = 0
        
        for an in range(1, N + 1):
            for ad in range(1, N + 1):
                for mn in range(1, N + 1):
                    for md in range(1, N + 1):
                        a = Fraction(an, ad)
                        mu = Fraction(mn, md)
                        total += 1
                        if is_rational_period(a, mu):
                            rational_count += 1
        
        density = rational_count / total
        print(f"  Height bound N={N:>2}: {rational_count:>6}/{total:>6} = {density:.4f}")
    
    print()
    print("  The density decreases with height, suggesting that 'most'")
    print("  Kepler orbits with rational parameters have irrational periods.")
    print()


# ──────────────────────────────────────────────────────────────

def main():
    solar_system_fingerprints()
    resonance_detection()
    orbit_classification()
    bohr_model_fingerprints()
    rational_density()
    
    print("=" * 70)
    print("  All applications demonstrated successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
P-adic Orbital Period Valuation — Interactive Demonstration

Demonstrates the arithmetic fingerprint of Kepler orbits:
given rational orbital parameters (a, μ), computes the p-adic
valuation profile of the period ratio for small primes, and
visualizes the tropical curve of the Kepler variety.

Usage:
    python demo.py
"""

from fractions import Fraction
from math import log, sqrt
import sys


def padic_val(n: int, p: int) -> int:
    """Compute the p-adic valuation of an integer n.
    
    v_p(n) = largest k such that p^k divides n.
    v_p(0) = infinity (we return a large number).
    """
    if n == 0:
        return float('inf')
    if n < 0:
        n = -n
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def padic_val_rat(r: Fraction, p: int) -> int:
    """Compute the p-adic valuation of a rational number r = num/den.
    
    v_p(r) = v_p(num) - v_p(den).
    """
    if r == 0:
        return float('inf')
    return padic_val(r.numerator, p) - padic_val(r.denominator, p)


def kepler_valuation_profile(a: Fraction, mu: Fraction, primes: list[int] = None) -> dict[int, int]:
    """Compute the p-adic valuation profile of the Kepler period ratio.
    
    Given semi-major axis a and gravitational parameter μ, the period ratio
    q satisfies q² · μ = a³. The valuation at prime p is:
        v_p(q) = (3·v_p(a) - v_p(μ)) / 2
    
    This is well-defined (i.e., the numerator is even) iff q is rational.
    
    Args:
        a: Semi-major axis (positive rational)
        mu: Gravitational parameter (positive rational)
        primes: List of primes to compute valuations for (default: first 10)
    
    Returns:
        Dictionary mapping prime p to v_p(q), or None if q is irrational.
    """
    if primes is None:
        primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    
    profile = {}
    for p in primes:
        val_a = padic_val_rat(a, p)
        val_mu = padic_val_rat(mu, p)
        diff = 3 * val_a - val_mu
        if diff % 2 != 0:
            return None  # Period ratio is irrational
        profile[p] = diff // 2
    return profile


def is_period_rational(a: Fraction, mu: Fraction, primes: list[int] = None) -> bool:
    """Check if the Kepler period ratio q = √(a³/μ) is rational.
    
    By the rationality criterion (Theorem 3): q is rational iff
    3·v_p(a) - v_p(μ) is even for all primes p.
    
    We check this for primes dividing the numerator or denominator of a³/μ.
    """
    ratio = a ** 3 / mu
    # Get all prime factors of numerator and denominator
    n = abs(ratio.numerator)
    d = ratio.denominator
    
    primes_to_check = set()
    for x in [n, d]:
        temp = x
        p = 2
        while p * p <= temp:
            if temp % p == 0:
                primes_to_check.add(p)
                while temp % p == 0:
                    temp //= p
            p += 1
        if temp > 1:
            primes_to_check.add(temp)
    
    for p in primes_to_check:
        val = padic_val_rat(ratio, p)
        if val % 2 != 0:
            return False
    return True


def compute_period_ratio(a: Fraction, mu: Fraction) -> Fraction | None:
    """Compute the period ratio q = √(a³/μ) if it's rational."""
    ratio = a ** 3 / mu
    if ratio <= 0:
        return None
    
    # Check if ratio is a perfect square
    n = ratio.numerator
    d = ratio.denominator
    
    sn = int(sqrt(n) + 0.5)
    sd = int(sqrt(d) + 0.5)
    
    if sn * sn == n and sd * sd == d:
        return Fraction(sn, sd)
    return None


def tropical_kepler_curve(p: int, a: Fraction, mu: Fraction):
    """Visualize the tropical Kepler curve over Q_p.
    
    The Kepler equation T²·μ = a³ tropicalizes to:
        max(2X + v_p(μ), 3·v_p(a))
    where X = v_p(T).
    
    The vertex (corner) of this tropical curve sits at the balancing point:
        2X + v_p(μ) = 3·v_p(a)
        X = (3·v_p(a) - v_p(μ)) / 2
    
    This is exactly v_p(q), the p-adic valuation of the period ratio!
    """
    val_a = padic_val_rat(a, p)
    val_mu = padic_val_rat(mu, p)
    
    vertex_x = (3 * val_a - val_mu) / 2
    vertex_y = 3 * val_a  # = 2*vertex_x + val_mu
    
    print(f"\n  Tropical Kepler Curve over Q_{p}:")
    print(f"  ─────────────────────────────────")
    print(f"  Monomial 1: 2X + v_{p}(μ) = 2X + {val_mu}")
    print(f"  Monomial 2: 3·v_{p}(a)    = {3 * val_a}")
    print(f"  Vertex at X = {vertex_x} (balancing point)")
    print(f"  Vertex depth = {vertex_y}")
    print()
    
    # ASCII visualization
    width = 60
    x_range = range(int(vertex_x) - 5, int(vertex_x) + 6)
    
    print(f"  {'X':>6} | Tropical curve value")
    print(f"  {'':>6} | {'─' * 40}")
    
    for x in x_range:
        mon1 = 2 * x + val_mu
        mon2 = 3 * val_a
        val = max(mon1, mon2)
        bar_len = max(0, min(40, int(val + 20)))
        marker = " ← vertex" if x == vertex_x else ""
        print(f"  {x:>6} | {'█' * bar_len} {val}{marker}")
    
    return vertex_x


def print_header():
    print("=" * 70)
    print("  P-ADIC ORBITAL PERIOD VALUATION")
    print("  Arithmetic Fingerprints of Kepler Orbits")
    print("=" * 70)
    print()


def demo_basic_valuation():
    """Demo 1: Basic p-adic valuation of period ratios."""
    print("─" * 70)
    print("  DEMO 1: Computing Kepler Period Valuation Profiles")
    print("─" * 70)
    print()
    
    examples = [
        (Fraction(1), Fraction(1), "Unit orbit: a=1, μ=1"),
        (Fraction(4), Fraction(1), "a=4, μ=1 → q²=64, q=8"),
        (Fraction(9), Fraction(1), "a=9, μ=1 → q²=729, q=27"),
        (Fraction(4), Fraction(8), "a=4, μ=8 → q²=8, q=2√2 (irrational!)"),
        (Fraction(2, 3), Fraction(8, 27), "a=2/3, μ=8/27 → q²=1, q=1"),
        (Fraction(100), Fraction(1000), "a=100, μ=1000 → q²=1000, q=10√10"),
        (Fraction(25), Fraction(125), "a=25, μ=125 → q²=125, q=5√5"),
        (Fraction(4, 9), Fraction(8, 729), "a=4/9, μ=8/729 → q²=8, irrational"),
    ]
    
    primes = [2, 3, 5, 7, 11]
    
    for a, mu, desc in examples:
        print(f"  {desc}")
        print(f"    a = {a}, μ = {mu}")
        
        rational = is_period_rational(a, mu)
        print(f"    Period ratio is {'RATIONAL' if rational else 'IRRATIONAL'}")
        
        if rational:
            q = compute_period_ratio(a, mu)
            if q is not None:
                print(f"    q = {q}")
            
            profile = kepler_valuation_profile(a, mu, primes)
            if profile is not None:
                nonzero = {p: v for p, v in profile.items() if v != 0}
                print(f"    Valuation profile: {profile}")
                if nonzero:
                    print(f"    Non-zero valuations: {nonzero}")
                else:
                    print(f"    All valuations are zero (q is a unit in Z)")
        else:
            # Show which primes obstruct rationality
            for p in primes:
                val_a = padic_val_rat(a, p)
                val_mu = padic_val_rat(mu, p)
                diff = 3 * val_a - val_mu
                if diff % 2 != 0:
                    print(f"    Obstruction at p={p}: 3·v_{p}(a) - v_{p}(μ) = {diff} (odd)")
        print()


def demo_rationality_criterion():
    """Demo 2: The rationality criterion in action."""
    print("─" * 70)
    print("  DEMO 2: Rationality Criterion (Theorem 3)")
    print("─" * 70)
    print()
    print("  A Kepler orbit (a, μ) has rational period ratio iff")
    print("  3·v_p(a) - v_p(μ) is even for ALL primes p.")
    print()
    
    # Systematic scan
    count_rational = 0
    count_irrational = 0
    
    print("  Scanning orbits with a, μ ∈ {n/d : 1 ≤ n,d ≤ 6}...")
    print()
    
    rational_orbits = []
    for an in range(1, 7):
        for ad in range(1, 7):
            for mn in range(1, 7):
                for md in range(1, 7):
                    a = Fraction(an, ad)
                    mu = Fraction(mn, md)
                    if is_period_rational(a, mu):
                        count_rational += 1
                        q = compute_period_ratio(a, mu)
                        if q is not None:
                            rational_orbits.append((a, mu, q))
                    else:
                        count_irrational += 1
    
    print(f"  Total orbits scanned: {count_rational + count_irrational}")
    print(f"  Rational period: {count_rational}")
    print(f"  Irrational period: {count_irrational}")
    print(f"  Rationality fraction: {count_rational / (count_rational + count_irrational):.4f}")
    print()
    
    # Show some rational orbits
    print("  First 10 rational orbits (a, μ, q):")
    for a, mu, q in rational_orbits[:10]:
        print(f"    a = {str(a):>5}, μ = {str(mu):>5}, q = {q}")
    print()


def demo_tropical_visualization():
    """Demo 3: Tropical curve visualization."""
    print("─" * 70)
    print("  DEMO 3: Tropical Kepler Curves")
    print("─" * 70)
    print()
    print("  The tropicalization of q²·μ = a³ over Q_p gives a")
    print("  piecewise-linear function whose vertex = v_p(q).")
    print()
    
    # Example: a = 12, μ = 3
    a = Fraction(12)
    mu = Fraction(3)
    q = compute_period_ratio(a, mu)
    print(f"  Orbit: a = {a}, μ = {mu}")
    if q:
        print(f"  Period ratio: q = {q}")
    print()
    
    for p in [2, 3]:
        vertex = tropical_kepler_curve(p, a, mu)
        if q:
            actual_val = padic_val_rat(q, p)
            print(f"  Verification: v_{p}(q={q}) = {actual_val}")
            print(f"  Tropical vertex X = {vertex}")
            assert vertex == actual_val, "Mismatch!"
            print(f"  ✓ Vertex-valuation correspondence confirmed!")
            print()


def demo_arithmetic_equivalence():
    """Demo 4: Arithmetic equivalence classes."""
    print("─" * 70)
    print("  DEMO 4: Arithmetic Equivalence Classes")
    print("─" * 70)
    print()
    print("  Two orbits are arithmetically equivalent if they have the")
    print("  same p-adic valuation profile at every prime.")
    print()
    
    # Collect orbits and group by profile
    from collections import defaultdict
    
    primes = [2, 3, 5, 7]
    classes = defaultdict(list)
    
    for an in range(1, 13):
        for ad in range(1, 7):
            for mn in range(1, 13):
                for md in range(1, 7):
                    a = Fraction(an, ad)
                    mu = Fraction(mn, md)
                    if is_period_rational(a, mu):
                        profile = kepler_valuation_profile(a, mu, primes)
                        if profile is not None:
                            key = tuple(profile[p] for p in primes)
                            classes[key].append((a, mu))
    
    # Show largest equivalence classes
    sorted_classes = sorted(classes.items(), key=lambda x: -len(x[1]))
    
    print(f"  Found {len(classes)} distinct arithmetic equivalence classes")
    print()
    print("  Top 5 largest classes:")
    for i, (key, orbits) in enumerate(sorted_classes[:5]):
        profile_str = ", ".join(f"v_{p}={v}" for p, v in zip(primes, key))
        print(f"    Class {i+1} [{profile_str}]: {len(orbits)} orbits")
        for a, mu in orbits[:3]:
            print(f"      a={a}, μ={mu}")
        if len(orbits) > 3:
            print(f"      ... and {len(orbits)-3} more")
        print()


def main():
    print_header()
    demo_basic_valuation()
    demo_rationality_criterion()
    demo_tropical_visualization()
    demo_arithmetic_equivalence()
    
    print("=" * 70)
    print("  All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
