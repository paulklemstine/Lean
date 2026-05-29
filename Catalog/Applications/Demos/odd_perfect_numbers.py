#!/usr/bin/env python3
"""
Applications of Multiplicative Rigidity Theory
===============================================

This module demonstrates real-world applications of the support-energy
exclusion framework:

1. Automated verification that specific prime supports cannot yield
   odd perfect numbers.
2. Lower bounds on the number of distinct prime factors.
3. Computational search for the "most nearly perfect" odd numbers.
4. Analysis of the prime-factor structure of highly abundant numbers.
"""

from fractions import Fraction
from typing import List, Dict, Tuple
from itertools import combinations


def sigma_prime_pow(p: int, a: int) -> int:
    """σ(p^a) = (p^{a+1} - 1) / (p - 1)."""
    return (p ** (a + 1) - 1) // (p - 1)


def local_abundancy(p: int, a: int) -> Fraction:
    """I(p, a) = σ(p^a) / p^a."""
    return Fraction(sigma_prime_pow(p, a), p ** a)


def support_energy(primes: List[int]) -> Fraction:
    """∏ p/(p-1) over the prime support."""
    result = Fraction(1)
    for p in primes:
        result *= Fraction(p, p - 1)
    return result


def is_prime(n: int) -> bool:
    """Primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def odd_primes_up_to(n: int) -> List[int]:
    """Return all odd primes up to n."""
    return [p for p in range(3, n + 1, 2) if is_prime(p)]


# ── Application 1: Prime Factor Lower Bounds ──

def minimum_primes_for_energy(threshold: Fraction = Fraction(2),
                              max_primes: int = 50) -> int:
    """
    Find the minimum number of consecutive odd primes needed for
    support energy to reach the threshold.

    This gives a constructive lower bound on the number of distinct
    prime factors of an odd perfect number.
    """
    primes = odd_primes_up_to(300)
    energy = Fraction(1)
    for i, p in enumerate(primes[:max_primes]):
        energy *= Fraction(p, p - 1)
        if energy >= threshold:
            return i + 1
    return -1  # Not reached


def prime_factor_lower_bound_analysis():
    """
    Demonstrate that odd perfect numbers need many prime factors.
    """
    print("Application 1: Lower Bounds on Number of Distinct Prime Factors")
    print("=" * 65)
    print()
    print("Using consecutive odd primes (best case for energy accumulation):")
    print()

    primes = odd_primes_up_to(200)
    energy = Fraction(1)
    print(f"  {'# Primes':>10} {'Largest':>10} {'Energy':>14} {'Gap from 2':>14}")
    print("  " + "-" * 55)
    for i, p in enumerate(primes[:20]):
        energy *= Fraction(p, p - 1)
        gap = Fraction(2) - energy
        marker = " ← first ≥ 2" if i > 0 and gap <= 0 and Fraction(2) - support_energy(primes[:i]) > 0 else ""
        print(f"  {i+1:>10} {p:>10} {float(energy):>14.8f} {float(gap):>+14.8f}{marker}")

    min_count = minimum_primes_for_energy()
    print(f"\n  Minimum consecutive odd primes for energy ≥ 2: {min_count}")
    print(f"  This means any odd perfect number needs at least {min_count} distinct")
    print(f"  prime factors (from the consecutive-prime energy barrier).")
    print()
    print("  Note: The proven lower bound from the literature is 9 distinct")
    print("  prime factors (Nielsen, 2015). Our energy barrier with consecutive")
    print("  primes gives a weaker but independently derived bound.")
    print()


# ── Application 2: Euler Prime Constraints ──

def euler_prime_constraints():
    """
    Analyze constraints on the Euler prime from the energy framework.
    """
    print("Application 2: Constraints on the Euler Prime")
    print("=" * 65)
    print()
    print("For an odd perfect n = p^k · m² with p ≡ 1 (mod 4), k ≡ 1 (mod 4),")
    print("the Euler prime p contributes I(p, k) to the abundancy product.")
    print()

    euler_candidates = [p for p in odd_primes_up_to(100) if p % 4 == 1]
    print(f"Euler prime candidates up to 100: {euler_candidates}")
    print()

    print(f"  {'p':>6} {'I(p,1)':>12} {'I(p,5)':>12} {'I(p,9)':>12} {'p/(p-1)':>12}")
    print("  " + "-" * 55)
    for p in euler_candidates:
        i1 = local_abundancy(p, 1)
        i5 = local_abundancy(p, 5)
        i9 = local_abundancy(p, 9)
        limit = Fraction(p, p - 1)
        print(f"  {p:>6} {float(i1):>12.8f} {float(i5):>12.8f} "
              f"{float(i9):>12.8f} {float(limit):>12.8f}")

    print()
    print("  Observation: Larger Euler primes contribute less to the abundancy,")
    print("  forcing the remaining primes to compensate. This creates a tension:")
    print("  the Euler prime must be large enough to satisfy p ≡ 1 (mod 4),")
    print("  but small enough to not drain too much energy from the support.")


# ── Application 3: Deficiency Gap Distribution ──

def deficiency_gap_distribution():
    """
    Study the distribution of deficiency gaps across candidate supports.
    """
    print("\nApplication 3: Deficiency Gap Distribution")
    print("=" * 65)
    print()

    pool = odd_primes_up_to(30)
    print(f"Prime pool: {pool}")
    print()

    # For each support size, find the support closest to energy = 2
    for size in range(2, 7):
        best_gap = None
        best_support = None
        worst_gap = None
        worst_support = None

        for combo in combinations(pool, size):
            energy = support_energy(list(combo))
            gap = Fraction(2) - energy

            if best_gap is None or abs(gap) < abs(best_gap):
                best_gap = gap
                best_support = list(combo)
            if worst_gap is None or gap > worst_gap:
                worst_gap = gap
                worst_support = list(combo)

        print(f"  Size {size}:")
        print(f"    Closest to 2: {best_support} → energy = {float(support_energy(best_support)):.8f}, "
              f"gap = {float(best_gap):+.8f}")
        print(f"    Farthest:     {worst_support} → energy = {float(support_energy(worst_support)):.8f}, "
              f"gap = {float(worst_gap):+.8f}")


# ── Application 4: Highly Abundant Odd Numbers ──

def highly_abundant_analysis():
    """
    Find odd numbers with highest abundancy ratio and analyze their structure.
    """
    print("\nApplication 4: Most Abundant Odd Numbers")
    print("=" * 65)
    print()

    # Compute abundancy for small odd numbers
    best = []
    for n in range(1, 10000, 2):
        s = sum(d for d in range(1, n + 1) if n % d == 0)
        abund = Fraction(s, n)
        best.append((n, abund, s))

    best.sort(key=lambda x: -x[1])

    print(f"  {'n':>8} {'σ(n)':>10} {'σ(n)/n':>14} {'Gap from 2':>14} {'Factorization':>20}")
    print("  " + "-" * 70)
    for n, abund, s in best[:15]:
        # Factor n
        factors = {}
        temp = n
        for p in range(2, n + 1):
            while temp % p == 0:
                factors[p] = factors.get(p, 0) + 1
                temp //= p
            if temp == 1:
                break
        fac_str = " · ".join(f"{p}^{a}" if a > 1 else str(p) for p, a in sorted(factors.items()))
        print(f"  {n:>8} {s:>10} {float(abund):>14.8f} {float(Fraction(2) - abund):>+14.8f} {fac_str:>20}")

    print()
    print("  None of these odd numbers achieves σ(n)/n = 2 (perfection).")
    print("  The gap from 2 measures the 'deficiency' of each candidate.")


if __name__ == "__main__":
    prime_factor_lower_bound_analysis()
    euler_prime_constraints()
    deficiency_gap_distribution()
    highly_abundant_analysis()


#!/usr/bin/env python3
"""
Odd Perfect Numbers: Multiplicative Rigidity Explorer
=====================================================

