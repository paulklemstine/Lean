#!/usr/bin/env python3
"""
Fibonacci Primitive Divisors — Interactive Demo

Demonstrates the key theorems formalized in Lean 4:
1. Fibonacci entry points (rank of apparition)
2. Primitive prime divisors
3. Lifting-the-Exponent (LTE) for Fibonacci
4. Carmichael's theorem verification

Run: python3 demo.py
"""

import math
from collections import defaultdict
from functools import lru_cache

# ─────────────────────────────────────────────
# Core Fibonacci computation
# ─────────────────────────────────────────────

@lru_cache(maxsize=None)
def fib(n):
    """Compute the n-th Fibonacci number."""
    if n <= 0:
        return 0
    if n == 1:
        return 1
    return fib(n - 1) + fib(n - 2)


def factorize(n):
    """Return the prime factorization of n as a dict {prime: exponent}."""
    if n <= 1:
        return {}
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


def v_p(n, p):
    """Compute the p-adic valuation of n."""
    if n == 0:
        return float('inf')
    count = 0
    while n % p == 0:
        count += 1
        n //= p
    return count


# ─────────────────────────────────────────────
# Entry Point (Rank of Apparition)
# ─────────────────────────────────────────────

def entry_point(p):
    """
    Compute z(p) = the smallest positive k such that p | F_k.
    
    Theorem (formalized): p | F_n  ↔  z(p) | n
    """
    for k in range(1, p * p):
        if fib(k) % p == 0:
            return k
    return None


def is_primitive_divisor(p, n):
    """
    Check if p is a primitive prime divisor of F_n.
    
    Definition (formalized): p is primitive for F_n iff
      p is prime, p | F_n, and ∀ 0 < k < n, p ∤ F_k.
    Equivalently: z(p) = n.
    """
    if not is_prime(p):
        return False
    return entry_point(p) == n


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


# ─────────────────────────────────────────────
# Demo 1: Fibonacci Numbers and Their Factorizations
# ─────────────────────────────────────────────

def demo_fibonacci_table():
    print("=" * 70)
    print("DEMO 1: Fibonacci Numbers and Their Prime Factorizations")
    print("=" * 70)
    print(f"{'n':>4}  {'F_n':>12}  {'Factorization':>25}  {'Primitive primes'}")
    print("-" * 70)
    
    for n in range(1, 25):
        fn = fib(n)
        factors = factorize(fn)
        factor_str = " × ".join(f"{p}^{e}" if e > 1 else str(p) 
                                for p, e in sorted(factors.items()))
        if fn == 1:
            factor_str = "1"
        
        primitives = [p for p in factors if is_primitive_divisor(p, n)]
        prim_str = ", ".join(str(p) for p in primitives) if primitives else "none"
        
        print(f"{n:>4}  {fn:>12}  {factor_str:>25}  {prim_str}")
    print()


# ─────────────────────────────────────────────
# Demo 2: Entry Points (Rank of Apparition)
# ─────────────────────────────────────────────

def demo_entry_points():
    print("=" * 70)
    print("DEMO 2: Entry Points z(p) — The Smallest k with p | F_k")
    print("=" * 70)
    print()
    print("Theorem (formalized): p | F_n  ⟺  z(p) | n")
    print("Theorem (formalized): z(p) divides p² - 1 for odd primes p ≠ 5")
    print()
    
    primes = [p for p in range(2, 50) if is_prime(p)]
    print(f"{'p':>4}  {'z(p)':>6}  {'F_{z(p)}':>12}  {'p²-1':>8}  {'z(p) | p²-1':>12}")
    print("-" * 50)
    
    for p in primes:
        zp = entry_point(p)
        fzp = fib(zp)
        psq = p * p - 1
        divides = "✓" if psq % zp == 0 else "✗"
        print(f"{p:>4}  {zp:>6}  {fzp:>12}  {psq:>8}  {divides:>12}")
    print()


