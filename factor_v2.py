#!/usr/bin/env python3
"""
Experiment 2: Structural factoring from Catalog.
Methods: Fermat (PythTriple), PollardRho+Brent (OrbitFactoring),
  PollardP-1 (SmoothOrder), Combined.
"""

import math, time, random, sys
from typing import Optional, Tuple

def is_prime(n: int, k: int = 20) -> bool:
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0: return False
    r, d = 0, n - 1
    while d % 2 == 0: r += 1; d //= 2
    for _ in range(k):
        a = random.randrange(2, n - 1)
        x = pow(a, d, n)
        if x == 1 or x == n - 1: continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1: break
        else: return False
    return True

def make_prime(nbits): 
    while True:
        p = random.getrandbits(nbits) | (1 << (nbits-1)) | 1
        if is_prime(p): return p

SP = []
_s = [True]*10000
for _i in range(2, 10000):
    if _s[_i]:
        SP.append(_i)
        for _j in range(_i*_i, 10000, _i): _s[_j] = False

def fermat(n, max_steps=200000):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    a = int(math.isqrt(n))
    if a*a == n: return (a, a)
    a += 1
    for _ in range(max_steps):
        b_sq = a*a - n
        b = int(math.isqrt(b_sq))
        if b*b == b_sq:
            p, q = a-b, a+b
            if 1 < p < n: return (p, q)
        a += 1
    return None

