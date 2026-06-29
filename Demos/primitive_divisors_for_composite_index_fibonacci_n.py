"""
Carmichael's Theorem on Primitive Divisors of Fibonacci Numbers — Demo

This script demonstrates Carmichael's 1913 theorem:
For every composite n > 12, the Fibonacci number F_n has at least one
"primitive prime divisor" — a prime p that divides F_n but does not
divide F_m for any 0 < m < n.

The exceptions are n = 1, 2, 6, 12 (plus all primes, which are handled separately).
"""

import math
from sympy import factorint, isprime, fibonacci
from collections import defaultdict

# ─────────────────────────────────────────────────────────
# 1. Core functions
# ─────────────────────────────────────────────────────────

def fib(n):
    """Compute Fibonacci number F_n."""
    return fibonacci(n)

def entry_point(p, max_search=None):
    """
    Find the entry point α(p) = smallest k > 0 with p | F_k.
    For prime p, α(p) always exists and α(p) ≤ p+1.
    """
    if max_search is None:
        max_search = p * p + 2
    for k in range(1, max_search + 1):
        if fib(k) % p == 0:
            return k
    return None

def find_primitive_divisors(n):
    """
    Find all primitive prime divisors of F_n.
    A prime p is primitive for F_n if p | F_n and p ∤ F_m for all 0 < m < n.
    Equivalently, p's entry point α(p) = n.
    """
    fn = fib(n)
    if fn <= 1:
        return []
    factors = factorint(fn)
    primitives = []
    for p in factors:
        ep = entry_point(p)
        if ep == n:
            primitives.append(p)
    return primitives

