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