Interactive demonstration of the support-energy exclusion principle
for odd perfect numbers. This tool lets you:

1. Input a finite set of odd primes and compute the support energy bound.
2. Determine whether that prime support is excluded from perfection.
3. Scan Euler-prime candidates and exponents for a given support.
4. Visualize how local abundancy factors approach but fail to reach 2.

Mathematical Background
-----------------------
An odd perfect number n satisfies σ(n) = 2n. Because σ is multiplicative,
this becomes a product equation over prime powers:

    ∏ I(p, a_p) = 2

where I(p, a) = σ(p^a)/p^a is the local abundancy factor. Since
I(p, a) < p/(p-1) for all primes p and exponents a, we get the
support energy barrier:

    2 ≤ ∏ p/(p-1)   over the prime support of n.

If ∏ p/(p-1) < 2 for a set of primes S, then no odd perfect number
has S as its complete prime support.
"""

from fractions import Fraction
from typing import List, Tuple, Optional
import sys


def sigma(n: int) -> int:
    """Compute σ(n), the sum of all positive divisors of n."""
    if n <= 0:
        return 0
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += d
    return total


def sigma_prime_pow(p: int, a: int) -> int:
    """Compute σ(p^a) = 1 + p + p² + ... + p^a using the geometric formula."""
    if a == 0:
        return 1
    return (p ** (a + 1) - 1) // (p - 1)


def local_abundancy(p: int, a: int) -> Fraction:
    """
    Compute I(p, a) = σ(p^a) / p^a ∈ Q.

    This is the local abundancy factor: the contribution of the prime
    power p^a to the total abundancy index σ(n)/n.

    For any prime p:
      - I(p, 0) = 1
      - I(p, a) is strictly increasing in a
      - 1 < I(p, a) < p/(p-1) for a ≥ 1
    """
    pa = p ** a
    return Fraction(sigma_prime_pow(p, a), pa)


def support_energy(primes: List[int]) -> Fraction:
    """
    Compute the support energy ∏ p/(p-1) for a set of primes.

    This is the theoretical upper bound on the abundancy of any number
    whose prime support is exactly the given set. If this product is < 2,
    no perfect number has this exact prime support.
    """
    product = Fraction(1)
    for p in primes:
        product *= Fraction(p, p - 1)
    return product


def deficiency_gap_bound(primes: List[int]) -> Fraction:
    """
    Compute the deficiency gap lower bound: 2 - ∏ p/(p-1).

    If positive, this certifies that no number with this prime support is perfect.
    """
    return Fraction(2) - support_energy(primes)


def check_support_exclusion(primes: List[int]) -> Tuple[bool, Fraction]:
    """
    Check whether a prime support is excluded from containing an odd perfect number.

    Returns (is_excluded, gap) where gap = 2 - ∏ p/(p-1).
    If gap > 0, the support is excluded (certified).
    """
    gap = deficiency_gap_bound(primes)
    return (gap > 0, gap)


def scan_euler_candidates(primes: List[int], max_exponent: int = 20):
    """
    Scan Euler-prime candidates for a given prime support.

    For each prime p in the support that satisfies p ≡ 1 (mod 4),
    and for exponents k ≡ 1 (mod 4), compute the exact abundancy
    product and check how close it gets to 2.
    """
    euler_primes = [p for p in primes if p % 4 == 1]
    if not euler_primes:
        print("  No Euler-prime candidates (need p ≡ 1 mod 4)")
        return

    results = []
    for ep in euler_primes:
        other_primes = [p for p in primes if p != ep]
        for k in range(1, max_exponent + 1, 4):  # k ≡ 1 (mod 4)
            # Compute I(ep, k) * ∏_{q ≠ ep} sup I(q, ·) = I(ep, k) * ∏ q/(q-1)
            euler_factor = local_abundancy(ep, k)
            other_energy = Fraction(1)
            for q in other_primes:
                other_energy *= Fraction(q, q - 1)
            max_abundancy = euler_factor * other_energy
            gap = Fraction(2) - max_abundancy
            results.append((ep, k, euler_factor, max_abundancy, gap))

    print(f"\n  {'Euler p':>8} {'k':>4} {'I(p,k)':>12} {'Max Abund':>12} {'Gap':>12} {'Status':>10}")
    print("  " + "-" * 70)
    for ep, k, ef, ma, gap in results:
        status = "EXCLUDED" if gap > 0 else "possible"
        ef_float = float(ef)
        ma_float = float(ma)
        gap_float = float(gap)
        print(f"  {ep:>8} {k:>4} {ef_float:>12.6f} {ma_float:>12.6f} {gap_float:>+12.6f} {status:>10}")


def visualize_abundancy_approach(primes: List[int], max_exp: int = 15):
    """
    Show how local abundancy factors grow with exponent and approach their limits.
    """
    print("\n  Local Abundancy Factors I(p, a) and their limits p/(p-1):")
    print(f"\n  {'a':>4}", end="")
    for p in primes:
        print(f"  {'p='+str(p):>12}", end="")
    print(f"  {'Product':>12}")
    print("  " + "-" * (4 + 14 * len(primes) + 14))

    for a in range(1, max_exp + 1):
        print(f"  {a:>4}", end="")
        product = Fraction(1)
        for p in primes:
            ia = local_abundancy(p, a)
            product *= ia
            print(f"  {float(ia):>12.8f}", end="")
        print(f"  {float(product):>12.8f}")

    print(f"\n  {'lim':>4}", end="")
    limit_product = Fraction(1)
    for p in primes:
        limit = Fraction(p, p - 1)
        limit_product *= limit
        print(f"  {float(limit):>12.8f}", end="")
    print(f"  {float(limit_product):>12.8f}")
    print(f"\n  Target: 2.00000000")
    print(f"  Support energy (product of limits): {float(limit_product):.8f}")
    if limit_product < 2:
        print(f"  → EXCLUDED: support energy < 2, gap = {float(Fraction(2) - limit_product):.8f}")
    else:
        print(f"  → NOT excluded: support energy ≥ 2")


def interactive_mode():
    """Run the interactive explorer."""
    print("=" * 72)
    print("  ODD PERFECT NUMBERS: Multiplicative Rigidity Explorer")
    print("=" * 72)
    print()
    print("  This tool explores the support-energy exclusion principle:")
    print("  If ∏ p/(p-1) < 2 for a set of odd primes, then NO odd perfect")
    print("  number can have exactly that prime support.")
    print()

    while True:
        print("-" * 72)
        print("\n  Options:")
        print("  1. Check a custom prime support")
        print("  2. Scan small supports systematically")
        print("  3. Euler candidate analysis")
        print("  4. Visualize abundancy approach")
        print("  5. Demo: known exclusions")
        print("  q. Quit")
        print()

        choice = input("  Choice: ").strip().lower()

        if choice == 'q':
            break
        elif choice == '1':
            raw = input("  Enter odd primes separated by spaces: ").strip()
            try:
                primes = sorted(set(int(x) for x in raw.split()))
                if not all(p > 2 and all(p % d != 0 for d in range(2, p)) for p in primes):
                    print("  Error: all inputs must be odd primes")
                    continue
                excluded, gap = check_support_exclusion(primes)
                energy = support_energy(primes)
                print(f"\n  Prime support: {primes}")
                print(f"  Support energy ∏ p/(p-1) = {energy} ≈ {float(energy):.8f}")
                print(f"  Deficiency gap bound: {gap} ≈ {float(gap):.8f}")
                if excluded:
                    print(f"  ✓ EXCLUDED: No odd perfect number has this prime support.")
                else:
                    print(f"  ✗ Not excluded by support energy alone.")
            except ValueError:
                print("  Error: invalid input")

        elif choice == '2':
            print("\n  Systematic scan of small prime supports:")
            small_primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
            # Check all subsets of size 2, 3, 4
            from itertools import combinations
            for size in range(2, 6):
                excluded_count = 0
                total_count = 0
                print(f"\n  Supports of size {size}:")
                for combo in combinations(small_primes, size):
                    total_count += 1
                    excl, gap = check_support_exclusion(list(combo))
                    if excl:
                        excluded_count += 1
                        if total_count <= 15:
                            print(f"    {list(combo)}: energy = {float(support_energy(list(combo))):.6f} < 2 → EXCLUDED")
                    else:
                        if total_count <= 15:
                            print(f"    {list(combo)}: energy = {float(support_energy(list(combo))):.6f} ≥ 2 → not excluded")
                print(f"    → {excluded_count}/{total_count} supports excluded")

        elif choice == '3':
            raw = input("  Enter odd primes separated by spaces: ").strip()
            try:
                primes = sorted(set(int(x) for x in raw.split()))
                scan_euler_candidates(primes)
            except ValueError:
                print("  Error: invalid input")

        elif choice == '4':
            raw = input("  Enter odd primes separated by spaces: ").strip()
            try:
                primes = sorted(set(int(x) for x in raw.split()))
                visualize_abundancy_approach(primes)
            except ValueError:
                print("  Error: invalid input")

        elif choice == '5':
            demo_known_exclusions()

        print()


def demo_known_exclusions():
    """Demonstrate the exclusion principle on known cases."""
    print("\n  ═══════════════════════════════════════════════════════")
    print("  DEMO: Support-Energy Exclusion Principle")
    print("  ═══════════════════════════════════════════════════════")

    test_cases = [
        ([3, 5], "Two smallest odd primes"),
        ([3, 7], "3 and 7"),
        ([5, 7, 11, 13], "Four primes without 3"),
        ([3, 5, 7], "Three smallest odd primes"),
        ([3, 5, 7, 11], "First four odd primes"),
        ([3, 5, 7, 11, 13], "First five odd primes"),
    ]

    print(f"\n  {'Support':>25} {'Energy':>12} {'Gap':>12} {'Status':>10}")
    print("  " + "-" * 65)

    for primes, desc in test_cases:
        energy = support_energy(primes)
        gap = Fraction(2) - energy
        status = "EXCLUDED" if gap > 0 else "possible"
        print(f"  {str(primes):>25} {float(energy):>12.6f} {float(gap):>+12.6f} {status:>10}  {desc}")

    print("\n  Key insight: {3, 5} has energy 15/8 = 1.875 < 2,")
    print("  so no odd perfect number has only 3 and 5 as prime factors.")
    print("  But {3, 5, 7} has energy 35/16 = 2.1875 ≥ 2, so this support")
    print("  is NOT excluded by the energy barrier alone.")
    print()
    print("  The energy barrier says: an odd perfect number needs enough")
    print("  prime factors for their combined 'energy' to reach 2.")
    print("  This is a certified, machine-verified exclusion principle.")

    # Also show the Euler candidate scan for {3, 5, 7}
    print("\n  Euler candidate analysis for {3, 5, 7}:")
    scan_euler_candidates([3, 5, 7], max_exponent=9)


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--demo":
        demo_known_exclusions()
    elif len(sys.argv) > 1:
        primes = sorted(set(int(x) for x in sys.argv[1:]))
        excluded, gap = check_support_exclusion(primes)
        energy = support_energy(primes)
        print(f"Prime support: {primes}")
        print(f"Support energy: {energy} ≈ {float(energy):.8f}")
        print(f"Gap: {gap} ≈ {float(gap):.8f}")
        print(f"{'EXCLUDED' if excluded else 'Not excluded'}")
    else:
        interactive_mode()


#!/usr/bin/env python3
"""
Visualization: Local Abundancy Landscape
=========================================

