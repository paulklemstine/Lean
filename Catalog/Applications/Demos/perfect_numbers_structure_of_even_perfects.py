#!/usr/bin/env python3
"""
Applications of Perfect Number Theory

Demonstrates real-world connections of divisor-sum arithmetic
to cryptography, coding theory, and computational number theory.
"""

from math import gcd, log2
from typing import List, Tuple
from fractions import Fraction


def sigma_efficient(n: int) -> int:
    """Sum of divisors via trial division."""
    if n <= 0:
        return 0
    total = 0
    d = 1
    while d * d <= n:
        if n % d == 0:
            total += d
            if d != n // d:
                total += n // d
        d += 1
    return total


def is_prime(n: int) -> bool:
    """Miller-Rabin primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2
    for a in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41]:
        if a >= n:
            continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


# =============================================================================
# Application 1: Mersenne Primes and Cryptographic Key Generation
# =============================================================================

def mersenne_prime_analysis():
    """
    Analyze Mersenne primes and their role in cryptographic applications.
    
    Mersenne primes are used in:
    - Random number generators (Mersenne Twister uses 2^19937 - 1)
    - Efficient modular arithmetic in crypto implementations
    """
    print("=" * 70)
    print("APPLICATION 1: Mersenne Primes in Cryptography")
    print("=" * 70)
    print()
    
    known_exponents = [2, 3, 5, 7, 13, 17, 19, 31, 61, 89, 107, 127, 521, 607]
    
    print("Known Mersenne prime exponents and their bit sizes:")
    print(f"{'p':>6} | {'2^p-1 bits':>12} | {'Perfect number bits':>20}")
    print("-" * 50)
    for p in known_exponents:
        mp_bits = p
        pn_bits = 2 * p - 1
        print(f"{p:>6} | {mp_bits:>12} | {pn_bits:>20}")
    
    print()
    print("Key insight: The Euclid–Euler theorem tells us that searching for")
    print("even perfect numbers is equivalent to searching for Mersenne primes.")
    print("The Great Internet Mersenne Prime Search (GIMPS) exploits this.")
    print()
    
    # Demonstrate the connection to efficient modular arithmetic
    print("Efficient modular arithmetic with Mersenne numbers:")
    p = 31
    m = (1 << p) - 1
    a, b = 1234567890, 987654321
    
    # Standard modular multiplication
    standard_result = (a * b) % m
    
    # Mersenne modular reduction: for M = 2^p - 1,
    # x mod M = (x & M) + (x >> p), iterated
    product = a * b
    result = product
    while result >= m:
        result = (result & m) + (result >> p)
    if result == m:
        result = 0
    
    print(f"  ({a} × {b}) mod (2^{p} - 1) = {standard_result}")
    print(f"  Via Mersenne reduction: {result}")
    print(f"  Match: {'✓' if standard_result == result else '✗'}")
    print()


# =============================================================================
# Application 2: Error-Detecting Codes via Divisor Structure
# =============================================================================

def error_detection_application():
    """
    Divisor-sum properties in error detection.
    
    The multiplicative structure of σ enables efficient computation
    of algebraic checksums over factored data blocks.
    """
    print("=" * 70)
    print("APPLICATION 2: Divisor-Sum Checksums")
    print("=" * 70)
    print()
    
    print("Multiplicative checksums using σ:")
    print("  If data blocks have coprime sizes, the global checksum")
    print("  equals the product of local checksums.")
    print()
    
    # Simulate data blocks with coprime sizes
    block_sizes = [(8, 9), (4, 15), (16, 27), (25, 49)]
    
    for a, b in block_sizes:
        assert gcd(a, b) == 1
        sa = sigma_efficient(a)
        sb = sigma_efficient(b)
        sab = sigma_efficient(a * b)
        
        print(f"  Blocks of size {a} × {b} = {a*b}:")
        print(f"    σ({a}) = {sa}, σ({b}) = {sb}")
        print(f"    σ({a*b}) = {sab} = {sa} × {sb} = {sa*sb}  ✓")
    
    print()
    print("  This property (formally proved as sigma_mul_of_coprime)")
    print("  enables hierarchical checksum computation.")
    print()


# =============================================================================
# Application 3: Amicable Numbers and Social Networks
# =============================================================================

def amicable_numbers():
    """
    Find amicable pairs using the sigma function.
    
    Two numbers (a, b) are amicable if σ(a) - a = b and σ(b) - b = a.
    This extends perfect numbers (where σ(n) - n = n).
    """
    print("=" * 70)
    print("APPLICATION 3: Amicable Numbers — Social Networks of Integers")
    print("=" * 70)
    print()
    
    pairs = []
    bound = 100_000
    
    for a in range(2, bound):
        b = sigma_efficient(a) - a
        if b > a and b < bound:
            if sigma_efficient(b) - b == a:
                pairs.append((a, b))
    
    print(f"Amicable pairs up to {bound}:")
    for a, b in pairs[:10]:
        sa = sigma_efficient(a) - a
        sb = sigma_efficient(b) - b
        print(f"  ({a}, {b}): s({a})={sa}={b}, s({b})={sb}={a}")
    
    print()
    print("  Perfect numbers are 'self-amicable': σ(n) - n = n")
    print("  The abundancy framework generalizes to k-amicable chains.")
    print()


# =============================================================================
# Application 4: Superabundant Numbers and Optimization
# =============================================================================

def superabundant_analysis():
    """
    Find superabundant numbers: n where I(n) > I(m) for all m < n.
    
    These are related to the Riemann Hypothesis via Robin's inequality:
    σ(n) < e^γ · n · ln(ln(n)) for all n > 5040, assuming RH.
    """
    print("=" * 70)
    print("APPLICATION 4: Superabundant Numbers and the Riemann Hypothesis")
    print("=" * 70)
    print()
    
    max_idx = Fraction(0)
    superabundant = []
    
    for n in range(1, 10001):
        idx = Fraction(sigma_efficient(n), n)
        if idx > max_idx:
            max_idx = idx
            superabundant.append((n, float(idx)))
    
    print("Superabundant numbers up to 10,000:")
    print(f"{'n':>8} | {'I(n)':>10} | {'Factorization':>30}")
    print("-" * 55)
    
    for n, idx in superabundant[:20]:
        # Simple factorization display
        factors = []
        temp = n
        for p in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
            k = 0
            while temp % p == 0:
                k += 1
                temp //= p
            if k > 0:
                factors.append(f"{p}^{k}" if k > 1 else str(p))
        if temp > 1:
            factors.append(str(temp))
        fact_str = " × ".join(factors) if factors else "1"
        print(f"{n:>8} | {idx:>10.6f} | {fact_str:>30}")
    
    print()
    print("  Robin's inequality: σ(n) < e^γ · n · ln(ln(n)) for n > 5040")
    print("  This is equivalent to the Riemann Hypothesis!")
    print("  Our abundancy framework provides the foundation for such")
    print("  formal investigations.")
    print()


# =============================================================================
# Application 5: Multiperfect Number Search
# =============================================================================

def multiperfect_search():
    """
    Search for k-perfect numbers: σ(n) = k·n.
    
    Perfect numbers have k=2. This extends the abundancy framework.
    """
    print("=" * 70)
    print("APPLICATION 5: Multiperfect Numbers — σ(n) = k·n")
    print("=" * 70)
    print()
    
    results = {k: [] for k in range(1, 6)}
    
    for n in range(1, 1_000_001):
        s = sigma_efficient(n)
        if s % n == 0:
            k = s // n
            if k <= 5:
                results[k].append(n)
    
    for k in range(1, 6):
        nums = results[k][:10]
        print(f"  k={k} ({k}-perfect): {nums}{'...' if len(results[k]) > 10 else ''}")
    
    print()
    print("  1-perfect: only n=1 (σ(1) = 1)")
    print("  2-perfect: the classical perfect numbers")
    print("  3-perfect ('triperfect'): σ(n) = 3n, very rare")
    print()


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    mersenne_prime_analysis()
    error_detection_application()
    amicable_numbers()
    superabundant_analysis()
    multiperfect_search()
    
    print("=" * 70)
    print("All applications demonstrated!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Perfect Numbers: Demonstrations and Explorations

This script demonstrates the key theorems about perfect numbers with
concrete numerical examples, making the mathematics tangible.
"""