# ─────────────────────────────────────────────
# Demo 3: Lifting-the-Exponent for Fibonacci
# ─────────────────────────────────────────────

def demo_lte():
    print("=" * 70)
    print("DEMO 3: Lifting-the-Exponent (LTE) for Fibonacci")
    print("=" * 70)
    print()
    print("Theorem (formalized): For odd prime p with p | F_k and p ∤ n:")
    print("  v_p(F_{nk}) = v_p(F_k) + v_p(n)")
    print()
    
    # Test cases: (p, k) pairs where p | F_k
    test_cases = [
        (3, 4),   # 3 | F_4 = 3
        (5, 5),   # 5 | F_5 = 5
        (7, 8),   # 7 | F_8 = 21
        (13, 7),  # 13 | F_7 = 13
        (89, 11), # 89 | F_11 = 89
    ]
    
    for p, k in test_cases:
        print(f"  p = {p}, k = {k}, F_k = {fib(k)}")
        print(f"  {'n':>4}  {'nk':>6}  {'F_{nk}':>15}  {'v_p(F_{nk})':>12}  "
              f"{'v_p(F_k)+v_p(n)':>16}  {'Match':>6}")
        print(f"  {'-'*60}")
        
        for n in range(1, 10):
            if n % p == 0:
                continue  # LTE requires p ∤ n
            nk = n * k
            fnk = fib(nk)
            lhs = v_p(fnk, p)
            rhs = v_p(fib(k), p) + v_p(n, p)
            match = "✓" if lhs == rhs else "✗"
            fnk_str = str(fnk) if fnk < 10**12 else f"~{fnk:.3e}"
            print(f"  {n:>4}  {nk:>6}  {fnk_str:>15}  {lhs:>12}  {rhs:>16}  {match:>6}")
        print()


# ─────────────────────────────────────────────
# Demo 4: Carmichael's Theorem Verification
# ─────────────────────────────────────────────

def demo_carmichael():
    print("=" * 70)
    print("DEMO 4: Carmichael's Theorem — Primitive Divisor Existence")
    print("=" * 70)
    print()
    print("Theorem (formalized for primes p ≥ 5):")
    print("  F_n has a primitive prime divisor for n ∉ {1, 2, 6, 12}")
    print()
    
    exceptions = []
    has_primitive = []
    
    for n in range(1, 51):
        fn = fib(n)
        if fn <= 1:
            exceptions.append(n)
            continue
        
        factors = factorize(fn)
        primitives = [p for p in factors if entry_point(p) == n]
        
        if primitives:
            has_primitive.append((n, primitives))
        else:
            exceptions.append(n)
    
    print(f"  Exceptions (no primitive divisor): {exceptions}")
    print(f"  Expected exceptions: [1, 2, 6, 12]")
    print()
    
    print(f"  {'n':>4}  {'F_n':>15}  {'Primitive primes'}")
    print(f"  {'-'*50}")
    for n, prims in has_primitive[:20]:
        fn = fib(n)
        fn_str = str(fn) if fn < 10**12 else f"~{fn:.3e}"
        print(f"  {n:>4}  {fn_str:>15}  {prims}")
    if len(has_primitive) > 20:
        print(f"  ... and {len(has_primitive) - 20} more")
    print()


# ─────────────────────────────────────────────
# Demo 5: Tropical (Min-Plus) Valuation Structure
# ─────────────────────────────────────────────