This heatmap shows the local abundancy factor I(p, a) = σ(p^a)/p^a
for various primes p and exponents a. The color intensity reveals
how each factor approaches its geometric limit p/(p-1) as the
exponent grows.

Key observations visible in this plot:
- Small primes (3, 5, 7) contribute much more than large primes
- All factors are strictly between 1 and p/(p-1)
- The factors converge rapidly for large p
- Perfect numbers require these factors to multiply to exactly 2
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
from fractions import Fraction


def sigma_prime_pow(p, a):
    if a == 0:
        return 1
    return (p ** (a + 1) - 1) // (p - 1)


def local_abundancy(p, a):
    return Fraction(sigma_prime_pow(p, a), p ** a)


def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


primes = [p for p in range(3, 50, 2) if is_prime(p)][:12]
max_exp = 12

# Compute the abundancy matrix
Z = np.zeros((len(primes), max_exp))
for i, p in enumerate(primes):
    for a in range(1, max_exp + 1):
        Z[i, a-1] = float(local_abundancy(p, a))

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Heatmap of I(p, a)
ax = axes[0]
im = ax.imshow(Z, aspect='auto', cmap='YlOrRd', vmin=1.0,
               interpolation='nearest')
ax.set_xticks(range(max_exp))
ax.set_xticklabels(range(1, max_exp + 1))
ax.set_yticks(range(len(primes)))
ax.set_yticklabels([str(p) for p in primes])
ax.set_xlabel('Exponent a', fontsize=12)
ax.set_ylabel('Prime p', fontsize=12)
ax.set_title('Local Abundancy I(p, a)', fontsize=14, fontweight='bold')
plt.colorbar(im, ax=ax, label='I(p, a)')