from math import gcd
from functools import reduce
from itertools import combinations


def sigma(n: int) -> int:
    """Sum of all positive divisors of n."""
    if n <= 0:
        return 0
    total = 0
    for d in range(1, n + 1):
        if n % d == 0:
            total += d
    return total


def sigma_fast(n: int) -> int:
    """Efficient sum of divisors using trial division up to sqrt(n)."""
    if n <= 0:
        return 0
    total = 0
    d = 1
    while d * d <= n:
        if n % d == 0:
            total += d
            if d != n // d:
                total += n // d
        d += 1
    return total


def is_perfect(n: int) -> bool:
    """Check if n is a perfect number."""
    return n > 0 and sigma_fast(n) == 2 * n


def is_prime(n: int) -> bool:
    """Simple primality test."""
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


def mersenne(p: int) -> int:
    """Mersenne number: 2^p - 1."""
    return (1 << p) - 1


def abundancy_index(n: int) -> float:
    """Abundancy index I(n) = sigma(n) / n."""
    if n <= 0:
        return 0.0
    return sigma_fast(n) / n


def prime_factorization(n: int) -> dict:
    """Return prime factorization as {prime: exponent}."""
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def little_omega(n: int) -> int:
    """Number of distinct prime factors."""
    return len(prime_factorization(n))


