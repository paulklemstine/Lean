#!/usr/bin/env python3
"""
Carmichael's Primitive Divisor Theorem — Interactive Demo

Demonstrates that every Fibonacci number F(n) with n > 12 has a
"primitive" prime divisor: a prime p that divides F(n) but does NOT
divide F(k) for any 0 < k < n.
"""

import math
import sys

# ─── Fibonacci (iterative) ──────────────────────────────────────────

_fib_cache = {0: 0, 1: 1}

def fib(n):
    if n in _fib_cache:
        return _fib_cache[n]
    for i in range(2, n + 1):
        if i not in _fib_cache:
            _fib_cache[i] = _fib_cache[i-1] + _fib_cache[i-2]
    return _fib_cache[n]

# ─── Number theory helpers ──────────────────────────────────────────

def prime_factors(n):
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

def divisors(n):
    divs = set()
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            divs.add(d)
            divs.add(n // d)
    return sorted(divs)

def entry_point(p, max_k=500):
    """Smallest k > 0 with p | F(k), using modular arithmetic."""
    if p <= 1:
        return None
    a, b = 0, 1  # F(0), F(1) mod p
    for k in range(1, max_k + 1):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None

def find_primitive_primes(n, max_n=200):
    """Find all primitive prime divisors of F(n)."""
    fn = fib(n)
    if fn <= 1:
        return []
    pf = prime_factors(fn)
    proper_divs = [d for d in divisors(n) if 0 < d < n]
    primitive = []
    for p in pf:
        is_prim = all(fib(d) % p != 0 for d in proper_divs)
        if is_prim:
            primitive.append(p)
    return primitive

# ─── Main demo ──────────────────────────────────────────────────────

def demo():
    # Precompute Fibonacci numbers
    for i in range(201):
        fib(i)

    print("=" * 72)
    print("  CARMICHAEL'S PRIMITIVE DIVISOR THEOREM FOR FIBONACCI NUMBERS")
    print("=" * 72)
    print()
    print("Theorem (Carmichael, 1913): For every n > 12, F(n) has at least")
    print("one primitive prime divisor — a prime p dividing F(n) that does")
    print("NOT divide F(k) for any 0 < k < n.")
    print()

    # Exceptions
    print("─" * 72)
    print("EXCEPTIONS (n ≤ 12 where F(n) > 1 but no primitive divisor):")
    print("─" * 72)
    for n in range(1, 13):
        fn = fib(n)
        if fn <= 1:
            continue
        prims = find_primitive_primes(n)
        if not prims:
            pf = prime_factors(fn)
            eps = {p: entry_point(p) for p in pf}
            info = ", ".join(f"{p} (enters at F({eps[p]}))" for p in sorted(pf))
            print(f"  n={n:2d}: F({n}) = {fn}, factors: {info}")

    # Verification table
    print()
    print("─" * 72)
    print("VERIFICATION for n = 13..35:")
    print("─" * 72)
    print(f"{'n':>3s}  {'F(n)':>12s}  {'Factorization':>28s}  {'Primitive':>18s}")
    print("─" * 72)
    for n in range(13, 36):
        fn = fib(n)
        pf = prime_factors(fn)
        prims = find_primitive_primes(n)
        fact = " · ".join(f"{p}^{e}" if e > 1 else str(p) for p, e in sorted(pf.items()))
        prim_str = ", ".join(map(str, sorted(prims)))
        print(f"{n:3d}  {fn:12d}  {fact:>28s}  {prim_str:>18s}")

    # Entry point examples
    print()
    print("─" * 72)
    print("ENTRY POINTS of small primes:")
    print("─" * 72)
    print("α(p) = smallest k > 0 with p | F(k)")
    print()
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    for p in primes:
        ep = entry_point(p)
        print(f"  α({p:2d}) = {ep:3d}   →  p is primitive for F({ep})")

    # Why n=12 fails
    print()
    print("─" * 72)
    print("WHY n = 12 IS THE LAST EXCEPTION:")
    print("─" * 72)
    print(f"  F(12) = 144 = 2⁴ · 3²")
    print(f"  • 2 first divides F(3) = 2  →  α(2) = 3 ≠ 12")
    print(f"  • 3 first divides F(4) = 3  →  α(3) = 4 ≠ 12")
    print(f"  Both primes enter before index 12. No primitive divisor!")
    print()
    print(f"  F(13) = 233 (prime)")
    print(f"  • 233 first divides F(13)   →  α(233) = 13 = n  ✓")
    print(f"  233 IS a primitive prime divisor of F(13).")

    # Applications
    print()
    print("─" * 72)
    print("APPLICATIONS:")
    print("─" * 72)
    print("""
  1. CRYPTOGRAPHY: Primitive primes of F(n) provide fresh randomness
     at each Fibonacci index — useful for key derivation.

  2. ALGEBRAIC NUMBER THEORY: Carmichael's theorem is the Fibonacci
     special case of Zsygmondy's theorem for Lucas sequences.

  3. PRIMALITY TESTING: If p is primitive for F(n), then the
     multiplicative order of φ mod p is exactly n, giving a
     certificate that n | (p ± 1).
    """)

if __name__ == "__main__":
    demo()


#!/usr/bin/env python3
"""
Visualizations for Carmichael's Primitive Divisor Theorem.
Creates plots showing the structure of primitive prime divisors of Fibonacci numbers.
"""

import math
from functools import lru_cache
from collections import defaultdict

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import matplotlib.patches as mpatches
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; skipping plots")

# ─── Fibonacci and number theory ────────────────────────────────────

@lru_cache(maxsize=None)
def fib(n):
    if n <= 1:
        return n
    return fib(n - 1) + fib(n - 2)

def prime_factors(n):
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

def divisors(n):
    divs = []
    for d in range(1, int(math.isqrt(n)) + 1):
        if n % d == 0:
            divs.append(d)
            if d != n // d:
                divs.append(n // d)
    return sorted(divs)

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    d = 5
    while d * d <= n:
        if n % d == 0 or (n + 2) % d == 0:
            return False
        d += 6
    return True

def find_primitive_primes(n):
    fn = fib(n)
    if fn <= 1:
        return []
    pf = prime_factors(fn)
    proper_divs = [d for d in divisors(n) if 0 < d < n]
    primitive = []
    for p in pf:
        is_prim = all(fib(d) % p != 0 for d in proper_divs)
        if is_prim:
            primitive.append(p)
    return primitive

def entry_point(p, max_k=500):
    for k in range(1, max_k + 1):
        if fib(k) % p == 0:
            return k
    return None

# ─── Visualizations ────────────────────────────────────────────────

def plot_primitive_count():
    """Plot the number of primitive prime divisors vs n."""
    if not HAS_MPL:
        return
    ns = list(range(1, 101))
    counts = []
    for n in ns:
        prims = find_primitive_primes(n)
        counts.append(len(prims))

    fig, ax = plt.subplots(figsize=(12, 5))
    colors = ['red' if c == 0 and fib(n) > 1 else 'steelblue'
              for n, c in zip(ns, counts)]
    ax.bar(ns, counts, color=colors, width=0.8)
    ax.set_xlabel('n', fontsize=13)
    ax.set_ylabel('Number of primitive prime divisors of F(n)', fontsize=13)
    ax.set_title("Carmichael's Theorem: Primitive Prime Divisors of Fibonacci Numbers",
                 fontsize=14)
    ax.axvline(x=12.5, color='gray', linestyle='--', alpha=0.7)
    ax.text(12.5, max(counts) * 0.9, 'n = 12 boundary', ha='right',
            fontsize=10, color='gray')

    red_patch = mpatches.Patch(color='red', label='No primitive divisor (exceptions)')
    blue_patch = mpatches.Patch(color='steelblue', label='Has primitive divisor')
    ax.legend(handles=[blue_patch, red_patch], fontsize=10)

    plt.tight_layout()
    plt.savefig('primitive_count.png', dpi=150)
    print("Saved: primitive_count.png")
    plt.close()


def plot_entry_point_map():
    """Plot entry points of small primes."""
    if not HAS_MPL:
        return
    primes = [p for p in range(2, 200) if is_prime(p)]
    eps = [(p, entry_point(p)) for p in primes if entry_point(p) is not None]

    fig, ax = plt.subplots(figsize=(12, 6))
    ps = [p for p, _ in eps]
    alphas = [a for _, a in eps]
    ax.scatter(ps, alphas, s=20, alpha=0.7, c='steelblue')

    # Plot p-1 and p+1 boundaries
    ax.plot(ps, [p - 1 for p in ps], 'r--', alpha=0.3, label='p - 1')
    ax.plot(ps, [p + 1 for p in ps], 'g--', alpha=0.3, label='p + 1')

    ax.set_xlabel('Prime p', fontsize=13)
    ax.set_ylabel('Entry point α(p)', fontsize=13)
    ax.set_title('Fibonacci Entry Points: α(p) = min{k > 0 : p | F(k)}', fontsize=14)
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('entry_points.png', dpi=150)
    print("Saved: entry_points.png")
    plt.close()


def plot_primitive_size():
    """Plot the size of the largest primitive prime divisor."""
    if not HAS_MPL:
        return
    ns = list(range(13, 81))
    largest_prim = []
    for n in ns:
        prims = find_primitive_primes(n)
        largest_prim.append(max(prims) if prims else 0)

    fig, ax = plt.subplots(figsize=(12, 6))
    ax.semilogy(ns, largest_prim, 'o-', markersize=4, color='steelblue')
    ax.semilogy(ns, [fib(n) for n in ns], '--', alpha=0.3, color='red', label='F(n)')
    ax.set_xlabel('n', fontsize=13)
    ax.set_ylabel('Largest primitive prime divisor (log scale)', fontsize=13)
    ax.set_title('Growth of Primitive Prime Divisors', fontsize=14)
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('primitive_size.png', dpi=150)
    print("Saved: primitive_size.png")
    plt.close()


def plot_divisibility_matrix():
    """Create a heatmap showing which primes divide which Fibonacci numbers."""
    if not HAS_MPL:
        return
    N = 30
    primes_in_range = set()
    for n in range(1, N + 1):
        fn = fib(n)
        if fn > 1:
            primes_in_range |= set(prime_factors(fn).keys())
    primes_sorted = sorted(primes_in_range)[:20]  # Top 20 primes

    matrix = []
    for p in primes_sorted:
        row = []
        for n in range(1, N + 1):
            if fib(n) % p == 0:
                row.append(1)
            else:
                row.append(0)
        matrix.append(row)

    fig, ax = plt.subplots(figsize=(14, 8))
    im = ax.imshow(matrix, aspect='auto', cmap='Blues', interpolation='nearest')
    ax.set_xlabel('n (Fibonacci index)', fontsize=13)
    ax.set_ylabel('Prime p', fontsize=13)
    ax.set_xticks(range(N))
    ax.set_xticklabels(range(1, N + 1), fontsize=8)
    ax.set_yticks(range(len(primes_sorted)))
    ax.set_yticklabels(primes_sorted, fontsize=9)
    ax.set_title('Divisibility: p | F(n)  (blue = divides)', fontsize=14)

    # Mark entry points with red dots
    for i, p in enumerate(primes_sorted):
        ep = entry_point(p, max_k=N)
        if ep and ep <= N:
            ax.plot(ep - 1, i, 'ro', markersize=6)
    ax.text(0.02, 0.98, '● = entry point α(p)', transform=ax.transAxes,
            fontsize=10, color='red', verticalalignment='top')

    plt.tight_layout()
    plt.savefig('divisibility_matrix.png', dpi=150)
    print("Saved: divisibility_matrix.png")
    plt.close()


if __name__ == "__main__":
    print("Generating visualizations for Carmichael's theorem...")
    plot_primitive_count()
    plot_entry_point_map()
    plot_primitive_size()
    plot_divisibility_matrix()
    print("\nAll visualizations generated successfully!")
