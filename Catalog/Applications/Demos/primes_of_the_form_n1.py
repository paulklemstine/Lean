#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations for primes of the form n² + 1.

Demonstrates:
1. Counting primes of the form n² + 1
2. Verifying the mod-4 constraint on prime divisors
3. Computing the Hardy-Littlewood constant
4. Finding semi-primes of the form n² + 1
5. Bateman-Horn prediction accuracy
"""

from math import log, sqrt, prod
from typing import List, Tuple


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


def sieve_primes(limit: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, v in enumerate(sieve) if v]


def prime_factorization(n: int) -> List[int]:
    """Return list of prime factors with multiplicity."""
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def count_nsq_plus_one_primes(N: int) -> int:
    """Count n < N such that n² + 1 is prime."""
    return sum(1 for n in range(N) if is_prime(n * n + 1))


def demo_basic_properties():
    """Demonstrate basic properties of n² + 1."""
    print("=" * 60)
    print("DEMO 1: Basic Properties of n² + 1")
    print("=" * 60)

    print("\nFirst 30 values of n² + 1 and their primality:")
    print(f"{'n':>4} {'n²+1':>8} {'Prime?':>8} {'Factors':>20}")
    print("-" * 44)
    for n in range(30):
        val = n * n + 1
        p = is_prime(val)
        factors = prime_factorization(val)
        print(f"{n:4d} {val:8d} {'  YES' if p else '   no':>8} {str(factors):>20}")

    print("\nVerification: 3 never divides n² + 1:")
    violations = [n for n in range(10000) if (n * n + 1) % 3 == 0]
    print(f"  Violations in n < 10000: {len(violations)} (expected: 0)")

    print("\nVerification: n² + 1 is never a perfect square for n ≥ 1:")
    squares = set(i * i for i in range(10001))
    sq_violations = [n for n in range(1, 10000) if (n * n + 1) in squares]
    print(f"  Violations in 1 ≤ n < 10000: {len(sq_violations)} (expected: 0)")


def demo_mod4_constraint():
    """Demonstrate that all odd prime divisors of n² + 1 are ≡ 1 (mod 4)."""
    print("\n" + "=" * 60)
    print("DEMO 2: Mod-4 Constraint on Prime Divisors")
    print("=" * 60)

    # Collect all odd prime divisors
    odd_prime_divisors_mod4 = {1: set(), 3: set()}
    for n in range(100000):
        val = n * n + 1
        for p in set(prime_factorization(val)):
            if p > 2:
                odd_prime_divisors_mod4[p % 4].add(p)

    print(f"\nOdd prime divisors of n² + 1 for n < 100000:")
    print(f"  Primes ≡ 1 (mod 4): {len(odd_prime_divisors_mod4[1])} found")
    print(f"  Primes ≡ 3 (mod 4): {len(odd_prime_divisors_mod4[3])} found (should be 0)")
    print(f"\n  First 20 primes ≡ 1 (mod 4) that divide some n²+1:")
    sorted_1mod4 = sorted(odd_prime_divisors_mod4[1])[:20]
    print(f"  {sorted_1mod4}")


def demo_hardy_littlewood():
    """Compute and verify Hardy-Littlewood constant for n² + 1."""
    print("\n" + "=" * 60)
    print("DEMO 3: Hardy-Littlewood Constant & Predictions")
    print("=" * 60)

    # Compute the constant using first many primes
    primes = sieve_primes(100000)
    C = 1.0
    for p in primes:
        if p == 2:
            continue
        if p % 4 == 1:
            C *= 1 - 1.0 / (p - 1)
        else:
            C *= 1 + 1.0 / (p - 1)

    print(f"\nHardy-Littlewood constant C ≈ {C:.6f}")
    print(f"(Using product over odd primes up to {primes[-1]})")

    print(f"\n{'N':>10} {'Actual':>10} {'Predicted':>12} {'Ratio':>8}")
    print("-" * 44)
    for exp in range(2, 7):
        N = 10 ** exp
        actual = count_nsq_plus_one_primes(N)
        if N > 2:
            predicted = C * N / log(N)
        else:
            predicted = 0
        ratio = actual / predicted if predicted > 0 else 0
        print(f"{N:10d} {actual:10d} {predicted:12.1f} {ratio:8.4f}")


def demo_semiprimes():
    """Find semi-primes of the form n² + 1."""
    print("\n" + "=" * 60)
    print("DEMO 4: Semi-primes of the Form n² + 1")
    print("=" * 60)

    semiprimes = []
    for n in range(2, 1000):
        val = n * n + 1
        factors = prime_factorization(val)
        if len(factors) == 2:
            semiprimes.append((n, val, factors))

    print(f"\nFirst 20 semi-primes of the form n² + 1:")
    print(f"{'n':>6} {'n²+1':>10} {'Factorization':>20}")
    print("-" * 40)
    for n, val, factors in semiprimes[:20]:
        print(f"{n:6d} {val:10d} {factors[0]:>8d} × {factors[1]}")

    # Count by number of prime factors
    print(f"\nDistribution of Ω(n² + 1) for n < 1000:")
    omega_counts = {}
    for n in range(1000):
        val = n * n + 1
        omega = len(prime_factorization(val))
        omega_counts[omega] = omega_counts.get(omega, 0) + 1

    for k in sorted(omega_counts):
        print(f"  Ω = {k}: {omega_counts[k]} values")


def demo_friedlander_iwaniec():
    """Demonstrate the connection to a² + b⁴."""
    print("\n" + "=" * 60)
    print("DEMO 5: Friedlander-Iwaniec Set {a² + b⁴}")
    print("=" * 60)

    # Find primes of the form a² + b⁴
    fi_primes = set()
    bound = 100000
    b = 1
    while b ** 4 < bound:
        a = 0
        while a * a + b ** 4 < bound:
            val = a * a + b ** 4
            if is_prime(val):
                fi_primes.add(val)
            a += 1
        b += 1

    # Primes of the form n² + 1 (special case b=1)
    nsq_primes = set()
    n = 0
    while n * n + 1 < bound:
        if is_prime(n * n + 1):
            nsq_primes.add(n * n + 1)
        n += 1

    print(f"\nPrimes < {bound}:")
    print(f"  Of the form a² + b⁴: {len(fi_primes)}")
    print(f"  Of the form n² + 1:  {len(nsq_primes)}")
    print(f"  Ratio (n²+1)/(a²+b⁴): {len(nsq_primes)/len(fi_primes):.4f}")
    print(f"\n  All n²+1 primes are in FI set: {nsq_primes.issubset(fi_primes)}")


if __name__ == "__main__":
    demo_basic_properties()
    demo_mod4_constraint()
    demo_hardy_littlewood()
    demo_semiprimes()
    demo_friedlander_iwaniec()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Distribution of primes of the form n² + 1.
Standalone script using matplotlib.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import log, isqrt


def sieve_primes(limit):
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, isqrt(limit) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, v in enumerate(sieve) if v]


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def bateman_horn_constant(num_primes=5000):
    primes = sieve_primes(num_primes * 15)
    C = 1.0
    count = 0
    for p in primes:
        if p == 2: continue
        if p % 4 == 1:
            C *= 1 - 1.0 / (p - 1)
        else:
            C *= 1 + 1.0 / (p - 1)
        count += 1
        if count >= num_primes: break
    return C


def main():
    N = 50000
    C = bateman_horn_constant()

    # Compute cumulative count
    ns = list(range(N))
    cumulative = []
    count = 0
    for n in ns:
        if is_prime(n * n + 1):
            count += 1
        cumulative.append(count)

    # Hardy-Littlewood prediction
    predictions = [C * n / log(n) if n > 2 else 0 for n in ns]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Cumulative count vs prediction
    ax1 = axes[0, 0]
    ax1.plot(ns[10:], cumulative[10:], 'b-', linewidth=0.8, label=r'Actual $\pi_{n^2+1}(x)$')
    ax1.plot(ns[10:], predictions[10:], 'r--', linewidth=1.2, label=r'$C \cdot x / \ln x$')
    ax1.set_xlabel('N')
    ax1.set_ylabel('Count')
    ax1.set_title(r'Primes of the form $n^2 + 1$: Counting function')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Ratio actual/predicted
    ax2 = axes[0, 1]
    ratios = [cumulative[i] / predictions[i] if predictions[i] > 0 else 0 for i in range(len(ns))]
    ax2.plot(ns[100:], ratios[100:], 'g-', linewidth=0.5)
    ax2.axhline(y=1.0, color='r', linestyle='--', linewidth=1)
    ax2.set_xlabel('N')
    ax2.set_ylabel('Ratio')
    ax2.set_title(r'Ratio $\pi_{n^2+1}(N) / (C \cdot N / \ln N)$')
    ax2.set_ylim(0.8, 1.2)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Mod-4 distribution of prime divisors
    ax3 = axes[1, 0]
    mod4_counts = {1: 0, 3: 0}
    prime_divisors_seen = set()
    for n in range(N):
        val = n * n + 1
        d = 2
        temp = val
        while d * d <= temp:
            if temp % d == 0:
                if d > 2 and d not in prime_divisors_seen:
                    prime_divisors_seen.add(d)
                    mod4_counts[d % 4] += 1
                while temp % d == 0:
                    temp //= d
            d += 1
        if temp > 2 and temp not in prime_divisors_seen:
            prime_divisors_seen.add(temp)
            mod4_counts[temp % 4] += 1

    bars = ax3.bar(['p ≡ 1 (mod 4)', 'p ≡ 3 (mod 4)'],
                   [mod4_counts[1], mod4_counts[3]],
                   color=['steelblue', 'coral'])
    ax3.set_title(r'Odd prime divisors of $n^2+1$ by residue mod 4')
    ax3.set_ylabel('Count of distinct primes')
    for bar, val in zip(bars, [mod4_counts[1], mod4_counts[3]]):
        ax3.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 5,
                str(val), ha='center', va='bottom', fontweight='bold')

    # Plot 4: Gap distribution between consecutive n with n²+1 prime
    ax4 = axes[1, 1]
    prime_ns = [n for n in range(N) if is_prime(n * n + 1)]
    gaps = [prime_ns[i+1] - prime_ns[i] for i in range(len(prime_ns) - 1)]
    ax4.hist(gaps, bins=range(1, max(gaps[:1000]) + 2), density=True, alpha=0.7, color='purple')
    ax4.set_xlabel('Gap between consecutive n')
    ax4.set_ylabel('Density')
    ax4.set_title(r'Gap distribution between consecutive $n$ with $n^2+1$ prime')
    ax4.set_xlim(0, 50)
    ax4.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('nsq_plus_one_primes.png', dpi=150, bbox_inches='tight')
    print("Saved: nsq_plus_one_primes.png")


if __name__ == "__main__":
    main()