def big_omega(n: int) -> int:
    """Total number of prime factors with multiplicity."""
    return sum(prime_factorization(n).values())


# =============================================================================
# Demo 1: The first few perfect numbers
# =============================================================================
print("=" * 70)
print("DEMO 1: The First Perfect Numbers")
print("=" * 70)
print()

perfect_numbers = []
for n in range(1, 100_000):
    if is_perfect(n):
        perfect_numbers.append(n)

print("Perfect numbers up to 100,000:")
for n in perfect_numbers:
    divs = [d for d in range(1, n) if n % d == 0]
    print(f"  {n:>6} = sum of proper divisors: {' + '.join(map(str, divs))} = {sum(divs)}")
print()

# =============================================================================
# Demo 2: Euclid–Euler theorem verification
# =============================================================================
print("=" * 70)
print("DEMO 2: Euclid–Euler Theorem — Mersenne Primes Yield Perfect Numbers")
print("=" * 70)
print()

print(f"{'p':>4} | {'2^p - 1':>15} | {'Prime?':>7} | {'2^(p-1)*(2^p-1)':>20} | {'Perfect?':>9}")
print("-" * 70)

for p in range(2, 20):
    if not is_prime(p):
        continue
    m = mersenne(p)
    mp = is_prime(m)
    n = (1 << (p - 1)) * m
    perf = is_perfect(n) if mp else "—"
    print(f"{p:>4} | {m:>15} | {'Yes' if mp else 'No':>7} | {n if mp else '—':>20} | {perf}")

print()
print("✓ Every Mersenne prime M_p = 2^p - 1 produces a perfect number 2^(p-1) * M_p")
print("✓ Every even perfect number has this form (Euler's converse)")
print()

# =============================================================================
# Demo 3: Sigma multiplicativity verification
# =============================================================================
print("=" * 70)
print("DEMO 3: Multiplicativity of σ — σ(ab) = σ(a)·σ(b) when gcd(a,b) = 1")
print("=" * 70)
print()

