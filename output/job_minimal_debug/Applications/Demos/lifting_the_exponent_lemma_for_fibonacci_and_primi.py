"""
Applications of the Fibonacci Lifting the Exponent Lemma
=========================================================

This module demonstrates practical applications of the theorem:
    v_p(F_{mk}) = v_p(F_m) + v_p(k)
for odd primes p ≠ 5 with p | F_m.
"""

from functools import lru_cache
from math import gcd, log2


# ─── Core utilities ────────────────────────────────────────────────

@lru_cache(maxsize=100000)
def fib(n):
    """Fibonacci number F_n."""
    if n <= 0:
        return 0
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b


def padic_val(p, n):
    """p-adic valuation v_p(n)."""
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True


def entry_point(p):
    """Rank of apparition α(p): smallest m > 0 with p | F_m."""
    for m in range(1, 2 * p + 2):
        if fib(m) % p == 0:
            return m
    return None


# ═══════════════════════════════════════════════════════════════════
# APPLICATION 1: Fast p-adic valuation of Fibonacci numbers
# ═══════════════════════════════════════════════════════════════════

def fast_fib_padic_val(p, n):
    """
    Compute v_p(F_n) without computing F_n.

    By the LTE: if α = α(p) is the entry point, then
        v_p(F_n) = v_p(F_α) + v_p(n/α)  when α | n,
        v_p(F_n) = 0                      when α ∤ n.

    Since v_p(F_α) = 1 for odd p ≠ 5, this simplifies to:
        v_p(F_n) = 1 + v_p(n/α)  when α | n.

    This computes v_p(F_n) in O(log n) time, without needing F_n itself
    (which has O(n) digits).
    """
    if n == 0:
        return float('inf')

    alpha = entry_point(p)
    if alpha is None or n % alpha != 0:
        return 0

    # v_p(F_α) is always 1 for odd p ≠ 5 (consequence of LTE)
    return 1 + padic_val(p, n // alpha)


def demo_fast_valuation():
    """Demonstrate computing v_p(F_n) for astronomically large n."""
    print("═" * 70)
    print("APPLICATION 1: Fast p-adic valuation of F_n (no big integers!)")
    print("═" * 70)
    print()
    print("  The LTE lets us compute v_p(F_n) in O(log n) time,")
    print("  even when F_n has millions of digits.")
    print()

    test_cases = [
        (3, 10**6, "F_{1,000,000}"),
        (3, 3**20, "F_{3^20}"),
        (7, 10**9, "F_{1,000,000,000}"),
        (13, 7 * 13**5, "F_{7 × 13^5}"),
        (89, 11 * 89**3, "F_{11 × 89^3}"),
        (3, 2 * 3**100, "F_{2 × 3^100}"),
    ]

    for p, n, desc in test_cases:
        val = fast_fib_padic_val(p, n)
        alpha = entry_point(p)
        print(f"  v_{p}({desc}) = {val}")
        print(f"    α({p}) = {alpha}, "
              f"{'n/α = ' + str(n // alpha) if n % alpha == 0 else 'α ∤ n'}, "
              f"v_{p}(n/α) = {padic_val(p, n // alpha) if n % alpha == 0 else 'N/A'}")
        print()

    # Verify against brute force for small cases
    print("  Verification against brute force (small n):")
    errors = 0
    for p in [3, 7, 13, 29, 43]:
        for n in range(1, 200):
            fast = fast_fib_padic_val(p, n)
            brute = padic_val(p, fib(n))
            if fast != brute:
                errors += 1
                print(f"    MISMATCH: p={p}, n={n}: fast={fast}, brute={brute}")
    print(f"  Checked {5 * 199} cases: {errors} mismatches.")
    print()


# ═══════════════════════════════════════════════════════════════════
# APPLICATION 2: Pisano period computation
# ═══════════════════════════════════════════════════════════════════

def pisano_period_prime(p):
    """Compute π(p), the Pisano period of F_n mod p."""
    if p == 2:
        return 3
    if p == 5:
        return 20
    # π(p) = lcm of the orders of α and β mod p
    # By theory: π(p) divides 2(p - (5/p)) where (5/p) is Legendre symbol
    prev, curr = 0, 1
    for i in range(1, 6 * p + 10):
        prev, curr = curr, (prev + curr) % p
        if prev == 0 and curr == 1:
            return i
    return None


def pisano_period_prime_power(p, e):
    """
    Compute π(p^e), the Pisano period of F_n mod p^e.

    By the LTE, for odd p ≠ 5: π(p^e) = π(p) · p^{e-1}.
    This is because the LTE controls exactly when additional
    factors of p appear in Fibonacci numbers.
    """
    pi_p = pisano_period_prime(p)
    if p == 2:
        if e == 1: return 3
        if e == 2: return 6
        return 3 * 2**(e - 1)
    if p == 5:
        return 4 * 5**e
    return pi_p * p**(e - 1)


def pisano_period(n):
    """Compute π(n), the Pisano period of F_n mod n, via CRT."""
    if n <= 1:
        return 1

    # Factor n
    result = 1
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            e = 0
            while temp % d == 0:
                e += 1
                temp //= d
            pi_pe = pisano_period_prime_power(d, e)
            result = result * pi_pe // gcd(result, pi_pe)
        d += 1
    if temp > 1:
        pi_pe = pisano_period_prime_power(temp, 1)
        result = result * pi_pe // gcd(result, pi_pe)

    return result


def demo_pisano_periods():
    """Demonstrate Pisano period computation using LTE."""
    print("═" * 70)
    print("APPLICATION 2: Pisano periods via LTE")
    print("═" * 70)
    print()
    print("  The LTE implies π(p^e) = π(p) · p^{e-1} for odd p ≠ 5.")
    print("  This gives efficient computation of π(n) for any n.")
    print()

    # Show π(p^e) for various primes
    print("  Prime power Pisano periods:")
    print(f"  {'p':>5s} {'π(p)':>6s} {'π(p²)':>8s} {'π(p³)':>10s} {'ratio':>8s}")
    print("  " + "-" * 40)

    for p in [3, 7, 11, 13, 29, 47, 89]:
        pi1 = pisano_period_prime(p)
        pi2 = pisano_period_prime_power(p, 2)
        pi3 = pisano_period_prime_power(p, 3)
        print(f"  {p:5d} {pi1:6d} {pi2:8d} {pi3:10d} "
              f"{'×' + str(p):>8s}")

    print()

    # Verify some Pisano periods
    print("  Verification: π(n) for small n")
    for n in [2, 3, 5, 7, 8, 9, 10, 12, 25, 49, 100, 1000]:
        pi = pisano_period(n)
        # Verify: F_{π(n)} ≡ 0 and F_{π(n)+1} ≡ 1 mod n
        check = fib(pi) % n == 0 and fib(pi + 1) % n == 1
        print(f"    π({n:5d}) = {pi:8d}  "
              f"{'✓' if check else '✗'}")

    print()


# ═══════════════════════════════════════════════════════════════════
# APPLICATION 3: Fibonacci-based primality certificates
# ═══════════════════════════════════════════════════════════════════

def fibonacci_primality_test(n):
    """
    A Fibonacci-based compositeness test.

    For prime p: p | F_{p - (5/p)}, where (5/p) is the Legendre symbol.
    If n does not satisfy this, n is composite.

    The LTE provides structural understanding of WHY this works:
    the entry point α(p) always divides p - (5/p).
    """
    if n < 2:
        return "composite"
    if n == 2 or n == 5:
        return "probably prime"
    if n % 2 == 0:
        return "composite"

    # Compute Legendre symbol (5/n) via quadratic reciprocity
    # (5/n) = (n/5) for n odd, n ≠ 5
    r = n % 5
    if r == 1 or r == 4:
        legendre = 1
    elif r == 2 or r == 3:
        legendre = -1
    else:
        legendre = 0

    # Check F_{n - legendre} ≡ 0 (mod n)
    target = n - legendre
    if fib(target) % n == 0:
        return "probably prime"
    else:
        return "composite"


def demo_primality():
    """Demonstrate Fibonacci-based primality testing."""
    print("═" * 70)
    print("APPLICATION 3: Fibonacci primality testing")
    print("═" * 70)
    print()
    print("  For prime p: α(p) | (p - (5/p)), so p | F_{p-(5/p)}.")
    print("  Composites usually fail this test (Fibonacci pseudoprimes")
    print("  are extremely rare).")
    print()

    test_nums = list(range(2, 50)) + [341, 561, 1105, 1729,
                                        323, 377, 4181]
    print(f"  {'n':>6s} {'actual':>12s} {'Fib test':>16s} {'correct?':>10s}")
    print("  " + "-" * 46)

    for n in test_nums:
        actual = "prime" if is_prime(n) else "composite"
        result = fibonacci_primality_test(n)
        correct = (actual == "prime" and "prime" in result) or \
                  (actual == "composite" and result == "composite")
        if not correct and actual == "composite":
            label = "Fib pseudoprime!"
        elif correct:
            label = "✓"
        else:
            label = "✗"
        if n < 50 or not correct or n in [323, 377, 4181]:
            print(f"  {n:6d} {actual:>12s} {result:>16s} {label:>10s}")

    print()


# ═══════════════════════════════════════════════════════════════════
# APPLICATION 4: Exact factorization of Fibonacci numbers
# ═══════════════════════════════════════════════════════════════════

def fibonacci_factorization_analysis(n):
    """
    Analyze the prime factorization of F_n using the LTE.

    For each prime p | F_n, the LTE tells us:
        v_p(F_n) = v_p(F_{α(p)}) + v_p(n/α(p)) = 1 + v_p(n/α(p))
    where α(p) is the entry point.

    This means:
    - If α(p) = n (primitive divisor), v_p(F_n) = 1.
    - If α(p) | n with α(p) < n, v_p(F_n) = 1 + v_p(n/α(p)).
    """
    fn = fib(n)
    if fn <= 1:
        return {}

    result = {}
    temp = fn
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            e = 0
            while temp % d == 0:
                e += 1
                temp //= d

            # Find entry point
            ep = entry_point(d) if d != 2 else 3
            is_primitive = (ep == n) if ep else False

            # Verify LTE prediction
            if ep and n % ep == 0 and d != 2 and d != 5:
                predicted_e = 1 + padic_val(d, n // ep)
            else:
                predicted_e = e  # can't use LTE for p=2 or p=5

            result[d] = {
                'exponent': e,
                'entry_point': ep,
                'primitive': is_primitive,
                'lte_predicted': predicted_e
            }
        d += 1
    if temp > 1:
        ep = entry_point(temp)
        is_primitive = (ep == n) if ep else False
        if ep and n % ep == 0 and temp != 2 and temp != 5:
            predicted_e = 1 + padic_val(temp, n // ep)
        else:
            predicted_e = 1
        result[temp] = {
            'exponent': 1,
            'entry_point': ep,
            'primitive': is_primitive,
            'lte_predicted': predicted_e
        }

    return result


def demo_factorization():
    """Demonstrate LTE-powered factorization analysis."""
    print("═" * 70)
    print("APPLICATION 4: Fibonacci factorization via LTE")
    print("═" * 70)
    print()

    for n in [12, 24, 30, 36, 48, 60, 100]:
        fn = fib(n)
        analysis = fibonacci_factorization_analysis(n)
        fn_str = str(fn) if len(str(fn)) <= 30 else str(fn)[:27] + "..."

        print(f"  F_{n} = {fn_str}")
        for p, info in sorted(analysis.items()):
            prim_str = "★ primitive" if info['primitive'] else ""
            match = "✓" if info['exponent'] == info['lte_predicted'] else "✗"
            if p in [2, 5]:
                match = "-"  # LTE doesn't apply for p=2,5
            print(f"    {p}^{info['exponent']}: α({p})={info['entry_point']}, "
                  f"LTE predicts {info['lte_predicted']} {match} {prim_str}")
        print()


# ─── Main ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Applications of the Fibonacci LTE Lemma                       ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_fast_valuation()
    demo_pisano_periods()
    demo_primality()
    demo_factorization()

    print("═" * 70)
    print("All applications demonstrated.")
    print("═" * 70)


"""
Fibonacci Lifting the Exponent Lemma — Demonstration
=====================================================

For an odd prime p ≠ 5, if p divides F_m, then for every positive integer k:
    v_p(F_{mk}) = v_p(F_m) + v_p(k)

where v_p denotes the p-adic valuation.

This script demonstrates the theorem with concrete numerical examples
and visualizations.
"""

import math
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
from functools import lru_cache
from collections import defaultdict


# ─── Core functions ──────────────────────────────────────────────────

@lru_cache(maxsize=100000)
def fib(n):
    """Compute the n-th Fibonacci number."""
    if n <= 0:
        return 0
    if n == 1:
        return 1
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b


def padic_val(p, n):
    """Compute v_p(n), the p-adic valuation of n."""
    if n == 0:
        return float('inf')
    if p < 2:
        return 0
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


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


# ─── Demo 1: Verify the theorem for specific examples ──────────────

def demo_specific_examples():
    """Demonstrate the LTE with hand-picked illustrative examples."""
    print("=" * 70)
    print("DEMO 1: Specific examples of the Fibonacci LTE")
    print("=" * 70)
    print()

    examples = [
        (3, 4, "p=3 divides F_4=3"),
        (3, 4, "p=3, m=4"),
        (7, 8, "p=7 divides F_8=21=3×7"),
        (13, 7, "p=13 divides F_7=13"),
        (3, 12, "p=3, m=12, F_12=144=3×48"),
        (89, 11, "p=89 divides F_11=89"),
    ]

    for p, m, desc in examples:
        print(f"  {desc}")
        print(f"  F_{m} = {fib(m)}, v_{p}(F_{m}) = {padic_val(p, fib(m))}")
        print()
        for k in [1, 2, 3, p, p * 2, p ** 2]:
            fmk = fib(m * k)
            lhs = padic_val(p, fmk)
            rhs = padic_val(p, fib(m)) + padic_val(p, k)
            status = "✓" if lhs == rhs else "✗"
            print(f"    k={k:5d}: v_{p}(F_{{{m}×{k}}}) = {lhs} "
                  f"= v_{p}(F_{m}) + v_{p}({k}) = "
                  f"{padic_val(p, fib(m))} + {padic_val(p, k)} = {rhs}  {status}")
        print()


# ─── Demo 2: Systematic verification ───────────────────────────────

def demo_systematic_verification():
    """Systematically verify the theorem for many (p, m, k) triples."""
    print("=" * 70)
    print("DEMO 2: Systematic verification")
    print("=" * 70)
    print()

    primes = [p for p in range(3, 50) if is_prime(p) and p != 5]
    count = 0
    failures = 0

    for p in primes:
        # Find the entry point: smallest m > 0 with p | F_m
        m = None
        for t in range(1, 200):
            if fib(t) % p == 0:
                m = t
                break
        if m is None:
            continue

        for k in range(1, 60):
            if m * k > 800:  # keep Fibonacci numbers manageable
                break
            lhs = padic_val(p, fib(m * k))
            rhs = padic_val(p, fib(m)) + padic_val(p, k)
            count += 1
            if lhs != rhs:
                failures += 1
                print(f"  FAILURE: p={p}, m={m}, k={k}")

    print(f"  Tested {count} triples (p, m, k) with "
          f"{len(primes)} primes ≤ 47.")
    print(f"  Failures: {failures}")
    print(f"  Result: {'ALL PASSED ✓' if failures == 0 else 'SOME FAILED ✗'}")
    print()


# ─── Demo 3: Visualize p-adic valuations ───────────────────────────

def demo_visualization():
    """Create visualizations of the p-adic structure of Fibonacci numbers."""
    print("=" * 70)
    print("DEMO 3: Visualizations (saved to files)")
    print("=" * 70)
    print()

    # --- Plot 1: v_p(F_n) for p=3, showing the additive structure ---
    p = 3
    m = 4  # entry point of 3 in Fibonacci sequence (F_4 = 3)
    N = 120
    ns = list(range(1, N + 1))
    vals = [padic_val(p, fib(n)) for n in ns]

    fig, axes = plt.subplots(2, 1, figsize=(14, 10))

    ax = axes[0]
    colors = []
    for n in ns:
        if n % m == 0:
            colors.append('#e74c3c')  # red for multiples of m
        else:
            colors.append('#3498db')  # blue otherwise
    ax.bar(ns, vals, color=colors, width=0.8)
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel(f'v₃(F_n)', fontsize=12)
    ax.set_title(f'3-adic valuation of Fibonacci numbers (entry point m={m})',
                 fontsize=14)
    ax.set_xlim(0, N + 1)

    # Add legend
    from matplotlib.patches import Patch
    legend_elements = [Patch(facecolor='#e74c3c', label=f'{m} | n'),
                       Patch(facecolor='#3498db', label=f'{m} ∤ n')]
    ax.legend(handles=legend_elements, fontsize=11)

    # --- Plot 2: LTE in action for p=3, m=4 ---
    ax = axes[1]
    ks = list(range(1, 41))
    v_fib_m = padic_val(p, fib(m))
    lte_vals = [padic_val(p, fib(m * k)) for k in ks]
    predicted = [v_fib_m + padic_val(p, k) for k in ks]

    ax.plot(ks, lte_vals, 'o', color='#e74c3c', markersize=8,
            label=f'v₃(F_{{4k}}) [actual]', zorder=3)
    ax.plot(ks, predicted, 's', color='#2ecc71', markersize=5,
            label=f'v₃(F_4) + v₃(k) = 1 + v₃(k) [predicted by LTE]',
            zorder=2, alpha=0.7)
    ax.set_xlabel('k', fontsize=12)
    ax.set_ylabel('p-adic valuation', fontsize=12)
    ax.set_title('LTE in action: v₃(F_{4k}) = v₃(F₄) + v₃(k)', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 41)

    plt.tight_layout()
    plt.savefig('fib_lte_visualization.png', dpi=150, bbox_inches='tight')
    print("  Saved: fib_lte_visualization.png")

    # --- Plot 3: Entry points and valuation landscape ---
    fig2, ax2 = plt.subplots(figsize=(14, 6))

    primes_to_show = [3, 7, 11, 13, 29, 43, 47]
    for i, p in enumerate(primes_to_show):
        # Find entry point
        entry = None
        for t in range(1, 300):
            if fib(t) % p == 0:
                entry = t
                break
        if entry is None:
            continue

        ks = list(range(1, 31))
        vals = [padic_val(p, fib(entry * k)) for k in ks]
        ax2.plot(ks, vals, 'o-', label=f'p={p}, α(p)={entry}',
                 markersize=5, linewidth=1.5)

    ax2.set_xlabel('k (multiplier of entry point)', fontsize=12)
    ax2.set_ylabel('v_p(F_{α(p)·k})', fontsize=12)
    ax2.set_title('p-adic valuations across different primes', fontsize=14)
    ax2.legend(fontsize=10, ncol=2)
    ax2.set_xlim(0, 31)

    plt.tight_layout()
    plt.savefig('fib_lte_primes.png', dpi=150, bbox_inches='tight')
    print("  Saved: fib_lte_primes.png")
    print()


# ─── Demo 4: Entry points (rank of apparition) ────────────────────

def demo_entry_points():
    """Show the entry points of primes in the Fibonacci sequence."""
    print("=" * 70)
    print("DEMO 4: Entry points α(p) — smallest m with p | F_m")
    print("=" * 70)
    print()
    print(f"  {'p':>5s} {'α(p)':>6s} {'F_{α(p)}':>20s} {'v_p(F_{α(p)})':>14s}"
          f" {'p±1':>8s} {'α(p) | ?':>10s}")
    print("  " + "-" * 65)

    primes = [p for p in range(3, 100) if is_prime(p) and p != 5]
    for p in primes:
        entry = None
        for t in range(1, 500):
            if fib(t) % p == 0:
                entry = t
                break
        if entry is None:
            continue

        f_entry = fib(entry)
        val = padic_val(p, f_entry)

        # Check if entry point divides p-1 or p+1
        divides = []
        if (p - 1) % entry == 0:
            divides.append(f"p-1={p - 1}")
        if (p + 1) % entry == 0:
            divides.append(f"p+1={p + 1}")

        f_str = str(f_entry) if len(str(f_entry)) <= 18 else str(f_entry)[:15] + "..."

        print(f"  {p:5d} {entry:6d} {f_str:>20s} {val:14d}"
              f" {' or '.join(divides):>20s}")

    print()
    print("  Note: α(p) always divides p - (5/p), where (5/p) is the")
    print("  Legendre symbol. This is +1 when p ≡ ±1 (mod 5),")
    print("  and -1 when p ≡ ±2 (mod 5).")
    print()


# ─── Demo 5: Application to primitive prime divisors ───────────────

def demo_primitive_divisors():
    """Show how LTE relates to Carmichael's theorem on primitive divisors."""
    print("=" * 70)
    print("DEMO 5: Primitive prime divisors of Fibonacci numbers")
    print("=" * 70)
    print()
    print("  Carmichael's theorem: For n > 12, F_n has a primitive prime")
    print("  divisor — a prime p with p | F_n but p ∤ F_d for all d | n, d < n.")
    print()

    for n in range(2, 60):
        fn = fib(n)
        if fn <= 1:
            continue

        # Find all prime divisors
        temp = fn
        prime_divs = []
        d = 2
        while d * d <= temp:
            if temp % d == 0:
                prime_divs.append(d)
                while temp % d == 0:
                    temp //= d
            d += 1
        if temp > 1:
            prime_divs.append(temp)

        # Check which are primitive
        proper_divs = [d for d in range(1, n) if n % d == 0]
        primitive = []
        non_primitive = []
        for p in prime_divs:
            is_prim = True
            for d in proper_divs:
                if fib(d) % p == 0:
                    is_prim = False
                    break
            if is_prim:
                primitive.append(p)
            else:
                non_primitive.append(p)

        fn_str = str(fn) if len(str(fn)) <= 20 else str(fn)[:17] + "..."
        print(f"  F_{n:3d} = {fn_str:>22s}  "
              f"primitive: {primitive}  "
              f"non-primitive: {non_primitive}")

    print()
    print("  The LTE formula v_p(F_{mk}) = v_p(F_m) + v_p(k) is the key")
    print("  tool for proving that non-primitive primes cannot account for")
    print("  all of F_n's magnitude, forcing primitive divisors to exist.")


# ─── Main ──────────────────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Fibonacci Lifting the Exponent Lemma — Interactive Demo       ║")
    print("║                                                                 ║")
    print("║  Theorem: For odd prime p ≠ 5 with p | F_m:                    ║")
    print("║    v_p(F_{mk}) = v_p(F_m) + v_p(k)                            ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()

    demo_specific_examples()
    demo_systematic_verification()
    demo_entry_points()
    demo_primitive_divisors()
    demo_visualization()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