# Annotate a few values
for i in range(min(5, len(primes))):
    for a in range(min(4, max_exp)):
        val = Z[i, a]
        ax.text(a, i, f'{val:.3f}', ha='center', va='center', fontsize=6,
                color='white' if val > 1.3 else 'black')

# Line plot: convergence to limit
ax2 = axes[1]
for i, p in enumerate(primes[:6]):
    exponents = list(range(0, max_exp + 1))
    values = [float(local_abundancy(p, a)) for a in exponents]
    limit = float(Fraction(p, p - 1))
    ax2.plot(exponents, values, 'o-', label=f'p={p}', markersize=4, linewidth=1.5)
    ax2.axhline(y=limit, color=ax2.get_lines()[-1].get_color(),
                linestyle=':', alpha=0.3, linewidth=1)

ax2.set_xlabel('Exponent a', fontsize=12)
ax2.set_ylabel('I(p, a)', fontsize=12)
ax2.set_title('Convergence to Geometric Limit\np/(p-1)', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9, loc='lower right')
ax2.set_ylim(0.95, 1.6)

# Gap from limit: p/(p-1) - I(p,a)
ax3 = axes[2]
for i, p in enumerate(primes[:6]):
    exponents = list(range(1, max_exp + 1))
    limit = Fraction(p, p - 1)
    gaps = [float(limit - local_abundancy(p, a)) for a in exponents]
    ax3.semilogy(exponents, gaps, 'o-', label=f'p={p}', markersize=4, linewidth=1.5)