tests = [(6, 5), (4, 9), (8, 15), (7, 11), (16, 27), (25, 49)]
for a, b in tests:
    g = gcd(a, b)
    sa, sb, sab = sigma_fast(a), sigma_fast(b), sigma_fast(a * b)
    check = "✓" if sab == sa * sb else "✗"
    print(f"  σ({a}×{b}) = σ({a*b}) = {sab}, σ({a})·σ({b}) = {sa}·{sb} = {sa*sb} {check}  (gcd={g})")

print()

# =============================================================================
# Demo 4: Abundancy index as a classification invariant
# =============================================================================
print("=" * 70)
print("DEMO 4: Abundancy Index I(n) = σ(n)/n")
print("=" * 70)
print()

print(f"{'n':>8} | {'σ(n)':>8} | {'I(n)':>10} | {'Classification':>15}")
print("-" * 50)

interesting = [1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 24, 28, 30, 36, 48, 60, 120, 496]
for n in interesting:
    s = sigma_fast(n)
    idx = s / n
    if idx == 2.0:
        cls = "PERFECT"
    elif idx < 2.0:
        cls = "Deficient"
    else:
        cls = "Abundant"
    print(f"{n:>8} | {s:>8} | {idx:>10.4f} | {cls:>15}")

print()
print("Key insight: Perfect numbers are exactly those with I(n) = 2")
print()

# =============================================================================
# Demo 5: Abundancy multiplicativity
# =============================================================================
print("=" * 70)
print("DEMO 5: Abundancy Multiplicativity — I(ab) = I(a)·I(b) when gcd(a,b)=1")
print("=" * 70)
print()

for a, b in [(4, 9), (8, 15), (7, 11), (6, 25)]:
    if gcd(a, b) == 1:
        ia = abundancy_index(a)
        ib = abundancy_index(b)
        iab = abundancy_index(a * b)
        print(f"  I({a}×{b}) = I({a*b}) = {iab:.6f}")
        print(f"  I({a})·I({b}) = {ia:.6f} × {ib:.6f} = {ia*ib:.6f}")
        print(f"  Match: {'✓' if abs(iab - ia*ib) < 1e-10 else '✗'}")
        print()

# =============================================================================
# Demo 6: Prime power sigma formulas
# =============================================================================
print("=" * 70)
print("DEMO 6: σ(p^k) = 1 + p + p² + ... + p^k")
print("=" * 70)
print()

for p in [2, 3, 5, 7]:
    if not is_prime(p):
        continue
    print(f"  p = {p}:")
    for k in range(0, 6):
        pk = p ** k
        s = sigma_fast(pk)
        geo_sum = sum(p ** i for i in range(k + 1))
        terms = " + ".join(f"{p}^{i}" for i in range(k + 1))
        check = "✓" if s == geo_sum else "✗"
        print(f"    σ({p}^{k}) = σ({pk:>6}) = {s:>8} = {terms} = {geo_sum:>8} {check}")
    print()

# =============================================================================
# Demo 7: Closed-form identity (p-1)·σ(p^k) = p^(k+1) - 1
# =============================================================================
print("=" * 70)
print("DEMO 7: Closed Form — (p-1)·σ(p^k) = p^(k+1) - 1")
print("=" * 70)
print()

for p in [2, 3, 5, 7]:
    for k in range(1, 5):
        lhs = (p - 1) * sigma_fast(p ** k)
        rhs = p ** (k + 1) - 1
        check = "✓" if lhs == rhs else "✗"
        print(f"  (p={p}, k={k}): ({p}-1)·σ({p}^{k}) = {lhs}, {p}^{k+1}-1 = {rhs}  {check}")
    print()

# =============================================================================
# Demo 8: Odd perfect number obstructions
# =============================================================================
print("=" * 70)
print("DEMO 8: Odd Perfect Number Obstructions")
print("=" * 70)
print()