def pollard_rho(n, c=1):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    if is_prime(n): return None
    f = lambda x: (x*x+c)%n
    rng = random.Random(c)
    y = rng.randrange(1, n)
    r, q = 1, 1
    x = y; g = 1
    mi = max(200000, int(3*n**0.25))
    while g == 1 and r <= mi:
        x = y
        for _ in range(r): y = f(y)
        k = 0
        while k < r and g == 1:
            for _ in range(min(128, r-k)):
                y = f(y)
                q = q*((x-y)%n)%n
            g = math.gcd(q, n)
            k += 128
        r *= 2
    if 1 < g < n: return (g, n//g)
    if g == n:
        g = 1
        while g == 1:
            y = f(y)
            g = math.gcd(abs(x-y), n)
        if 1 < g < n: return (g, n//g)
    return None

def pollard_rho_multi(n, tries=25):
    for c in range(1, tries+1):
        r = pollard_rho(n, c=c)
        if r: return r
    return None

def pollard_pm1(n, B1=100000):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    primes = []
    sieve = bytearray(b'\x01')*(B1+1)
    sieve[0] = sieve[1] = 0
    for i in range(2, B1+1):
        if sieve[i]:
            primes.append(i)
            for j in range(i*i, B1+1, i): sieve[j] = 0
    a = 2
    for p in primes:
        pp = p
        while pp <= B1:
            a = pow(a, p, n)
            pp *= p
    g = math.gcd(a-1, n)
    if 1 < g < n: return (g, n//g)
    return None

def combined(n):
    if n < 2: return None
    for p in SP:
        if p*p > n: break
        if n % p == 0:
            q = n//p
            if q > 1: return (min(p,q), max(p,q))
    for exp in range(2, min(n.bit_length(), 64)):
        root = int(round(n**(1.0/exp)))
        for r in range(max(2, root-1), root+2):
            if pow(r, exp) == n: return (r, n//r)
    r = fermat(n, max_steps=100000)
    if r: return (min(r), max(r))
    r = pollard_rho_multi(n, tries=25)
    if r: return (min(r), max(r))
    r = pollard_pm1(n, B1=50000)
    if r: return (min(r), max(r))
    r = pollard_pm1(n, B1=200000)
    if r: return (min(r), max(r))
    return None

def run_bench():
    random.seed(42)
    
    print("=" * 90)
    print("FACTORIZATION BENCHMARK — Catalog Structural Methods v2")
    print("=" * 90)
    
    # --- Balanced semiprimes ---
    print("\n=== Balanced semiprimes (p ≈ q) ===")
    print(f"{'Bits':<7} {'Digs':<6} {'fermat':<14} {'rho':<14} {'p-1':<14} {'combined':<14}")
    print("-" * 70)
    
    for bits in [24, 32, 40, 48, 56, 64]:
        random.seed(42 + bits)
        p = make_prime(bits//2+1)
        q = make_prime(bits-bits//2+1)
        n = p*q
        
        row = f"{bits:<7} {len(str(n)):<6}"
        for name, method, kw in [
            ("fermat", fermat, {"max_steps": 200000}),
            ("rho", pollard_rho_multi, {"tries": 25}),
            ("p-1", pollard_pm1, {"B1": 50000}),
        ]:
            t0 = time.perf_counter()
            r = method(n, **kw)
            t = (time.perf_counter() - t0) * 1000
            ok = r is not None and r[0]*r[1]==n and 1<r[0]<n
            row += f" {t:.1f}ms {'✓' if ok else '✗':<4}"
        
        t0 = time.perf_counter()
        r = combined(n)
        t = (time.perf_counter() - t0) * 1000
        ok = r is not None and r[0]*r[1]==n and 1<r[0]<n
        row += f" {t:.1f}ms {'✓' if ok else '✗':<4}"
        print(row)
    
    # --- Unbalanced semiprimes ---
    print("\n=== Unbalanced semiprimes (p << q) ===")
    print(f"{'Bits':<7} {'Digs':<6} {'fermat':<14} {'rho':<14} {'p-1':<14} {'combined':<14}")
    print("-" * 70)
    
    for bits in [32, 48, 64]:
        random.seed(100 + bits)
        p = make_prime(bits//3+1)
        q = make_prime(2*bits//3+1)
        n = p*q
        
        row = f"{bits:<7} {len(str(n)):<6}"
        for name, method, kw in [
            ("fermat", fermat, {"max_steps": 200000}),
            ("rho", pollard_rho_multi, {"tries": 25}),
            ("p-1", pollard_pm1, {"B1": 50000}),
        ]:
            t0 = time.perf_counter()
            r = method(n, **kw)
            t = (time.perf_counter() - t0) * 1000
            ok = r is not None and r[0]*r[1]==n and 1<r[0]<n
            row += f" {t:.1f}ms {'✓' if ok else '✗':<4}"
        
        t0 = time.perf_counter()
        r = combined(n)
        t = (time.perf_counter() - t0) * 1000
        ok = r is not None and r[0]*r[1]==n and 1<r[0]<n
        row += f" {t:.1f}ms {'✓' if ok else '✗':<4}"
        print(row)
    
    # --- Catalog-known numbers ---
    print("\n=== Catalog-known structural numbers ===")
    print(f"{'Name':<25} {'N':<20} {'time':<12} {'Factorization'}")
    print("-" * 75)
    
    tests = [
        ("561 = 3·11·17 (Carmichael)", 561),
        ("1729 = 7·13·19 (HR)", 1729),
        ("5041 = 71² (Euler's)", 5041),
        ("2047 = 23·89 (M₁₁)", 2047),
        ("89×179 (Cunningham)", 89*179),
        ("47×59 (Safe primes)", 47*59),
        ("4294967297 = F₅", 4294967297),
    ]
    
    for name, n in tests:
        t0 = time.perf_counter()
        r = combined(n)
        t = (time.perf_counter() - t0) * 1000
        if r:
            print(f"{name:<35} {t:.3f}ms   {r[0]}×{r[1]}")
        else:
            print(f"{name:<35} {t:.3f}ms   FAILED")
    
    # --- Scaling ---
    print("\n=== Scaling behavior: combined on balanced semiprimes ===")
    print(f"{'Bits':<7} {'time_ms':<12} {'log(t)':<10} {'n^0.25':<15} {'ratio t/n^0.25'}")
    print("-" * 65)
    
    for bits in [24, 32, 40, 48, 56, 64]:
        random.seed(42+bits)
        p = make_prime(bits//2+1)
        q = make_prime(bits-bits//2+1)
        n = p*q
        
        ts = []
        for _ in range(3):
            t0 = time.perf_counter()
            combined(n)
            ts.append((time.perf_counter()-t0)*1000)
        t = sorted(ts)[1]
        r4 = n**0.25
        print(f"{bits:<7} {t:<12.2f} {math.log(max(t,0.001)):<10.3f} {r4:<15.0f} {t/r4:.6f}")

if __name__ == "__main__":
    run_bench()