ax3.set_xlabel('Exponent a', fontsize=12)
ax3.set_ylabel('Gap: p/(p-1) - I(p, a)', fontsize=12)
ax3.set_title('Exponential Convergence Rate\n(log scale)', fontsize=14, fontweight='bold')
ax3.legend(fontsize=9)

plt.tight_layout()
plt.savefig('viz_abundancy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_abundancy_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Support Energy Barrier for Odd Perfect Numbers
=============================================================

This plot shows how the support energy ∏ p/(p-1) grows as we add
consecutive odd primes. The horizontal line at y=2 is the critical
threshold: only supports with energy ≥ 2 can potentially support
an odd perfect number.

The key insight is that the energy grows slowly—it takes at least 3
consecutive odd primes to cross the barrier, and larger primes
contribute progressively less energy.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
from fractions import Fraction


def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def odd_primes_up_to(n):
    return [p for p in range(3, n + 1, 2) if is_prime(p)]


primes = odd_primes_up_to(100)
energies = []
energy = Fraction(1)
for p in primes:
    energy *= Fraction(p, p - 1)
    energies.append(float(energy))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: cumulative energy
x = list(range(1, len(energies) + 1))
colors = ['#e74c3c' if e < 2 else '#2ecc71' for e in energies]
ax1.bar(x, energies, color=colors, alpha=0.7, edgecolor='white', linewidth=0.5)
ax1.axhline(y=2, color='#3498db', linewidth=2, linestyle='--', label='Critical threshold (y=2)')
ax1.set_xlabel('Number of consecutive odd primes', fontsize=12)
ax1.set_ylabel('Support energy ∏ p/(p-1)', fontsize=12)
ax1.set_title('Support Energy Barrier\nfor Odd Perfect Numbers', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)

# Annotate key points
ax1.annotate(f'1 prime: {energies[0]:.3f}', xy=(1, energies[0]),
            xytext=(3, energies[0] - 0.2), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='gray'))