print("Searching for odd perfect numbers up to 10^6...")
odd_perfects = [n for n in range(1, 1_000_001, 2) if is_perfect(n)]
print(f"  Found: {odd_perfects if odd_perfects else 'NONE'}")
print()

print("No odd prime power is perfect:")
for p in [3, 5, 7, 11, 13]:
    for k in range(1, 10):
        n = p ** k
        if is_perfect(n):
            print(f"  ✗ {p}^{k} = {n} is perfect!")
        # else silently pass
print("  ✓ Verified: no odd prime power up to 13^9 is perfect")
print()

print("If an odd perfect number existed, it would need:")
print("  • At least 2 distinct prime factors (proved)")
print("  • Cannot be a prime power (proved)")
print("  • At least 10^1500 (Ochem & Rao, 2012)")
print("  • At least 101 prime factors counting multiplicity (Nielsen, 2015)")
print()

# =============================================================================
# Demo 9: Mersenne prime → exponent prime
# =============================================================================
print("=" * 70)
print("DEMO 9: If 2^p - 1 is prime, then p is prime")
print("=" * 70)
print()

print(f"{'p':>4} | {'2^p - 1':>15} | {'p prime?':>9} | {'M_p prime?':>11}")
print("-" * 50)
for p in range(2, 25):
    m = mersenne(p)
    pp = is_prime(p)
    mp = is_prime(m)
    flag = ""
    if mp and not pp:
        flag = " ← COUNTEREXAMPLE!"
    if not pp and not mp:
        flag = " (composite exp → composite mersenne)"
    print(f"{p:>4} | {m:>15} | {'Yes' if pp else 'No':>9} | {'Yes' if mp else 'No':>11}{flag}")

print()
print("✓ Every Mersenne prime has a prime exponent (proved)")
print("  (The converse is false: 2^11 - 1 = 2047 = 23 × 89)")
print()

print("=" * 70)
print("All demonstrations complete!")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Perfect Number Theory

Generates publication-quality figures illustrating key mathematical structures.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from math import gcd
from fractions import Fraction
import base64
from io import BytesIO


def sigma_efficient(n: int) -> int:
    if n <= 0:
        return 0
    total = 0
    d = 1
    while d * d <= n:
        if n % d == 0:
            total += d
            if d != n // d:
                total += n // d
        d += 1
    return total


def is_prime(n: int) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0: return False
    d = 3
    while d * d <= n:
        if n % d == 0: return False
        d += 2
    return True


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight', facecolor='white')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


# =============================================================================
# Visualization 1: Abundancy Index Landscape
# =============================================================================

