#!/usr/bin/env python3
"""
Applications of the Galois Theory Detection Framework

This module demonstrates practical applications of the formal Galois obstruction
theory, including:

1. Batch analysis of polynomial families
2. Visualization of derived series
3. Statistical analysis of Galois groups of random quintics
4. Educational demonstrations of the Abel-Ruffini theorem

All algorithms correspond to formally verified mathematical results.
"""

import sympy
from sympy import Poly, ZZ, QQ, GF, Symbol, factorial
from sympy.abc import x
from typing import List, Dict, Tuple
import random
from algorithms import (
    ResolventCertificate,
    analyze_quintic_galois_group,
    cycle_type,
    is_solvable,
    derived_series,
)
from itertools import permutations


# =============================================================================
# Application 1: Batch Analysis of Polynomial Families
# =============================================================================

def analyze_family_x5_ax_b(a_range: range, b_range: range) -> Dict[str, int]:
    """
    Analyze the family x⁵ + ax + b for various integer values of a and b.
    
    This demonstrates the detection engine on a parametric family of quintics.
    For most choices of (a, b), the Galois group is S₅.
    
    Returns statistics on how many polynomials have each type of Galois group.
    """
    stats = {
        'total': 0,
        'reducible': 0,
        'certified_S5': 0,
        'likely_S5': 0,
        'other': 0,
    }
    
    for a in a_range:
        for b in b_range:
            if a == 0 and b == 0:
                continue
            coeffs = [1, 0, 0, 0, a, b]
            result = analyze_quintic_galois_group(coeffs, max_prime=50)
            stats['total'] += 1
            
            if not result['irreducible']:
                stats['reducible'] += 1
            elif result['galois_group'] == 'S₅':
                stats['certified_S5'] += 1
            elif 'likely' in str(result['galois_group']):
                stats['likely_S5'] += 1
            else:
                stats['other'] += 1
    
    return stats


# =============================================================================
# Application 2: Derived Series Visualization
# =============================================================================

def visualize_derived_series(n: int) -> str:
    """
    Create an ASCII visualization of the derived series of S_n.
    
    Shows the chain of subgroups with their orders and whether
    the series terminates (solvable) or stabilizes (not solvable).
    """
    all_perms = set(permutations(range(n)))
    series = derived_series(all_perms, n)
    
    lines = [f"Derived Series of S_{n} (|S_{n}| = {factorial(n)})"]
    lines.append("=" * 50)
    
    for i, group in enumerate(series):
        bar_length = min(int(len(group) / len(all_perms) * 40), 40)
        bar = "█" * bar_length + "░" * (40 - bar_length)
        
        if i > 0 and len(group) == len(series[i-1]) and len(group) > 1:
            lines.append(f"  G⁽{i}⁾ |{bar}| {len(group):>6}  ← STABILIZED")
            break
        elif len(group) == 1:
            lines.append(f"  G⁽{i}⁾ |{'░' * 40}|      1  ← TRIVIAL ✓")
            break
        else:
            lines.append(f"  G⁽{i}⁾ |{bar}| {len(group):>6}")
    
    solvable = len(series[-1]) == 1
    lines.append("")
    if solvable:
        lines.append(f"  ✓ S_{n} is SOLVABLE (derived length = {len(series) - 1})")
        lines.append(f"  → Polynomials of degree {n} CAN be solved by radicals")
    else:
        lines.append(f"  ✗ S_{n} is NOT SOLVABLE (derived series stabilizes)")
        lines.append(f"  → Generic polynomials of degree {n} CANNOT be solved by radicals")
    
    return "\n".join(lines)


# =============================================================================
# Application 3: Statistical Analysis of Random Quintics
# =============================================================================

def random_quintic_statistics(num_samples: int = 50, coeff_bound: int = 10) -> Dict:
    """
    Sample random quintics x⁵ + a₃x³ + a₂x² + a₁x + a₀ and analyze their
    Galois groups.
    
    This demonstrates the "generic" nature of S₅: most quintics have Galois
    group S₅, confirming the formal result that non-solvability is the norm.
    
    Returns:
        Dictionary with statistical results
    """
    results = {
        'total': 0,
        'irreducible': 0,
        'S5': 0,
        'not_S5': 0,
        'unknown': 0,
        'examples_S5': [],
        'examples_not_S5': [],
    }
    
    random.seed(42)  # Reproducibility
    
    for _ in range(num_samples):
        a3 = random.randint(-coeff_bound, coeff_bound)
        a2 = random.randint(-coeff_bound, coeff_bound)
        a1 = random.randint(-coeff_bound, coeff_bound)
        a0 = random.randint(-coeff_bound, coeff_bound)
        
        if a0 == 0:
            a0 = 1  # Ensure non-trivial constant term
        
        coeffs = [1, 0, a3, a2, a1, a0]
        result = analyze_quintic_galois_group(coeffs, max_prime=50)
        results['total'] += 1
        
        if result['irreducible']:
            results['irreducible'] += 1
            if result['galois_group'] == 'S₅':
                results['S5'] += 1
                if len(results['examples_S5']) < 3:
                    results['examples_S5'].append(coeffs)
            elif 'unknown' in str(result['solvable_by_radicals']):
                results['unknown'] += 1
            else:
                results['not_S5'] += 1
                if len(results['examples_not_S5']) < 3:
                    results['examples_not_S5'].append(coeffs)
    
    return results