def demo_tropical():
    print("=" * 70)
    print("DEMO 5: Tropical (Min-Plus) Valuation — Ultrametric Property")
    print("=" * 70)
    print()
    print("Theorem (formalized): v_p(a + b) ≥ min(v_p(a), v_p(b))")
    print("  This is the defining property of the tropical semiring structure.")
    print()
    
    p = 3
    print(f"  p = {p}")
    print(f"  {'a':>6}  {'b':>6}  {'a+b':>6}  {'v_p(a)':>7}  {'v_p(b)':>7}  "
          f"{'min':>5}  {'v_p(a+b)':>9}  {'≥ min':>6}")
    print(f"  {'-'*60}")
    
    test_pairs = [(9, 18), (27, 54), (3, 6), (81, 9), (12, 15), 
                  (fib(8), fib(12)), (fib(4), fib(8))]
    for a, b in test_pairs:
        va = v_p(a, p)
        vb = v_p(b, p)
        vab = v_p(a + b, p)
        m = min(va, vb)
        check = "✓" if vab >= m else "✗"
        print(f"  {a:>6}  {b:>6}  {a+b:>6}  {va:>7}  {vb:>7}  {m:>5}  {vab:>9}  {check:>6}")
    print()


# ─────────────────────────────────────────────
# Demo 6: Growth Bounds
# ─────────────────────────────────────────────

def demo_growth():
    print("=" * 70)
    print("DEMO 6: Growth Bounds for Fibonacci Numbers")
    print("=" * 70)
    print()
    print("Theorem (formalized): F_n ≥ 2^((n-2)/2) for n ≥ 2")
    print("Theorem (formalized): F_m × F_n ≤ F_{m+n} for m,n ≥ 1")
    print()
    
    print("  Exponential lower bound:")
    print(f"  {'n':>4}  {'F_n':>15}  {'2^((n-2)/2)':>15}  {'Ratio':>8}")
    print(f"  {'-'*45}")
    for n in [5, 10, 15, 20, 25, 30, 35, 40]:
        fn = fib(n)
        bound = 2 ** ((n - 2) // 2)
        ratio = fn / bound
        print(f"  {n:>4}  {fn:>15}  {bound:>15}  {ratio:>8.2f}")
    print()
    
    print("  Multiplicative bound F_m × F_n ≤ F_{m+n}:")
    print(f"  {'m':>4}  {'n':>4}  {'F_m×F_n':>12}  {'F_{m+n}':>12}  {'Check':>6}")
    print(f"  {'-'*45}")
    for m, n in [(3, 4), (5, 5), (7, 3), (10, 8), (6, 6)]:
        prod = fib(m) * fib(n)
        fmn = fib(m + n)
        check = "✓" if prod <= fmn else "✗"
        print(f"  {m:>4}  {n:>4}  {prod:>12}  {fmn:>12}  {check:>6}")
    print()


# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  FIBONACCI PRIMITIVE DIVISORS — FORMAL VERIFICATION DEMO       ║")
    print("║  All results verified in Lean 4 with Mathlib                   ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_fibonacci_table()
    demo_entry_points()
    demo_lte()
    demo_carmichael()
    demo_tropical()
    demo_growth()
    
    print("=" * 70)
    print("Summary of Formalized Results (all proved, zero sorry)")
    print("=" * 70)
    print("""
Key theorems proved in Lean 4:

1. fib_dvd_iff_entry_dvd:  p | F_n  ⟺  z(p) | n
   (Entry point characterization via strong divisibility)

2. fib_lte:  v_p(F_{nk}) = v_p(F_k) + v_p(n)  when p ∤ n
   (Lifting-the-Exponent for Fibonacci sequences)

3. entry_point_dvd_sq_sub_one:  ∃ k, k | p²-1 ∧ p | F_k
   (Entry point bound via matrix Frobenius argument)

4. fib_prime_has_primitive:  F_p has a primitive divisor for prime p ≥ 5
   (Carmichael's theorem for prime indices)

5. Carmichael exceptions verified: n = 1, 2, 6, 12 have no primitives
   (Computational verification of all exception cases)

6. padic_val_min_le_add:  v_p(a+b) ≥ min(v_p(a), v_p(b))
   (Tropical ultrametric inequality)

7. fib_exponential_lower_bound:  F_n ≥ 2^((n-2)/2)
   (Growth bound for Fibonacci)

8. fib_mul_le_fib_add:  F_m × F_n ≤ F_{m+n}
   (Multiplicative growth bound)
""")
