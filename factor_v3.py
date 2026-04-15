#!/usr/bin/env python3
"""
Experiment 3: Channel-amplified factoring from Catalog.

Key Catalog insight (Foundations.lean): totalChannels(k) = k(k+1)/2.
At k=8 (octonion), 36 channels vs 3 at k=2 (Gaussian).
Applied to factoring: run multiple methods/strategies in interleaved fashion,
amplifying the probability of finding a factor per unit time.

Also: structural number detection — Catalog-known numbers factor in µs.
"""

import math, time, random
from typing import Optional, Tuple

def is_prime(n, k=20):
    if n < 2: return False
    if n < 4: return True
    if n % 2 == 0: return False
    r, d = 0, n-1
    while d % 2 == 0: r += 1; d //= 2
    for _ in range(k):
        a = random.randrange(2, n-1)
        x = pow(a, d, n)
        if x == 1 or x == n-1: continue
        for _ in range(r-1):
            x = pow(x, 2, n)
            if x == n-1: break
        else: return False
    return True

def make_prime(nbits):
    while True:
        p = random.getrandbits(nbits)|(1<<(nbits-1))|1
        if is_prime(p): return p

SP = []
_s = [True]*10000
for _i in range(2, 10000):
    if _s[_i]:
        SP.append(_i)
        for _j in range(_i*_i, 10000, _i): _s[_j] = False

# ============================================================================
# Channel-Amplified Factoring: interleave Fermat + PollardRho steps
#
# Instead of running Fermat to completion (which wastes time if N is unbalanced)
# then falling through to rho, INTERLEAVE steps from both methods.
# This is the channel amplification theorem applied:
# - Fermat channel: probe for balanced structure
# - Rho channel: probe for orbit collision (general)
# - p-1 channel: probe for smooth p-1
# Running them together gives 3 independent "channels" of factor detection.
# ============================================================================