ax1.annotate(f'2 primes: {energies[1]:.3f}', xy=(2, energies[1]),
            xytext=(4, energies[1] - 0.15), fontsize=9,
            arrowprops=dict(arrowstyle='->', color='gray'))

# Find crossing point
crossing = next(i for i, e in enumerate(energies) if e >= 2)
ax1.annotate(f'{crossing+1} primes: crosses 2!', xy=(crossing+1, energies[crossing]),
            xytext=(crossing+3, 1.5), fontsize=9, color='#e74c3c',
            arrowprops=dict(arrowstyle='->', color='#e74c3c'))

ax1.set_xlim(0.5, min(15, len(energies)) + 0.5)
ax1.set_ylim(0, max(energies[:15]) * 1.1)

# Right: individual contributions p/(p-1)
contributions = [Fraction(p, p-1) for p in primes[:20]]
contrib_float = [float(c) for c in contributions]
ax2.bar(range(1, 21), contrib_float, color='#9b59b6', alpha=0.7, edgecolor='white')
ax2.set_xlabel('Prime index (1=3, 2=5, 3=7, ...)', fontsize=12)
ax2.set_ylabel('Individual factor p/(p-1)', fontsize=12)
ax2.set_title('Individual Prime Contributions\n(decreasing toward 1)', fontsize=14, fontweight='bold')

