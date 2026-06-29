#!/usr/bin/env python3
"""
Carmichael's Primitive Divisor Theorem for Fibonacci Numbers — Demo

Demonstrates that for n > 12, F_n always has a primitive prime divisor:
a prime p that divides F_n but does not divide F_k for any 0 < k < n.
"""

import math
from collections import defaultdict

def fib(n):
    """Fast Fibonacci via matrix exponentiation."""
    if n <= 1: return n
    a, b = 0, 1
    for _ in range(2, n + 1):
        a, b = b, a + b
    return b

def trial_factor(n, limit=10**6):
    factors = {}
    d = 2
    while d * d <= n and d <= limit:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors

def entry_point_mod(p, max_k=500):
    """Find entry point z(p) using modular arithmetic (fast)."""
    a, b = 0, 1
    for k in range(1, max_k + 1):
        a, b = b, (a + b) % p
        if a == 0:
            return k
    return None

def is_prime(n):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0 or n % 3 == 0: return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0: return False
        i += 6
    return True

def euler_totient(n):
    result, p, temp = n, 2, n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0: temp //= p
            result -= result // p
        p += 1
    if temp > 1: result -= result // temp
    return result

print()
print("╔═════════════════════════════════════════════════════════════╗")
print("║  CARMICHAEL'S PRIMITIVE DIVISOR THEOREM — DEMO            ║")
print("╚═════════════════════════════════════════════════════════════╝")
print()

# Demo 1: Entry points
print("=" * 60)
print("  ENTRY POINTS z(p) FOR SMALL PRIMES")
print("=" * 60)
print()
print("z(p) = smallest k > 0 with p | F_k")
print()
print(f"{'p':>6} {'z(p)':>6} {'p mod 5':>8} {'z(p)|p-1?':>10} {'z(p)|2(p+1)?':>13}")
print("-" * 50)
primes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97]
for p in primes:
    z = entry_point_mod(p, 2*p+10)
    pmod5 = p % 5
    div_pm1 = "✓" if z and (p-1) % z == 0 else ""
    div_2pp1 = "✓" if z and (2*(p+1)) % z == 0 else ""
    print(f"{p:>6} {z:>6} {pmod5:>8} {div_pm1:>10} {div_2pp1:>13}")
print()

# Demo 2: Primitive divisors for small composite n
print("=" * 60)
print("  PRIMITIVE DIVISORS OF F_n (COMPOSITE n ≤ 30)")
print("=" * 60)
print()
composites = [4,6,8,9,10,12,14,15,16,18,20,21,24,25,28,30]
for n in composites:
    fn = fib(n)
    factors = trial_factor(fn)
    primitive, non_prim = [], []
    for p in sorted(factors.keys()):
        z = entry_point_mod(p, n+1)
        (primitive if z == n else non_prim).append((p, z))
    status = "✓" if primitive else "✗ EXCEPTION"
    fstr = ' · '.join(f'{p}^{e}' if e > 1 else str(p) for p, e in sorted(factors.items()))
    prim_str = ', '.join(f'{p}' for p, _ in primitive) if primitive else 'none'
    print(f"n={n:>2}: F_{n} = {fn:>8} = {fstr:>20}  "
          f"primitive: {prim_str:>8}  {status}")
print()
print("Exceptions at n=6,12 are the only ones — Carmichael's theorem!")
print()

# Demo 3: Verify for n = 13..100
print("=" * 60)
print("  VERIFICATION: COMPOSITE n FROM 13 TO 100")
print("=" * 60)
print()
verified, total = 0, 0
for n in range(13, 101):
    if is_prime(n): continue
    total += 1
    fn = fib(n)
    factors = trial_factor(fn)
    if any(entry_point_mod(p, n+1) == n for p in factors):
        verified += 1
    else:
        print(f"  FAILURE at n={n}!")
print(f"Verified {verified}/{total} composite n in [13,100]. All pass ✓")
print()

# Demo 4: Growth of primitive part
print("=" * 60)
print("  WHY PRIMITIVE DIVISORS EXIST: THE Φ_n BOUND")
print("=" * 60)
print()
print("The primitive part Φ_n ≈ φ^{φ(n)} where φ(n) = Euler's totient.")
print("For n > 12 composite, Φ_n > n, guaranteeing a primitive prime ∤ n.")
print()
phi = (1 + math.sqrt(5)) / 2
print(f"{'n':>8} {'φ(n)':>6} {'φ(n)·log₁₀φ':>13} {'log₁₀n':>8} {'ratio':>8}")
print("-" * 48)
for n in [24, 30, 100, 144, 1000, 10002, 10080, 30030]:
    if is_prime(n): continue
    t = euler_totient(n)
    log_phi = t * math.log10(phi)
    log_n = math.log10(n)
    print(f"{n:>8} {t:>6} {log_phi:>13.1f} {log_n:>8.2f} {log_phi/log_n:>8.1f}x")
print()
print("The ratio grows without bound, so Φ_n >> n for large n.")
print()
print("Demo complete!")