def channel_amplified(n: int, budget: int = 0) -> Optional[Tuple[int, int]]:
    """Factor using channel-amplified interleaved search.
    
    Channels (from Catalog Foundations.lean):
    - Ch1: Fermat/Pythagorean triple search — probes balanced structure
    - Ch2: Pollard rho with Brent — probes orbit collisions  
    - Ch3: Pollard p-1 — probes smooth-factor structure
    - Ch4: Small prime sieve — probes trivial factors
    - Ch5: Perfect power — probes power structure
    
    Budget = total iterations to distribute across channels.
    Default: 3 * n^0.25 (since that's rho's expected complexity).
    """
    if n < 2: return None
    
    # Ch4 + Ch5: Instant channels
    for p in SP:
        if p*p > n: break
        if n % p == 0:
            q = n // p
            if q > 1: return (min(p,q), max(p,q))
    
    for exp in range(2, min(n.bit_length(), 64)):
        root = int(round(n**(1.0/exp)))
        for r in range(max(2, root-1), root+2):
            if pow(r, exp) == n: return (r, n//r)
    
    if is_prime(n): return None
    
    if budget == 0:
        budget = int(3 * n**0.25) + 1000
    
    # Ch1 (Fermat) + Ch2 (Rho) interleaved
    # Fermat step: advance a by 1
    # Rho step: advance one iteration of the orbit map
    
    sqrt_n = int(math.isqrt(n))
    fermat_a = sqrt_n + 1 if sqrt_n * sqrt_n != n else sqrt_n
    
    # Initialize rho state for multiple starting points (multi-start from Catalog)
    c_values = list(range(1, 11))
    rho_states = {}
    for c in c_values:
        rng = random.Random(c)
        y0 = rng.randrange(1, n)
        rho_states[c] = {
            'f': lambda x, c=c: (x*x+c)%n,
            'x': y0, 'y': y0, 'r': 1, 'q': 1, 'g': 1,
            'y_save': y0, 'phase': 'advance', 'steps': 0
        }
    
    # Distribute budget: 30% Fermat, 60% Rho, 10% spare
    fermat_budget = budget // 3
    rho_budget = 2 * budget // 3
    
    # Phase 1: Interleave
    fermat_steps = 0
    rho_total_steps = 0
    rho_idx = 0  # which c value to advance
    
    while fermat_steps < fermat_budget or rho_total_steps < rho_budget:
        # Fermat channel
        if fermat_steps < fermat_budget:
            b_sq = fermat_a * fermat_a - n
            if b_sq >= 0:
                b = int(math.isqrt(b_sq))
                if b * b == b_sq:
                    p, q = fermat_a - b, fermat_a + b
                    if 1 < p < n: return (min(p,q), max(p,q))
            fermat_a += 1
            fermat_steps += 1
        
        # Rho channel (advance one state by one batch of 128 steps)
        if rho_total_steps < rho_budget:
            c = c_values[rho_idx % len(c_values)]
            st = rho_states[c]
            
            if st['g'] == 1:
                for _ in range(min(128, rho_budget - rho_total_steps)):
                    st['y'] = st['f'](st['y'])
                    st['q'] = st['q'] * ((st['x'] - st['y']) % n) % n
                    st['steps'] += 1
                st['g'] = math.gcd(st['q'], n)
                rho_total_steps += st['steps']
                
                if 1 < st['g'] < n:
                    return (min(st['g'], n//st['g']), max(st['g'], n//st['g']))
                if st['g'] == n:
                    # Restart this channel
                    st['g'] = 1
                    st['q'] = 1
                    rng2 = random.Random(c + rho_total_steps)
                    y0 = rng2.randrange(1, n)
                    st['x'] = y0; st['y'] = y0; st['r'] = 1
                    st['steps'] = 0
            
            rho_idx += 1
    
    # Phase 2: Quick p-1 channel
    result = _quick_pm1(n, B1=50000)
    if result: return result
    
    # Phase 3: Full rho as fallback  
    return _full_rho(n, tries=25)

def _quick_pm1(n, B1=50000):
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
    if 1 < g < n: return (min(g, n//g), max(g, n//g))
    return None

def _full_rho(n, tries=25):
    for c in range(1, tries+1):
        result = _single_rho(n, c)
        if result: return result
    return None

def _single_rho(n, c=1):
    f = lambda x: (x*x+c)%n
    rng = random.Random(c)
    y = rng.randrange(1, n)
    r, q = 1, 1
    x = y; g = 1
    mi = max(500000, int(5*n**0.25))
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
    if 1 < g < n: return (min(g, n//g), max(g, n//g))
    if g == n:
        g = 1
        while g == 1:
            y = f(y)
            g = math.gcd(abs(x-y), n)
        if 1 < g < n: return (min(g, n//g), max(g, n//g))
    return None


# ============================================================================
# Previous methods for comparison
# ============================================================================

def fermat_only(n, max_steps=200000):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    a = int(math.isqrt(n))
    if a*a == n: return (a, a)
    a += 1
    for _ in range(max_steps):
        b_sq = a*a-n
        b = int(math.isqrt(b_sq))
        if b*b == b_sq:
            p, q = a-b, a+b
            if 1 < p < n: return (min(p,q), max(p,q))
        a += 1
    return None

def rho_only(n):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    for p in SP:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    if is_prime(n): return None
    return _full_rho(n, tries=25)

def pm1_only(n):
    if n < 2: return None
    if n % 2 == 0: return (2, n//2)
    for p in SP:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    r = _quick_pm1(n, B1=100000)
    if r: return r
    return _quick_pm1(n, B1=500000)

# Baseline combined (from experiment 2)
def combined_v2(n):
    if n < 2: return None
    for p in SP:
        if p*p > n: break
        if n % p == 0: return (min(p,n//p), max(p,n//p))
    for exp in range(2, min(n.bit_length(), 64)):
        root = int(round(n**(1.0/exp)))
        for r in range(max(2, root-1), root+2):
            if pow(r, exp) == n: return (r, n//r)
    r = fermat_only(n, max_steps=100000)
    if r: return r
    r = _full_rho(n, tries=25)
    if r: return r
    r = _quick_pm1(n, B1=50000)
    if r: return r
    r = _quick_pm1(n, B1=200000)
    if r: return r
    return None


# ============================================================================
# Benchmark
# ============================================================================

def run_bench():
    random.seed(42)
    
    print("=" * 100)
    print("FACTORIZATION BENCHMARK v3 — Channel Amplified (Catalog: Foundations.lean)")
    print("Channel amplification: interleave Fermat+Rho+p1 instead of sequential cascade")
    print("=" * 100)
    
    methods = [
        ("fermat", fermat_only),
        ("rho_only", rho_only),
        ("pm1_only", pm1_only),
        ("combined_v2", combined_v2),
        ("ch_amplified", channel_amplified),
    ]
    
    # --- Balanced semiprimes ---
    print("\n=== Balanced semiprimes (p ≈ q) ===")
    header = f"{'Bits':<6} {'Dgs':<5}" + "".join(f" {name:<14}" for name, _ in methods)
    print(header)
    print("-" * len(header))
    
    for bits in [24, 32, 40, 48, 56, 64]:
        random.seed(42+bits)
        p = make_prime(bits//2+1)
        q = make_prime(bits-bits//2+1)
        n = p*q
        
        row = f"{bits:<6} {len(str(n)):<5}"
        for name, method in methods:
            t0 = time.perf_counter()
            r = method(n)
            t = (time.perf_counter()-t0)*1000
            ok = r is not None and r[0]*r[1]==n and 1<r[0]<n
            row += f" {t:.1f}{'✓' if ok else '✗'}"
            if not ok: row += "     "
        print(row)
    
    # --- Unbalanced semiprimes ---
    print("\n=== Unbalanced semiprimes (p << q) ===")
    print(header)
    print("-" * len(header))
    
    for bits in [32, 48, 64]:
        random.seed(100+bits)
        p = make_prime(bits//3+1)
        q = make_prime(2*bits//3+1)
        n = p*q
        
        row = f"{bits:<6} {len(str(n)):<5}"
        for name, method in methods:
            t0 = time.perf_counter()
            r = method(n)
            t = (time.perf_counter()-t0)*1000
            ok = r is not None and r[0]*r[1]==n and 1<r[0]<n
            row += f" {t:.1f}{'✓' if ok else '✗'}"
            if not ok: row += "     "
        print(row)
    
    # --- Catalog-known numbers ---
    print("\n=== Catalog structural numbers ===")
    tests = [
        ("561 = 3·11·17", 561),
        ("1729 = 7·13·19", 1729),
        ("5041 = 71²", 5041),
        ("2047 = 23·89", 2047),
        ("89×179 (Cunningham)", 89*179),
        ("4294967297 = F₅", 4294967297),
    ]
    
    print(f"{'Name':<25} {'N':<15} {'ch_amp(µs)':<12} {'Factorization'}")
    print("-" * 70)
    for name, n in tests:
        t0 = time.perf_counter()
        r = channel_amplified(n)
        t = (time.perf_counter()-t0)*1e6
        if r:
            print(f"{name:<25} {n:<15} {t:.1f}µs     {r[0]}×{r[1]}")
        else:
            print(f"{name:<25} {n:<15} {t:.1f}µs     FAILED")

if __name__ == "__main__":
    run_bench()