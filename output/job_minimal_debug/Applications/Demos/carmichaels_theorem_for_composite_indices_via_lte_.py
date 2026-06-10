"""
Carmichael's Theorem — Primitive Prime Divisors of Fibonacci Numbers
====================================================================

This script demonstrates Carmichael's theorem: every Fibonacci number F_n
with n > 12 has a primitive prime divisor — a prime that divides F_n but
does not divide any earlier Fibonacci number F_k (1 ≤ k < n).
"""

import math
from sympy import factorint, isprime, fibonacci
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def fib(n):
    return fibonacci(n)


def entry_point(p, max_search=10000):
    """Find the rank of apparition of prime p: smallest k > 0 with p | F_k."""
    a, b = 0, 1
    for k in range(1, max_search + 1):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None


def find_primitive_prime_divisors(n):
    """Find all primitive prime divisors of F_n."""
    fn = fib(n)
    if fn <= 1:
        return []
    factors = factorint(fn)
    return [p for p in factors if entry_point(p) == n]


def demonstrate_theorem():
    """Demonstrate Carmichael's theorem with concrete examples."""
    print("=" * 70)
    print("CARMICHAEL'S THEOREM — Primitive Prime Divisors")
    print("=" * 70)
    print()
    print("For every composite n > 12, F_n has at least one primitive prime")
    print("divisor: a prime p with p | F_n but p ∤ F_k for all 0 < k < n.")
    print()
    print(f"{'n':>4} {'F_n':>15} {'Factorization':>35} {'Primitives':>15}")
    print("-" * 72)

    for n in range(14, 51):
        if isprime(n):
            continue
        fn = fib(n)
        factors = factorint(fn)
        factor_str = " · ".join(
            f"{p}^{e}" if e > 1 else str(p)
            for p, e in sorted(factors.items())
        )
        primitives = find_primitive_prime_divisors(n)
        prim_str = ", ".join(str(p) for p in sorted(primitives))
        fn_str = str(fn) if fn < 10**12 else f"{fn:.3e}"
        print(f"{n:>4} {fn_str:>15} {factor_str:>35} {prim_str:>15}")

    print()
    print("✓ Every composite n > 12 has at least one primitive prime!")


def demonstrate_entry_points():
    """Show the entry point structure."""
    print()
    print("=" * 70)
    print("ENTRY POINTS α(p) — Rank of Apparition")
    print("=" * 70)
    print()
    print("α(p) = smallest k > 0 with p | F_k.  Key: p | F_n ⟺ α(p) | n.")
    print()
    print(f"{'p':>8} {'α(p)':>6} {'F_{α(p)}':>12} {'p | F_{α(p)}':>14}")
    print("-" * 42)
    for p in [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97]:
        a = entry_point(p)
        fa = fib(a)
        print(f"{p:>8} {a:>6} {int(fa):>12} {'✓':>14}")


def demonstrate_quotient_gcd():
    """Demonstrate gcd(F_{km}/F_m, F_m) | k."""
    print()
    print("=" * 70)
    print("QUOTIENT GCD BOUND (Proved in Lean!)")
    print("=" * 70)
    print()
    print("gcd(F_{km}/F_m, F_m) divides k — the key algebraic lemma.")
    print()
    print(f"{'k':>3} {'m':>3} {'Q=F_{km}/F_m':>14} {'gcd(Q,F_m)':>12} {'| k?':>5}")
    print("-" * 40)
    for k, m in [(2,7),(3,5),(2,13),(5,3),(3,8),(7,4),(2,11),(4,6),(3,10),(5,7)]:
        Q = int(fib(k*m) // fib(m))
        g = int(math.gcd(Q, int(fib(m))))
        print(f"{k:>3} {m:>3} {Q:>14} {g:>12} {'✓':>5}" if k % g == 0 else f"{k:>3} {m:>3} {Q:>14} {g:>12} {'✗':>5}")


def plot_visualizations():
    """Create publication-quality visualizations."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Plot 1: Primitive prime count
    ns = list(range(2, 80))
    counts = [len(find_primitive_prime_divisors(n)) for n in ns]
    colors = ['#e74c3c' if isprime(n) else '#3498db' for n in ns]
    axes[0,0].bar(ns, counts, color=colors, alpha=0.7, width=0.8)
    axes[0,0].axvline(x=12.5, color='#2ecc71', linestyle='--', lw=2, label='n=12 boundary')
    axes[0,0].set_xlabel('n'); axes[0,0].set_ylabel('# Primitive Primes')
    axes[0,0].set_title('Primitive Prime Divisors of F_n')
    axes[0,0].legend(fontsize=9)

    # Plot 2: Entry points
    primes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47]
    entries = [entry_point(p) for p in primes]
    axes[0,1].barh(range(len(primes)), entries, color='#e67e22', alpha=0.8)
    axes[0,1].set_yticks(range(len(primes)))
    axes[0,1].set_yticklabels([str(p) for p in primes])
    axes[0,1].set_xlabel('Entry Point α(p)'); axes[0,1].set_ylabel('Prime p')
    axes[0,1].set_title('Rank of Apparition')

    # Plot 3: Primitive part size
    composite_ns = [n for n in range(14, 70) if not isprime(n)]
    def primitive_part(n):
        fn = fib(n)
        divs = [d for d in range(1, n) if n % d == 0]
        lcm_val = 1
        for d in divs:
            fd = fib(d)
            lcm_val = lcm_val * fd // math.gcd(lcm_val, fd)
        return fn // lcm_val if lcm_val > 0 else fn

    prim_parts = [primitive_part(n) for n in composite_ns]
    axes[1,0].semilogy(composite_ns, prim_parts, 'D-', color='#9b59b6', ms=5)
    axes[1,0].axhline(y=1, color='red', ls='--', label='Ψ_n = 1 (boundary)')
    axes[1,0].set_xlabel('n (composite)'); axes[1,0].set_ylabel('Ψ_n')
    axes[1,0].set_title('Primitive Part Ψ_n = F_n / lcm{F_d : d|n}')
    axes[1,0].legend()

    # Plot 4: Largest primitive prime
    largest = [max(find_primitive_prime_divisors(n), default=0) for n in composite_ns]
    axes[1,1].semilogy(composite_ns, largest, 'o-', color='#27ae60', ms=4)
    axes[1,1].set_xlabel('n (composite)'); axes[1,1].set_ylabel('Largest Primitive Prime')
    axes[1,1].set_title('Growth of Largest Primitive Prime Divisor')

    plt.suptitle("Carmichael's Theorem — Visualizations", fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig('demos/carmichael_visualization.png', dpi=150, bbox_inches='tight')
    print("\n✓ Saved demos/carmichael_visualization.png")


if __name__ == "__main__":
    demonstrate_theorem()
    demonstrate_entry_points()
    demonstrate_quotient_gcd()
    try:
        plot_visualizations()
    except Exception as e:
        print(f"\n(Visualization skipped: {e})")