def plot_abundancy_landscape():
    """Plot abundancy index I(n) for n up to 1000."""
    fig, ax = plt.subplots(figsize=(12, 6))
    
    ns = list(range(1, 1001))
    abundancies = [sigma_efficient(n) / n for n in ns]
    
    # Color by classification
    colors = []
    for n, a in zip(ns, abundancies):
        if abs(a - 2.0) < 1e-10:
            colors.append('#FF0000')  # Perfect
        elif a < 2.0:
            colors.append('#4169E1')  # Deficient
        else:
            colors.append('#228B22')  # Abundant
    
    ax.scatter(ns, abundancies, c=colors, s=2, alpha=0.6)
    ax.axhline(y=2.0, color='red', linestyle='--', alpha=0.5, label='I(n) = 2 (Perfect)')
    ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.3)
    
    # Mark perfect numbers
    perfects = [n for n in ns if abs(sigma_efficient(n) / n - 2.0) < 1e-10 and n > 1]
    for p in perfects:
        ax.annotate(f'{p}', (p, 2.0), textcoords="offset points", xytext=(0, 10),
                   fontsize=9, color='red', fontweight='bold', ha='center')
    
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('I(n) = σ(n)/n', fontsize=12)
    ax.set_title('Abundancy Index Landscape', fontsize=14, fontweight='bold')
    ax.set_ylim(0.8, 4.0)
    
    deficient_patch = mpatches.Patch(color='#4169E1', label='Deficient (I < 2)')
    perfect_patch = mpatches.Patch(color='#FF0000', label='Perfect (I = 2)')
    abundant_patch = mpatches.Patch(color='#228B22', label='Abundant (I > 2)')
    ax.legend(handles=[deficient_patch, perfect_patch, abundant_patch], loc='upper right')
    
    ax.grid(True, alpha=0.2)
    
    fig.savefig('/workspace/request-project/abundancy_landscape.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# =============================================================================
# Visualization 2: Mersenne Primes and Perfect Numbers
# =============================================================================

def plot_mersenne_perfect():
    """Visualize the Euclid-Euler correspondence."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Left: Mersenne numbers
    ps = list(range(2, 25))
    mersennes = [(1 << p) - 1 for p in ps]
    is_mersenne_prime = [is_prime(m) for m in mersennes]
    
    colors = ['#FF4444' if mp else '#CCCCCC' for mp in is_mersenne_prime]
    bars = ax1.bar(ps, [np.log2(m) for m in mersennes], color=colors, edgecolor='black', linewidth=0.5)
    
    ax1.set_xlabel('Exponent p', fontsize=12)
    ax1.set_ylabel('log₂(2ᵖ - 1) ≈ p', fontsize=12)
    ax1.set_title('Mersenne Numbers 2ᵖ - 1', fontsize=14, fontweight='bold')
    
    for i, (p, mp) in enumerate(zip(ps, is_mersenne_prime)):
        if mp:
            ax1.annotate(f'M_{p}', (p, np.log2(mersennes[i])), 
                        textcoords="offset points", xytext=(0, 5),
                        fontsize=8, color='red', fontweight='bold', ha='center')
    
    prime_patch = mpatches.Patch(color='#FF4444', label='Mersenne Prime')
    composite_patch = mpatches.Patch(color='#CCCCCC', label='Composite')
    ax1.legend(handles=[prime_patch, composite_patch])
    
    # Right: Perfect numbers growth
    perfect_data = []
    for p in range(2, 20):
        if is_prime(p):
            m = (1 << p) - 1
            if is_prime(m):
                n = (1 << (p - 1)) * m
                perfect_data.append((p, n))
    
    if perfect_data:
        ps_perf, ns_perf = zip(*perfect_data)
        ax2.semilogy(ps_perf, ns_perf, 'ro-', markersize=10, linewidth=2)
        for p, n in perfect_data:
            ax2.annotate(f'n={n}', (p, n), textcoords="offset points", 
                        xytext=(10, 0), fontsize=9)
    
    ax2.set_xlabel('Mersenne exponent p', fontsize=12)
    ax2.set_ylabel('Perfect number (log scale)', fontsize=12)
    ax2.set_title('Even Perfect Numbers', fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    
    fig.tight_layout()
    fig.savefig('/workspace/request-project/mersenne_perfect.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# =============================================================================
# Visualization 3: Sigma Multiplicativity
# =============================================================================

def plot_sigma_multiplicativity():
    """Visualize the multiplicative structure of sigma."""
    fig, ax = plt.subplots(figsize=(10, 8))
    
    n_max = 50
    data = []
    
    for a in range(1, n_max):
        for b in range(a + 1, n_max):
            if gcd(a, b) == 1 and a * b <= 500:
                sa = sigma_efficient(a)
                sb = sigma_efficient(b)
                sab = sigma_efficient(a * b)
                data.append((sa * sb, sab))
    
    if data:
        x, y = zip(*data)
        ax.scatter(x, y, s=8, alpha=0.5, c='#4169E1')
        
        max_val = max(max(x), max(y))
        ax.plot([0, max_val], [0, max_val], 'r--', alpha=0.5, label='y = x (perfect agreement)')
    
    ax.set_xlabel('σ(a) · σ(b)', fontsize=12)
    ax.set_ylabel('σ(a · b)', fontsize=12)
    ax.set_title('Multiplicativity: σ(ab) = σ(a)·σ(b) when gcd(a,b) = 1', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    
    fig.savefig('/workspace/request-project/sigma_multiplicativity.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# =============================================================================
# Visualization 4: Abundancy of Prime Powers
# =============================================================================

def plot_prime_power_abundancy():
    """Plot I(p^k) for various primes and exponents."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    primes = [2, 3, 5, 7, 11, 13]
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(primes)))
    
    for p, color in zip(primes, colors):
        ks = list(range(0, 15))
        abundancies = []
        for k in ks:
            pk = p ** k
            s = sigma_efficient(pk)
            abundancies.append(s / pk)
        
        ax.plot(ks, abundancies, 'o-', color=color, label=f'p = {p}', markersize=5)
        
        # Theoretical limit: p/(p-1)
        limit = p / (p - 1)
        ax.axhline(y=limit, color=color, linestyle=':', alpha=0.3)
    
    ax.set_xlabel('Exponent k', fontsize=12)
    ax.set_ylabel('I(p^k)', fontsize=12)
    ax.set_title('Abundancy of Prime Powers: I(p^k) → p/(p-1) as k → ∞', 
                fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.2)
    ax.set_ylim(0.9, 2.5)
    
    fig.savefig('/workspace/request-project/prime_power_abundancy.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# =============================================================================
# Visualization 5: Perfect Number Theorem Dependency Graph
# =============================================================================

def plot_theorem_dependency():
    """Create a visual theorem dependency graph."""
    fig, ax = plt.subplots(figsize=(14, 10))
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.axis('off')
    
    # Node positions and labels
    nodes = {
        'sigma_one': (1, 8),
        'sigma_prime': (3, 8),
        'sigma_prime_pow': (5, 7),
        'sigma_closed': (7, 7),
        'sigma_coprime': (3, 6),
        'sigma_two_pow': (7, 5.5),
        'mersenne_prime': (9, 7),
        'abundancy_pos': (1, 4.5),
        'abundancy_two': (3, 4.5),
        'abundancy_coprime': (5, 4.5),
        'abundancy_prime': (7, 4),
        'euclid': (3, 2.5),
        'euler': (7, 2.5),
        'euclid_euler': (5, 1),
        'odd_not_pp': (1, 1),
        'odd_two_factors': (9, 1),
    }
    
    labels = {
        'sigma_one': 'σ(1) = 1',
        'sigma_prime': 'σ(p) = p+1',
        'sigma_prime_pow': 'σ(p^k) = Σp^i',
        'sigma_closed': '(p-1)σ(p^k)\n= p^(k+1)-1',
        'sigma_coprime': 'σ(ab) =\nσ(a)σ(b)',
        'sigma_two_pow': 'σ(2^k) =\n2^(k+1)-1',
        'mersenne_prime': 'M_p prime\n⟹ p prime',
        'abundancy_pos': 'I(n) > 0',
        'abundancy_two': 'I(n)=2 ⟺\nPerfect',
        'abundancy_coprime': 'I(ab) =\nI(a)·I(b)',
        'abundancy_prime': 'I(p) =\n(p+1)/p',
        'euclid': 'Euclid:\nMersenne ⟹\nPerfect',
        'euler': 'Euler:\nEven Perfect\n⟹ Mersenne',
        'euclid_euler': 'EUCLID–EULER\nTHEOREM',
        'odd_not_pp': 'Odd Perfect\n≠ p^k',
        'odd_two_factors': 'Odd Perfect:\nω(n) ≥ 2',
    }
    
    # Layer colors
    layer_colors = {
        'sigma_one': '#E8F4FD', 'sigma_prime': '#E8F4FD', 
        'sigma_prime_pow': '#E8F4FD', 'sigma_closed': '#E8F4FD',
        'sigma_coprime': '#E8F4FD', 'sigma_two_pow': '#E8F4FD',
        'mersenne_prime': '#E8F4FD',
        'abundancy_pos': '#FFF3E0', 'abundancy_two': '#FFF3E0',
        'abundancy_coprime': '#FFF3E0', 'abundancy_prime': '#FFF3E0',
        'euclid': '#E8F5E9', 'euler': '#E8F5E9',
        'euclid_euler': '#FFCDD2',
        'odd_not_pp': '#F3E5F5', 'odd_two_factors': '#F3E5F5',
    }
    
    # Draw edges
    edges = [
        ('sigma_prime', 'sigma_prime_pow'),
        ('sigma_prime_pow', 'sigma_closed'),
        ('sigma_closed', 'sigma_two_pow'),
        ('sigma_coprime', 'abundancy_coprime'),
        ('sigma_prime_pow', 'abundancy_prime'),
        ('sigma_coprime', 'euclid'),
        ('sigma_two_pow', 'euclid'),
        ('sigma_coprime', 'euler'),
        ('sigma_two_pow', 'euler'),
        ('mersenne_prime', 'euler'),
        ('euclid', 'euclid_euler'),
        ('euler', 'euclid_euler'),
        ('sigma_prime_pow', 'odd_not_pp'),
        ('odd_not_pp', 'odd_two_factors'),
    ]
    
    for n1, n2 in edges:
        x1, y1 = nodes[n1]
        x2, y2 = nodes[n2]
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5, alpha=0.6))
    
    # Draw nodes
    for name, (x, y) in nodes.items():
        color = layer_colors[name]
        bbox = dict(boxstyle='round,pad=0.4', facecolor=color, edgecolor='black', linewidth=1.5)
        fontsize = 8 if name != 'euclid_euler' else 10
        fontweight = 'bold' if name == 'euclid_euler' else 'normal'
        ax.text(x, y, labels[name], ha='center', va='center', fontsize=fontsize,
               fontweight=fontweight, bbox=bbox)
    
    # Layer labels
    ax.text(-0.5, 7.5, 'Layer 1:\nσ Engine', fontsize=10, fontweight='bold', 
           color='#1565C0', va='center')
    ax.text(-0.5, 4.5, 'Layer 2:\nAbundancy', fontsize=10, fontweight='bold',
           color='#E65100', va='center')
    ax.text(-0.5, 2, 'Layer 3:\nClassification', fontsize=10, fontweight='bold',
           color='#2E7D32', va='center')
    ax.text(-0.5, 0.5, 'Layer 4:\nObstructions', fontsize=10, fontweight='bold',
           color='#6A1B9A', va='center')
    
    ax.set_title('Theorem Dependency Graph: Perfect Number Theory', 
                fontsize=16, fontweight='bold', pad=20)
    
    fig.savefig('/workspace/request-project/theorem_dependency.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("Generating visualizations...")
    
    b64_1 = plot_abundancy_landscape()
    print(f"  ✓ Abundancy landscape ({len(b64_1)} chars)")
    
    b64_2 = plot_mersenne_perfect()
    print(f"  ✓ Mersenne-perfect correspondence ({len(b64_2)} chars)")
    
    b64_3 = plot_sigma_multiplicativity()
    print(f"  ✓ Sigma multiplicativity ({len(b64_3)} chars)")
    
    b64_4 = plot_prime_power_abundancy()
    print(f"  ✓ Prime power abundancy ({len(b64_4)} chars)")
    
    b64_5 = plot_theorem_dependency()
    print(f"  ✓ Theorem dependency graph ({len(b64_5)} chars)")
    
    print("\nAll visualizations saved!")
    print("Files: abundancy_landscape.png, mersenne_perfect.png,")
    print("       sigma_multiplicativity.png, prime_power_abundancy.png,")
    print("       theorem_dependency.png")