# Annotate with prime values
for i in range(min(8, len(primes))):
    ax2.annotate(f'p={primes[i]}', xy=(i+1, contrib_float[i]),
                xytext=(i+1, contrib_float[i] + 0.02), fontsize=7,
                ha='center', rotation=45)

ax2.axhline(y=1, color='gray', linewidth=1, linestyle=':', alpha=0.5, label='Limit as p→∞')
ax2.legend(fontsize=9)

plt.tight_layout()
plt.savefig('viz_energy_barrier.png', dpi=150, bbox_inches='tight')
print("Saved viz_energy_barrier.png")


#!/usr/bin/env python3
"""
Visualization: Support Exclusion Map
=====================================

This visualization shows which prime supports are excluded by the
energy barrier theorem. For each pair of primes from the first 10
odd primes, we compute the support energy and mark excluded supports
in red and non-excluded ones in green.

The plot reveals the phase transition: small prime sets are excluded
(energy < 2), while larger or denser sets cross the barrier.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np
from fractions import Fraction
from itertools import combinations


def is_prime(n):
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def support_energy(primes):
    result = Fraction(1)
    for p in primes:
        result *= Fraction(p, p - 1)
    return result


primes = [p for p in range(3, 50, 2) if is_prime(p)][:10]

fig, axes = plt.subplots(1, 2, figsize=(15, 6))

# Left: 2-element support heatmap
ax = axes[0]
n = len(primes)
Z = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i != j:
            e = float(support_energy([primes[i], primes[j]]))
            Z[i, j] = e
        else:
            Z[i, j] = float(Fraction(primes[i], primes[i] - 1))

im = ax.imshow(Z, cmap='RdYlGn_r', vmin=1.0, vmax=2.5, interpolation='nearest')
ax.set_xticks(range(n))
ax.set_xticklabels([str(p) for p in primes], fontsize=9)
ax.set_yticks(range(n))
ax.set_yticklabels([str(p) for p in primes], fontsize=9)
ax.set_xlabel('Prime q', fontsize=12)
ax.set_ylabel('Prime p', fontsize=12)
ax.set_title('Two-Prime Support Energy\n{p, q} → p/(p-1) · q/(q-1)', fontsize=14, fontweight='bold')
plt.colorbar(im, ax=ax, label='Support Energy')

# Mark the 2.0 boundary
for i in range(n):
    for j in range(n):
        if i != j:
            val = Z[i, j]
            color = 'white' if val > 1.8 else 'black'
            marker = '✓' if val >= 2.0 else '✗'
            ax.text(j, i, f'{val:.2f}\n{marker}', ha='center', va='center',
                    fontsize=6, color=color)

# Right: exclusion fraction by support size
ax2 = axes[1]
max_size = min(8, len(primes))
sizes = list(range(2, max_size + 1))
excluded_fracs = []
total_counts = []

for k in sizes:
    excluded = 0
    total = 0
    for combo in combinations(primes, k):
        total += 1
        if support_energy(list(combo)) < 2:
            excluded += 1
    excluded_fracs.append(excluded / total * 100 if total > 0 else 0)
    total_counts.append(total)

bars = ax2.bar(sizes, excluded_fracs, color='#e74c3c', alpha=0.7, edgecolor='white')
ax2.set_xlabel('Support size |S|', fontsize=12)
ax2.set_ylabel('Percentage of supports excluded (%)', fontsize=12)
ax2.set_title('Fraction of Supports Excluded\nby Energy Barrier', fontsize=14, fontweight='bold')
ax2.set_ylim(0, 105)
ax2.set_xticks(sizes)

# Annotate with counts
for i, (bar, frac, total) in enumerate(zip(bars, excluded_fracs, total_counts)):
    ax2.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 2,
             f'{frac:.0f}%\n({total} total)', ha='center', fontsize=8)

# Add a horizontal line at 0%
ax2.axhline(y=0, color='gray', linewidth=0.5)

plt.tight_layout()
plt.savefig('viz_exclusion_map.png', dpi=150, bbox_inches='tight')
print("Saved viz_exclusion_map.png")