def mobius_primitive_part(n):
    """
    Compute the Möbius primitive part Φ_n = ∏_{d|n} F_d^{μ(n/d)}.
    This is always a positive integer for n > 1.
    """
    from sympy import divisors, mobius as sympy_mobius
    from fractions import Fraction

    divs = divisors(n)
    result = Fraction(1)
    for d in divs:
        mu = sympy_mobius(n // d)
        if mu == 0:
            continue
        fd = fib(d)
        if fd == 0:
            if mu > 0:
                return 0
            continue
        if mu > 0:
            result *= fd
        else:
            result /= fd
    return int(result)

# ─────────────────────────────────────────────────────────
# 2. Demonstrate Carmichael's theorem
# ─────────────────────────────────────────────────────────

print("=" * 70)
print("CARMICHAEL'S THEOREM ON PRIMITIVE DIVISORS OF FIBONACCI NUMBERS")
print("=" * 70)
print()
print("Theorem (Carmichael, 1913): For composite n > 12, F_n has a")
print("primitive prime divisor — a prime dividing F_n but no smaller F_m.")
print()

# Show the exceptions first
print("─" * 70)
print("EXCEPTIONS (composite n ≤ 12 with NO primitive prime divisor):")
print("─" * 70)
for n in [1, 2, 6, 12]:
    fn = fib(n)
    if fn <= 1:
        print(f"  n = {n:3d}: F_{n} = {fn} (no prime factors)")
        continue
    factors = factorint(fn)
    prims = find_primitive_divisors(n)
    print(f"  n = {n:3d}: F_{n} = {int(fn):10d} = ", end="")
    parts = []
    for p, e in sorted(factors.items()):
        ep = entry_point(p)
        parts.append(f"{p}^{e}" if e > 1 else str(p))
    print(" × ".join(parts), end="")
    eps = {p: entry_point(p) for p in factors}
    print(f"  entry points: {eps}  primitive: {prims}")

print()
print("─" * 70)
print("VERIFICATION for composite n from 14 to 60:")
print("─" * 70)
print(f"{'n':>4s}  {'F_n':>15s}  {'Factorization':>30s}  {'Primitive divisors':>20s}  {'Φ_n':>8s}")
print("─" * 70)

for n in range(14, 61):
    if isprime(n):
        continue
    fn = fib(n)
    factors = factorint(fn)
    prims = find_primitive_divisors(n)
    phi_n = mobius_primitive_part(n)

    # Format factorization
    parts = []
    for p, e in sorted(factors.items()):
        parts.append(f"{p}^{e}" if e > 1 else str(p))
    fact_str = " × ".join(parts)
    if len(fact_str) > 30:
        fact_str = fact_str[:27] + "..."

    prim_str = ", ".join(str(p) for p in sorted(prims))

    print(f"{n:4d}  {int(fn):15d}  {fact_str:>30s}  {prim_str:>20s}  {int(phi_n):>8d}")

# ─────────────────────────────────────────────────────────
# 3. Entry point analysis
# ─────────────────────────────────────────────────────────

print()
print("─" * 70)
print("ENTRY POINT TABLE for small primes:")
print("─" * 70)
print(f"{'p':>5s}  {'α(p)':>6s}  {'p mod 5':>8s}  {'Note':>30s}")
print("─" * 70)

for p in range(2, 50):
    if not isprime(p):
        continue
    ep = entry_point(p)
    mod5 = p % 5
    note = ""
    if ep is not None:
        if ep == p - 1:
            note = "α(p) = p-1"
        elif ep == p + 1:
            note = "α(p) = p+1"
        elif ep == 2 * (p + 1):
            note = "α(p) = 2(p+1)"
        elif ep == (p - 1) // 2:
            note = "α(p) = (p-1)/2"
    print(f"{p:5d}  {ep:6d}  {mod5:8d}  {note:>30s}")

# ─────────────────────────────────────────────────────────
# 4. Möbius primitive part growth
# ─────────────────────────────────────────────────────────

print()
print("─" * 70)
print("MÖBIUS PRIMITIVE PART Φ_n and its relationship to n:")
print("─" * 70)
print(f"{'n':>4s}  {'Φ_n':>15s}  {'φ(n)':>6s}  {'φ^φ(n)':>15s}  {'Φ_n/n':>10s}  {'Primitive?':>10s}")
print("─" * 70)

from sympy import totient

phi = (1 + math.sqrt(5)) / 2  # golden ratio

for n in range(2, 61):
    if isprime(n) or n <= 1:
        continue
    phi_n = mobius_primitive_part(n)
    euler_phi = totient(n)
    golden_power = phi ** euler_phi
    ratio = phi_n / n if n > 0 else 0
    has_prim = "YES" if find_primitive_divisors(n) else "NO"

    print(f"{n:4d}  {phi_n:15d}  {euler_phi:6d}  {golden_power:15.1f}  {ratio:10.2f}  {has_prim:>10s}")

# ─────────────────────────────────────────────────────────
# 5. Visualization
# ─────────────────────────────────────────────────────────

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    import numpy as np

    # Plot 1: Primitive divisors vs n
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Collect data
    ns = []
    smallest_prims = []
    phi_ns = []
    euler_phis = []

    for n in range(14, 101):
        if isprime(n):
            continue
        prims = find_primitive_divisors(n)
        if prims:
            ns.append(n)
            smallest_prims.append(min(prims))
            phi_ns.append(mobius_primitive_part(n))
            euler_phis.append(int(totient(n)))

    # Panel 1: Smallest primitive divisor vs n
    ax = axes[0, 0]
    ax.scatter(ns, smallest_prims, s=15, alpha=0.7, color='royalblue')
    ax.plot(ns, ns, 'r--', alpha=0.5, label='y = n')
    ax.set_xlabel('n (composite)')
    ax.set_ylabel('Smallest primitive prime divisor')
    ax.set_title('Smallest Primitive Divisor of F_n')
    ax.legend()
    ax.set_yscale('log')

    # Panel 2: Möbius primitive part vs n
    ax = axes[0, 1]
    ax.scatter(ns, phi_ns, s=15, alpha=0.7, color='forestgreen')
    ax.plot(ns, ns, 'r--', alpha=0.5, label='y = n')
    ax.set_xlabel('n (composite)')
    ax.set_ylabel('Φ_n (Möbius primitive part)')
    ax.set_title('Möbius Primitive Part Φ_n')
    ax.legend()
    ax.set_yscale('log')

    # Panel 3: Entry point distribution
    ax = axes[1, 0]
    all_eps = defaultdict(list)
    for n in range(2, 80):
        fn = fib(n)
        if fn <= 1:
            continue
        for p in factorint(fn):
            ep = entry_point(p)
            if ep is not None:
                all_eps[n].append((p, ep))
    for n in sorted(all_eps.keys()):
        for p, ep in all_eps[n]:
            color = 'red' if ep == n else 'gray'
            alpha = 0.8 if ep == n else 0.3
            ax.scatter(n, ep, s=10, color=color, alpha=alpha)
    ax.plot([0, 80], [0, 80], 'b--', alpha=0.3, label='α(p) = n (primitive)')
    ax.set_xlabel('n')
    ax.set_ylabel('Entry point α(p)')
    ax.set_title('Entry Points of Prime Factors of F_n')
    ax.legend(fontsize=8)

    # Panel 4: Ratio Φ_n / φ^{φ(n)}
    ax = axes[1, 1]
    ratios = [phi_ns[i] / phi**euler_phis[i] for i in range(len(ns))]
    ax.scatter(ns, ratios, s=15, alpha=0.7, color='darkorange')
    ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('n (composite)')
    ax.set_ylabel('Φ_n / φ^{φ(n)}')
    ax.set_title('Correction Factor in Primitive Part')

    plt.tight_layout()
    plt.savefig('demos/carmichael_plots.png', dpi=150, bbox_inches='tight')
    print("\n✓ Plots saved to demos/carmichael_plots.png")

except ImportError:
    print("\n(matplotlib not available; skipping plots)")

print()
print("=" * 70)
print("SUMMARY")
print("=" * 70)
print("""
Carmichael's theorem (1913) states that for every n > 12 with n composite,
the Fibonacci number F_n possesses at least one "primitive" prime divisor —
a prime that divides F_n but does not divide any smaller Fibonacci number.

The exceptions (composite n with no primitive divisor) are exactly:
  n = 1:  F_1 = 1 (no prime factors)
  n = 2:  F_2 = 1 (no prime factors)
  n = 6:  F_6 = 8 = 2³ (α(2) = 3 ≠ 6)
  n = 12: F_12 = 144 = 2⁴ × 3² (α(2) = 3, α(3) = 4, neither = 12)

Key proof ingredients:
1. Nat.fib_gcd: gcd(F_m, F_n) = F_{gcd(m,n)} (strong divisibility)
2. Entry point theory: the smallest k with p | F_k divides every n with p | F_n
3. Möbius primitive part: Φ_n = ∏_{d|n} F_d^{μ(n/d)} ≈ φ^{φ(n)} > n for n > 12
""")