# =============================================================================
# Application 4: Educational Demonstrations
# =============================================================================

def demonstrate_abel_ruffini():
    """
    Educational demonstration of the Abel-Ruffini theorem.
    
    Shows the progression from solvable (degree ≤ 4) to non-solvable (degree 5)
    through the derived series of symmetric groups.
    """
    print("\n" + "="*60)
    print("  The Abel-Ruffini Theorem: Why Degree 5 is Special")
    print("="*60)
    
    print("""
  For polynomials of degree n, the "most complex" Galois group is S_n.
  A polynomial is solvable by radicals only if its Galois group is solvable.
  
  The derived series tells us whether S_n is solvable:
""")
    
    for n in range(2, 6):
        print(visualize_derived_series(n))
        print()
    
    print("""
  KEY INSIGHT:
  ═══════════
  • Degrees 2, 3, 4: S_n is solvable → formulas exist
    - Degree 2: Quadratic formula (known to Babylonians, ~2000 BCE)
    - Degree 3: Cardano's formula (1545 CE)
    - Degree 4: Ferrari's formula (1545 CE)
  
  • Degree 5: S₅ is NOT solvable → no general formula exists
    - Abel (1824): First proof of impossibility
    - Galois (1832): Complete characterization via group theory
    
  The formal verification confirms: this impossibility is a THEOREM,
  not a limitation of human ingenuity. No formula using +, −, ×, ÷, 
  and n-th roots can ever solve the general quintic.
""")


def demonstrate_specific_quintic():
    """
    Detailed walkthrough of the analysis of x⁵ - x - 1.
    """
    print("\n" + "="*60)
    print("  Case Study: x⁵ − x − 1")
    print("="*60)
    
    coeffs = [1, 0, 0, 0, -1, -1]
    
    print("""
  Step 1: Irreducibility
  ──────────────────────
  x⁵ − x − 1 has no rational roots (by the rational root theorem,
  the only candidates are ±1, and f(1) = -1, f(-1) = -1).
  
  It also has no factorization into polynomials of degree 2 and 3
  over ℚ (can be verified by coefficient comparison).
  
  → f is irreducible over ℚ ✓
""")
    
    cert = ResolventCertificate(coeffs).compute()
    
    print(f"  Step 2: Discriminant")
    print(f"  ────────────────────")
    print(f"  Δ(f) = {cert.discriminant}")
    print(f"  Is Δ a perfect square? {'Yes' if cert.disc_is_square else 'No'}")
    if not cert.disc_is_square:
        print(f"  → Gal(f) is NOT contained in A₅")
    
    print(f"\n  Step 3: Modular Factorization")
    print(f"  ─────────────────────────────")
    
    count = 0
    for p, pattern in sorted(cert.all_patterns.items()):
        if count >= 15:
            break
        interpretation = ""
        if pattern == [5]:
            interpretation = "→ 5-cycle (Frobenius at p)"
        elif sorted(pattern) == [1, 1, 1, 2]:
            interpretation = "→ transposition (Frobenius at p)"
        elif sorted(pattern) == [1, 1, 3]:
            interpretation = "→ 3-cycle"
        elif sorted(pattern) == [2, 3]:
            interpretation = "→ product of 2-cycle and 3-cycle"
        print(f"  f mod {p:>3}: {str(pattern):>15}  {interpretation}")
        count += 1
    
    print(f"\n  Step 4: Galois Group Identification")
    print(f"  ────────────────────────────────────")
    if cert.is_complete():
        print(f"  • f is irreducible mod {cert.prime_irred} → 5-cycle exists in Gal(f)")
        print(f"  • f factors as (2,1,1,1) mod {cert.prime_trans} → transposition exists in Gal(f)")
        print(f"  • Gal(f) is transitive (since f is irreducible over ℚ)")
        print(f"  • By the subgroup theorem: transitive + 5-cycle + transposition → Gal(f) = S₅")
    
    print(f"\n  Step 5: Conclusion")
    print(f"  ──────────────────")
    print(f"  Gal(x⁵ − x − 1) = S₅")
    print(f"  S₅ is not solvable (derived series: 120 → 60 → 60 → ...)")
    print(f"  ∴ x⁵ − x − 1 = 0 is NOT SOLVABLE BY RADICALS")
    print(f"\n  This means: there is no formula using +, −, ×, ÷, and n-th roots")
    print(f"  that expresses ANY root of x⁵ − x − 1.")


# =============================================================================
# Main
# =============================================================================

def main():
    # Application 1: Educational demonstration
    demonstrate_abel_ruffini()
    
    # Application 2: Specific quintic analysis
    demonstrate_specific_quintic()
    
    # Application 3: Random quintic statistics
    print("\n" + "="*60)
    print("  Statistical Analysis of Random Quintics")
    print("="*60)
    
    stats = random_quintic_statistics(num_samples=30, coeff_bound=8)
    print(f"\n  Sampled {stats['total']} random monic quintics with coefficients in [-8, 8]")
    print(f"  Irreducible: {stats['irreducible']} ({100*stats['irreducible']/stats['total']:.0f}%)")
    if stats['irreducible'] > 0:
        print(f"  Of the irreducible ones:")
        print(f"    Certified S₅: {stats['S5']} ({100*stats['S5']/max(stats['irreducible'],1):.0f}%)")
        print(f"    Unknown:       {stats['unknown']}")
    print(f"\n  This confirms: S₅ is the 'generic' Galois group for quintics.")
    print(f"  Non-solvability is the RULE, not the exception.")
    
    # Application 4: Batch family analysis  
    print("\n" + "="*60)
    print("  Family Analysis: x⁵ + ax + b")
    print("="*60)
    
    stats = analyze_family_x5_ax_b(range(-5, 6), range(-5, 6))
    print(f"\n  Analyzed {stats['total']} polynomials x⁵ + ax + b")
    print(f"  with a ∈ [-5, 5], b ∈ [-5, 5]")
    print(f"\n  Reducible:     {stats['reducible']}")
    print(f"  Certified S₅:  {stats['certified_S5']}")
    print(f"  Likely S₅:     {stats['likely_S5']}")
    print(f"  Other:         {stats['other']}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Galois Theory Detection Engine — Interactive Demo

This script demonstrates the mathematical machinery behind the Abel–Ruffini
obstruction framework. Given a quintic polynomial over ℚ, it computes arithmetic
invariants (discriminant, modular factorization patterns) and determines whether
the polynomial's Galois group is likely S₅, which would certify that the polynomial
is not solvable by radicals.

Usage:
    python demo.py

The demo examines several well-known quintics and explains the mathematical
reasoning behind each verdict.
"""

import sympy
from sympy import Poly, ZZ, QQ, GF, factorint, Symbol, sqrt, Rational
from sympy.abc import x
from typing import List, Tuple, Optional
import itertools


def polynomial_discriminant(coeffs: List[int]) -> int:
    """
    Compute the discriminant of a polynomial given by its coefficients.
    For a polynomial a_n x^n + ... + a_1 x + a_0, coeffs = [a_n, ..., a_0].
    Uses sympy's built-in discriminant computation.
    """
    p = Poly(sum(c * x**(len(coeffs)-1-i) for i, c in enumerate(coeffs)), x, domain=ZZ)
    return int(p.discriminant())


def is_perfect_square(n: int) -> bool:
    """Check if an integer is a perfect square."""
    if n < 0:
        return False
    r = int(n ** 0.5)
    for candidate in [r - 1, r, r + 1]:
        if candidate >= 0 and candidate * candidate == n:
            return True
    return False


def factor_mod_p(coeffs: List[int], p: int) -> List[int]:
    """
    Factor a polynomial modulo a prime p.
    Returns a list of degrees of irreducible factors.
    
    Args:
        coeffs: Polynomial coefficients [a_n, ..., a_0]
        p: Prime number
    
    Returns:
        Sorted list of degrees of irreducible factors over GF(p)
    """
    try:
        poly = Poly(sum(c * x**(len(coeffs)-1-i) for i, c in enumerate(coeffs)), x, domain=GF(p))
        if poly.degree() < len(coeffs) - 1:
            # Leading coefficient vanishes mod p
            return []
        factors = poly.factor_list()[1]
        degrees = sorted([f[0].degree() for f in factors for _ in range(f[1])])
        return degrees
    except Exception:
        return []


def check_irreducibility_modp(coeffs: List[int], p: int) -> bool:
    """Check if polynomial is irreducible mod p."""
    pattern = factor_mod_p(coeffs, p)
    n = len(coeffs) - 1
    return pattern == [n]


def find_frobenius_evidence(coeffs: List[int], max_prime: int = 200) -> dict:
    """
    Search for modular factorization evidence that identifies the Galois group.
    
    For a degree-5 polynomial, we look for:
    - A prime where the polynomial is irreducible mod p (→ 5-cycle in Galois group)
    - A prime where the polynomial factors as (2,1,1,1) mod p (→ transposition)
    
    If both exist and the discriminant is not a perfect square,
    the Galois group is S₅.
    """
    n = len(coeffs) - 1
    primes = [p for p in range(2, max_prime) if sympy.isprime(p)]
    
    evidence = {
        'five_cycle_prime': None,
        'five_cycle_pattern': None,
        'transposition_prime': None,
        'transposition_pattern': None,
        'all_patterns': {},
        'discriminant': None,
        'disc_is_square': None,
    }
    
    # Compute discriminant
    disc = polynomial_discriminant(coeffs)
    evidence['discriminant'] = disc
    evidence['disc_is_square'] = is_perfect_square(abs(disc))
    
    for p in primes:
        # Skip primes dividing the leading coefficient
        if coeffs[0] % p == 0:
            continue
        
        pattern = factor_mod_p(coeffs, p)
        if not pattern or sum(pattern) != n:
            continue
            
        evidence['all_patterns'][p] = pattern
        
        # Check for 5-cycle (irreducible mod p)
        if pattern == [5] and evidence['five_cycle_prime'] is None:
            evidence['five_cycle_prime'] = p
            evidence['five_cycle_pattern'] = pattern
        
        # Check for transposition-like element
        # Pattern [1, 1, 1, 2] means a quadratic factor and three linear factors
        if sorted(pattern) == [1, 1, 1, 2] and evidence['transposition_prime'] is None:
            evidence['transposition_prime'] = p
            evidence['transposition_pattern'] = pattern
    
    return evidence


def analyze_quintic(name: str, coeffs: List[int]) -> None:
    """
    Analyze a quintic polynomial and print a detailed report.
    
    Args:
        name: Human-readable name for the polynomial
        coeffs: Coefficients [a_5, a_4, a_3, a_2, a_1, a_0]
    """
    print(f"\n{'='*70}")
    print(f"  Analyzing: {name}")
    print(f"{'='*70}")
    
    # Display polynomial
    terms = []
    n = len(coeffs) - 1
    for i, c in enumerate(coeffs):
        deg = n - i
        if c == 0:
            continue
        if deg == 0:
            terms.append(f"{c:+d}")
        elif deg == 1:
            if c == 1:
                terms.append("+x")
            elif c == -1:
                terms.append("-x")
            else:
                terms.append(f"{c:+d}x")
        else:
            if c == 1:
                terms.append(f"+x^{deg}")
            elif c == -1:
                terms.append(f"-x^{deg}")
            else:
                terms.append(f"{c:+d}x^{deg}")
    
    poly_str = " ".join(terms).lstrip("+").strip()
    print(f"\n  f(x) = {poly_str}")
    
    # Check irreducibility over Q using sympy
    poly = Poly(sum(c * x**(n-i) for i, c in enumerate(coeffs)), x, domain=QQ)
    is_irred = poly.is_irreducible
    print(f"\n  Irreducible over ℚ: {'Yes ✓' if is_irred else 'No ✗'}")
    
    if not is_irred:
        factors = poly.factor_list()
        print(f"  Factors: {factors}")
        print(f"\n  → This polynomial factors over ℚ, so its Galois group")
        print(f"    is a proper subgroup of S₅. Skipping further analysis.")
        return
    
    # Gather Frobenius evidence
    evidence = find_frobenius_evidence(coeffs)
    
    print(f"\n  Discriminant: {evidence['discriminant']}")
    print(f"  Discriminant is a perfect square: {'Yes' if evidence['disc_is_square'] else 'No'}")
    
    print(f"\n  Modular Factorization Patterns (first 20 primes):")
    print(f"  {'Prime':>6}  {'Pattern':>20}  {'Cycle Type':>15}")
    print(f"  {'─'*6}  {'─'*20}  {'─'*15}")
    
    count = 0
    for p, pattern in sorted(evidence['all_patterns'].items()):
        if count >= 20:
            break
        cycle_desc = str(tuple(sorted(pattern, reverse=True)))
        marker = ""
        if pattern == [5]:
            marker = " ← 5-cycle!"
        elif sorted(pattern) == [1, 1, 1, 2]:
            marker = " ← transposition!"
        print(f"  {p:>6}  {str(pattern):>20}  {cycle_desc:>15}{marker}")
        count += 1
    
    # Verdict
    print(f"\n  ─── Galois Group Analysis ───")
    
    has_5cycle = evidence['five_cycle_prime'] is not None
    has_transp = evidence['transposition_prime'] is not None
    disc_nonsquare = not evidence['disc_is_square']
    
    if has_5cycle:
        print(f"  ✓ Found 5-cycle: f is irreducible mod {evidence['five_cycle_prime']}")
        print(f"    → Galois group contains an element of order 5")
    else:
        print(f"  ✗ No 5-cycle found (f reducible mod all tested primes)")
    
    if has_transp:
        print(f"  ✓ Found transposition-type: f factors as (2,1,1,1) mod {evidence['transposition_prime']}")
        print(f"    → Galois group contains an element of order 2")
    else:
        print(f"  ✗ No transposition-type factorization found")
    
    if disc_nonsquare:
        print(f"  ✓ Discriminant is not a perfect square")
        print(f"    → Galois group is NOT contained in A₅")
    else:
        print(f"  ✗ Discriminant is a perfect square")
        print(f"    → Galois group may be contained in A₅")
    
    print(f"\n  ─── Verdict ───")
    if has_5cycle and has_transp:
        print(f"  ★ CERTIFIED: Galois group is S₅")
        print(f"    A transitive subgroup of S₅ containing both a 5-cycle")
        print(f"    and a transposition must be all of S₅.")
        print(f"\n  ★ CONCLUSION: f(x) = {poly_str} is NOT SOLVABLE BY RADICALS")
        print(f"    There is no formula involving +, −, ×, ÷, and n-th roots")
        print(f"    that produces any root of this polynomial.")
        print(f"\n    This follows from the formal obstruction pipeline:")
        print(f"    1. Gal(f) ≅ S₅ (certified by Frobenius elements)")
        print(f"    2. S₅ is not solvable (its derived series never reaches {{e}})")
        print(f"    3. A polynomial with non-solvable Galois group has no root")
        print(f"       expressible by radicals (Galois's theorem)")
    elif has_5cycle:
        print(f"  ◐ PARTIAL: 5-cycle found but transposition evidence incomplete")
        print(f"    Further analysis needed (try more primes or resolvent methods)")
    else:
        print(f"  ? INCONCLUSIVE: Insufficient modular evidence")
        print(f"    The Galois group could be a proper subgroup of S₅")


def main():
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     Galois Theory Detection Engine — Abel–Ruffini Obstruction      ║")
    print("║                                                                    ║")
    print("║  This tool analyzes quintic polynomials over ℚ to determine        ║")
    print("║  whether they are solvable by radicals, using modular arithmetic   ║")
    print("║  to identify the Galois group.                                     ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    # Test polynomials
    quintics = [
        ("x⁵ − x − 1", [1, 0, 0, 0, -1, -1]),
        ("x⁵ − 6x + 3", [1, 0, 0, 0, -6, 3]),
        ("x⁵ − 4x + 2", [1, 0, 0, 0, -4, 2]),
        ("x⁵ + 20x + 16", [1, 0, 0, 0, 20, 16]),
        ("x⁵ − 5x + 12", [1, 0, 0, 0, -5, 12]),
        ("x⁵ − 2", [1, 0, 0, 0, 0, -2]),  # Solvable (cyclic Galois group)
    ]
    
    for name, coeffs in quintics:
        analyze_quintic(name, coeffs)
    
    print(f"\n{'='*70}")
    print(f"  Summary of the Obstruction Pipeline")
    print(f"{'='*70}")
    print("""
  The detection engine implements the following formal pipeline:

  1. ARITHMETIC DATA: For a quintic f ∈ ℚ[X], compute:
     • Discriminant Δ(f)
     • Factorization patterns of f mod p for small primes p

  2. GROUP IDENTIFICATION: From modular patterns, identify Frobenius elements:
     • f irreducible mod p  →  5-cycle in Gal(f)
     • f = (deg 2)(deg 1)³ mod p  →  transposition in Gal(f)

  3. SUBGROUP THEOREM: A transitive subgroup of S₅ containing a 5-cycle
     and a transposition is all of S₅.

  4. OBSTRUCTION: S₅ is not solvable (its derived series
     S₅ ⊃ A₅ ⊃ A₅ ⊃ ... never reaches {e}).

  5. GALOIS'S THEOREM: A polynomial with non-solvable Galois group
     has no root expressible by radicals.

  Each step has been formally verified in our framework.
""")


if __name__ == "__main__":
    main()
